package com.medikiosk.service;

import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.response.RedFlagAlertResponse;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.entity.RedFlagAlert;
import com.medikiosk.model.entity.RedFlagRule;
import com.medikiosk.repository.InterviewResponseRepository;
import com.medikiosk.repository.PatientSessionRepository;
import com.medikiosk.repository.RedFlagAlertRepository;
import com.medikiosk.repository.RedFlagRuleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class RedFlagService {
    private final RedFlagRuleRepository ruleRepository;
    private final RedFlagAlertRepository alertRepository;
    private final PatientSessionRepository sessionRepository;
    private final InterviewResponseRepository responseRepository;

    @Transactional
    public List<RedFlagAlertResponse> evaluateSession(UUID sessionId) {
        PatientSession session = sessionRepository.findById(sessionId).orElse(null);
        if (session == null) return new ArrayList<>();

        List<RedFlagAlertResponse> alerts = new ArrayList<>();
        List<RedFlagRule> activeRules = ruleRepository.findAll();

        responseRepository.findBySessionIdOrderByAnsweredAt(sessionId).forEach(resp -> {
            String text = resp.getAnswerText();
            if (text == null) return;
            text = text.toLowerCase();

            for (RedFlagRule rule : activeRules) {
                if (!Boolean.TRUE.equals(rule.getIsActive())) continue;

                List<String> triggers = rule.getTriggerConditions();
                if (triggers != null && !triggers.isEmpty()) {
                    boolean matchAll = triggers.stream().allMatch(text::contains);
                    if (matchAll) {
                        RedFlagAlert alert = RedFlagAlert.builder()
                            .session(session)
                            .rule(rule)
                            .patient(session.getPatient())
                            .severity(rule.getSeverity())
                            .status("ACTIVE")
                            .triggeredBy(resp.getAnswerText())
                            .build();

                        alertRepository.save(alert);
                        alerts.add(RedFlagAlertResponse.builder()
                            .id(alert.getId())
                            .sessionId(sessionId)
                            .ruleCode(rule.getRuleCode())
                            .ruleName(rule.getName())
                            .severity(rule.getSeverity())
                            .status(alert.getStatus())
                            .triggeredBy(alert.getTriggeredBy())
                            .createdAt(alert.getCreatedAt())
                            .build());
                    }
                }
            }
        });

        return alerts;
    }

    
    @Transactional
    public List<RedFlagAlertResponse> evaluateIntake(UUID sessionId, String historyText, List<String> mlFlags) {
        PatientSession session = sessionRepository.findById(sessionId).orElse(null);
        if (session == null) return List.of();

        
        alertRepository.deleteAll(alertRepository.findBySessionId(sessionId));

        
        
        
        StringBuilder mlExpanded = new StringBuilder();
        if (mlFlags != null) {
            for (String flag : mlFlags) {
                List<String> phrases = PYTHON_TO_PHRASES.getOrDefault(flag, List.of(flag.replace('_', ' ')));
                phrases.forEach(p -> mlExpanded.append(' ').append(p));
            }
        }
        String haystack = normalise(
                (historyText == null ? "" : historyText) + mlExpanded);

        List<RedFlagAlertResponse> raised = new ArrayList<>();
        List<RedFlagAlert> toSave = new ArrayList<>();

        for (RedFlagRule rule : ruleRepository.findAll()) {
            if (!Boolean.TRUE.equals(rule.getIsActive())) continue;
            List<String> triggers = rule.getTriggerConditions();
            if (triggers == null || triggers.isEmpty()) continue;

            
            
            
            List<String> matched = new ArrayList<>();
            boolean all = true;
            for (String trigger : triggers) {
                String phrase = phraseFor(trigger);
                if (haystack.contains(phrase)) {
                    matched.add(phrase);
                } else {
                    all = false;
                    break;
                }
            }
            if (!all) continue;

            RedFlagAlert alert = RedFlagAlert.builder()
                    .session(session)
                    .rule(rule)
                    .patient(session.getPatient())
                    .severity(rule.getSeverity())
                    .status("ACTIVE")
                    .triggeredBy(String.join(" + ", matched))
                    .build();
            toSave.add(alert);
        }

        if (!toSave.isEmpty()) {
            alertRepository.saveAll(toSave);
            for (RedFlagAlert a : toSave) {
                raised.add(RedFlagAlertResponse.builder()
                        .id(a.getId())
                        .sessionId(sessionId)
                        .ruleCode(a.getRule().getRuleCode())
                        .ruleName(a.getRule().getName())
                        .severity(a.getSeverity())
                        .status(a.getStatus())
                        .triggeredBy(a.getTriggeredBy())
                        .createdAt(a.getCreatedAt())
                        .build());
            }
        }

        log.info("Red-flag evaluation for session {}: {} alert(s) raised", sessionId, raised.size());
        return raised;
    }

    
    private static final Map<String, List<String>> PYTHON_TO_PHRASES = Map.of(
        "chest_pain_with_breathlessness", List.of("chest pain", "breathing difficulty"),
        "stroke_warning",                 List.of("sudden weakness", "speech difficulty"),
        "sudden_severe_headache",         List.of("severe headache"),
        "severe_breathing_problem",       List.of("breathing difficulty"),
        "loss_of_consciousness",          List.of("loss of consciousness"),
        "severe_bleeding",                List.of("severe bleeding")
    );

    
    private static String phraseFor(String trigger) {
        return trigger == null ? "" : trigger.trim().toLowerCase().replace('_', ' ');
    }

    
    private static String normalise(String text) {
        return text.toLowerCase().replaceAll("[^a-z0-9]+", " ").trim();
    }

    
    @Transactional(readOnly = true)
    public boolean hasActiveRedFlag(UUID sessionId) {
        return alertRepository.findBySessionId(sessionId).stream()
                .anyMatch(a -> "ACTIVE".equalsIgnoreCase(a.getStatus()));
    }

    
    @Transactional(readOnly = true)
    public List<String> getActiveFlagLabels(UUID sessionId) {
        List<String> labels = new ArrayList<>();
        for (RedFlagAlert a : alertRepository.findBySessionId(sessionId)) {
            if (!"ACTIVE".equalsIgnoreCase(a.getStatus())) continue;
            String name = a.getRule() != null && a.getRule().getName() != null
                    ? a.getRule().getName()
                    : (a.getTriggeredBy() != null ? a.getTriggeredBy() : "Red flag");
            labels.add(name + (a.getSeverity() != null ? " (" + a.getSeverity() + ")" : ""));
        }
        return labels;
    }

    @Transactional(readOnly = true)
    public List<RedFlagAlertResponse> getAlertsForSession(UUID sessionId) {
        return alertRepository.findBySessionId(sessionId).stream()
                .map(a -> RedFlagAlertResponse.builder()
                        .id(a.getId())
                        .sessionId(a.getSession().getId())
                        .ruleCode(a.getRule() != null ? a.getRule().getRuleCode() : null)
                        .ruleName(a.getRule() != null ? a.getRule().getName() : "ML-detected")
                        .severity(a.getSeverity())
                        .status(a.getStatus())
                        .triggeredBy(a.getTriggeredBy())
                        .triageNotes(a.getTriageNotes())
                        .createdAt(a.getCreatedAt())
                        .build())
                .toList();
    }

    @Transactional
    public RedFlagAlertResponse acknowledgeAlert(UUID alertId, String notes, String acknowledgedBy) {
        RedFlagAlert alert = alertRepository.findById(alertId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Red flag alert not found: " + alertId));
        alert.setStatus("ACKNOWLEDGED");
        alert.setTriageNotes(notes);
        if (acknowledgedBy != null && !acknowledgedBy.isBlank()) {
            try { alert.setAcknowledgedBy(UUID.fromString(acknowledgedBy)); }
            catch (IllegalArgumentException ignored) {}
        }
        alert.setAcknowledgedAt(LocalDateTime.now());
        alertRepository.save(alert);
        return RedFlagAlertResponse.builder()
                .id(alert.getId())
                .sessionId(alert.getSession().getId())
                .ruleCode(alert.getRule() != null ? alert.getRule().getRuleCode() : null)
                .ruleName(alert.getRule() != null ? alert.getRule().getName() : "ML-detected")
                .severity(alert.getSeverity())
                .status(alert.getStatus())
                .triageNotes(alert.getTriageNotes())
                .createdAt(alert.getCreatedAt())
                .build();
    }

    @Transactional(readOnly = true)
    public List<RedFlagAlertResponse> getAllActiveAlerts() {
        return alertRepository.findByStatus("ACTIVE").stream()
                .map(a -> RedFlagAlertResponse.builder()
                        .id(a.getId())
                        .sessionId(a.getSession().getId())
                        .ruleCode(a.getRule() != null ? a.getRule().getRuleCode() : null)
                        .ruleName(a.getRule() != null ? a.getRule().getName() : "ML-detected")
                        .severity(a.getSeverity())
                        .status(a.getStatus())
                        .triggeredBy(a.getTriggeredBy())
                        .createdAt(a.getCreatedAt())
                        .build())
                .toList();
    }
}
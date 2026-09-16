package com.medikiosk.service;

import com.medikiosk.exception.MediKioskException;
import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.request.SubmitIntakeRequest;
import com.medikiosk.model.dto.response.RedFlagAlertResponse;
import com.medikiosk.model.entity.ClinicalHistory;
import com.medikiosk.model.entity.NerEntity;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.enums.SessionStatus;
import com.medikiosk.repository.ClinicalHistoryRepository;
import com.medikiosk.repository.MedicalDocumentRepository;
import com.medikiosk.repository.NerEntityRepository;
import com.medikiosk.repository.PatientSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;


@Service
@RequiredArgsConstructor
@Slf4j
public class IntakeService {

    private final PatientSessionRepository sessionRepo;
    private final ClinicalHistoryRepository historyRepo;
    private final MedicalDocumentRepository documentRepo;
    private final RedFlagService redFlagService;
    private final FastApiClient fastApiClient;
    private final NerEntityRepository nerEntityRepository;

    
    @Transactional
    public Map<String, Object> submitIntake(SubmitIntakeRequest req) {
        UUID sessionId;
        try {
            sessionId = UUID.fromString(req.getSessionId().trim());
        } catch (IllegalArgumentException e) {
            throw new MediKioskException("sessionId must be a UUID");
        }

        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));

        Map<String, Object> h = req.getStructuredHistory() != null
                ? req.getStructuredHistory() : Map.of();
        Map<String, Object> hpi = asMap(h.get("history_of_present_illness"));

        ClinicalHistory history = historyRepo.findBySessionId(sessionId)
                .orElseGet(() -> ClinicalHistory.builder().session(session).build());

        history.setChiefComplaint(str(h.get("chief_complaint")));
        history.setComplaintDuration(str(hpi.get("duration")));
        history.setComplaintSeverity(str(hpi.get("severity")));
        history.setHpiOnset(str(hpi.get("onset")));
        history.setHpiCharacter(str(hpi.get("character")));
        history.setHpiRadiation(joinList(hpi.get("radiation")));
        history.setHpiAssociatedSymptoms(asStringList(hpi.get("associated_symptoms")));
        history.setHpiExacerbating(joinList(hpi.get("aggravating_factors")));
        history.setHpiRelieving(joinList(hpi.get("relieving_factors")));

        history.setPastMedical(labelledRows(h.get("past_medical_history"), "condition"));
        history.setPastSurgical(labelledRows(h.get("past_surgical_history"), "procedure"));
        history.setCurrentMedications(labelledRows(h.get("medications"), "name"));
        history.setKnownAllergies(labelledRows(h.get("allergies"), "allergen"));
        history.setFamilyHistory(labelledRows(h.get("family_history"), "condition"));

        Map<String, Object> personal = asMap(h.get("personal_history"));
        history.setSmokingStatus(str(personal.get("smoking")));
        history.setAlcoholStatus(str(personal.get("alcohol")));
        history.setTobaccoChewing(str(personal.get("tobacco")));

        history.setRosCardiovascular(joinList(h.get("review_of_systems")));
        history.setCompletenessScore(completeness(history));
        history.setIsFinalized(true);
        historyRepo.save(history);

        
        
        extractAndSaveNerEntities(sessionId, historyText(history, req));

        
        
        
        
        session.setStatus(SessionStatus.REVIEW);
        session.touch();
        sessionRepo.save(session);

        
        
        
        List<RedFlagAlertResponse> flags = redFlagService.evaluateIntake(
                sessionId, historyText(history, req), req.getRedFlags());

        long docPages = documentRepo.countBySessionId(sessionId);
        log.info("Intake stored for session {} ({}% complete, {} document page(s))",
                sessionId, history.getCompletenessScore(), docPages);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("sessionId", sessionId);
        out.put("status", "SUBMITTED");
        out.put("sessionStatus", session.getStatus().name());
        out.put("chiefComplaint", history.getChiefComplaint());
        out.put("completenessScore", history.getCompletenessScore());
        out.put("documentPageCount", docPages);
        out.put("redFlags", flags.stream().map(RedFlagAlertResponse::getRuleName).toList());
        out.put("redFlagSeverity", flags.stream()
                .anyMatch(f -> "CRITICAL".equalsIgnoreCase(f.getSeverity())) ? "CRITICAL"
                : (flags.isEmpty() ? "NONE" : "HIGH"));
        out.put("requiresTriage", flags.stream()
                .anyMatch(f -> "CRITICAL".equalsIgnoreCase(f.getSeverity())));
        out.put("tokenNumber", "#P" + (Math.abs(sessionId.hashCode()) % 800 + 100));
        out.put("submittedAt", LocalDateTime.now().toString());
        return out;
    }


    private void extractAndSaveNerEntities(UUID sessionId, String text) {
        if (text == null || text.isBlank()) return;
        try {
            nerEntityRepository.deleteBySessionId(sessionId); 
            Map<String, Object> nerResult = fastApiClient.extractMedicalEntities(text, "en");
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> entities =
                    (List<Map<String, Object>>) nerResult.getOrDefault("entities", List.of());

            List<NerEntity> toSave = entities.stream()
                    .filter(e -> e.get("value") != null && e.get("label") != null)
                    .map(e -> NerEntity.builder()
                            .sessionId(sessionId)
                            .entityLabel(String.valueOf(e.get("label")))
                            .entityValue(String.valueOf(e.get("value")))
                            .confidence(e.get("confidence") instanceof Number n ? n.doubleValue() : null)
                            .source("llm")
                            .language("en")
                            .build())
                    .toList();

            if (!toSave.isEmpty()) {
                nerEntityRepository.saveAll(toSave);
                log.info("Saved {} NER entities for session {}", toSave.size(), sessionId);
            }
        } catch (Exception e) {
            log.warn("NER extraction failed for session {}: {}", sessionId, e.getMessage());
        }
    }

    
    private static String historyText(ClinicalHistory h, SubmitIntakeRequest req) {
        StringBuilder sb = new StringBuilder();
        if (h.getChiefComplaint() != null) sb.append(h.getChiefComplaint()).append(' ');
        if (h.getHpiCharacter() != null) sb.append(h.getHpiCharacter()).append(' ');
        if (h.getHpiRadiation() != null) sb.append(h.getHpiRadiation()).append(' ');
        if (h.getComplaintDuration() != null) sb.append(h.getComplaintDuration()).append(' ');
        if (h.getHpiAssociatedSymptoms() != null) {
            sb.append(String.join(" ", h.getHpiAssociatedSymptoms())).append(' ');
        }
        if (h.getRosCardiovascular() != null) sb.append(h.getRosCardiovascular()).append(' ');
        if (h.getSmokingStatus() != null) sb.append("smoking ").append(h.getSmokingStatus()).append(' ');
        appendRows(sb, h.getPastMedical());
        appendRows(sb, h.getCurrentMedications());
        if (req.getFinalSummary() != null) sb.append(req.getFinalSummary());
        return sb.toString();
    }

    private static void appendRows(StringBuilder sb, List<Map<String, Object>> rows) {
        if (rows == null) return;
        for (Map<String, Object> row : rows) {
            for (Object v : row.values()) {
                String s = str(v);
                if (s != null) sb.append(s).append(' ');
            }
        }
    }

    
    private static int completeness(ClinicalHistory h) {
        int filled = 0;
        int total = 8;
        if (notBlank(h.getChiefComplaint())) filled++;
        if (notBlank(h.getHpiOnset()) || notBlank(h.getComplaintDuration())) filled++;
        if (notBlank(h.getHpiCharacter())) filled++;
        if (nonEmpty(h.getPastMedical())) filled++;
        if (nonEmpty(h.getCurrentMedications())) filled++;
        if (nonEmpty(h.getKnownAllergies())) filled++;
        if (nonEmpty(h.getFamilyHistory())) filled++;
        if (notBlank(h.getSmokingStatus()) || notBlank(h.getAlcoholStatus())) filled++;
        return filled * 100 / total;
    }

    private static boolean notBlank(String s) { return s != null && !s.isBlank(); }
    private static boolean nonEmpty(List<?> l) { return l != null && !l.isEmpty(); }

    private static String str(Object v) {
        if (v == null) return null;
        String s = String.valueOf(v).trim();
        return s.isEmpty() || "null".equalsIgnoreCase(s) ? null : s;
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> asMap(Object v) {
        return v instanceof Map<?, ?> m ? (Map<String, Object>) m : Map.of();
    }

    private static List<String> asStringList(Object v) {
        if (!(v instanceof List<?> list)) return List.of();
        List<String> out = new ArrayList<>();
        for (Object o : list) {
            String s = str(o);
            if (s != null) out.add(s);
        }
        return out;
    }

    private static String joinList(Object v) {
        List<String> items = asStringList(v);
        if (!items.isEmpty()) return String.join(", ", items);
        return str(v);
    }

    
    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> labelledRows(Object v, String labelKey) {
        if (!(v instanceof List<?> list)) return List.of();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Object o : list) {
            if (o instanceof Map<?, ?> m) {
                out.add(new LinkedHashMap<>((Map<String, Object>) m));
            } else {
                String s = str(o);
                if (s != null) out.add(Map.of(labelKey, s));
            }
        }
        return out;
    }
}
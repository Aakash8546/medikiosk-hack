package com.medikiosk.service;

import com.medikiosk.exception.MediKioskException;
import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.request.NextQuestionRequest;
import com.medikiosk.model.dto.request.SubmitResponseRequest;
import com.medikiosk.model.dto.response.InterviewStatusResponse;
import com.medikiosk.model.dto.response.QuestionResponse;
import com.medikiosk.model.entity.ClinicalHistory;
import com.medikiosk.model.entity.InterviewQuestion;
import com.medikiosk.model.entity.InterviewResponse;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.enums.SessionStatus;
import com.medikiosk.model.entity.NerEntity;
import com.medikiosk.repository.ClinicalHistoryRepository;
import com.medikiosk.repository.InterviewQuestionRepository;
import com.medikiosk.repository.InterviewResponseRepository;
import com.medikiosk.repository.NerEntityRepository;
import com.medikiosk.repository.PatientSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class InterviewService {

    private final InterviewQuestionRepository questionRepo;
    private final InterviewResponseRepository responseRepo;
    private final PatientSessionRepository sessionRepo;
    private final ClinicalHistoryRepository historyRepo;
    private final ConsentService consentService;
    private final AuditService auditService;
    private final FastApiClient fastApiClient;
    private final RedFlagService redFlagService;
    private final NerEntityRepository nerEntityRepository;

    @Transactional
    public QuestionResponse getNextQuestion(NextQuestionRequest req) {
        UUID sessionId = UUID.fromString(req.getSessionId());

        PatientSession session = sessionRepo.findById(sessionId)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));

        if (!consentService.hasRequiredConsents(sessionId)) {
            throw new MediKioskException("Required consents not accepted. Cannot start interview.");
        }

        if (session.getStatus() == SessionStatus.CONSENT) {
            session.setStatus(SessionStatus.INTERVIEW);
            session.touch();
            sessionRepo.save(session);
        }

        String sessionType = req.getSessionType() != null ? req.getSessionType() : "GENERAL";
        List<InterviewQuestion> allQuestions = questionRepo
            .findByIsActiveTrueAndAppliesToInOrderBySequenceOrder(
                List.of(sessionType, "BOTH"));

        Set<UUID> answeredIds = new HashSet<>();
        responseRepo.findBySessionIdOrderByAnsweredAt(sessionId)
            .forEach(r -> answeredIds.add(r.getQuestion().getId()));

        for (InterviewQuestion q : allQuestions) {
            if (!answeredIds.contains(q.getId())) {
                int progress = allQuestions.isEmpty() ? 0 : (answeredIds.size() * 100) / allQuestions.size();
                boolean isLast = answeredIds.size() == allQuestions.size() - 1;

                return QuestionResponse.builder()
                    .id(q.getId().toString())
                    .questionKey(q.getQuestionKey())
                    .questionText("hi".equals(req.getLanguage()) && q.getQuestionTextHi() != null
                        ? q.getQuestionTextHi() : q.getQuestionTextEn())
                    .questionType(q.getQuestionType().name())
                    .category(q.getCategory())
                    .isMandatory(q.getIsMandatory())
                    .isLastQuestion(isLast)
                    .progress(progress)
                    .build();
            }
        }

        finalizeInterview(sessionId);
        return null;
    }

    @Transactional
    public void submitResponse(SubmitResponseRequest req) {
        UUID sessionId = UUID.fromString(req.getSessionId());
        UUID questionId = UUID.fromString(req.getQuestionId());

        PatientSession session = sessionRepo.findById(sessionId)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        InterviewQuestion question = questionRepo.findById(questionId)
            .orElseThrow(() -> new ResourceNotFoundException("Question not found: " + questionId));

        String processedAnswer = req.getAnswerText();
        if (Boolean.TRUE.equals(req.getIsVoiceInput()) && req.getRawTranscript() != null) {
            processedAnswer = req.getRawTranscript();
            try {
                Map<String, Object> nerResult = fastApiClient.extractMedicalEntities(
                        req.getRawTranscript(),
                        req.getLanguage() != null ? req.getLanguage() : "en");

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> entities =
                        (List<Map<String, Object>>) nerResult.getOrDefault("entities", List.of());

                String lang = req.getLanguage() != null ? req.getLanguage() : "en";
                List<NerEntity> toSave = entities.stream()
                        .filter(e -> e.get("value") != null && e.get("label") != null)
                        .map(e -> NerEntity.builder()
                                .sessionId(sessionId)
                                .questionId(questionId)
                                .entityLabel(String.valueOf(e.get("label")))
                                .entityValue(String.valueOf(e.get("value")))
                                .confidence(e.get("confidence") instanceof Number n ? n.doubleValue() : null)
                                .source("llm")
                                .language(lang)
                                .build())
                        .toList();

                if (!toSave.isEmpty()) {
                    nerEntityRepository.saveAll(toSave);
                    log.info("Saved {} NER entities for session {} question {}",
                            toSave.size(), sessionId, questionId);
                }
            } catch (Exception e) {
                log.warn("NER processing failed for session {}: {}", sessionId, e.getMessage());
            }
        }

        InterviewResponse response = responseRepo
            .findBySessionIdAndQuestionId(sessionId, questionId)
            .orElse(InterviewResponse.builder()
                .session(session)
                .question(question)
                .build());

        response.setAnswerText(processedAnswer);
        response.setAnswerChoices(req.getAnswerChoices());
        response.setAnswerNumeric(req.getAnswerNumeric());
        response.setIsVoiceInput(Boolean.TRUE.equals(req.getIsVoiceInput()));
        response.setRawTranscript(req.getRawTranscript());
        response.setConfidenceScore(req.getConfidenceScore());
        response.setLanguage(req.getLanguage() != null ? req.getLanguage() : "en");

        responseRepo.save(response);
        session.touch();
        sessionRepo.save(session);
        
        redFlagService.evaluateSession(sessionId);
    }

    public InterviewStatusResponse getStatus(String sessionId) {
        UUID sid = UUID.fromString(sessionId);

        PatientSession session = sessionRepo.findById(sid)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));

        List<InterviewQuestion> allQuestions = questionRepo
            .findByIsActiveTrueAndAppliesToInOrderBySequenceOrder(List.of("GENERAL", "AYUSH", "BOTH"));

        int answered = responseRepo.countBySessionId(sid);
        int total = allQuestions.size();
        int progress = total > 0 ? (answered * 100) / total : 0;

        return InterviewStatusResponse.builder()
            .sessionId(sessionId)
            .totalQuestions(total)
            .answeredQuestions(answered)
            .progress(progress)
            .status(session.getStatus().name())
            .build();
    }

    

    @Transactional
    public Map<String, Object> startAiInterview(String sessionIdStr, String language) {
        try {
            if (sessionIdStr != null && !sessionIdStr.isBlank()) {
                UUID sessionId = UUID.fromString(sessionIdStr);
                PatientSession session = sessionRepo.findById(sessionId).orElse(null);
                if (session != null) {
                    if (session.getStatus() == SessionStatus.CONSENT) {
                        session.setStatus(SessionStatus.INTERVIEW);
                        session.touch();
                        sessionRepo.save(session);
                    }
                }
            }
        } catch (Exception ignored) {}

        return fastApiClient.startAiInterview(sessionIdStr, language);
    }

    @Transactional
    public Map<String, Object> processAiResponse(String sessionIdStr, String answerText, String expectedField, String lastQuestion, String language, org.springframework.web.multipart.MultipartFile audioFile) {
        UUID sessionId = null;
        try {
            if (sessionIdStr != null && !sessionIdStr.isBlank()) {
                sessionId = UUID.fromString(sessionIdStr);
                PatientSession session = sessionRepo.findById(sessionId).orElse(null);
                if (session != null) {
                    session.touch();
                    sessionRepo.save(session);
                }
            }
        } catch (Exception ignored) {}

        Map<String, Object> res = fastApiClient.submitAiResponse(sessionIdStr, answerText, expectedField, lastQuestion, language, audioFile);

        if (sessionId != null && Boolean.TRUE.equals(res.get("is_completed"))) {
            try {
                finalizeInterview(sessionId);
            } catch (Exception ignored) {}
        }

        return res;
    }

    public Map<String, Object> getAiSummary(String sessionIdStr, String language) {
        return fastApiClient.getAiSummary(sessionIdStr, null, language);
    }

    private void finalizeInterview(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId).orElseThrow();
        session.setStatus(SessionStatus.DOCUMENTS);
        session.touch();
        sessionRepo.save(session);

        buildClinicalHistory(sessionId);

        auditService.log("SYSTEM", null, "INTERVIEW_COMPLETED",
            "patient_sessions", sessionId, sessionId, null);
    }

    private void buildClinicalHistory(UUID sessionId) {
        List<InterviewResponse> responses = responseRepo.findBySessionIdOrderByAnsweredAt(sessionId);

        ClinicalHistory history = historyRepo.findBySessionId(sessionId)
            .orElse(ClinicalHistory.builder()
                .session(sessionRepo.findById(sessionId).orElseThrow())
                .build());

        for (InterviewResponse r : responses) {
            String key = r.getQuestion().getQuestionKey();
            String answer = r.getAnswerText();
            if (answer == null && r.getAnswerChoices() != null && !r.getAnswerChoices().isEmpty()) {
                answer = String.join(", ", r.getAnswerChoices());
            }
            if (answer == null && r.getAnswerNumeric() != null) {
                answer = r.getAnswerNumeric().toString();
            }
            if (answer == null) continue;

            switch (key) {
                case "CHIEF_COMPLAINT"    -> history.setChiefComplaint(answer);
                case "COMPLAINT_DURATION" -> history.setComplaintDuration(answer);
                case "COMPLAINT_SEVERITY" -> history.setComplaintSeverity(answer);
                case "PAIN_CHARACTER"     -> history.setHpiCharacter(answer);
                case "AGGRAVATING_FACTORS" -> history.setHpiExacerbating(answer);
                case "RELIEVING_FACTORS"  -> history.setHpiRelieving(answer);
                case "SMOKING_STATUS"     -> history.setSmokingStatus(answer);
                case "ALCOHOL_STATUS"     -> history.setAlcoholStatus(answer);
                default -> log.debug("Unmapped question key: {}", key);
            }
        }

        int filled = 0;
        if (history.getChiefComplaint() != null) filled++;
        if (history.getComplaintDuration() != null) filled++;
        if (history.getHpiCharacter() != null) filled++;
        if (history.getSmokingStatus() != null) filled++;
        int totalCheckedFields = 4; 
        history.setCompletenessScore(totalCheckedFields > 0 ? (filled * 100) / totalCheckedFields : 0);

        historyRepo.save(history);
    }
}
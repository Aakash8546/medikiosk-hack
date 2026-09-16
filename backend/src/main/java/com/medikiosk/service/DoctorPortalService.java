package com.medikiosk.service;

import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.request.UpdateVitalsRequest;
import com.medikiosk.model.dto.response.*;
import com.medikiosk.model.entity.AyushAssessment;
import com.medikiosk.model.entity.ClinicalHistory;
import com.medikiosk.model.entity.MedicalDocument;
import com.medikiosk.model.entity.Patient;
import com.medikiosk.model.entity.RedFlagAlert;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.enums.SessionStatus;
import com.medikiosk.repository.AyushAssessmentRepository;
import com.medikiosk.repository.ClinicalHistoryRepository;
import com.medikiosk.repository.ConsentRecordRepository;
import com.medikiosk.repository.MedicalDocumentRepository;
import com.medikiosk.repository.PatientRepository;
import com.medikiosk.repository.PatientSessionRepository;
import com.medikiosk.model.entity.NerEntity;
import com.medikiosk.repository.NerEntityRepository;
import com.medikiosk.repository.RedFlagAlertRepository;
import com.medikiosk.repository.UserRepository;
import com.medikiosk.model.entity.User;
import com.medikiosk.model.entity.SessionVitals;
import com.medikiosk.repository.SessionVitalsRepository;
import com.medikiosk.model.entity.ClinicalSummaryOverride;
import com.medikiosk.model.entity.Consultation;
import com.medikiosk.repository.ClinicalSummaryOverrideRepository;
import com.medikiosk.repository.ConsultationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DoctorPortalService {

    private final PatientSessionRepository sessionRepo;
    private final PatientRepository patientRepo;
    private final AyushService ayushService;
    private final RedFlagService redFlagService;
    private final MedicalDocumentRepository documentRepo;
    private final ClinicalHistoryRepository historyRepo;
    private final AyushAssessmentRepository ayushRepo;
    private final RedFlagAlertRepository redFlagAlertRepo;
    private final DrugInteractionService drugInteractionService;
    private final ConsentRecordRepository consentRepo;
    private final UserRepository userRepo;
    private final NerEntityRepository nerEntityRepository;
    private final SessionVitalsRepository vitalsRepo;
    private final ConsultationRepository consultationRepo;
    private final ClinicalSummaryOverrideRepository summaryOverrideRepo;


    
    @Transactional(readOnly = true)
    public DoctorDashboardStatsResponse getDoctorDashboardStats(String username) {
        List<PatientSession> allSessions = sessionRepo.findAll();

        long totalToday = allSessions.size();
        long activeNow = allSessions.stream().filter(s -> s.getStatus() != SessionStatus.SUBMITTED && s.getStatus() != SessionStatus.EXPIRED).count();
        long completedToday = allSessions.stream().filter(s -> s.getStatus() == SessionStatus.SUBMITTED).count();

        
        
        List<PatientSession> queue = sessionRepo.findActiveQueueWithPatient();
        List<UUID> queueIds = queue.stream().map(PatientSession::getId).collect(Collectors.toList());

        Set<UUID> redFlagged = queueIds.isEmpty() ? Set.of() : redFlagAlertRepo.findSessionIdsWithActiveAlerts();
        Map<UUID, String> complaints = queueIds.isEmpty() ? Map.of() : historyRepo.findBySessionIdIn(queueIds).stream()
                .filter(h -> h.getSession() != null && h.getChiefComplaint() != null && !h.getChiefComplaint().isBlank())
                .collect(Collectors.toMap(h -> h.getSession().getId(), ClinicalHistory::getChiefComplaint, (a, b) -> a));
        Map<UUID, String> prakritis = queueIds.isEmpty() ? Map.of() : ayushRepo.findBySessionIdIn(queueIds).stream()
                .filter(a -> a.getSession() != null && a.getPrakritiResult() != null && !a.getPrakritiResult().isBlank())
                .collect(Collectors.toMap(a -> a.getSession().getId(), AyushAssessment::getPrakritiResult, (a, b) -> a));

        List<OpdQueueItemResponse> queueItems = queue.stream()
                .map(s -> mapToQueueItem(s, redFlagged.contains(s.getId()),
                        complaints.get(s.getId()), prakritis.get(s.getId())))
                .sorted((a, b) -> {
                    if (a.isRedFlag() != b.isRedFlag()) return a.isRedFlag() ? -1 : 1;
                    String sa = a.getStartedAt() != null ? a.getStartedAt() : "";
                    String sb = b.getStartedAt() != null ? b.getStartedAt() : "";
                    return sa.compareTo(sb);
                })
                .collect(Collectors.toList());

        User doctor = userRepo.findByUsername(username).orElse(null);
        String doctorName = (doctor != null && doctor.getFullName() != null && !doctor.getFullName().isBlank())
                ? doctor.getFullName() : username;
        String specialty = (doctor != null && doctor.getRole() != null)
                ? toSpecialtyLabel(doctor.getRole().name()) : "Physician";

        return DoctorDashboardStatsResponse.builder()
                .doctorName(doctorName)
                .specialty(specialty)
                .totalPatientsToday(totalToday)
                .activeNow(activeNow)
                .opdCountToday(totalToday)
                .completedCountToday(completedToday)
                .patientQueue(queueItems)
                .build();
    }

    
    @Transactional(readOnly = true)
    public D2PatientDetailResponse getD2PatientDetail(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient patient = session.getPatient();

        
        
        List<String> flagLabels = redFlagService.getActiveFlagLabels(sessionId);
        ClinicalHistory h = historyRepo.findBySessionId(sessionId).orElse(null);
        List<String> medications = h != null
                ? describeRows(h.getCurrentMedications(), "name", "dose", "frequency") : List.of();

        return D2PatientDetailResponse.builder()
                .sessionId(sessionId)
                .patientId(patient.getId())
                .tokenNumber("OPD Token #" + (Math.abs(sessionId.hashCode()) % 800 + 100))
                .patientName(patient.getFullName() != null ? patient.getFullName() : "Patient " + patient.getAbhaId())
                .abhaId(patient.getAbhaId() != null ? patient.getAbhaId() : "Not linked")
                .age(patient.getDateOfBirth() != null
                        ? java.time.Period.between(patient.getDateOfBirth(), java.time.LocalDate.now()).getYears() : 0)
                .gender(patient.getGender() != null ? patient.getGender() : "—")
                .language(session.getLanguage() != null ? session.getLanguage() : "en")
                .priority(flagLabels.isEmpty() ? "NORMAL" : "HIGH")
                .consentGranted(consentRepo.findBySessionId(sessionId).stream()
                        .anyMatch(c -> c.getStatus() == com.medikiosk.model.enums.ConsentStatus.ACCEPTED))
                .sessionType(session.getSessionType() != null ? session.getSessionType().name() : "GENERAL")
                .prakritiBadge(ayushRepo.findBySessionId(sessionId)
                        .map(AyushAssessment::getPrakritiResult).orElse("—"))
                .hasRedFlag(!flagLabels.isEmpty())
                .redFlagSymptoms(flagLabels)
                .drugInteractionWarnings(checkInteractions(medications))
                .build();
    }

    
    @Transactional(readOnly = true)
    public D3PatientClinicalViewResponse getD3ClinicalView(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();

        ClinicalHistory h = historyRepo.findBySessionId(sessionId).orElse(null);
        ClinicalSummaryOverride override = summaryOverrideRepo.findBySessionId(sessionId).orElse(null);
        boolean consentGranted = consentRepo.findBySessionId(sessionId).stream()
                .anyMatch(c -> c.getStatus() == com.medikiosk.model.enums.ConsentStatus.ACCEPTED);

        List<String> complaints = (override != null && override.getHistoryOfPresentIllness() != null && !override.getHistoryOfPresentIllness().isBlank())
                ? List.of(override.getHistoryOfPresentIllness())
                : (h != null ? buildComplaints(h) : List.of());

        List<String> pastMedical = (override != null && override.getPastMedicalHistory() != null && !override.getPastMedicalHistory().isBlank())
                ? List.of(override.getPastMedicalHistory())
                : (h != null ? describeRows(h.getPastMedical(), "condition", "year", "status") : List.of());

        List<String> familyHist = (override != null && override.getFamilyHistory() != null && !override.getFamilyHistory().isEmpty())
                ? override.getFamilyHistory()
                : (h != null ? describeRows(h.getFamilyHistory(), "relation", "condition") : List.of());

        return D3PatientClinicalViewResponse.builder()
                .sessionId(sessionId)
                .patientId(p.getId())
                .patientName(p.getFullName() != null ? p.getFullName() : "Patient")
                .abhaId(p.getAbhaId() != null ? p.getAbhaId() : "Not linked")
                .ageGenderAbha(buildAgeGenderAbha(p))
                .consentStatusBanner(consentGranted
                        ? "✓ ABDM Consent Granted — Data sharing active for this encounter"
                        : "⚠ ABDM Consent Not Granted — Data sharing is not active for this encounter")
                .vitalsGrid(buildDynamicVitalsGrid(vitalsAsMap(vitalsRepo.findBySessionId(sessionId).orElse(null))))
                .chiefComplaints(complaints)
                .prakritiSnapshot(buildPrakritiSnapshot(sessionId))
                .currentMedications(h != null
                        ? describeRows(h.getCurrentMedications(), "name", "dose", "frequency")
                        : List.of())
                .familyHistory(familyHist)
                .allergies(h != null
                        ? describeRows(h.getKnownAllergies(), "allergen", "reaction", "severity")
                        : List.of())
                .build();
    }

    
    @Transactional(readOnly = true)
    public D4AiClinicalSummaryResponse getD4AiSummary(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();

        ClinicalHistory h = historyRepo.findBySessionId(sessionId).orElse(null);
        AyushAssessment ayush = ayushRepo.findBySessionId(sessionId).orElse(null);
        ClinicalSummaryOverride override = summaryOverrideRepo.findBySessionId(sessionId).orElse(null);

        List<String> medications = h != null
                ? describeRows(h.getCurrentMedications(), "name", "dose", "frequency") : List.of();
        List<String> allergies = h != null
                ? describeRows(h.getKnownAllergies(), "allergen", "reaction", "severity") : List.of();

        List<String> pastMedical = (override != null && override.getPastMedicalHistory() != null && !override.getPastMedicalHistory().isBlank())
                ? List.of(override.getPastMedicalHistory())
                : (h != null ? describeRows(h.getPastMedical(), "condition", "year", "status") : List.of());

        String hpiText = (override != null && override.getHistoryOfPresentIllness() != null && !override.getHistoryOfPresentIllness().isBlank())
                ? override.getHistoryOfPresentIllness()
                : buildHpiNarrative(p, h);

        int intakeCompleteness = h != null && h.getCompletenessScore() != null
                ? h.getCompletenessScore() : (override != null ? 100 : 0);

        return D4AiClinicalSummaryResponse.builder()
                .sessionId(sessionId)
                .patientName(p.getFullName() != null ? p.getFullName() : "Patient")
                .abhaId(p.getAbhaId() != null ? p.getAbhaId() : "Not linked")
                .hpiSummary(hpiText)
                .hpiConfidence(override != null ? 100 : (h != null && h.getChiefComplaint() != null ? intakeCompleteness : 0))
                .vitalsSummary(measuredVitals())
                .vitalsConfidence(0)
                .pastMedicalHistory(pastMedical.isEmpty()
                        ? List.of("No past medical history recorded at the kiosk.") : pastMedical)
                .pastHistoryConfidence(pastMedical.isEmpty() ? 0 : (override != null ? 100 : intakeCompleteness))
                .totalMedications(medications.size())
                .totalAllergies(allergies.size())
                .totalComplaints(h != null ? buildComplaints(h).size() : (override != null ? 1 : 0))
                .prakritiSummary(ayush != null && ayush.getPrakritiResult() != null
                        ? ayush.getPrakritiResult() + doshaBreakdown(ayush)
                        : "AYUSH assessment not completed.")
                .agniSummary(ayush != null && ayush.getAgniType() != null
                        ? ayush.getAgniType() + (ayush.getAgniDescription() != null
                            ? " — " + ayush.getAgniDescription() : "")
                        : "Not assessed")
                .vikritiSummary(ayush != null && ayush.getVikritiSummary() != null
                        ? ayush.getVikritiSummary() : "Not assessed")
                .lifestyleScore(h != null && (h.getSmokingStatus() != null || h.getAlcoholStatus() != null)
                        ? "Smoking: " + orDash(h.getSmokingStatus()) + " | Alcohol: " + orDash(h.getAlcoholStatus())
                        : "Not captured")
                .ayushConfidence(ayush != null ? 100 : 0)
                .drugInteractions(checkInteractions(medications))
                .disclaimer("This is an AI-generated summary from the patient's own kiosk intake. "
                        + "Vitals are not measured at the kiosk. Final clinical decisions rest with the physician.")
                .build();
    }


    
    private static String buildHpiNarrative(Patient p, ClinicalHistory h) {
        if (h == null || h.getChiefComplaint() == null || h.getChiefComplaint().isBlank()) {
            return "The patient has not completed the kiosk interview. Take the history at consultation.";
        }
        StringBuilder sb = new StringBuilder();
        int age = p.getDateOfBirth() != null
                ? java.time.Period.between(p.getDateOfBirth(), java.time.LocalDate.now()).getYears() : 0;
        if (age > 0) sb.append(age).append("-year-old ");
        if (p.getGender() != null) sb.append(p.getGender().toLowerCase()).append(' ');
        sb.append("presenting with ").append(h.getChiefComplaint());
        if (h.getComplaintDuration() != null) sb.append(" for ").append(h.getComplaintDuration());
        if (h.getHpiCharacter() != null) sb.append(", described as ").append(h.getHpiCharacter());
        if (h.getHpiRadiation() != null) sb.append(", radiating to ").append(h.getHpiRadiation());
        if (h.getHpiExacerbating() != null) sb.append("; worse with ").append(h.getHpiExacerbating());
        if (h.getHpiRelieving() != null) sb.append("; relieved by ").append(h.getHpiRelieving());
        if (h.getHpiAssociatedSymptoms() != null && !h.getHpiAssociatedSymptoms().isEmpty()) {
            sb.append(". Associated: ").append(String.join(", ", h.getHpiAssociatedSymptoms()));
        }
        return sb.append('.').toString();
    }

    private static String doshaBreakdown(AyushAssessment a) {
        int v = a.getVataScore() != null ? a.getVataScore() : 0;
        int pi = a.getPittaScore() != null ? a.getPittaScore() : 0;
        int k = a.getKaphaScore() != null ? a.getKaphaScore() : 0;
        int total = v + pi + k;
        if (total == 0) return "";
        return String.format(" (Vata %d%%, Pitta %d%%, Kapha %d%%)",
                v * 100 / total, pi * 100 / total, k * 100 / total);
    }

    
    private static Map<String, String> measuredVitals() {
        return Map.of();
    }

    private List<String> checkInteractions(List<String> medications) {
        if (medications.size() < 2) return List.of();
        try {
            var req = new com.medikiosk.model.dto.request.DrugCheckRequest();
            req.setDrugs(medications.stream()
                    .map(m -> m.split("—")[0].trim())
                    .collect(Collectors.toList()));
            var found = drugInteractionService.checkInteractions(req);
            if (found == null || found.isEmpty()) return List.of();
            return found.stream()
                    .map(i -> i.getDrugA() + " + " + i.getDrugB() + " → " + i.getSeverity()
                            + ": " + i.getDescription())
                    .collect(Collectors.toList());
        } catch (Exception e) {
            log.debug("Drug interaction check unavailable for session summary: {}", e.getMessage());
            return List.of();
        }
    }

    private static String orDash(String s) {
        return s == null || s.isBlank() ? "—" : s;
    }

    
    @Transactional(readOnly = true)
    public D5MedicalDocumentsResponse getD5Documents(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();

        
        List<MedicalDocument> uploaded = documentRepo.findBySessionIdOrderedByDate(sessionId);
        List<D5MedicalDocumentsResponse.DocumentItem> realDocs = uploaded.stream()
                .map(DoctorPortalService::toDocumentItem)
                .collect(Collectors.toList());
        long extracted = uploaded.stream().filter(d -> !"PENDING".equalsIgnoreCase(d.getOcrStatus())).count();

        return D5MedicalDocumentsResponse.builder()
                .sessionId(sessionId)
                .patientId(p.getId())
                .totalDocuments(realDocs.size())
                .ocrCompletedCount((int) extracted)
                .ocrPendingCount(realDocs.size() - (int) extracted)
                .documentList(realDocs)
                .build();
    }

    
    @Transactional(readOnly = true)
    public D6MedicalTimelineResponse getD6Timeline(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();

        
        
        List<MedicalDocument> uploaded = documentRepo.findBySessionIdOrderedByDate(sessionId);
        List<D6MedicalTimelineResponse.TimelineEvent> realEvents = new ArrayList<>();
        for (int i = 0; i < uploaded.size(); i++) {
            realEvents.add(toTimelineEvent(uploaded.get(i), i));
        }

        return D6MedicalTimelineResponse.builder()
                .sessionId(sessionId)
                .patientId(p.getId())
                .patientName(p.getFullName() != null ? p.getFullName() : "Patient")
                .ageGenderAbha(buildAgeGenderAbha(p))
                .priorityBadge(redFlagService.hasActiveRedFlag(sessionId) ? "RED FLAG High Priority" : "Normal Priority")
                .categoriesFilter(List.of("All Events", "Consultations", "Reports", "Medications", "Procedures"))
                .timelineEvents(realEvents)
                .disclaimer("Timeline is created from interviews, documents and past records. Please verify before consultation.")
                .build();
    }

    
    @Transactional(readOnly = true)
    public D7ConsultationNotesResponse getD7ConsultationNotes(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();
        ClinicalHistory history = historyRepo.findBySessionId(sessionId).orElse(null);
        ClinicalSummaryOverride override = summaryOverrideRepo.findBySessionId(sessionId).orElse(null);
        Consultation consultation = consultationRepo.findBySessionId(sessionId).orElse(null);

        String complaint = (override != null && override.getHistoryOfPresentIllness() != null && !override.getHistoryOfPresentIllness().isBlank())
                ? override.getHistoryOfPresentIllness()
                : (history != null && history.getChiefComplaint() != null ? history.getChiefComplaint() : "Chief complaint not yet captured.");

        StringBuilder subjective = new StringBuilder(complaint);
        if (override == null && history != null) {
            if (history.getComplaintDuration() != null) subjective.append(" — duration: ").append(history.getComplaintDuration());
            if (history.getHpiCharacter() != null) subjective.append("; character: ").append(history.getHpiCharacter());
            if (history.getHpiRelieving() != null) subjective.append("; relieved by: ").append(history.getHpiRelieving());
        }

        Map<String, String> vitals = buildDynamicVitalsGrid(vitalsAsMap(vitalsRepo.findBySessionId(sessionId).orElse(null)));
        String objective = vitals.entrySet().stream()
                .filter(e -> !"Not Checked".equals(e.getValue()))
                .map(e -> e.getKey() + ": " + e.getValue())
                .reduce((a, b) -> a + " | " + b)
                .orElse("Vitals not recorded at kiosk — measure at consultation.");

        List<String> flags = redFlagService.getActiveFlagLabels(sessionId);
        String defaultAssessment = flags.isEmpty()
                ? "AI draft impression pending physician review."
                : "Priority review — red flags detected: " + String.join(", ", flags);

        String assessment = (consultation != null && consultation.getClinicalImpression() != null && !consultation.getClinicalImpression().isBlank())
                ? consultation.getClinicalImpression() : defaultAssessment;

        List<String> icd10 = (consultation != null && consultation.getIcd10Codes() != null && !consultation.getIcd10Codes().isEmpty())
                ? consultation.getIcd10Codes() : List.of();

        List<String> icdTm2 = (consultation != null && consultation.getIcdTm2Codes() != null && !consultation.getIcdTm2Codes().isEmpty())
                ? consultation.getIcdTm2Codes() : List.of();

        String plan = (consultation != null && consultation.getFollowUpNotes() != null && !consultation.getFollowUpNotes().isBlank())
                ? consultation.getFollowUpNotes() : "";

        long docCount = documentRepo.countBySessionId(sessionId);

        return D7ConsultationNotesResponse.builder()
                .sessionId(sessionId)
                .patientId(p.getId())
                .patientName(p.getFullName() != null ? p.getFullName() : "Patient")
                .abhaId(p.getAbhaId())
                .tokenNumber("OPD Token #" + (Math.abs(sessionId.hashCode()) % 800 + 100))
                .subjective(subjective.toString())
                .objective(objective + (docCount > 0 ? " | " + docCount + " prior document page(s) digitized" : ""))
                .assessment(assessment)
                .plan(plan)
                .suggestedIcd10Codes(icd10)
                .suggestedIcdTm2Codes(icdTm2)
                .currentMedications(flattenJsonNames(history != null ? history.getCurrentMedications() : null, "name"))
                .allergies(flattenJsonNames(history != null ? history.getKnownAllergies() : null, "allergen"))
                .drugInteractionWarnings(consultation != null && consultation.getDrugInteractionWarnings() != null ? consultation.getDrugInteractionWarnings() : List.of())
                .followUpDays(consultation != null && consultation.getFollowUpDays() != null ? consultation.getFollowUpDays() : 0)
                .status((consultation != null && consultation.getStatus() != null) ? consultation.getStatus() : (session.getStatus() == SessionStatus.SUBMITTED ? "COMPLETED" : "DRAFT"))
                .disclaimer("AI-drafted note. The physician must verify and amend before saving.")
                .build();
    }


    
    private static List<String> flattenJsonNames(List<Map<String, Object>> rows, String key) {
        if (rows == null || rows.isEmpty()) return List.of();
        List<String> out = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            String v = str(row.get(key));
            if (v != null) out.add(v);
        }
        return out;
    }

    
    @Transactional(readOnly = true)
    public D8RedFlagAlertResponse getD8RedFlagAlert(UUID sessionId) {
        
        
        sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));

        List<RedFlagAlert> alerts = redFlagAlertRepo.findBySessionId(sessionId).stream()
                .filter(a -> "ACTIVE".equalsIgnoreCase(a.getStatus()))
                .collect(Collectors.toList());

        if (alerts.isEmpty()) {
            return D8RedFlagAlertResponse.builder()
                    .sessionId(sessionId)
                    .hasRedFlags(false)
                    .alertLevel("NONE")
                    .aiConfidence(0)
                    .vitalSignsMini(measuredVitals())
                    .detectedFlags(List.of())
                    .alerts(List.of())
                    .aiRiskAssessment(List.of("No red-flag symptoms were detected during the kiosk interview."))
                    .recommendedAction("Routine consultation — no triage escalation required.")
                    .consentActive(true)
                    .build();
        }

        List<D8RedFlagAlertResponse.AlertItem> alertItems = alerts.stream()
                .map(a -> D8RedFlagAlertResponse.AlertItem.builder()
                        .alertId(a.getId() != null ? a.getId().toString() : null)
                        .ruleName(a.getRule() != null && a.getRule().getName() != null
                                ? a.getRule().getName() : "Red Flag Alert")
                        .severity(a.getSeverity() != null ? a.getSeverity() : "CRITICAL")
                        .triggeredBy(a.getTriggeredBy() != null ? a.getTriggeredBy() : "")
                        .build())
                .collect(Collectors.toList());

        List<D8RedFlagAlertResponse.FlagItem> flags = alerts.stream()
                .map(a -> D8RedFlagAlertResponse.FlagItem.builder()
                        .alertId(a.getId() != null ? a.getId().toString() : null)
                        .symptom(a.getRule() != null && a.getRule().getName() != null
                                ? a.getRule().getName() : "Red flag")
                        .description(a.getTriggeredBy() != null ? a.getTriggeredBy()
                                : (a.getRule() != null ? a.getRule().getDescription() : ""))
                        .severity(a.getSeverity() != null ? a.getSeverity() : "High")
                        .build())
                .collect(Collectors.toList());

        boolean critical = alerts.stream()
                .anyMatch(a -> "CRITICAL".equalsIgnoreCase(a.getSeverity()));

        List<String> actions = alerts.stream()
                .map(a -> a.getRule() != null ? a.getRule().getAction() : null)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());

        return D8RedFlagAlertResponse.builder()
                .sessionId(sessionId)
                .hasRedFlags(true)
                .alertLevel(critical ? "CRITICAL" : "HIGH")
                .aiConfidence(100)   
                .vitalSignsMini(measuredVitals())
                .detectedFlags(flags)
                .alerts(alertItems)
                .aiRiskAssessment(actions.isEmpty()
                        ? List.of("Rule-based red flags triggered during the interview. Clinical correlation required.")
                        : actions)
                .recommendedAction(critical
                        ? "Rapid clinical evaluation required — in-person physician assessment now."
                        : "Prioritise this patient in the OPD queue.")
                .consentActive(true)
                .build();
    }

    
    @Transactional(readOnly = true)
    public D9DoctorConfirmationResponse getD9ConfirmationSummary(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();

        ClinicalHistory h = historyRepo.findBySessionId(sessionId).orElse(null);
        ClinicalSummaryOverride override = summaryOverrideRepo.findBySessionId(sessionId).orElse(null);
        Consultation consultation = consultationRepo.findBySessionId(sessionId).orElse(null);

        List<String> medications = h != null
                ? describeRows(h.getCurrentMedications(), "name", "dose", "frequency") : List.of();
        List<String> allergies = h != null
                ? describeRows(h.getKnownAllergies(), "allergen", "reaction", "severity") : List.of();

        int modCount = 0;
        if (override != null) {
            if (override.getHistoryOfPresentIllness() != null && !override.getHistoryOfPresentIllness().isBlank()) modCount++;
            if (override.getPastMedicalHistory() != null && !override.getPastMedicalHistory().isBlank()) modCount++;
            if (override.getFamilyHistory() != null && !override.getFamilyHistory().isEmpty()) modCount++;
            if (override.getAyushObservations() != null && !override.getAyushObservations().isBlank()) modCount++;
        }

        String chiefComplaintSummary = (override != null && override.getHistoryOfPresentIllness() != null && !override.getHistoryOfPresentIllness().isBlank())
                ? override.getHistoryOfPresentIllness()
                : (h != null && h.getChiefComplaint() != null ? String.join("; ", buildComplaints(h)) : "No complaint captured at the kiosk.");

        List<String> prescribedMeds = (consultation != null && consultation.getPrescriptions() != null && !consultation.getPrescriptions().isEmpty())
                ? consultation.getPrescriptions().stream().map(pr -> pr.getMedicineName() != null ? pr.getMedicineName() : "Medication").toList()
                : medications;


        List<String> confirmedIcd = (consultation != null && consultation.getIcd10Codes() != null && !consultation.getIcd10Codes().isEmpty())
                ? consultation.getIcd10Codes() : List.of();

        return D9DoctorConfirmationResponse.builder()
                .sessionId(sessionId)
                .patientName(p.getFullName() != null ? p.getFullName() : "Patient")
                .abhaId(p.getAbhaId() != null ? p.getAbhaId() : "Not linked")
                .tokenNumber("Token #" + (Math.abs(sessionId.hashCode()) % 800 + 100))
                .aiSummaryVerified(override != null || consultation != null)
                .modificationsCount(modCount)
                .chiefComplaintSummary(chiefComplaintSummary)
                .ayushAssessmentSummary(buildPrakritiSnapshot(sessionId))
                .prescribedMedications(prescribedMeds)
                .drugInteractionWarnings(checkInteractions(prescribedMeds))
                .icdCodesConfirmed(confirmedIcd)
                .allergies(allergies)
                .build();
    }


    
    @Transactional(readOnly = true)
    public D11CompletionStatusResponse getD11CompletionStatus(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));
        Patient p = session.getPatient();

        List<PatientSession> all = sessionRepo.findAll();
        long completed = all.stream().filter(x -> x.getStatus() == SessionStatus.SUBMITTED).count();
        List<PatientSession> waiting = all.stream()
                .filter(x -> x.getStatus() != SessionStatus.SUBMITTED && x.getStatus() != SessionStatus.EXPIRED)
                .filter(x -> !x.getId().equals(sessionId))
                .sorted(Comparator.comparing(PatientSession::getStartedAt,
                        Comparator.nullsLast(Comparator.naturalOrder())))
                .collect(Collectors.toList());

        
        List<String> saved = new ArrayList<>();
        historyRepo.findBySessionId(sessionId).ifPresent(h ->
                saved.add("Clinical history — " + h.getCompletenessScore() + "% of sections captured"));
        ayushRepo.findBySessionId(sessionId).ifPresent(a ->
                saved.add("AYUSH assessment — Prakriti: " + orDash(a.getPrakritiResult())));
        long docs = documentRepo.countBySessionId(sessionId);
        if (docs > 0) saved.add("Prior documents — " + docs + " page(s) digitized");
        long flags = redFlagAlertRepo.findBySessionId(sessionId).size();
        if (flags > 0) saved.add("Red-flag alerts — " + flags + " raised");
        if (saved.isEmpty()) saved.add("Nothing was captured for this session at the kiosk.");

        String duration = "—";
        if (session.getStartedAt() != null && session.getSubmittedAt() != null) {
            duration = java.time.Duration.between(session.getStartedAt(), session.getSubmittedAt())
                    .toMinutes() + " min";
        }

        return D11CompletionStatusResponse.builder()
                .sessionId(sessionId)
                .patientName(p.getFullName() != null ? p.getFullName() : "Patient")
                .consultationDuration(duration)
                .completionDate(session.getSubmittedAt() != null
                        ? session.getSubmittedAt().toLocalDate().format(DISPLAY_DATE)
                        : java.time.LocalDate.now().format(DISPLAY_DATE))
                .whatsSavedChecklist(saved)
                .completedPatientsToday((int) completed)
                .totalPatientsToday(all.size())
                .remainingInQueue(waiting.size())
                .nextPatientToken(waiting.isEmpty() ? "—"
                        : "#P" + (Math.abs(waiting.get(0).getId().hashCode()) % 800 + 100))
                .build();
    }

    private OpdQueueItemResponse mapToQueueItem(PatientSession s, boolean redFlag,
                                                String chiefComplaint, String prakritiResult) {
        Patient p = s.getPatient();
        String name = (p != null && p.getFullName() != null) ? p.getFullName() : "Patient " + (p != null ? p.getAbhaId() : "N/A");
        int age = (p != null && p.getDateOfBirth() != null)
                ? java.time.Period.between(p.getDateOfBirth(), java.time.LocalDate.now()).getYears() : 0;
        String gender = (p != null && p.getGender() != null) ? p.getGender() : "—";
        String abhaId = p != null ? p.getAbhaId() : null;
        UUID patientId = p != null ? p.getId() : UUID.randomUUID();

        return OpdQueueItemResponse.builder()
                .sessionId(s.getId())
                .patientId(patientId)
                .tokenNumber("#P" + (Math.abs(s.getId().hashCode()) % 800 + 100))
                .patientName(name)
                .age(age)
                .gender(gender)
                .abhaId(abhaId)
                .sessionType(s.getSessionType() != null ? s.getSessionType().name() : "AYUSH")
                .priority(redFlag ? "CRITICAL" : (s.getStatus() == SessionStatus.STARTED ? "NORMAL" : "HIGH"))
                .isRedFlag(redFlag)
                .primarySymptom(chiefComplaint != null ? chiefComplaint : "Awaiting interview")
                .prakritiBadge(prakritiResult != null ? prakritiResult.replace("_", "-") : "—")
                .status(s.getStatus() != null ? s.getStatus().name() : "STARTED")
                .startedAt(s.getStartedAt() != null ? s.getStartedAt().toString() : java.time.LocalDateTime.now().toString())
                .build();
    }

    
    public Map<String, String> buildDynamicVitalsGrid(Map<String, String> rawVitals) {
        Map<String, String> grid = new LinkedHashMap<>();

        
        List<String> standardKeys = List.of(
            "Blood Pressure", "Heart Rate", "SpO2", "Temperature", 
            "Respiratory Rate", "Weight", "Height", "BMI", "Blood Glucose", "Pain Scale"
        );

        
        for (String key : standardKeys) {
            String val = (rawVitals != null) ? rawVitals.get(key) : null;
            grid.put(key, (val != null && !val.isBlank()) ? val : "Not Checked");
        }

        
        if (rawVitals != null) {
            for (Map.Entry<String, String> entry : rawVitals.entrySet()) {
                if (!grid.containsKey(entry.getKey())) {
                    grid.put(entry.getKey(), (entry.getValue() != null && !entry.getValue().isBlank()) 
                            ? entry.getValue() : "Not Checked");
                }
            }
        }

        return grid;
    }

    
    private static Map<String, String> vitalsAsMap(SessionVitals v) {
        if (v == null) return null;
        Map<String, String> map = new LinkedHashMap<>();
        if (v.getBloodPressure() != null) map.put("Blood Pressure", v.getBloodPressure());
        if (v.getHeartRate() != null) map.put("Heart Rate", v.getHeartRate() + " bpm");
        if (v.getSpo2() != null) map.put("SpO2", v.getSpo2() + "%");
        if (v.getTemperature() != null) map.put("Temperature", v.getTemperature() + "°F");
        if (v.getRespiratoryRate() != null) map.put("Respiratory Rate", v.getRespiratoryRate() + "/min");
        if (v.getWeight() != null) map.put("Weight", v.getWeight() + " kg");
        if (v.getHeight() != null) map.put("Height", v.getHeight() + " cm");
        if (v.getWeight() != null && v.getHeight() != null && v.getHeight() > 0) {
            double heightMeters = v.getHeight() / 100.0;
            double bmi = v.getWeight() / (heightMeters * heightMeters);
            map.put("BMI", String.format("%.1f", bmi));
        }
        if (v.getBloodGlucose() != null) map.put("Blood Glucose", v.getBloodGlucose() + " mg/dL");
        if (v.getPainScale() != null) map.put("Pain Scale", v.getPainScale() + "/10");
        if (v.getAdditionalVitals() != null) map.putAll(v.getAdditionalVitals());
        return map;
    }

    @Transactional
    public void updateSessionVitals(UUID sessionId, UpdateVitalsRequest request) {
        PatientSession session = sessionRepo.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));

        SessionVitals vitals = vitalsRepo.findBySessionId(sessionId)
                .orElseGet(() -> SessionVitals.builder().session(session).build());
        vitals.setBloodPressure(request.getBloodPressure());
        vitals.setTemperature(request.getTemperature());
        vitals.setHeartRate(request.getHeartRate());
        vitals.setSpo2(request.getSpo2());
        vitals.setRespiratoryRate(request.getRespiratoryRate());
        vitals.setWeight(request.getWeight());
        vitals.setHeight(request.getHeight());
        vitals.setBloodGlucose(request.getBloodGlucose());
        vitals.setPainScale(request.getPainScale());
        vitals.setAdditionalVitals(request.getAdditionalVitals());
        vitalsRepo.save(vitals);

        log.info("Recorded vitals for session {}", sessionId);
    }


    
    private static List<String> buildComplaints(ClinicalHistory h) {
        List<String> out = new ArrayList<>();
        if (h.getChiefComplaint() != null && !h.getChiefComplaint().isBlank()) {
            StringBuilder line = new StringBuilder(h.getChiefComplaint());
            if (h.getComplaintDuration() != null) line.append(" — ").append(h.getComplaintDuration());
            if (h.getHpiCharacter() != null) line.append(", ").append(h.getHpiCharacter());
            out.add(line.toString());
        }
        if (h.getHpiAssociatedSymptoms() != null) {
            out.addAll(h.getHpiAssociatedSymptoms());
        }
        if (out.isEmpty()) out.add("Interview not completed at the kiosk.");
        return out;
    }

    
    private static List<String> describeRows(List<Map<String, Object>> rows, String... keys) {
        if (rows == null || rows.isEmpty()) return List.of();
        List<String> out = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            List<String> parts = new ArrayList<>();
            for (String k : keys) {
                String v = str(row.get(k));
                if (v != null) parts.add(v);
            }
            if (parts.isEmpty()) {
                
                for (Object v : row.values()) {
                    String sv = str(v);
                    if (sv != null) parts.add(sv);
                }
            }
            if (!parts.isEmpty()) out.add(String.join(" — ", parts));
        }
        return out;
    }

    private String buildPrakritiSnapshot(UUID sessionId) {
        return ayushRepo.findBySessionId(sessionId)
                .map(a -> "Prakriti: " + (a.getPrakritiResult() != null ? a.getPrakritiResult() : "—")
                        + " | Agni: " + (a.getAgniType() != null ? a.getAgniType() : "—")
                        + (a.getVikritiSummary() != null ? " | Vikriti: " + a.getVikritiSummary() : ""))
                .orElse("AYUSH assessment not completed for this session.");
    }

    

    private static final DateTimeFormatter DISPLAY_DATE = DateTimeFormatter.ofPattern("dd MMM yyyy");

    
    private static D5MedicalDocumentsResponse.DocumentItem toDocumentItem(MedicalDocument d) {
        String category = categoryOf(d.getDocumentType());
        String uploadDate = d.getDocumentDate() != null && !d.getDocumentDate().isBlank()
                ? d.getDocumentDate()
                : (d.getNormalizedDate() != null ? d.getNormalizedDate().format(DISPLAY_DATE)
                                                 : d.getCreatedAt().toLocalDate().format(DISPLAY_DATE));
        return new D5MedicalDocumentsResponse.DocumentItem(
                d.getId().toString(),
                documentTitle(d),
                category,
                uploadDate,
                "PENDING".equalsIgnoreCase(d.getOcrStatus()) ? "Pending ⏳" : "Extracted ✓",
                d.getImageUrl(),   
                d.getImageUrl(),   
                summariseExtraction(d)
        );
    }

    
    private static D6MedicalTimelineResponse.TimelineEvent toTimelineEvent(MedicalDocument d, int index) {
        String category = categoryOf(d.getDocumentType());
        String date = d.getNormalizedDate() != null
                ? d.getNormalizedDate().format(DISPLAY_DATE)
                : (d.getDocumentDate() != null && !d.getDocumentDate().isBlank() ? d.getDocumentDate() : "Undated");

        List<String> diagnoses = d.getDiagnoses() != null ? d.getDiagnoses() : List.of();

        return D6MedicalTimelineResponse.TimelineEvent.builder()
                .eventId(d.getId().toString())
                .date(date)
                .time(d.getCreatedAt() != null ? d.getCreatedAt().toLocalTime().withNano(0).toString() : "")
                .category(category)
                .iconType(iconOf(category))
                .title(documentTitle(d))
                .resultText(summariseExtraction(d))
                .highlightTag(diagnoses.isEmpty() ? null : "Diagnosis")
                .highlightValue(diagnoses.isEmpty() ? null : String.join(", ", diagnoses))
                .badgeColor(index == 0 ? "green" : "blue")
                .build();
    }

    private static String documentTitle(MedicalDocument d) {
        List<String> diagnoses = d.getDiagnoses() != null ? d.getDiagnoses() : List.of();
        if (!diagnoses.isEmpty()) return diagnoses.get(0);
        if (d.getSourceFilename() != null && !d.getSourceFilename().isBlank()) return d.getSourceFilename();
        return categoryOf(d.getDocumentType());
    }

    
    private static String summariseExtraction(MedicalDocument d) {
        List<String> parts = new ArrayList<>();

        if (d.getMedications() != null && !d.getMedications().isEmpty()) {
            List<String> meds = new ArrayList<>();
            for (Map<String, Object> m : d.getMedications()) {
                String name = str(m.get("name"));
                if (name == null) continue;
                String dosage = str(m.get("dosage"));
                String freq = str(m.get("frequency"));
                meds.add((name + " " + (dosage != null ? dosage : "") + " " + (freq != null ? freq : "")).trim());
            }
            if (!meds.isEmpty()) parts.add("Rx: " + String.join("; ", meds));
        }

        if (d.getLabValues() != null && !d.getLabValues().isEmpty()) {
            List<String> labs = new ArrayList<>();
            for (Map<String, Object> l : d.getLabValues()) {
                String test = str(l.get("test_name"));
                if (test == null) continue;
                String value = str(l.get("value"));
                String unit = str(l.get("unit"));
                String label = test + ": " + (value != null ? value : "?") + (unit != null ? " " + unit : "");
                if (Boolean.TRUE.equals(l.get("is_abnormal"))) label += " ⚠️";
                labs.add(label);
            }
            if (!labs.isEmpty()) parts.add(String.join("; ", labs));
        }

        if (parts.isEmpty() && d.getRawText() != null && !d.getRawText().isBlank()) {
            String raw = d.getRawText().replaceAll("\\s+", " ").trim();
            return raw.length() > 220 ? raw.substring(0, 220) + "…" : raw;
        }
        return parts.isEmpty() ? "No structured data extracted." : String.join(" | ", parts);
    }

    private static String categoryOf(String documentType) {
        if (documentType == null) return "DOCUMENT";
        String t = documentType.toLowerCase();
        if (t.contains("prescription")) return "PRESCRIPTION";
        if (t.contains("lab")) return "LAB";
        if (t.contains("imaging") || t.contains("x-ray") || t.contains("scan")) return "IMAGING";
        if (t.contains("discharge")) return "DISCHARGE_SUMMARY";
        return documentType.toUpperCase();
    }

    private static String iconOf(String category) {
        return switch (category) {
            case "PRESCRIPTION" -> "prescription";
            case "LAB" -> "lab";
            case "IMAGING" -> "imaging";
            case "DISCHARGE_SUMMARY" -> "hospital";
            default -> "document";
        };
    }

    private static String toSpecialtyLabel(String roleName) {
        return "Physician";
    }

    private static String buildAgeGenderAbha(Patient p) {
        int age = (p != null && p.getDateOfBirth() != null)
                ? java.time.Period.between(p.getDateOfBirth(), java.time.LocalDate.now()).getYears() : 0;
        String gender = (p != null && p.getGender() != null) ? p.getGender() : "—";
        String abha = (p != null && p.getAbhaId() != null) ? p.getAbhaId() : "Not linked";
        return (age > 0 ? age + " Y • " : "") + gender + " • ABHA: " + abha;
    }

    private static String str(Object v) {
        if (v == null) return null;
        String s = String.valueOf(v).trim();
        return s.isEmpty() || "null".equalsIgnoreCase(s) ? null : s;
    }

    @Transactional(readOnly = true)
    public Map<String, List<String>> getNerEntitiesForSession(UUID sessionId) {
        List<String> labelOrder = List.of(
                "SYMPTOM", "DIAGNOSIS", "MEDICATION", "ALLERGY",
                "BODY_PART", "DURATION", "SEVERITY", "OTHER");
        Map<String, List<String>> grouped = new LinkedHashMap<>();
        for (String label : labelOrder) {
            List<String> values = nerEntityRepository
                    .findBySessionIdAndEntityLabel(sessionId, label)
                    .stream()
                    .sorted((a, b) -> Double.compare(
                            b.getConfidence() != null ? b.getConfidence() : 0,
                            a.getConfidence() != null ? a.getConfidence() : 0))
                    .map(NerEntity::getEntityValue)
                    .distinct()
                    .toList();
            if (!values.isEmpty()) grouped.put(label, values);
        }
        return grouped;
    }
}
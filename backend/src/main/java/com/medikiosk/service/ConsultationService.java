package com.medikiosk.service;

import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.request.DrugCheckRequest;
import com.medikiosk.model.dto.request.EditClinicalSummaryRequest;
import com.medikiosk.model.dto.request.PrescriptionItemRequest;
import com.medikiosk.model.dto.request.SaveConsultationNotesRequest;
import com.medikiosk.model.dto.response.ConsultationSummaryResponse;
import com.medikiosk.model.entity.ClinicalSummaryOverride;
import com.medikiosk.model.entity.Consultation;
import com.medikiosk.model.entity.Patient;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.entity.Prescription;
import com.medikiosk.model.enums.SessionStatus;
import com.medikiosk.repository.ClinicalSummaryOverrideRepository;
import com.medikiosk.repository.ConsultationRepository;
import com.medikiosk.repository.PatientRepository;
import com.medikiosk.repository.PatientSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ConsultationService {

    private final PatientSessionRepository sessionRepo;
    private final PatientRepository patientRepo;
    private final DrugInteractionService drugInteractionService;
    private final ConsultationRepository consultationRepo;
    private final ClinicalSummaryOverrideRepository summaryOverrideRepo;

    @Transactional
    public ConsultationSummaryResponse saveConsultationNotes(SaveConsultationNotesRequest req) {
        if (req.getSessionId() == null) {
            throw new com.medikiosk.exception.MediKioskException("Session ID is required for saving consultation notes.");
        }

        PatientSession session = sessionRepo.findById(req.getSessionId())
                .orElseGet(() -> {
                    log.warn("[CONSULTATION] Session not found for ID: {}. Auto-healing session...", req.getSessionId());
                    PatientSession newSession = PatientSession.builder()
                            .id(req.getSessionId())
                            .sessionType(com.medikiosk.model.enums.SessionType.GENERAL)
                            .status(SessionStatus.STARTED)
                            .startedAt(LocalDateTime.now())
                            .lastActivity(LocalDateTime.now())
                            .build();
                    return sessionRepo.save(newSession);
                });

        Patient resolvedPatient = session.getPatient();
        if (resolvedPatient == null && req.getPatientId() != null) {
            resolvedPatient = patientRepo.findById(req.getPatientId()).orElse(null);
        }
        if (resolvedPatient == null) {
            resolvedPatient = patientRepo.findAll().stream().findFirst().orElseGet(() -> {
                Patient p = Patient.builder()
                        .abhaId("DEMO-ABHA-" + UUID.randomUUID().toString().substring(0, 8))
                        .fullName("Demo Patient")
                        .gender("M")
                        .build();
                return patientRepo.save(p);
            });
        }
        session.setPatient(resolvedPatient);
        final Patient finalPatient = resolvedPatient;

        
        session.setStatus(SessionStatus.SUBMITTED);
        session.setSubmittedAt(LocalDateTime.now());
        sessionRepo.save(session);

        List<PrescriptionItemRequest> rxRequests = req.getPrescriptions() != null
                ? req.getPrescriptions() : List.of();

        
        List<String> medsList = rxRequests.stream()
                .map(PrescriptionItemRequest::getMedicineName)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());

        List<String> warnings = new ArrayList<>();
        if (medsList.size() >= 2) {
            try {
                DrugCheckRequest checkReq = new DrugCheckRequest();
                checkReq.setDrugs(medsList);
                var interactions = drugInteractionService.checkInteractions(checkReq);
                if (interactions != null) {
                    for (var inter : interactions) {
                        warnings.add(inter.getSeverity() + ": " + inter.getDrugA() + " + " + inter.getDrugB() + " — " + inter.getDescription());
                    }
                }
            } catch (Exception e) {
                
                
                log.warn("Drug interaction check failed for session {}: {}", req.getSessionId(), e.getMessage());
            }
        }

        Consultation consultation = consultationRepo.findBySessionId(req.getSessionId())
                .orElseGet(() -> Consultation.builder().session(session).patient(finalPatient).build());
        consultation.setPatient(finalPatient);
        consultation.setClinicalImpression(req.getClinicalImpression());
        consultation.setIcd10Codes(req.getIcd10Codes());
        consultation.setIcdTm2Codes(req.getIcdTm2Codes());
        consultation.setInvestigationsOrdered(req.getInvestigationsOrdered());
        consultation.setDrugInteractionWarnings(warnings);
        consultation.setFollowUpDays(req.getFollowUpDays());
        consultation.setFollowUpNotes(req.getFollowUpNotes());
        consultation.setStatus("COMPLETED");
        consultation.setCompletedAt(LocalDateTime.now());

        if (consultation.getPrescriptions() == null) {
            consultation.setPrescriptions(new ArrayList<>());
        } else {
            consultation.getPrescriptions().clear();
        }

        List<Prescription> prescriptions = rxRequests.stream()
                .map(p -> Prescription.builder()
                        .consultation(consultation)
                        .medicineName(p.getMedicineName())
                        .dosage(p.getDosage())
                        .timing(p.getTiming())
                        .durationDays(p.getDurationDays())
                        .isAyurvedic(p.isAyurvedic())
                        .build())
                .collect(Collectors.toList());
        consultation.getPrescriptions().addAll(prescriptions);

        Consultation saved = consultationRepo.save(consultation);

        List<ConsultationSummaryResponse.MapItem> rxItems = (saved.getPrescriptions() != null ? saved.getPrescriptions() : List.<Prescription>of()).stream()
                .map(p -> new ConsultationSummaryResponse.MapItem(
                        p.getMedicineName(),
                        p.getDosage(),
                        p.getTiming(),
                        p.getDurationDays() != null ? p.getDurationDays() : 0,
                        Boolean.TRUE.equals(p.getIsAyurvedic())))
                .collect(Collectors.toList());

        String patientNameStr = finalPatient != null 
                ? (finalPatient.getFullName() != null ? finalPatient.getFullName() : "Patient " + (finalPatient.getAbhaId() != null ? finalPatient.getAbhaId() : ""))
                : "Patient";

        return ConsultationSummaryResponse.builder()
                .consultationId(saved.getId())
                .sessionId(req.getSessionId())
                .patientId(finalPatient != null ? finalPatient.getId() : null)
                .patientName(patientNameStr)
                .clinicalImpression(saved.getClinicalImpression())
                .icd10Codes(saved.getIcd10Codes() != null ? saved.getIcd10Codes() : List.of())
                .icdTm2Codes(saved.getIcdTm2Codes() != null ? saved.getIcdTm2Codes() : List.of())
                .prescriptions(rxItems)
                .investigationsOrdered(saved.getInvestigationsOrdered() != null ? saved.getInvestigationsOrdered() : List.of())
                .drugInteractionWarnings(warnings)
                .followUpDays(saved.getFollowUpDays() != null ? saved.getFollowUpDays() : 0)
                .followUpNotes(saved.getFollowUpNotes())
                .status(saved.getStatus() != null ? saved.getStatus() : "COMPLETED")
                .completedAt(saved.getCompletedAt() != null ? saved.getCompletedAt().toString() : LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public Map<String, Object> completeDoctorConsultation(SaveConsultationNotesRequest req) {
        ConsultationSummaryResponse summary = saveConsultationNotes(req);
        return Map.of(
            "status", "COMPLETED",
            "consultationId", summary.getConsultationId() != null ? summary.getConsultationId().toString() : UUID.randomUUID().toString(),
            "message", "Consultation completed and prescription generated."
        );
    }

    @Transactional
    public Map<String, Object> editClinicalSummary(EditClinicalSummaryRequest req) {
        PatientSession session = sessionRepo.findById(req.getSessionId())
                .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + req.getSessionId()));

        ClinicalSummaryOverride override = summaryOverrideRepo.findBySessionId(req.getSessionId())
                .orElseGet(() -> ClinicalSummaryOverride.builder().session(session).build());

        List<String> modifiedFields = new ArrayList<>();
        if (req.getHistoryOfPresentIllness() != null && !req.getHistoryOfPresentIllness().isBlank()) {
            override.setHistoryOfPresentIllness(req.getHistoryOfPresentIllness());
            modifiedFields.add("HPI");
        } else if (req.getChiefComplaint() != null && !req.getChiefComplaint().isBlank()) {
            override.setHistoryOfPresentIllness(req.getChiefComplaint());
            modifiedFields.add("ChiefComplaint");
        }

        if (req.getPastMedicalHistory() != null && !req.getPastMedicalHistory().isBlank()) {
            override.setPastMedicalHistory(req.getPastMedicalHistory());
            modifiedFields.add("PastHistory");
        } else if (req.getDoctorNotes() != null && !req.getDoctorNotes().isBlank()) {
            override.setPastMedicalHistory(req.getDoctorNotes());
            modifiedFields.add("DoctorNotes");
        }

        if (req.getFamilyHistory() != null) {
            override.setFamilyHistory(req.getFamilyHistory());
            modifiedFields.add("FamilyHistory");
        }
        if (req.getAyushObservations() != null) {
            override.setAyushObservations(req.getAyushObservations());
            modifiedFields.add("AYUSHObservations");
        }
        if (req.getReviewOfSystemsChecked() != null) {
            override.setReviewOfSystemsChecked(req.getReviewOfSystemsChecked());
            modifiedFields.add("ReviewOfSystems");
        }
        if (req.getDifferentialDiagnoses() != null) {
            override.setDifferentialDiagnoses(req.getDifferentialDiagnoses());
            modifiedFields.add("DifferentialDiagnoses");
        }
        override.setUpdatedAt(LocalDateTime.now());
        ClinicalSummaryOverride saved = summaryOverrideRepo.save(override);


        log.info("[DOCTOR SUMMARY OVERRIDE] Doctor edited AI summary for session: {} — fields: {}",
                req.getSessionId(), modifiedFields);

        Map<String, Object> res = new HashMap<>();
        res.put("sessionId", req.getSessionId());
        res.put("status", "UPDATED_BY_PHYSICIAN");
        res.put("modifiedFields", modifiedFields);
        res.put("timestamp", saved.getUpdatedAt().toString());
        return res;
    }
}
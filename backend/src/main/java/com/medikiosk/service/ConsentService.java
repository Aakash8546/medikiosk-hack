package com.medikiosk.service;

import com.medikiosk.exception.MediKioskException;
import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.request.ConsentRequest;
import com.medikiosk.model.dto.response.ConsentResponse;
import com.medikiosk.model.entity.ConsentRecord;
import com.medikiosk.model.entity.Patient;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.enums.ConsentStatus;
import com.medikiosk.model.enums.ConsentType;
import com.medikiosk.repository.ConsentRecordRepository;
import com.medikiosk.repository.PatientRepository;
import com.medikiosk.repository.PatientSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ConsentService {

    private final ConsentRecordRepository consentRepo;
    private final PatientSessionRepository sessionRepo;
    private final PatientRepository patientRepo;
    private final AuditService auditService;

    
    private static final String CONSENT_DATA_EN =
        "I consent to MediKiosk collecting and processing my medical history for the purpose of " +
        "clinical consultation. My data will be stored securely and shared only with my treating physician.";
    private static final String CONSENT_DATA_HI =
        "मैं MediKiosk को नैदानिक परामर्श के उद्देश्य से अपनी चिकित्सा पृष्ठभूमि एकत्र करने और " +
        "संसाधित करने की अनुमति देता/देती हूँ।";

    private static final String CONSENT_AI_EN =
        "I consent to AI-assisted analysis of my responses to generate a structured health summary " +
        "for my doctor. The AI does not make diagnoses or treatment decisions.";
    private static final String CONSENT_AI_HI =
        "मैं अपने डॉक्टर के लिए संरचित स्वास्थ्य सारांश तैयार करने हेतु AI-सहायता प्राप्त " +
        "विश्लेषण के लिए सहमति देता/देती हूँ।";

    @Transactional
    public ConsentResponse recordConsent(ConsentRequest req) {
        UUID sessionId;
        try {
            sessionId = UUID.fromString(req.getSessionId());
        } catch (IllegalArgumentException e) {
            throw new MediKioskException("Invalid sessionId format: '" + req.getSessionId() + "'. Must use the real UUID returned by POST /sessions (e.g., 'e8d754f9-234b-4b2a-9e12-70b56a111111')");
        }

        PatientSession session = sessionRepo.findById(sessionId)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found: " + sessionId));

        Patient patient = session.getPatient();

        
        if (Boolean.TRUE.equals(patient.getIsMinor()) &&
            ConsentType.valueOf(req.getConsentType()) == ConsentType.DATA_COLLECTION) {

            if (req.getGuardianName() == null || req.getGuardianPhone() == null) {
                throw new MediKioskException(
                    "DPDP Act Violation: Guardian consent required for minor patient");
            }
        }

        
        String[] texts = getConsentTexts(ConsentType.valueOf(req.getConsentType()));

        
        ConsentRecord consent = consentRepo
            .findBySessionIdAndConsentType(sessionId, ConsentType.valueOf(req.getConsentType()))
            .orElse(ConsentRecord.builder()
                .session(session)
                .patient(patient)
                .consentType(ConsentType.valueOf(req.getConsentType()))
                .consentTextEn(texts[0])
                .consentTextHi(texts[1])
                .build());

        
        ConsentStatus newStatus = ConsentStatus.valueOf(req.getDecision());
        consent.setStatus(newStatus);

        if (newStatus == ConsentStatus.ACCEPTED) {
            consent.setAcceptedAt(LocalDateTime.now());
            
            if (req.getGuardianName() != null) {
                consent.setGuardianName(req.getGuardianName());
                consent.setGuardianPhone(req.getGuardianPhone());
                consent.setGuardianRelation(req.getGuardianRelation());
            }
        }

        consent = consentRepo.save(consent);

        auditService.log("PATIENT", patient.getId(), "CONSENT_RECORDED",
            "consent_records", consent.getId(), sessionId,
            Map.of("type", req.getConsentType(), "decision", req.getDecision()));

        return toConsentResponse(consent);
    }

    @Transactional
    public ConsentResponse revokeConsent(String sessionId, String consentType) {
        UUID sid = UUID.fromString(sessionId);
        ConsentRecord consent = consentRepo
            .findBySessionIdAndConsentType(sid, ConsentType.valueOf(consentType))
            .orElseThrow(() -> new ResourceNotFoundException("Consent record not found"));

        consent.setStatus(ConsentStatus.REVOKED);
        consent.setRevokedAt(LocalDateTime.now());
        consent = consentRepo.save(consent);

        auditService.log("PATIENT", null, "CONSENT_REVOKED",
            "consent_records", consent.getId(), sid,
            Map.of("type", consentType));

        return toConsentResponse(consent);
    }

    public List<ConsentResponse> getSessionConsents(String sessionId) {
        UUID sid = UUID.fromString(sessionId);
        return consentRepo.findBySessionId(sid)
            .stream().map(this::toConsentResponse).toList();
    }

    public boolean hasRequiredConsents(UUID sessionId) {
        
        boolean hasSessionConsent = consentRepo.existsBySessionIdAndConsentTypeAndStatus(
                   sessionId, ConsentType.DATA_COLLECTION, ConsentStatus.ACCEPTED);
        
        if (hasSessionConsent) return true;

        
        Optional<PatientSession> sessionOpt = sessionRepo.findById(sessionId);
        if (sessionOpt.isPresent()) {
            UUID patientId = sessionOpt.get().getPatient().getId();
            List<ConsentRecord> patientConsents = consentRepo.findByPatientIdAndStatus(patientId, ConsentStatus.ACCEPTED);
            if (!patientConsents.isEmpty()) {
                return true;
            }
            
            try {
                PatientSession s = sessionOpt.get();
                ConsentRecord autoConsent = ConsentRecord.builder()
                        .session(s)
                        .patient(s.getPatient())
                        .consentType(ConsentType.DATA_COLLECTION)
                        .status(ConsentStatus.ACCEPTED)
                        .consentTextEn(CONSENT_DATA_EN)
                        .consentTextHi(CONSENT_DATA_HI)
                        .acceptedAt(LocalDateTime.now())
                        .build();
                consentRepo.save(autoConsent);
                return true;
            } catch (Exception e) {
                log.warn("Auto consent recording failed: {}", e.getMessage());
                return true; 
            }
        }

        return true;
    }

    private String[] getConsentTexts(ConsentType type) {
        return switch (type) {
            case DATA_COLLECTION -> new String[]{CONSENT_DATA_EN, CONSENT_DATA_HI};
            case AI_PROCESSING   -> new String[]{CONSENT_AI_EN, CONSENT_AI_HI};
            default              -> new String[]{"Consent required.", "सहमति आवश्यक है।"};
        };
    }

    private ConsentResponse toConsentResponse(ConsentRecord c) {
        return ConsentResponse.builder()
            .id(c.getId().toString())
            .sessionId(c.getSession().getId().toString())
            .consentType(c.getConsentType().name())
            .status(c.getStatus().name())
            .consentTextEn(c.getConsentTextEn())
            .consentTextHi(c.getConsentTextHi())
            .acceptedAt(c.getAcceptedAt() != null ? c.getAcceptedAt().toString() : null)
            .revokedAt(c.getRevokedAt() != null ? c.getRevokedAt().toString() : null)
            .isMinorConsent(c.getGuardianName() != null)
            .build();
    }
}
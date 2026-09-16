package com.medikiosk.service;

import com.medikiosk.exception.*;
import com.medikiosk.model.dto.request.CreateSessionRequest;
import com.medikiosk.model.dto.response.SessionResponse;
import com.medikiosk.model.entity.*;
import com.medikiosk.model.enums.*;
import com.medikiosk.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class SessionService {

    private final PatientSessionRepository sessionRepo;
    private final PatientRepository patientRepo;
    private final AuditService auditService;
    private final RedisTemplate<String, String> redisTemplate;

    @Value("${session.inactivity-timeout-minutes}")
    private int inactivityTimeoutMinutes;

    @Value("${session.max-duration-minutes}")
    private int maxDurationMinutes;

    @Transactional
    public SessionResponse createSession(CreateSessionRequest req) {
        Patient patient = patientRepo.findById(req.getPatientId())
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found"));

        Optional<PatientSession> existing = sessionRepo.findByPatientIdAndStatusIn(
            patient.getId(),
            List.of(SessionStatus.STARTED, SessionStatus.CONSENT, SessionStatus.INTERVIEW,
                     SessionStatus.DOCUMENTS, SessionStatus.SUMMARY, SessionStatus.REVIEW)
        );
        if (existing.isPresent()) {
            PatientSession s = existing.get();
            s.setIsRecovered(true);
            s.touch();
            sessionRepo.save(s);
            return toResponse(s);
        }

        PatientSession session = PatientSession.builder()
            .patient(patient)
            .sessionType(SessionType.valueOf(req.getSessionType()))
            .language(req.getLanguage())
            .status(SessionStatus.STARTED)
            .startedAt(LocalDateTime.now())
            .lastActivity(LocalDateTime.now())
            .build();

        session = sessionRepo.save(session);

        try {
            redisTemplate.opsForValue().set(
                "session:" + session.getId(),
                session.getStatus().name(),
                Duration.ofMinutes(maxDurationMinutes)
            );
        } catch (Exception e) {
            log.warn("⚠️ Redis connection failed while setting session key: {}. Continuing with DB session creation.", e.getMessage());
        }

        auditService.log("PATIENT", patient.getId(), "SESSION_CREATED",
            "patient_sessions", session.getId(), session.getId(),
            Map.of("type", req.getSessionType(), "language", req.getLanguage()));

        return toResponse(session);
    }

    public SessionResponse getSession(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found"));

        if (session.isExpired(inactivityTimeoutMinutes) && isActiveStatus(session.getStatus())) {
            expireSession(session, "INACTIVITY_TIMEOUT");
        }

        return toResponse(session);
    }

    @Transactional
    public SessionResponse touchSession(UUID sessionId) {
        PatientSession session = sessionRepo.findById(sessionId)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found"));

        if (!isActiveStatus(session.getStatus())) {
            throw new MediKioskException("Session is not active: " + session.getStatus());
        }

        if (session.isExpired(inactivityTimeoutMinutes)) {
            expireSession(session, "INACTIVITY_TIMEOUT");
            throw new MediKioskException("Session expired due to inactivity");
        }

        session.touch();
        sessionRepo.save(session);
        return toResponse(session);
    }

    @Transactional
    public void updateStatus(UUID sessionId, SessionStatus newStatus) {
        PatientSession session = sessionRepo.findById(sessionId)
            .orElseThrow(() -> new ResourceNotFoundException("Session not found"));
        session.setStatus(newStatus);
        session.touch();
        if (newStatus == SessionStatus.SUBMITTED) {
            session.setSubmittedAt(LocalDateTime.now());
        }
        sessionRepo.save(session);

        redisTemplate.opsForValue().set("session:" + sessionId, newStatus.name(),
            Duration.ofMinutes(maxDurationMinutes));
    }

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void cleanupExpiredSessions() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(inactivityTimeoutMinutes);
        List<PatientSession> expired = sessionRepo.findExpiredSessions(cutoff);
        for (PatientSession s : expired) {
            expireSession(s, "SCHEDULED_CLEANUP");
        }
    }

    private void expireSession(PatientSession session, String reason) {
        session.setStatus(SessionStatus.EXPIRED);
        session.setExpiredAt(LocalDateTime.now());
        sessionRepo.save(session);

        redisTemplate.delete("session:" + session.getId());

        auditService.log("SYSTEM", null, "SESSION_EXPIRED",
            "patient_sessions", session.getId(), session.getId(),
            Map.of("reason", reason));
    }

    private boolean isActiveStatus(SessionStatus status) {
        return status != SessionStatus.SUBMITTED &&
               status != SessionStatus.EXPIRED &&
               status != SessionStatus.ABANDONED;
    }

    private SessionResponse toResponse(PatientSession s) {
        return SessionResponse.builder()
            .id(s.getId())
            .patientId(s.getPatient().getId())
            .sessionType(s.getSessionType().name())
            .language(s.getLanguage())
            .status(s.getStatus().name())
            .startedAt(s.getStartedAt().toString())
            .lastActivity(s.getLastActivity().toString())
            .isRecovered(s.getIsRecovered())
            .build();
    }
}
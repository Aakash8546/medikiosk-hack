package com.medikiosk.repository;

import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.model.enums.SessionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PatientSessionRepository extends JpaRepository<PatientSession, UUID> {
    List<PatientSession> findByPatientIdAndStatusNot(UUID patientId, SessionStatus status);

    @Query("SELECT s FROM PatientSession s WHERE s.status NOT IN ('SUBMITTED','EXPIRED','ABANDONED') " +
           "AND s.lastActivity < :cutoff")
    List<PatientSession> findExpiredSessions(LocalDateTime cutoff);

    Optional<PatientSession> findByPatientIdAndStatusIn(UUID patientId, List<SessionStatus> statuses);

    
    @Query("SELECT s FROM PatientSession s JOIN FETCH s.patient "
         + "WHERE s.status NOT IN ('SUBMITTED','EXPIRED')")
    List<PatientSession> findActiveQueueWithPatient();
}
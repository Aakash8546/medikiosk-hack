package com.medikiosk.repository;

import com.medikiosk.model.entity.ConsentRecord;
import com.medikiosk.model.enums.ConsentStatus;
import com.medikiosk.model.enums.ConsentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConsentRecordRepository extends JpaRepository<ConsentRecord, UUID> {

    List<ConsentRecord> findBySessionId(UUID sessionId);

    Optional<ConsentRecord> findBySessionIdAndConsentType(UUID sessionId, ConsentType consentType);

    boolean existsBySessionIdAndConsentTypeAndStatus(
        UUID sessionId, ConsentType consentType, ConsentStatus status);

    List<ConsentRecord> findByPatientIdAndStatus(UUID patientId, ConsentStatus status);
}
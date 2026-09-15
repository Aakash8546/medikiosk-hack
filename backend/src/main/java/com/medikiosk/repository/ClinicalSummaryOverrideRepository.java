package com.medikiosk.repository;

import com.medikiosk.model.entity.ClinicalSummaryOverride;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClinicalSummaryOverrideRepository extends JpaRepository<ClinicalSummaryOverride, UUID> {
    Optional<ClinicalSummaryOverride> findBySessionId(UUID sessionId);
}
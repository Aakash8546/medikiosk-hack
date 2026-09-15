package com.medikiosk.repository;

import com.medikiosk.model.entity.ClinicalHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClinicalHistoryRepository extends JpaRepository<ClinicalHistory, UUID> {
    Optional<ClinicalHistory> findBySessionId(UUID sessionId);

    List<ClinicalHistory> findBySessionIdIn(Collection<UUID> sessionIds);
}
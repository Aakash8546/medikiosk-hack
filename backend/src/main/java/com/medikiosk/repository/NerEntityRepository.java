package com.medikiosk.repository;

import com.medikiosk.model.entity.NerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface NerEntityRepository extends JpaRepository<NerEntity, UUID> {

    List<NerEntity> findBySessionId(UUID sessionId);

    List<NerEntity> findBySessionIdAndEntityLabel(UUID sessionId, String entityLabel);

    @Query("SELECT e FROM NerEntity e WHERE e.sessionId = :sessionId ORDER BY e.confidence DESC NULLS LAST")
    List<NerEntity> findBySessionIdOrderByConfidenceDesc(UUID sessionId);

    void deleteBySessionId(UUID sessionId);
}
package com.medikiosk.repository;

import com.medikiosk.model.entity.SessionVitals;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SessionVitalsRepository extends JpaRepository<SessionVitals, UUID> {
    Optional<SessionVitals> findBySessionId(UUID sessionId);
}
package com.medikiosk.repository;

import com.medikiosk.model.entity.Consultation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ConsultationRepository extends JpaRepository<Consultation, UUID> {
    Optional<Consultation> findBySessionId(UUID sessionId);
}
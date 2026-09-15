package com.medikiosk.repository;

import com.medikiosk.model.entity.AyushAssessment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AyushAssessmentRepository extends JpaRepository<AyushAssessment, UUID> {
    Optional<AyushAssessment> findBySessionId(UUID sessionId);

    List<AyushAssessment> findBySessionIdIn(Collection<UUID> sessionIds);
}
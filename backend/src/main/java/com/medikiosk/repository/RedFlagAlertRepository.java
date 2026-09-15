package com.medikiosk.repository;

import com.medikiosk.model.entity.RedFlagAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public interface RedFlagAlertRepository extends JpaRepository<RedFlagAlert, UUID> {
    List<RedFlagAlert> findBySessionId(UUID sessionId);
    List<RedFlagAlert> findByStatus(String status);

    
    @Query("SELECT DISTINCT a.session.id FROM RedFlagAlert a WHERE a.status = 'ACTIVE'")
    Set<UUID> findSessionIdsWithActiveAlerts();
}
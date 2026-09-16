package com.medikiosk.service;

import com.medikiosk.model.entity.AuditLog;
import com.medikiosk.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.MDC;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditRepo;

    @Async
    public void log(String actorType, UUID actorId, String action,
                    String resourceType, UUID resourceId,
                    UUID sessionId, Map<String, Object> metadata) {
        AuditLog entry = AuditLog.builder()
            .actorType(actorType)
            .actorId(actorId)
            .action(action)
            .resourceType(resourceType)
            .resourceId(resourceId)
            .sessionId(sessionId)
            .metadata(metadata)
            .correlationId(MDC.get("correlationId"))
            .build();
        auditRepo.save(entry);
    }
}
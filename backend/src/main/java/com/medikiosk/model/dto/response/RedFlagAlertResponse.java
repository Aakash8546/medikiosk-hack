package com.medikiosk.model.dto.response;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RedFlagAlertResponse {
    private UUID id;
    private UUID sessionId;
    private String ruleCode;
    private String ruleName;
    private String severity;
    private String status;
    private String triggeredBy;
    private String triageNotes;
    private LocalDateTime createdAt;
}
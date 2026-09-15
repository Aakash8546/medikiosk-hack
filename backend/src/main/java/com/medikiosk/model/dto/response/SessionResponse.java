package com.medikiosk.model.dto.response;

import lombok.*;
import java.util.UUID;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class SessionResponse {
    private UUID id;
    private UUID patientId;
    private String sessionType;
    private String language;
    private String status;
    private String startedAt;
    private String lastActivity;
    private Boolean isRecovered;
}
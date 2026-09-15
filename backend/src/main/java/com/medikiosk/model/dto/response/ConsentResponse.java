package com.medikiosk.model.dto.response;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConsentResponse {
    private String id;
    private String sessionId;
    private String consentType;
    private String status;
    private String consentTextEn;
    private String consentTextHi;
    private String acceptedAt;
    private String revokedAt;
    private Boolean isMinorConsent;
}
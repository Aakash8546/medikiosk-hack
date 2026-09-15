package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D8RedFlagAlertResponse {
    private UUID sessionId;
    private boolean hasRedFlags;
    private String alertLevel; 
    private int aiConfidence;
    private Map<String, String> vitalSignsMini;
    private List<FlagItem> detectedFlags;
    private List<AlertItem> alerts;
    private List<String> aiRiskAssessment;
    private String recommendedAction;
    private boolean consentActive;

    @Data @AllArgsConstructor @NoArgsConstructor @Builder
    public static class FlagItem {
        private String alertId;
        private String symptom;
        private String description;
        private String severity; 
    }

    @Data @AllArgsConstructor @NoArgsConstructor @Builder
    public static class AlertItem {
        private String alertId;
        private String ruleName;
        private String severity; 
        private String triggeredBy;
    }
}
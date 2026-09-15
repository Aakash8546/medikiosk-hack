package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D2PatientDetailResponse {
    private UUID sessionId;
    private UUID patientId;
    private String tokenNumber;
    private String patientName;
    private String abhaId;
    private int age;
    private String gender;
    private String language;
    private String priority;
    private boolean consentGranted;
    private String sessionType;
    private String prakritiBadge;
    private boolean hasRedFlag;
    private List<String> redFlagSymptoms;
    private List<String> drugInteractionWarnings;
}
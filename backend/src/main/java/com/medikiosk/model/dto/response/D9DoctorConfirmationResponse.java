package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D9DoctorConfirmationResponse {
    private UUID sessionId;
    private String patientName;
    private String abhaId;
    private String tokenNumber;
    private boolean aiSummaryVerified;
    private int modificationsCount;
    private String chiefComplaintSummary;
    private String ayushAssessmentSummary;
    private List<String> prescribedMedications;
    private List<String> drugInteractionWarnings;
    private List<String> icdCodesConfirmed;
    private List<String> allergies;
}
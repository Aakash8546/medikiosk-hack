package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;


@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D7ConsultationNotesResponse {
    private UUID sessionId;
    private UUID patientId;
    private String patientName;
    private String abhaId;
    private String tokenNumber;
    
    private String subjective;
    
    private String objective;
    
    private String assessment;
    
    private String plan;
    private List<String> suggestedIcd10Codes;
    private List<String> suggestedIcdTm2Codes;
    private List<String> currentMedications;
    private List<String> allergies;
    private List<String> drugInteractionWarnings;
    private int followUpDays;
    private String status;      
    private String disclaimer;
}
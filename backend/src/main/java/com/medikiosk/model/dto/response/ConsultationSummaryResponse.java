package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConsultationSummaryResponse {
    private UUID consultationId;
    private UUID sessionId;
    private UUID patientId;
    private String patientName;
    private String clinicalImpression;
    private List<String> icd10Codes;
    private List<String> icdTm2Codes;
    private List<MapItem> prescriptions;
    private List<String> investigationsOrdered;
    private List<String> drugInteractionWarnings;
    private int followUpDays;
    private String followUpNotes;
    private String status; 
    private String completedAt;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class MapItem {
        private String medicineName;
        private String dosage;
        private String timing;
        private int durationDays;
        private boolean isAyurvedic;
    }
}
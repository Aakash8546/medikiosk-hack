package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D4AiClinicalSummaryResponse {
    private UUID sessionId;
    private String patientName;
    private String abhaId;
    
    
    private String hpiSummary;
    private int hpiConfidence;
    
    
    private Map<String, String> vitalsSummary;
    private int vitalsConfidence;
    
    
    private List<String> pastMedicalHistory;
    private int pastHistoryConfidence;
    
    
    private int totalMedications;
    private int totalAllergies;
    private int totalComplaints;
    
    
    private String prakritiSummary;
    private String agniSummary;
    private String vikritiSummary;
    private String lifestyleScore;
    private int ayushConfidence;
    
    
    private List<String> drugInteractions;
    private String disclaimer;

    public static D4AiClinicalSummaryResponseBuilder builder() { return new D4AiClinicalSummaryResponseBuilder(); }
    public static class D4AiClinicalSummaryResponseBuilder {
        private UUID sessionId; private String patientName; private String abhaId; private String hpiSummary; private int hpiConfidence;
        private Map<String, String> vitalsSummary; private int vitalsConfidence; private List<String> pastMedicalHistory; private int pastHistoryConfidence;
        private int totalMedications; private int totalAllergies; private int totalComplaints; private String prakritiSummary; private String agniSummary;
        private String vikritiSummary; private String lifestyleScore; private int ayushConfidence; private List<String> drugInteractions; private String disclaimer;

        public D4AiClinicalSummaryResponseBuilder sessionId(UUID sessionId) { this.sessionId = sessionId; return this; }
        public D4AiClinicalSummaryResponseBuilder patientName(String patientName) { this.patientName = patientName; return this; }
        public D4AiClinicalSummaryResponseBuilder abhaId(String abhaId) { this.abhaId = abhaId; return this; }
        public D4AiClinicalSummaryResponseBuilder hpiSummary(String hpiSummary) { this.hpiSummary = hpiSummary; return this; }
        public D4AiClinicalSummaryResponseBuilder hpiConfidence(int hpiConfidence) { this.hpiConfidence = hpiConfidence; return this; }
        public D4AiClinicalSummaryResponseBuilder vitalsSummary(Map<String, String> vitalsSummary) { this.vitalsSummary = vitalsSummary; return this; }
        public D4AiClinicalSummaryResponseBuilder vitalsConfidence(int vitalsConfidence) { this.vitalsConfidence = vitalsConfidence; return this; }
        public D4AiClinicalSummaryResponseBuilder pastMedicalHistory(List<String> pastMedicalHistory) { this.pastMedicalHistory = pastMedicalHistory; return this; }
        public D4AiClinicalSummaryResponseBuilder pastHistoryConfidence(int pastHistoryConfidence) { this.pastHistoryConfidence = pastHistoryConfidence; return this; }
        public D4AiClinicalSummaryResponseBuilder totalMedications(int totalMedications) { this.totalMedications = totalMedications; return this; }
        public D4AiClinicalSummaryResponseBuilder totalAllergies(int totalAllergies) { this.totalAllergies = totalAllergies; return this; }
        public D4AiClinicalSummaryResponseBuilder totalComplaints(int totalComplaints) { this.totalComplaints = totalComplaints; return this; }
        public D4AiClinicalSummaryResponseBuilder prakritiSummary(String prakritiSummary) { this.prakritiSummary = prakritiSummary; return this; }
        public D4AiClinicalSummaryResponseBuilder agniSummary(String agniSummary) { this.agniSummary = agniSummary; return this; }
        public D4AiClinicalSummaryResponseBuilder vikritiSummary(String vikritiSummary) { this.vikritiSummary = vikritiSummary; return this; }
        public D4AiClinicalSummaryResponseBuilder lifestyleScore(String lifestyleScore) { this.lifestyleScore = lifestyleScore; return this; }
        public D4AiClinicalSummaryResponseBuilder ayushConfidence(int ayushConfidence) { this.ayushConfidence = ayushConfidence; return this; }
        public D4AiClinicalSummaryResponseBuilder drugInteractions(List<String> drugInteractions) { this.drugInteractions = drugInteractions; return this; }
        public D4AiClinicalSummaryResponseBuilder disclaimer(String disclaimer) { this.disclaimer = disclaimer; return this; }

        public D4AiClinicalSummaryResponse build() {
            D4AiClinicalSummaryResponse r = new D4AiClinicalSummaryResponse();
            r.sessionId = this.sessionId; r.patientName = this.patientName; r.abhaId = this.abhaId; r.hpiSummary = this.hpiSummary;
            r.hpiConfidence = this.hpiConfidence; r.vitalsSummary = this.vitalsSummary; r.vitalsConfidence = this.vitalsConfidence;
            r.pastMedicalHistory = this.pastMedicalHistory; r.pastHistoryConfidence = this.pastHistoryConfidence; r.totalMedications = this.totalMedications;
            r.totalAllergies = this.totalAllergies; r.totalComplaints = this.totalComplaints; r.prakritiSummary = this.prakritiSummary;
            r.agniSummary = this.agniSummary; r.vikritiSummary = this.vikritiSummary; r.lifestyleScore = this.lifestyleScore;
            r.ayushConfidence = this.ayushConfidence; r.drugInteractions = this.drugInteractions; r.disclaimer = this.disclaimer;
            return r;
        }
    }
}
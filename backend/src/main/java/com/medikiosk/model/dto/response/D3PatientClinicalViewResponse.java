package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D3PatientClinicalViewResponse {
    private UUID sessionId;
    private UUID patientId;
    private String patientName;
    private String abhaId;
    private String ageGenderAbha;
    private String consentStatusBanner;
    private Map<String, String> vitalsGrid;
    private List<String> chiefComplaints;
    private String prakritiSnapshot;
    private List<String> currentMedications;
    private List<String> familyHistory;
    private List<String> allergies;

    public static D3PatientClinicalViewResponseBuilder builder() { return new D3PatientClinicalViewResponseBuilder(); }
    public static class D3PatientClinicalViewResponseBuilder {
        private UUID sessionId; private UUID patientId; private String patientName; private String abhaId;
        private String ageGenderAbha;
        private String consentStatusBanner; private Map<String, String> vitalsGrid; private List<String> chiefComplaints;
        private String prakritiSnapshot; private List<String> currentMedications; private List<String> familyHistory; private List<String> allergies;

        public D3PatientClinicalViewResponseBuilder sessionId(UUID sessionId) { this.sessionId = sessionId; return this; }
        public D3PatientClinicalViewResponseBuilder patientId(UUID patientId) { this.patientId = patientId; return this; }
        public D3PatientClinicalViewResponseBuilder patientName(String patientName) { this.patientName = patientName; return this; }
        public D3PatientClinicalViewResponseBuilder abhaId(String abhaId) { this.abhaId = abhaId; return this; }
        public D3PatientClinicalViewResponseBuilder ageGenderAbha(String ageGenderAbha) { this.ageGenderAbha = ageGenderAbha; return this; }
        public D3PatientClinicalViewResponseBuilder consentStatusBanner(String consentStatusBanner) { this.consentStatusBanner = consentStatusBanner; return this; }
        public D3PatientClinicalViewResponseBuilder vitalsGrid(Map<String, String> vitalsGrid) { this.vitalsGrid = vitalsGrid; return this; }
        public D3PatientClinicalViewResponseBuilder chiefComplaints(List<String> chiefComplaints) { this.chiefComplaints = chiefComplaints; return this; }
        public D3PatientClinicalViewResponseBuilder prakritiSnapshot(String prakritiSnapshot) { this.prakritiSnapshot = prakritiSnapshot; return this; }
        public D3PatientClinicalViewResponseBuilder currentMedications(List<String> currentMedications) { this.currentMedications = currentMedications; return this; }
        public D3PatientClinicalViewResponseBuilder familyHistory(List<String> familyHistory) { this.familyHistory = familyHistory; return this; }
        public D3PatientClinicalViewResponseBuilder allergies(List<String> allergies) { this.allergies = allergies; return this; }

        public D3PatientClinicalViewResponse build() {
            D3PatientClinicalViewResponse r = new D3PatientClinicalViewResponse();
            r.sessionId = this.sessionId; r.patientId = this.patientId; r.patientName = this.patientName; r.abhaId = this.abhaId;
            r.ageGenderAbha = this.ageGenderAbha; r.consentStatusBanner = this.consentStatusBanner; r.vitalsGrid = this.vitalsGrid; r.chiefComplaints = this.chiefComplaints;
            r.prakritiSnapshot = this.prakritiSnapshot; r.currentMedications = this.currentMedications; r.familyHistory = this.familyHistory; r.allergies = this.allergies;
            return r;
        }
    }
}
package com.medikiosk.model.dto.request;

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
public class EditClinicalSummaryRequest {
    private UUID sessionId;
    private String chiefComplaint;
    private String doctorNotes;
    private String historyOfPresentIllness;
    private String pastMedicalHistory;
    private List<String> familyHistory;
    private String ayushObservations;
    private List<String> reviewOfSystemsChecked;
    private List<String> differentialDiagnoses;
}
package com.medikiosk.model.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.Valid;
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
public class SaveConsultationNotesRequest {
    private UUID sessionId;
    
    private UUID patientId;
    
    @JsonAlias({"diagnosis", "clinicalImpression"})
    private String clinicalImpression;
    private List<String> icd10Codes;
    private List<String> icdTm2Codes; 

    @Valid
    private List<PrescriptionItemRequest> prescriptions;
    private List<String> investigationsOrdered;
    private int followUpDays;
    
    @JsonAlias({"doctorNotes", "followUpNotes"})
    private String followUpNotes;
}
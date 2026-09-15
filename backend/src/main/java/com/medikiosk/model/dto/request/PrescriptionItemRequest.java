package com.medikiosk.model.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PrescriptionItemRequest {
    @JsonAlias({"drugName", "medicineName"})
    private String medicineName;
    private String dosage;       
    @JsonAlias({"frequency", "timing"})
    private String timing;       
    private Integer durationDays;
    private boolean isAyurvedic;
}
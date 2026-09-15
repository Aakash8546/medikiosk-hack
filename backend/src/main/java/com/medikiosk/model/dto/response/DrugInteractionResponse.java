package com.medikiosk.model.dto.response;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DrugInteractionResponse {
    private UUID id;
    private String drugA;
    private String drugB;
    private String severity;
    private String description;
    private String clinicalEffect;
    private String recommendation;
}
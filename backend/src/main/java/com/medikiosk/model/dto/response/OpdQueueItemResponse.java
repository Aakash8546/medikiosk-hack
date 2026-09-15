package com.medikiosk.model.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OpdQueueItemResponse {
    private UUID sessionId;
    private UUID patientId;
    private String tokenNumber;
    private String patientName;
    private int age;
    private String gender;
    private String abhaId;
    private String sessionType; 
    private String priority;    
    @JsonProperty("isRedFlag")
    private boolean isRedFlag;
    private String primarySymptom;
    private String prakritiBadge;
    private String status;        
    private String startedAt;
}
package com.medikiosk.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;
import java.util.UUID;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateVitalsRequest {
    private UUID sessionId;
    
    
    private String bloodPressure;     
    private Double temperature;        
    private Integer heartRate;         
    private Integer spo2;              
    private Integer respiratoryRate;   
    private Double weight;             
    private Double height;             
    private Double bloodGlucose;       
    private Integer painScale;         
    
    
    private Map<String, String> additionalVitals;
}
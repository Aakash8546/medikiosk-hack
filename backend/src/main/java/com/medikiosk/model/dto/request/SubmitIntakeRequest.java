package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.util.List;
import java.util.Map;


@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class SubmitIntakeRequest {

    @NotBlank(message = "Session ID is required")
    private String sessionId;

    
    private Map<String, Object> structuredHistory;

    
    private String finalSummary;

    
    private List<String> redFlags;
}
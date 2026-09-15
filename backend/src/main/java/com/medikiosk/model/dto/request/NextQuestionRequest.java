package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NextQuestionRequest {
    @NotBlank(message = "Session ID is required")
    private String sessionId;

    private String lastAnsweredQuestionId;
    private String sessionType;            
    private String language;               
}
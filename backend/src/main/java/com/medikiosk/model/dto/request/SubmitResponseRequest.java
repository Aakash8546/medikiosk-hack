package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubmitResponseRequest {
    @NotBlank(message = "Session ID is required")
    private String sessionId;

    @NotBlank(message = "Question ID is required")
    private String questionId;

    private String answerText;
    private List<String> answerChoices;
    private java.math.BigDecimal answerNumeric;
    private Boolean isVoiceInput;
    private String rawTranscript;
    private Double confidenceScore;
    private String language;
}
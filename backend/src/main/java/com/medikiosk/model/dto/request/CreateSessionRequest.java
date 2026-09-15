package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import java.util.UUID;

@Data @NoArgsConstructor @AllArgsConstructor
public class CreateSessionRequest {
    @NotNull(message = "Patient ID is required")
    private UUID patientId;

    @NotBlank(message = "Session type is required")
    @Pattern(regexp = "GENERAL|AYUSH", message = "Session type must be GENERAL or AYUSH")
    private String sessionType;

    @NotBlank(message = "Language is required")
    @Pattern(regexp = "hi|en", message = "Language must be hi or en")
    private String language;
}
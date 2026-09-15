package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CreatePatientRequest {
    private String abhaId;

    @NotBlank(message = "Full name is required")
    private String fullName;

    private String dateOfBirth;     
    private String gender;          

    private String phone;
    private String phoneNumber;     

    public String getPhone() {
        String p = (phone != null && !phone.isBlank()) ? phone : phoneNumber;
        if (p == null) return null;
        String cleaned = p.replaceAll("[^0-9]", "");
        if (cleaned.length() == 12 && cleaned.startsWith("91")) {
            return cleaned.substring(2);
        }
        return cleaned;
    }

    private String address;
    private Boolean isMinor;
    private String guardianPhone;
    private String preferredLanguage;
}
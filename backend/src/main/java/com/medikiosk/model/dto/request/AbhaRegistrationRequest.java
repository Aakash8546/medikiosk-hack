package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AbhaRegistrationRequest {

    @NotBlank(message = "Transaction ID is required")
    private String txnId;

    private String phone;
    private String address;
    private String preferredLanguage;
}
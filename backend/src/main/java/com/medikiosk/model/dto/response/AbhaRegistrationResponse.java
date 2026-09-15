package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AbhaRegistrationResponse {
    private UUID patientId;
    private String abhaId;
    private String fullName;
    private String dateOfBirth;
    private String gender;
    private String phone;
    private String address;
    private String message;
    @Builder.Default
    private boolean isMock = true;
}
package com.medikiosk.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConsentRequest {

    @NotBlank(message = "Session ID is required")
    private String sessionId;

    @NotBlank(message = "Consent type is required")
    @Pattern(regexp = "DATA_COLLECTION|AI_PROCESSING|CLINICAL_SUMMARY|ABDM_SHARE|GUARDIAN_ON_BEHALF",
             message = "Invalid consent type")
    private String consentType;

    @NotBlank(message = "Decision is required")
    @Pattern(regexp = "ACCEPTED|DECLINED", message = "Decision must be ACCEPTED or DECLINED")
    private String decision;

    
    private String guardianName;
    private String guardianPhone;
    private String guardianRelation;

    
    public String getSessionId() { return sessionId; }
    public String getConsentType() { return consentType; }
    public String getDecision() { return decision; }
    public String getGuardianName() { return guardianName; }
    public String getGuardianPhone() { return guardianPhone; }
    public String getGuardianRelation() { return guardianRelation; }

    public void setSessionId(String sessionId) { this.sessionId = sessionId; }
    public void setConsentType(String consentType) { this.consentType = consentType; }
    public void setDecision(String decision) { this.decision = decision; }
    public void setGuardianName(String guardianName) { this.guardianName = guardianName; }
    public void setGuardianPhone(String guardianPhone) { this.guardianPhone = guardianPhone; }
    public void setGuardianRelation(String guardianRelation) { this.guardianRelation = guardianRelation; }
}
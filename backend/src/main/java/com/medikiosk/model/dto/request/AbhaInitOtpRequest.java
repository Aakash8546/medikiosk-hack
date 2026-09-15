package com.medikiosk.model.dto.request;

public class AbhaInitOtpRequest {
    private String abhaId;
    private String authMethod;

    public AbhaInitOtpRequest() {}

    public AbhaInitOtpRequest(String abhaId, String authMethod) {
        this.abhaId = abhaId;
        this.authMethod = authMethod;
    }

    public String getAbhaId() { return abhaId; }
    public String getAuthMethod() { return authMethod; }

    public void setAbhaId(String abhaId) { this.abhaId = abhaId; }
    public void setAuthMethod(String authMethod) { this.authMethod = authMethod; }

    public static AbhaInitOtpRequestBuilder builder() { return new AbhaInitOtpRequestBuilder(); }

    public static class AbhaInitOtpRequestBuilder {
        private String abhaId = "";
        private String authMethod = "MOBILE_OTP";

        public AbhaInitOtpRequestBuilder abhaId(String abhaId) { this.abhaId = abhaId; return this; }
        public AbhaInitOtpRequestBuilder authMethod(String authMethod) { this.authMethod = authMethod; return this; }

        public AbhaInitOtpRequest build() {
            return new AbhaInitOtpRequest(this.abhaId, this.authMethod);
        }
    }
}
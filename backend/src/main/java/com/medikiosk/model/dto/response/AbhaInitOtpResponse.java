package com.medikiosk.model.dto.response;

public class AbhaInitOtpResponse {
    private String txnId;
    private String message;
    private String maskedMobile;
    private Boolean isMock;

    public AbhaInitOtpResponse() {}

    public AbhaInitOtpResponse(String txnId, String message, String maskedMobile, Boolean isMock) {
        this.txnId = txnId;
        this.message = message;
        this.maskedMobile = maskedMobile;
        this.isMock = isMock;
    }

    public String getTxnId() { return txnId; }
    public String getMessage() { return message; }
    public String getMaskedMobile() { return maskedMobile; }
    public Boolean getIsMock() { return isMock; }

    public void setTxnId(String txnId) { this.txnId = txnId; }
    public void setMessage(String message) { this.message = message; }
    public void setMaskedMobile(String maskedMobile) { this.maskedMobile = maskedMobile; }
    public void setIsMock(Boolean isMock) { this.isMock = isMock; }

    public static AbhaInitOtpResponseBuilder builder() { return new AbhaInitOtpResponseBuilder(); }

    public static class AbhaInitOtpResponseBuilder {
        private String txnId = "";
        private String message = "OTP sent to registered mobile number successfully.";
        private String maskedMobile = "XXXXXX9876";
        private Boolean isMock = true;

        public AbhaInitOtpResponseBuilder txnId(String txnId) { this.txnId = txnId; return this; }
        public AbhaInitOtpResponseBuilder message(String message) { this.message = message; return this; }
        public AbhaInitOtpResponseBuilder maskedMobile(String maskedMobile) { this.maskedMobile = maskedMobile; return this; }
        public AbhaInitOtpResponseBuilder isMock(Boolean isMock) { this.isMock = isMock; return this; }

        public AbhaInitOtpResponse build() {
            return new AbhaInitOtpResponse(this.txnId, this.message, this.maskedMobile, this.isMock);
        }
    }
}
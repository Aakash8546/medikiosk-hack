package com.medikiosk.model.dto.request;

public class AbhaVerifyOtpRequest {
    private String txnId;
    private String otp;
    private String abhaId;

    public AbhaVerifyOtpRequest() {}

    public AbhaVerifyOtpRequest(String txnId, String otp, String abhaId) {
        this.txnId = txnId;
        this.otp = otp;
        this.abhaId = abhaId;
    }

    public String getTxnId() { return txnId; }
    public String getOtp() { return otp; }
    public String getAbhaId() { return abhaId; }

    public void setTxnId(String txnId) { this.txnId = txnId; }
    public void setOtp(String otp) { this.otp = otp; }
    public void setAbhaId(String abhaId) { this.abhaId = abhaId; }

    public static AbhaVerifyOtpRequestBuilder builder() { return new AbhaVerifyOtpRequestBuilder(); }

    public static class AbhaVerifyOtpRequestBuilder {
        private String txnId = "";
        private String otp = "";
        private String abhaId = "";

        public AbhaVerifyOtpRequestBuilder txnId(String txnId) { this.txnId = txnId; return this; }
        public AbhaVerifyOtpRequestBuilder otp(String otp) { this.otp = otp; return this; }
        public AbhaVerifyOtpRequestBuilder abhaId(String abhaId) { this.abhaId = abhaId; return this; }

        public AbhaVerifyOtpRequest build() {
            return new AbhaVerifyOtpRequest(this.txnId, this.otp, this.abhaId);
        }
    }
}
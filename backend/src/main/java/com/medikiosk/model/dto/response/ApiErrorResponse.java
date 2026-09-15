package com.medikiosk.model.dto.response;

import lombok.*;

@Data 
@NoArgsConstructor 
@AllArgsConstructor
public class ApiErrorResponse {
    private int status;
    private String error;
    private String message;
    private String errorCode;
    private String correlationId;
    private String timestamp;

    public int getStatus() { return status; }
    public String getError() { return error; }
    public String getMessage() { return message; }
    public String getErrorCode() { return errorCode; }
    public String getCorrelationId() { return correlationId; }
    public String getTimestamp() { return timestamp; }

    public void setStatus(int status) { this.status = status; }
    public void setError(String error) { this.error = error; }
    public void setMessage(String message) { this.message = message; }
    public void setErrorCode(String errorCode) { this.errorCode = errorCode; }
    public void setCorrelationId(String correlationId) { this.correlationId = correlationId; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }

    public static ApiErrorResponseBuilder builder() { return new ApiErrorResponseBuilder(); }

    public static class ApiErrorResponseBuilder {
        private int status;
        private String error;
        private String message;
        private String errorCode;
        private String correlationId;
        private String timestamp;

        public ApiErrorResponseBuilder status(int status) { this.status = status; return this; }
        public ApiErrorResponseBuilder error(String error) { this.error = error; return this; }
        public ApiErrorResponseBuilder message(String message) { this.message = message; return this; }
        public ApiErrorResponseBuilder errorCode(String errorCode) { this.errorCode = errorCode; return this; }
        public ApiErrorResponseBuilder correlationId(String correlationId) { this.correlationId = correlationId; return this; }
        public ApiErrorResponseBuilder timestamp(String timestamp) { this.timestamp = timestamp; return this; }

        public ApiErrorResponse build() {
            ApiErrorResponse res = new ApiErrorResponse();
            res.status = this.status;
            res.error = this.error;
            res.message = this.message;
            res.errorCode = this.errorCode;
            res.correlationId = this.correlationId;
            res.timestamp = this.timestamp;
            return res;
        }
    }
}
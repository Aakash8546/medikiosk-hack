package com.medikiosk.exception;

public class MediKioskException extends RuntimeException {
    public MediKioskException(String message) {
        super(message);
    }
    public MediKioskException(String message, Throwable cause) {
        super(message, cause);
    }
}
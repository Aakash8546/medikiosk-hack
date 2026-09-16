package com.medikiosk.util;

import java.util.regex.Pattern;

public class PhiSanitizer {

    private static final Pattern PHONE_PATTERN = Pattern.compile("\\b\\d{10}\\b");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}");
    private static final Pattern DOB_PATTERN = Pattern.compile("\\b\\d{4}-\\d{2}-\\d{2}\\b");

    public static String sanitize(String input) {
        if (input == null) {
            return null;
        }
        String sanitized = input;
        sanitized = PHONE_PATTERN.matcher(sanitized).replaceAll("[REDACTED_PHONE]");
        sanitized = EMAIL_PATTERN.matcher(sanitized).replaceAll("[REDACTED_EMAIL]");
        sanitized = DOB_PATTERN.matcher(sanitized).replaceAll("[REDACTED_DATE]");
        return sanitized;
    }
}
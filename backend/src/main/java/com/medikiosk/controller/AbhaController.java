package com.medikiosk.controller;

import com.medikiosk.model.dto.request.AadhaarOtpRequest;
import com.medikiosk.model.dto.request.AbhaInitOtpRequest;
import com.medikiosk.model.dto.request.AbhaRegistrationRequest;
import com.medikiosk.model.dto.request.AbhaVerifyOtpRequest;
import com.medikiosk.model.dto.response.AbhaInitOtpResponse;
import com.medikiosk.model.dto.response.AbhaRegistrationResponse;
import com.medikiosk.model.dto.response.PatientResponse;
import com.medikiosk.service.AbhaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/abha")
@RequiredArgsConstructor
@Tag(name = "ABHA Authentication", description = "ABDM Free Govt Sandbox + Mock OTP Auth for Patient Kiosk Registration")
public class AbhaController {

    private final AbhaService abhaService;

    @PostMapping("/generate-otp")
    @Operation(summary = "Generate OTP via Real ABDM Gateway or Mock Engine")
    public ResponseEntity<AbhaInitOtpResponse> generateOtp(@RequestBody(required = false) Map<String, Object> body) {
        String abhaId = "";
        String authMethod = "MOBILE_OTP";

        if (body != null) {
            if (body.get("abhaId") != null) abhaId = body.get("abhaId").toString().trim();
            if (body.get("authMethod") != null) authMethod = body.get("authMethod").toString().trim();
        }

        AbhaInitOtpRequest req = AbhaInitOtpRequest.builder()
            .abhaId(abhaId)
            .authMethod(authMethod)
            .build();

        return ResponseEntity.ok(abhaService.generateOtp(req));
    }

    @PostMapping("/verify-otp")
    @Operation(summary = "Verify OTP and Auto-Login/Register Patient")
    public ResponseEntity<PatientResponse> verifyOtp(@RequestBody(required = false) Map<String, Object> body) {
        String txnId = "";
        String otp = "";
        String abhaId = "";

        if (body != null) {
            if (body.get("txnId") != null) txnId = body.get("txnId").toString().trim();
            if (body.get("otp") != null) otp = body.get("otp").toString().trim();
            if (body.get("abhaId") != null) abhaId = body.get("abhaId").toString().trim();
        }

        AbhaVerifyOtpRequest req = AbhaVerifyOtpRequest.builder()
            .txnId(txnId)
            .otp(otp)
            .abhaId(abhaId)
            .build();

        return ResponseEntity.ok(abhaService.verifyOtpAndLogin(req));
    }

    @PostMapping("/aadhaar/generate-otp")
    @Operation(summary = "Generate OTP for Aadhaar Verification (Registration or Login)")
    public ResponseEntity<AbhaInitOtpResponse> generateAadhaarOtp(@RequestBody Map<String, Object> body) {
        String aadhaarNumber = body != null && body.get("aadhaarNumber") != null ? body.get("aadhaarNumber").toString().trim() : "";
        String purpose = body != null && body.get("purpose") != null ? body.get("purpose").toString().trim() : "REGISTRATION";

        AadhaarOtpRequest req = AadhaarOtpRequest.builder()
                .aadhaarNumber(aadhaarNumber)
                .purpose(purpose)
                .build();

        return ResponseEntity.ok(abhaService.generateAadhaarOtp(req));
    }

    @PostMapping("/aadhaar/verify-otp")
    @Operation(summary = "Verify Aadhaar OTP for Registration or Login")
    public ResponseEntity<Map<String, Object>> verifyAadhaarOtp(@RequestBody Map<String, Object> body) {
        String txnId = body != null && body.get("txnId") != null ? body.get("txnId").toString().trim() : "";
        String otp = body != null && body.get("otp") != null ? body.get("otp").toString().trim() : "";

        AbhaVerifyOtpRequest req = AbhaVerifyOtpRequest.builder()
                .txnId(txnId)
                .otp(otp)
                .build();

        return ResponseEntity.ok(abhaService.verifyAadhaarOtp(req));
    }

    @PostMapping("/register")
    @Operation(summary = "Register new ABHA account and auto-create Patient")
    public ResponseEntity<AbhaRegistrationResponse> registerAbha(@RequestBody Map<String, Object> body) {
        String txnId = body != null && body.get("txnId") != null ? body.get("txnId").toString().trim() : "";
        String phone = body != null && body.get("phone") != null ? body.get("phone").toString().trim() : "";
        String address = body != null && body.get("address") != null ? body.get("address").toString().trim() : "";
        String lang = body != null && body.get("preferredLanguage") != null ? body.get("preferredLanguage").toString().trim() : "en";

        AbhaRegistrationRequest req = AbhaRegistrationRequest.builder()
                .txnId(txnId)
                .phone(phone)
                .address(address)
                .preferredLanguage(lang)
                .build();

        return ResponseEntity.ok(abhaService.registerAbha(req));
    }

    @GetMapping("/linked-accounts/{phone}")
    @Operation(summary = "Get all ABHA accounts linked to a phone number")
    public ResponseEntity<List<PatientResponse>> getLinkedAccounts(@PathVariable String phone) {
        return ResponseEntity.ok(abhaService.getLinkedAccounts(phone));
    }

    @PostMapping("/face/verify")
    @Operation(summary = "AI Face Recognition Login for Patient")
    public ResponseEntity<PatientResponse> verifyFaceBiometric(@RequestBody(required = false) Map<String, Object> body) {
        return ResponseEntity.ok(abhaService.verifyFaceBiometric(body));
    }

    @PostMapping("/biometric/fingerprint")
    @Operation(summary = "Fingerprint Biometric Scanner Login for Patient")
    public ResponseEntity<PatientResponse> verifyFingerprintBiometric(@RequestBody(required = false) Map<String, Object> body) {
        return ResponseEntity.ok(abhaService.verifyFingerprintBiometric(body));
    }

    @PostMapping("/biometric/enroll-face")
    @Operation(summary = "Enroll Face Embedding for Patient")
    public ResponseEntity<Map<String, Object>> enrollFaceBiometric(@RequestBody(required = false) Map<String, Object> body) {
        return ResponseEntity.ok(abhaService.enrollFaceBiometric(body));
    }

    @PostMapping("/biometric/enroll-fingerprint")
    @Operation(summary = "Enroll Fingerprint Device ID for Patient")
    public ResponseEntity<Map<String, Object>> enrollFingerprintBiometric(@RequestBody(required = false) Map<String, Object> body) {
        return ResponseEntity.ok(abhaService.enrollFingerprintBiometric(body));
    }

    @GetMapping("/biometric/enrollments")
    @Operation(summary = "Get all enrolled face embeddings for AI matching")
    public ResponseEntity<List<Map<String, Object>>> getFaceEnrollments() {
        return ResponseEntity.ok(abhaService.getFaceEnrollments());
    }

    @PostMapping("/biometric/match-fingerprint")
    @Operation(summary = "Match patient by enrolled device fingerprint")
    public ResponseEntity<PatientResponse> matchFingerprintByDevice(@RequestBody(required = false) Map<String, Object> body) {
        return ResponseEntity.ok(abhaService.matchFingerprintByDevice(body));
    }
}


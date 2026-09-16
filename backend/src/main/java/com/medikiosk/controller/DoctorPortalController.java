package com.medikiosk.controller;

import com.medikiosk.model.dto.request.UpdateVitalsRequest;
import com.medikiosk.model.dto.response.*;
import com.medikiosk.service.DoctorPortalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/doctor")
@RequiredArgsConstructor
@Tag(name = "Doctor Portal", description = "Dedicated 1-Screen-1-API Endpoints for Doctor Mobile App (Screens D1 – D11)")
public class DoctorPortalController {

    private final DoctorPortalService doctorPortalService;
    private final com.medikiosk.service.ConsultationService consultationService;

    @GetMapping("/dashboard")
    @Operation(summary = "D1 Screen — Doctor Dashboard & OPD Queue List")
    public ResponseEntity<DoctorDashboardStatsResponse> getDashboardStats(Authentication auth) {
        return ResponseEntity.ok(doctorPortalService.getDoctorDashboardStats(auth.getName()));
    }

    @GetMapping("/patient-detail/{sessionId}")
    @Operation(summary = "D2 Screen — Patient Queue Detail & Basic Info")
    public ResponseEntity<D2PatientDetailResponse> getD2PatientDetail(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD2PatientDetail(sessionId));
    }

    @GetMapping("/clinical-view/{sessionId}")
    @Operation(summary = "D3 Screen — Patient Clinical View (Vitals, Complaints, History)")
    public ResponseEntity<D3PatientClinicalViewResponse> getD3ClinicalView(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD3ClinicalView(sessionId));
    }

    @GetMapping("/ai-summary/{sessionId}")
    @Operation(summary = "D4 Screen — AI Clinical Summary & Confidence Scores")
    public ResponseEntity<D4AiClinicalSummaryResponse> getD4AiSummary(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD4AiSummary(sessionId));
    }

    @GetMapping("/documents/{sessionId}")
    @Operation(summary = "D5 Screen — Medical Documents & OCR Status List")
    public ResponseEntity<D5MedicalDocumentsResponse> getD5Documents(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD5Documents(sessionId));
    }

    @GetMapping("/timeline/{sessionId}")
    @Operation(summary = "D6 Screen — Chronological Medical Timeline")
    public ResponseEntity<D6MedicalTimelineResponse> getD6Timeline(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD6Timeline(sessionId));
    }

    @GetMapping("/consultation-notes/{sessionId}")
    @Operation(summary = "D7 Screen — Consultation Notes (SOAP) pre-filled from kiosk intake")
    public ResponseEntity<D7ConsultationNotesResponse> getD7ConsultationNotes(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD7ConsultationNotes(sessionId));
    }

    @GetMapping("/red-flag-alert/{sessionId}")
    @Operation(summary = "D8 Screen — Red Flag Severity Details & Risk Assessment")
    public ResponseEntity<D8RedFlagAlertResponse> getD8RedFlagAlert(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD8RedFlagAlert(sessionId));
    }

    @GetMapping("/confirmation-summary/{sessionId}")
    @Operation(summary = "D9 Screen — Doctor Confirmation Pre-Submit Review")
    public ResponseEntity<D9DoctorConfirmationResponse> getD9ConfirmationSummary(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD9ConfirmationSummary(sessionId));
    }

    @GetMapping("/completion-status/{sessionId}")
    @Operation(summary = "D11 Screen — Consultation Completion Stats & Next Patient Token")
    public ResponseEntity<D11CompletionStatusResponse> getD11CompletionStatus(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getD11CompletionStatus(sessionId));
    }

    @PostMapping("/vitals/{sessionId}")
    @Operation(summary = "Update Patient Vitals — Doctor / Nurse Manual Vitals Entry")
    public ResponseEntity<String> updateVitals(
            @PathVariable UUID sessionId,
            @RequestBody UpdateVitalsRequest request) {
        request.setSessionId(sessionId);
        doctorPortalService.updateSessionVitals(sessionId, request);
        return ResponseEntity.ok("Vitals updated successfully by Doctor");
    }

    @GetMapping("/ner-entities/{sessionId}")
    @Operation(summary = "NER Entities — AI-extracted medical entities from patient interview answers")
    public ResponseEntity<Map<String, List<String>>> getNerEntities(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(doctorPortalService.getNerEntitiesForSession(sessionId));
    }

    @PostMapping("/consultation-notes/{sessionId}")
    @Operation(summary = "9.2 — Complete Doctor Consultation & Finalize Session")
    public ResponseEntity<Map<String, Object>> completeDoctorConsultation(
            @PathVariable UUID sessionId,
            @RequestBody com.medikiosk.model.dto.request.SaveConsultationNotesRequest req) {
        req.setSessionId(sessionId);
        return ResponseEntity.ok(consultationService.completeDoctorConsultation(req));
    }
}
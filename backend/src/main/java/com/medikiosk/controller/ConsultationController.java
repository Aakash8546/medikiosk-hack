package com.medikiosk.controller;

import com.medikiosk.model.dto.request.EditClinicalSummaryRequest;
import com.medikiosk.model.dto.request.SaveConsultationNotesRequest;
import com.medikiosk.model.dto.response.ConsultationSummaryResponse;
import com.medikiosk.service.ConsultationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/consultation")
@RequiredArgsConstructor
@Tag(name = "Consultation & Notes", description = "Endpoints for Doctor Consultation Notes, ICD-10/TM2 Coding & Rx (D7, D9, D10, D11)")
public class ConsultationController {

    private final ConsultationService consultationService;

    @RequestMapping(value = "/summary/edit", method = {RequestMethod.POST, RequestMethod.PUT})
    @Operation(summary = "D7 — Doctor Edit & Override AI Clinical Summary")
    public ResponseEntity<Map<String, Object>> editClinicalSummary(@RequestBody EditClinicalSummaryRequest req) {
        return ResponseEntity.ok(consultationService.editClinicalSummary(req));
    }

    @PostMapping("/notes")
    @Operation(summary = "D10 & D11 — Save Consultation Notes, ICD Codes, Prescriptions & Finalize Session")
    public ResponseEntity<ConsultationSummaryResponse> saveConsultationNotes(@Valid @RequestBody SaveConsultationNotesRequest req) {
        return ResponseEntity.ok(consultationService.saveConsultationNotes(req));
    }
}
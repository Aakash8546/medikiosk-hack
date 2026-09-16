package com.medikiosk.controller;

import com.medikiosk.model.dto.request.CreatePatientRequest;
import com.medikiosk.model.dto.response.PatientResponse;
import com.medikiosk.service.PatientService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/patients")
@RequiredArgsConstructor
@Tag(name = "Patient", description = "Patient registration and lookup")
public class PatientController {

    private final PatientService patientService;

    @PostMapping
    @Operation(summary = "Register a new patient")
    public ResponseEntity<PatientResponse> create(@Valid @RequestBody CreatePatientRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(patientService.createPatient(request));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get patient by ID")
    public ResponseEntity<PatientResponse> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(patientService.getById(id));
    }

    @GetMapping("/abha/{abhaId}")
    @Operation(summary = "Lookup patient by ABHA ID")
    public ResponseEntity<PatientResponse> getByAbha(@PathVariable String abhaId) {
        return ResponseEntity.ok(patientService.getByAbhaId(abhaId));
    }

    @GetMapping("/phone/{phone}")
    @Operation(summary = "Lookup patient by Phone Number (Re-login)")
    public ResponseEntity<PatientResponse> getByPhone(@PathVariable String phone) {
        return ResponseEntity.ok(patientService.getByPhone(phone));
    }
}
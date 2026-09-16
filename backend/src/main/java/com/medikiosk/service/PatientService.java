package com.medikiosk.service;

import com.medikiosk.exception.*;
import com.medikiosk.model.dto.request.CreatePatientRequest;
import com.medikiosk.model.dto.response.PatientResponse;
import com.medikiosk.model.entity.Patient;
import com.medikiosk.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.time.Period;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PatientService {

    private final PatientRepository patientRepo;
    private final AuditService auditService;

    @Transactional
    public PatientResponse createPatient(CreatePatientRequest req) {
        if (req.getAbhaId() != null && !req.getAbhaId().isBlank() && patientRepo.existsByAbhaId(req.getAbhaId())) {
            throw new DuplicateResourceException("Patient with ABHA ID already exists");
        }

        LocalDate dob = parseDateOfBirth(req.getDateOfBirth());
        boolean isMinor = false;
        if (dob != null) {
            isMinor = Period.between(dob, LocalDate.now()).getYears() < 18;
        }
        if (req.getIsMinor() != null) {
            isMinor = req.getIsMinor();
        }

        Patient patient = Patient.builder()
            .abhaId(req.getAbhaId() != null && !req.getAbhaId().isBlank() ? req.getAbhaId() : null)
            .fullName(req.getFullName())
            .dateOfBirth(dob)
            .gender(req.getGender() != null ? req.getGender().toUpperCase() : "MALE")
            .phone(req.getPhone())
            .address(req.getAddress())
            .isMinor(isMinor)
            .guardianPhone(req.getGuardianPhone())
            .preferredLanguage(req.getPreferredLanguage() != null ? req.getPreferredLanguage() : "en")
            .build();

        patient = patientRepo.save(patient);

        auditService.log("SYSTEM", null, "PATIENT_CREATED",
            "patients", patient.getId(), null,
            Map.of("abhaId", patient.getAbhaId() != null ? "present" : "absent"));

        return toResponse(patient);
    }

    public PatientResponse getById(UUID id) {
        Patient patient = patientRepo.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found: " + id));
        return toResponse(patient);
    }

    public PatientResponse getByAbhaId(String abhaId) {
        if (abhaId == null || abhaId.isBlank()) {
            throw new ResourceNotFoundException("Invalid ABHA ID provided.");
        }

        String raw = abhaId.trim();
        String cleaned = raw.replaceAll("[^0-9a-zA-Z-]", "").trim();
        String digitsOnly = raw.replaceAll("[^0-9]", "");

        
        java.util.Optional<Patient> match = patientRepo.findFirstByAbhaId(raw);
        if (match.isEmpty() && !cleaned.equals(raw)) {
            
            match = patientRepo.findFirstByAbhaId(cleaned);
        }
        if (match.isEmpty() && !digitsOnly.isBlank() && !digitsOnly.equals(cleaned)) {
            
            match = patientRepo.findFirstByAbhaId(digitsOnly);
        }
        if (match.isEmpty() && digitsOnly.length() == 14) {
            
            String hyphenated = digitsOnly.substring(0, 2) + "-" + 
                                digitsOnly.substring(2, 6) + "-" + 
                                digitsOnly.substring(6, 10) + "-" + 
                                digitsOnly.substring(10, 14);
            match = patientRepo.findFirstByAbhaId(hyphenated);
        }
        if (match.isEmpty()) {
            
            String phoneStr = digitsOnly;
            if (phoneStr.length() == 12 && phoneStr.startsWith("91")) {
                phoneStr = phoneStr.substring(2);
            } else if (phoneStr.length() > 10) {
                phoneStr = phoneStr.substring(phoneStr.length() - 10);
            }
            if (phoneStr.length() == 10) {
                match = patientRepo.findFirstByPhone(phoneStr);
            }
        }

        Patient patient = match.orElseThrow(() -> new ResourceNotFoundException("Patient not found with ABHA: " + abhaId));
        return toResponse(patient);
    }

    public PatientResponse getByPhone(String phone) {
        String cleaned = phone != null ? phone.replaceAll("[^0-9]", "") : "";
        if (cleaned.length() == 12 && cleaned.startsWith("91")) {
            cleaned = cleaned.substring(2);
        }
        String finalPhone = cleaned;
        Patient patient = patientRepo.findFirstByPhone(finalPhone)
            .orElseThrow(() -> new ResourceNotFoundException("Patient not found with phone: " + phone));
        return toResponse(patient);
    }

    private LocalDate parseDateOfBirth(String dobStr) {
        if (dobStr == null || dobStr.isBlank()) return null;
        String trimmed = dobStr.trim().replaceAll("\\s+", "");
        try {
            return LocalDate.parse(trimmed);
        } catch (Exception e1) {
            try {
                if (trimmed.contains("/")) {
                    return LocalDate.parse(trimmed, java.time.format.DateTimeFormatter.ofPattern("d/M/yyyy"));
                } else if (trimmed.contains("-")) {
                    return LocalDate.parse(trimmed, java.time.format.DateTimeFormatter.ofPattern("d-M-yyyy"));
                }
            } catch (Exception e2) {
                
            }
        }
        return null;
    }

    private PatientResponse toResponse(Patient p) {
        return PatientResponse.builder()
            .id(p.getId())
            .abhaId(p.getAbhaId())
            .fullName(p.getFullName())
            .dateOfBirth(p.getDateOfBirth() != null ? p.getDateOfBirth().toString() : null)
            .gender(p.getGender())
            .phone(p.getPhone())
            .address(p.getAddress())
            .isMinor(p.getIsMinor())
            .preferredLanguage(p.getPreferredLanguage())
            .createdAt(p.getCreatedAt() != null ? p.getCreatedAt().toString() : java.time.LocalDateTime.now().toString())
            .build();
    }
}
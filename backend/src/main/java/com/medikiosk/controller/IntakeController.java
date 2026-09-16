package com.medikiosk.controller;

import com.medikiosk.model.dto.request.SubmitIntakeRequest;
import com.medikiosk.service.IntakeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/intake")
@RequiredArgsConstructor
@Tag(name = "Kiosk Intake", description = "Submits the completed patient interview to the hospital record")
public class IntakeController {

    private final IntakeService intakeService;

    @PostMapping("/submit")
    @Operation(summary = "Submit the completed clinical history captured at the kiosk")
    public ResponseEntity<Map<String, Object>> submit(@Valid @RequestBody SubmitIntakeRequest request) {
        return ResponseEntity.ok(intakeService.submitIntake(request));
    }
}
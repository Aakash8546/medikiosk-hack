package com.medikiosk.controller;

import com.medikiosk.model.dto.response.RedFlagAlertResponse;
import com.medikiosk.service.RedFlagService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/red-flags")
@RequiredArgsConstructor
public class RedFlagController {

    private final RedFlagService redFlagService;

    @PostMapping("/evaluate/{sessionId}")
    public ResponseEntity<List<RedFlagAlertResponse>> evaluateSession(
            @PathVariable UUID sessionId) {
        return ResponseEntity.ok(redFlagService.evaluateSession(sessionId));
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<List<RedFlagAlertResponse>> getAlertsForSession(
            @PathVariable UUID sessionId) {
        return ResponseEntity.ok(redFlagService.getAlertsForSession(sessionId));
    }

    @RequestMapping(value = "/{alertId}/acknowledge", method = {RequestMethod.POST, RequestMethod.PUT})
    public ResponseEntity<RedFlagAlertResponse> acknowledgeAlert(
            @PathVariable UUID alertId,
            @RequestParam(required = false) String notes,
            @RequestParam(required = false) String acknowledgedBy) {
        return ResponseEntity.ok(redFlagService.acknowledgeAlert(alertId, notes, acknowledgedBy));
    }

    @GetMapping("/active")
    public ResponseEntity<List<RedFlagAlertResponse>> getActiveAlerts() {
        return ResponseEntity.ok(redFlagService.getAllActiveAlerts());
    }
}
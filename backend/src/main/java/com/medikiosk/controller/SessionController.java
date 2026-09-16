package com.medikiosk.controller;

import com.medikiosk.model.dto.request.CreateSessionRequest;
import com.medikiosk.model.dto.response.SessionResponse;
import com.medikiosk.service.SessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/sessions")
@RequiredArgsConstructor
@Tag(name = "Session", description = "Patient intake session management")
public class SessionController {

    private final SessionService sessionService;

    @PostMapping
    @Operation(summary = "Create or recover a patient intake session")
    public ResponseEntity<SessionResponse> create(@Valid @RequestBody CreateSessionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(sessionService.createSession(request));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get session by ID (checks for expiry)")
    public ResponseEntity<SessionResponse> get(@PathVariable UUID id) {
        return ResponseEntity.ok(sessionService.getSession(id));
    }

    @PutMapping("/{id}/touch")
    @Operation(summary = "Reset inactivity timer")
    public ResponseEntity<SessionResponse> touch(@PathVariable UUID id) {
        return ResponseEntity.ok(sessionService.touchSession(id));
    }
}
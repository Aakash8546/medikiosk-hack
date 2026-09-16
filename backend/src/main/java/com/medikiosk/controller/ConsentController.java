package com.medikiosk.controller;

import com.medikiosk.model.dto.request.ConsentRequest;
import com.medikiosk.model.dto.response.ConsentResponse;
import com.medikiosk.service.ConsentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/consent")
@RequiredArgsConstructor
@Tag(name = "Consent", description = "DPDP Act 2023 compliant consent management")
public class ConsentController {

    private final ConsentService consentService;

    @PostMapping
    @Operation(summary = "Record patient consent decision (ACCEPTED/DECLINED)")
    public ResponseEntity<ConsentResponse> recordConsent(@Valid @RequestBody ConsentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(consentService.recordConsent(request));
    }

    @GetMapping("/session/{sessionId}")
    @Operation(summary = "Get all consents for a session")
    public ResponseEntity<List<ConsentResponse>> getSessionConsents(@PathVariable String sessionId) {
        return ResponseEntity.ok(consentService.getSessionConsents(sessionId));
    }

    @DeleteMapping("/session/{sessionId}/type/{consentType}")
    @Operation(summary = "Revoke a previously given consent (DPDP right to withdraw)")
    public ResponseEntity<ConsentResponse> revokeConsent(
            @PathVariable String sessionId,
            @PathVariable String consentType) {
        return ResponseEntity.ok(consentService.revokeConsent(sessionId, consentType));
    }
}
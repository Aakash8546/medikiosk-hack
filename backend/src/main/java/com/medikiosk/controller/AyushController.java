package com.medikiosk.controller;

import com.medikiosk.model.dto.request.AyushAssessmentRequest;
import com.medikiosk.model.dto.response.AyushAssessmentResponse;
import com.medikiosk.service.AyushService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController
@RequestMapping("/ayush")
@RequiredArgsConstructor
@Slf4j
public class AyushController {
    private final AyushService ayushService;

    @PostMapping("/assessment")
    public ResponseEntity<AyushAssessmentResponse> submitAssessment(@RequestBody AyushAssessmentRequest req) {
        return ResponseEntity.ok(ayushService.submitAssessment(req));
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<AyushAssessmentResponse> getAssessmentForSession(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(ayushService.getAssessmentForSession(sessionId));
    }

    @GetMapping("/session/{sessionId}/recommendations")
    public ResponseEntity<com.medikiosk.model.dto.response.AyushRecommendationsResponse> getRecommendationsForSession(@PathVariable UUID sessionId) {
        return ResponseEntity.ok(ayushService.getRecommendationsForSession(sessionId));
    }

    @GetMapping(value = "/session/{sessionId}/pdf", produces = {MediaType.APPLICATION_PDF_VALUE, MediaType.APPLICATION_OCTET_STREAM_VALUE, MediaType.ALL_VALUE})
    public ResponseEntity<byte[]> downloadAyushSummaryPdf(
            @PathVariable UUID sessionId,
            @RequestParam(value = "lang", defaultValue = "en") String lang) {
        log.info("[AYUSH PDF] Download request for session: {}, lang: {}", sessionId, lang);
        try {
            com.medikiosk.model.dto.response.AyushAssessmentResponse assessment = ayushService.getAssessmentForSession(sessionId);
            byte[] pdfBytes = ayushService.generateSummaryPdf(sessionId, lang);
            log.info("[AYUSH PDF] Generated {} bytes for session: {}", pdfBytes.length, sessionId);
            
            String sanitizedName = (assessment.getPatientName() != null ? assessment.getPatientName() : "Patient")
                    .replaceAll("[^a-zA-Z0-9_]", "_");
            String fileName = "Ayush_Prescription_" + sanitizedName + ".pdf";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.set(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"");
            headers.setContentLength(pdfBytes.length);
            return ResponseEntity.ok().headers(headers).body(pdfBytes);
        } catch (Exception e) {
            log.error("[AYUSH PDF] Failed for session {}: {}", sessionId, e.getMessage(), e);
            throw new RuntimeException("PDF generation failed: " + e.getMessage(), e);
        }
    }
}
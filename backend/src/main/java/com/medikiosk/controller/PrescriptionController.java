package com.medikiosk.controller;

import com.medikiosk.service.FastApiClient;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.Map;

@RestController
@RequestMapping("/api/prescription")
@RequiredArgsConstructor
public class PrescriptionController {

    private final FastApiClient fastApiClient;

    @PostMapping(value = "/extract", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> extractPrescription(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "enable_preprocessing", defaultValue = "true") String enablePreprocessing
    ) {
        try {
            byte[] bytes = file.getBytes();
            String filename = file.getOriginalFilename() != null ? file.getOriginalFilename() : "prescription.jpg";
            Map<String, Object> response = fastApiClient.extractPrescription(bytes, filename, enablePreprocessing);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("status", "error", "message", e.getMessage()));
        }
    }
}
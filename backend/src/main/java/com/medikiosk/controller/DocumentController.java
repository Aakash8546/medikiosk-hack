package com.medikiosk.controller;

import com.medikiosk.model.entity.MedicalDocument;
import com.medikiosk.service.DocumentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/documents")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Document OCR & Digitization", description = "Endpoints for uploading prior medical documents & prescriptions")
public class DocumentController {

    private final DocumentService documentService;

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload one or multiple medical documents/prescriptions for OCR & structured timeline extraction")
    public ResponseEntity<Map<String, Object>> uploadDocuments(
            @RequestPart(name = "files", required = false) List<MultipartFile> filesPart,
            @RequestPart(name = "file", required = false) MultipartFile filePart,
            @RequestParam(name = "sessionId", required = false) String sessionIdParam,
            @RequestParam(name = "session_id", required = false) String sessionIdForm) {

        String sessionId = (sessionIdParam != null && !sessionIdParam.isBlank()) ? sessionIdParam : sessionIdForm;

        List<MultipartFile> files = new ArrayList<>();
        if (filesPart != null) files.addAll(filesPart);
        if (filePart != null && !filePart.isEmpty()) files.add(filePart);

        return ResponseEntity.ok(documentService.uploadAndExtract(sessionId, files));
    }

    @GetMapping("/session/{sessionId}")
    @Operation(summary = "List the OCR'd documents already attached to a kiosk session")
    public ResponseEntity<Map<String, Object>> getSessionDocuments(@PathVariable UUID sessionId) {
        List<MedicalDocument> docs = documentService.getSessionDocuments(sessionId);
        return ResponseEntity.ok(Map.of(
                "sessionId", sessionId,
                "page_count", docs.size(),
                "timeline", docs.stream().map(DocumentController::toTimelineEntry).toList()
        ));
    }

    
    private static Map<String, Object> toTimelineEntry(MedicalDocument d) {
        Map<String, Object> m = new java.util.LinkedHashMap<>();
        m.put("document_id", d.getId());
        m.put("source_filename", d.getSourceFilename());
        m.put("document_type", d.getDocumentType());
        m.put("document_date", d.getDocumentDate());
        m.put("normalized_date", d.getNormalizedDate() != null ? d.getNormalizedDate().toString() : null);
        m.put("page_number", d.getPageNumber());
        m.put("diagnoses", d.getDiagnoses() != null ? d.getDiagnoses() : List.of());
        m.put("medications", d.getMedications() != null ? d.getMedications() : List.of());
        m.put("lab_values", d.getLabValues() != null ? d.getLabValues() : List.of());
        m.put("procedures", d.getProcedures() != null ? d.getProcedures() : List.of());
        m.put("raw_text", d.getRawText());
        m.put("ocr_confidence_note", d.getOcrConfidenceNote());
        m.put("image_url", d.getImageUrl());
        return m;
    }
}
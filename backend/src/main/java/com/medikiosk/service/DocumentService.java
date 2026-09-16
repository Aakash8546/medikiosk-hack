package com.medikiosk.service;

import com.medikiosk.exception.MediKioskException;
import com.medikiosk.exception.ServiceUnavailableException;
import com.medikiosk.model.entity.MedicalDocument;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.repository.MedicalDocumentRepository;
import com.medikiosk.repository.PatientSessionRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;


@Service
@Slf4j
public class DocumentService {

    @Value("${fastapi.base-url:http://localhost:8000}")
    private String fastapiBaseUrl;

    private final MedicalDocumentRepository documentRepo;
    private final PatientSessionRepository sessionRepo;
    private final CloudinaryService cloudinaryService;

    
    private final RestTemplate restTemplate;

    public DocumentService(@Qualifier("ocrRestTemplate") RestTemplate restTemplate,
                           MedicalDocumentRepository documentRepo,
                           PatientSessionRepository sessionRepo,
                           CloudinaryService cloudinaryService) {
        this.restTemplate = restTemplate;
        this.documentRepo = documentRepo;
        this.sessionRepo = sessionRepo;
        this.cloudinaryService = cloudinaryService;
    }

    
    @Transactional
    @SuppressWarnings("unchecked")
    public Map<String, Object> uploadAndExtract(String sessionId, List<MultipartFile> files) {
        if (files == null || files.isEmpty()) {
            throw new MediKioskException("No files provided for OCR");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();

        for (MultipartFile f : files) {
            if (f == null || f.isEmpty()) continue;
            final byte[] bytes;
            try {
                bytes = f.getBytes();
            } catch (Exception e) {
                log.error("Failed to read uploaded file '{}'", f.getOriginalFilename(), e);
                throw new MediKioskException("Failed to read uploaded file(s)");
            }
            final String name = f.getOriginalFilename() != null ? f.getOriginalFilename() : "document.png";
            body.add("files", new ByteArrayResource(bytes) {
                @Override
                public String getFilename() {
                    return name;
                }
            });
        }

        if (body.isEmpty()) {
            throw new MediKioskException("No readable files provided for OCR");
        }

        
        
        List<String> imageUrls = new ArrayList<>();
        for (MultipartFile f : files) {
            if (f == null || f.isEmpty()) continue;
            String url = cloudinaryService.upload(f, sessionId != null ? sessionId : "unknown");
            imageUrls.add(url); 
        }

        
        Map<String, Object> result;
        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(
                    fastapiBaseUrl + "/api/v1/documents/upload",
                    new HttpEntity<>(body, headers), Map.class);
            result = response.getBody() != null ? new LinkedHashMap<>(response.getBody()) : new LinkedHashMap<>();
        } catch (Exception e) {
            log.error("OCR call to FastAPI failed: {}", e.getMessage());
            throw new ServiceUnavailableException(
                    "Document OCR service is temporarily unavailable. Please try again.");
        }

        List<Map<String, Object>> timeline =
                (List<Map<String, Object>>) result.getOrDefault("timeline", List.of());

        int saved = persistTimeline(sessionId, timeline, imageUrls);

        result.put("sessionId", sessionId);
        result.put("saved_page_count", saved);
        result.put("persisted", saved > 0);
        return result;
    }

    
    private int persistTimeline(String sessionId, List<Map<String, Object>> timeline,
                                List<String> imageUrls) {
        if (sessionId == null || sessionId.isBlank() || timeline.isEmpty()) return 0;

        UUID sessionUuid;
        try {
            sessionUuid = UUID.fromString(sessionId.trim());
        } catch (IllegalArgumentException e) {
            log.warn("Documents uploaded with a non-UUID sessionId '{}' — OCR returned, nothing stored", sessionId);
            return 0;
        }

        Optional<PatientSession> session = sessionRepo.findById(sessionUuid);
        if (session.isEmpty()) {
            log.warn("Documents uploaded for unknown session {} — OCR returned, nothing stored", sessionUuid);
            return 0;
        }

        List<MedicalDocument> rows = new ArrayList<>();
        for (int i = 0; i < timeline.size(); i++) {
            Map<String, Object> page = timeline.get(i);
            
            String imageUrl = (i < imageUrls.size()) ? imageUrls.get(i) : null;
            rows.add(MedicalDocument.builder()
                    .session(session.get())
                    .sourceFilename(asString(page.get("source_filename")))
                    .documentType(asString(page.get("document_type")))
                    .documentDate(asString(page.get("document_date")))
                    .normalizedDate(parseDate(asString(page.get("normalized_date"))))
                    .pageNumber(asInt(page.get("page_number"), 1))
                    .diagnoses(asStringList(page.get("diagnoses")))
                    .medications(asMapList(page.get("medications")))
                    .labValues(asMapList(page.get("lab_values")))
                    .procedures(asStringList(page.get("procedures")))
                    .rawText(asString(page.get("raw_text")))
                    .ocrConfidenceNote(asString(page.get("ocr_confidence_note")))
                    .ocrStatus("EXTRACTED")
                    .imageUrl(imageUrl)
                    .build());
        }
        documentRepo.saveAll(rows);
        log.info("Stored {} OCR'd document page(s) for session {}", rows.size(), sessionUuid);
        return rows.size();
    }

    @Transactional(readOnly = true)
    public List<MedicalDocument> getSessionDocuments(UUID sessionId) {
        return documentRepo.findBySessionIdOrderedByDate(sessionId);
    }

    
    
    

    private static String asString(Object v) {
        return v == null ? null : String.valueOf(v);
    }

    private static int asInt(Object v, int fallback) {
        if (v instanceof Number n) return n.intValue();
        try {
            return v == null ? fallback : Integer.parseInt(String.valueOf(v).trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    @SuppressWarnings("unchecked")
    private static List<String> asStringList(Object v) {
        if (!(v instanceof List<?> list)) return List.of();
        List<String> out = new ArrayList<>();
        for (Object o : list) if (o != null) out.add(String.valueOf(o));
        return out;
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> asMapList(Object v) {
        if (!(v instanceof List<?> list)) return List.of();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Object o : list) if (o instanceof Map<?, ?> m) out.add((Map<String, Object>) m);
        return out;
    }

    private static LocalDate parseDate(String iso) {
        if (iso == null || iso.isBlank() || "null".equalsIgnoreCase(iso)) return null;
        try {
            return LocalDate.parse(iso.trim());
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
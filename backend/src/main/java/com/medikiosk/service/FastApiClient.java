package com.medikiosk.service;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.Map;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class FastApiClient {

    @Value("${fastapi.base-url:http://localhost:8000}")
    private String fastapiBaseUrl;

    private final RestTemplate restTemplate;

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "asrFallback")
    public String transcribeAudio(byte[] audioBytes, String language) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.set("X-Language", language);

        HttpEntity<byte[]> entity = new HttpEntity<>(audioBytes, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(
            fastapiBaseUrl + "/asr/transcribe", entity, Map.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            return (String) response.getBody().get("transcript");
        }
        return null;
    }

    public String asrFallback(byte[] audioBytes, String language, Throwable ex) {
        log.warn("ASR FastAPI circuit open - falling back to text-only mode. Error: {}", ex.getMessage());
        return null;
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "ttsFallback")
    public byte[] synthesizeSpeech(String text, String language) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        Map<String, String> body = Map.of("text", text, "language", language);
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<byte[]> response = restTemplate.postForEntity(
            fastapiBaseUrl + "/tts/synthesize", entity, byte[].class);

        return response.getStatusCode().is2xxSuccessful() ? response.getBody() : null;
    }

    public byte[] ttsFallback(String text, String language, Throwable ex) {
        log.warn("TTS FastAPI circuit open - no audio prompt. Error: {}", ex.getMessage());
        return null;
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "nerFallback")
    public Map<String, Object> extractMedicalEntities(String text, String language) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        org.springframework.util.MultiValueMap<String, String> body =
            new org.springframework.util.LinkedMultiValueMap<>();
        body.add("text", text);
        body.add("language", language != null ? language : "en");

        HttpEntity<org.springframework.util.MultiValueMap<String, String>> entity =
            new HttpEntity<>(body, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(
            fastapiBaseUrl + "/ner/extract", entity, Map.class);

        return response.getStatusCode().is2xxSuccessful() ? response.getBody() : Map.of();
    }

    public Map<String, Object> nerFallback(String text, String language, Throwable ex) {
        log.warn("NER FastAPI circuit open - storing raw text only. Error: {}", ex.getMessage());
        return Map.of("raw_text", text, "entities", List.of());
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "aiStartFallback")
    public Map<String, Object> startAiInterview(String sessionId, String language) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        org.springframework.util.MultiValueMap<String, String> body = new org.springframework.util.LinkedMultiValueMap<>();
        body.add("language", language != null ? language : "en");

        HttpEntity<org.springframework.util.MultiValueMap<String, String>> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(
                fastapiBaseUrl + "/api/v1/interview/start", entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> res = response.getBody();
                return Map.of(
                    "session_id", res.getOrDefault("session_id", sessionId),
                    "next_question", res.getOrDefault("question_text", "What is your main complaint?"),
                    "question_text", res.getOrDefault("question_text", "What is your main complaint?"),
                    "question_audio_base64", res.getOrDefault("question_audio_base64", ""),
                    "quick_replies", res.getOrDefault("quick_replies", List.of()),
                    "status", res.getOrDefault("status", "in_progress"),
                    "is_completed", false
                );
            }
        } catch (Exception e) {
            log.warn("Direct /api/v1/interview/start failed, retrying fallback format: {}", e.getMessage());
        }

        return Map.of(
            "session_id", sessionId,
            "next_question", "hi".equalsIgnoreCase(language) ? "आपकी मुख्य समस्या क्या है?" : "What is your primary symptom?",
            "is_completed", false
        );
    }

    public Map<String, Object> aiStartFallback(String sessionId, String language, Throwable ex) {
        log.error("AI Interview Start circuit open. Fallback to default prompt. Error: {}", ex.getMessage());
        return Map.of(
            "session_id", sessionId,
            "next_question", "hi".equalsIgnoreCase(language) ? "आपकी मुख्य समस्या क्या है?" : "What is your primary symptom?",
            "fallback", true,
            "is_completed", false
        );
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "aiRespondFallback")
    public Map<String, Object> submitAiResponse(String sessionId, String answerText, String expectedField, String lastQuestion, String language, org.springframework.web.multipart.MultipartFile audioFile) {
        HttpHeaders headers = new HttpHeaders();
        org.springframework.util.MultiValueMap<String, Object> body = new org.springframework.util.LinkedMultiValueMap<>();

        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        if (audioFile != null && !audioFile.isEmpty()) {
            try {
                org.springframework.core.io.ByteArrayResource fileResource = new org.springframework.core.io.ByteArrayResource(audioFile.getBytes()) {
                    @Override
                    public String getFilename() {
                        return audioFile.getOriginalFilename() != null ? audioFile.getOriginalFilename() : "audio.m4a";
                    }
                };
                body.add("audio_file", fileResource);
            } catch (Exception e) {
                log.error("Failed to read audio file bytes: {}", e.getMessage());
            }
        }

        body.add("session_id", sessionId != null ? sessionId : "");
        body.add("text_answer", answerText != null ? answerText : "");

        HttpEntity<org.springframework.util.MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(
                fastapiBaseUrl + "/api/v1/interview/reply", entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> res = response.getBody();
                String status = (String) res.getOrDefault("status", "in_progress");
                boolean isCompleted = "completed".equalsIgnoreCase(status);
                boolean isEmergency = "emergency_stop".equalsIgnoreCase(status);

                Map<String, Object> out = new java.util.HashMap<>();
                out.put("session_id", sessionId);
                out.put("status", status);
                out.put("is_completed", isCompleted);
                out.put("is_emergency", isEmergency);
                out.put("next_question", res.getOrDefault("question_text", isCompleted ? "Interview completed." : ""));
                out.put("question_text", res.getOrDefault("question_text", isCompleted ? "Interview completed." : ""));
                out.put("question_audio_base64", res.getOrDefault("question_audio_base64", ""));
                out.put("quick_replies", res.getOrDefault("quick_replies", List.of()));
                out.put("final_summary", res.getOrDefault("final_summary", Map.of()));
                out.put("structured_history", res.getOrDefault("structured_history", Map.of()));
                out.put("red_flags", res.getOrDefault("red_flags", List.of()));
                return out;
            }
        } catch (org.springframework.web.client.HttpStatusCodeException e) {
            log.error("AI Interview Reply HTTP error {}: {}", e.getStatusCode(), e.getResponseBodyAsString());
            String detailMsg = "AI service error";
            try {
                Map<?, ?> errMap = new com.fasterxml.jackson.databind.ObjectMapper().readValue(e.getResponseBodyAsString(), Map.class);
                if (errMap.get("detail") != null) {
                    detailMsg = errMap.get("detail").toString();
                } else if (errMap.get("message") != null) {
                    detailMsg = errMap.get("message").toString();
                }
            } catch (Exception ignored) {}
            return Map.of(
                "session_id", sessionId != null ? sessionId : "",
                "is_completed", false,
                "status", "error",
                "message", detailMsg
            );
        } catch (Exception e) {
            log.error("AI Interview Reply failed: {}", e.getMessage());
        }

        return Map.of(
            "session_id", sessionId != null ? sessionId : "",
            "is_completed", false,
            "status", "error",
            "message", "AI service temporarily unavailable. Please try again."
        );
    }

    public Map<String, Object> aiRespondFallback(String sessionId, String answerText, String expectedField, String lastQuestion, String language, org.springframework.web.multipart.MultipartFile audioFile, Throwable ex) {
        log.error("AI Interview Respond circuit open. Error: {}", ex.getMessage());
        return Map.of("session_id", sessionId, "is_completed", true, "fallback", true);
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "aiSummaryFallback")
    public Map<String, Object> getAiSummary(String sessionId, Map<String, Object> history, String language) {
        try {
            String url = fastapiBaseUrl + "/api/v1/interview/summary/" + sessionId
                    + "?language=" + (language != null ? language : "en");

            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> res = response.getBody();
                Map<String, Object> out = new java.util.HashMap<>();
                out.put("session_id", sessionId);
                out.put("summary", res.getOrDefault("summary", res.getOrDefault("final_summary", "")));
                out.put("structured_history", res.getOrDefault("structured_history", Map.of()));
                out.put("red_flags", res.getOrDefault("red_flags", List.of()));
                out.put("status", res.getOrDefault("status", "completed"));
                return out;
            }
        } catch (Exception e) {
            log.warn("FastAPI AI summary call failed for session {}: {}", sessionId, e.getMessage());
        }

        
        boolean isHi = "hi".equalsIgnoreCase(language);
        return Map.of(
            "summary", isHi
                ? "मरीज़ का AI क्लीनिकल साक्षात्कार सफलतापूर्वक पूरा हुआ।"
                : "Patient AI clinical intake interview completed successfully.",
            "status", "completed"
        );
    }

    public Map<String, Object> aiSummaryFallback(String sessionId, Map<String, Object> history, String language, Throwable ex) {
        log.warn("FastAPI ML service offline - returning mock clinical summary. Error: {}", ex.getMessage());
        boolean isHi = "hi".equalsIgnoreCase(language);
        return Map.of(
            "summary", isHi 
                ? "मरीज़ को पिछले कुछ दिनों से मुख्य लक्षण की शिकायत है। सभी मुख्य मेडिकल रिकॉर्ड एकत्र कर लिए गए हैं।" 
                : "Patient reports primary symptoms starting recently. All relevant clinical intake data collected.",
            "possible_considerations", List.of(
                "Clinical Evaluation Recommended",
                "Routine Vital Checks Required"
            )
        );
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "prescriptionFallback")
    public Map<String, Object> extractPrescription(byte[] fileBytes, String filename, String enablePreprocessing) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        org.springframework.util.MultiValueMap<String, Object> body = new org.springframework.util.LinkedMultiValueMap<>();
        org.springframework.core.io.ByteArrayResource fileResource = new org.springframework.core.io.ByteArrayResource(fileBytes) {
            @Override
            public String getFilename() {
                return filename;
            }
        };

        body.add("file", fileResource);
        body.add("enable_preprocessing", enablePreprocessing);

        HttpEntity<org.springframework.util.MultiValueMap<String, Object>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(
            fastapiBaseUrl + "/api/v1/prescription/extract-prescription", entity, Map.class);

        return response.getStatusCode().is2xxSuccessful() ? response.getBody() : Map.of();
    }

    public Map<String, Object> prescriptionFallback(byte[] fileBytes, String filename, String enablePreprocessing, Throwable ex) {
        log.error("Prescription OCR circuit open. Error: {}", ex.getMessage());
        return Map.of("status", "error", "message", "Prescription OCR Service unavailable: " + ex.getMessage());
    }

    

    @CircuitBreaker(name = "fastapi", fallbackMethod = "faceVerifyFallback")
    public Map<String, Object> verifyFaceScan(String faceImageBase64, List<Map<String, Object>> knownPatients) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = Map.of(
            "image_base64", faceImageBase64 != null ? faceImageBase64 : "",
            "known_patients", knownPatients != null ? knownPatients : List.of()
        );

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(
            fastapiBaseUrl + "/api/v1/ai/face-verify", entity, Map.class);

        return response.getStatusCode().is2xxSuccessful() && response.getBody() != null
            ? response.getBody()
            : Map.of("matched", false, "message", "Face verification failed");
    }

    public Map<String, Object> faceVerifyFallback(String faceImageBase64, List<Map<String, Object>> knownPatients, Throwable ex) {
        log.error("Face verify FastAPI circuit open: {}", ex.getMessage());
        return Map.of("matched", false, "message", "Face service unavailable: " + ex.getMessage());
    }

    @CircuitBreaker(name = "fastapi", fallbackMethod = "faceExtractFallback")
    public Map<String, Object> extractFaceEmbedding(String faceImageBase64) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, String> body = Map.of("image_base64", faceImageBase64 != null ? faceImageBase64 : "");
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(
            fastapiBaseUrl + "/api/v1/ai/face-extract", entity, Map.class);

        return response.getStatusCode().is2xxSuccessful() && response.getBody() != null
            ? response.getBody()
            : Map.of("success", false, "message", "Embedding extraction failed");
    }

    public Map<String, Object> faceExtractFallback(String faceImageBase64, Throwable ex) {
        log.error("Face extract FastAPI circuit open: {}", ex.getMessage());
        return Map.of("success", false, "message", "Face service unavailable: " + ex.getMessage());
    }
}

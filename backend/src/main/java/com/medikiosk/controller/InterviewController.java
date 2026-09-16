package com.medikiosk.controller;

import com.medikiosk.model.dto.request.NextQuestionRequest;
import com.medikiosk.model.dto.request.SubmitResponseRequest;
import com.medikiosk.model.dto.response.InterviewStatusResponse;
import com.medikiosk.model.dto.response.QuestionResponse;
import com.medikiosk.service.InterviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/interview")
@RequiredArgsConstructor
@Tag(name = "Interview", description = "Clinical history taking interview engine")
public class InterviewController {

    private final InterviewService interviewService;

    @PostMapping("/next-question")
    @Operation(summary = "Get the next unanswered clinical question for the session")
    public ResponseEntity<?> nextQuestion(@Valid @RequestBody NextQuestionRequest request) {
        QuestionResponse question = interviewService.getNextQuestion(request);
        if (question == null) {
            return ResponseEntity.ok(Map.of(
                "message", "Interview completed",
                "status", "COMPLETED"
            ));
        }
        return ResponseEntity.ok(question);
    }

    @PostMapping("/submit-response")
    @Operation(summary = "Submit patient answer to a clinical question")
    public ResponseEntity<Void> submitResponse(@Valid @RequestBody SubmitResponseRequest request) {
        interviewService.submitResponse(request);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/status/{sessionId}")
    @Operation(summary = "Get interview progress status for a session")
    public ResponseEntity<InterviewStatusResponse> getStatus(@PathVariable String sessionId) {
        return ResponseEntity.ok(interviewService.getStatus(sessionId));
    }

    

    @PostMapping("/start")
    @Operation(summary = "Start interview session (Flutter Endpoint)")
    public ResponseEntity<Map<String, Object>> startInterviewFlutter(
            @RequestParam(required = false, defaultValue = "en") String language,
            @RequestParam(required = false) String sessionId) {
        String effectiveSessionId = (sessionId != null && !sessionId.isBlank()) ? sessionId : java.util.UUID.randomUUID().toString();
        return ResponseEntity.ok(interviewService.startAiInterview(effectiveSessionId, language));
    }

    @PostMapping(value = "/reply", consumes = {"multipart/form-data", "application/x-www-form-urlencoded"})
    @Operation(summary = "Submit interview reply audio/text (Flutter Endpoint)")
    public ResponseEntity<Map<String, Object>> processReplyFlutter(
            @RequestParam(name = "session_id", required = false) String sessionIdForm,
            @RequestParam(name = "sessionId", required = false) String sessionIdParam,
            @RequestParam(name = "text_answer", required = false) String textAnswerForm,
            @RequestParam(name = "answerText", required = false) String textAnswerParam,
            @RequestParam(name = "expected_field", required = false) String expectedField,
            @RequestParam(name = "last_question", required = false) String lastQuestion,
            @RequestParam(name = "language", required = false, defaultValue = "en") String language,
            @RequestPart(name = "audio_file", required = false) org.springframework.web.multipart.MultipartFile audioFile) {
        String effectiveSessionId = (sessionIdForm != null && !sessionIdForm.isBlank()) ? sessionIdForm : sessionIdParam;
        String effectiveTextAnswer = (textAnswerForm != null && !textAnswerForm.isBlank()) ? textAnswerForm : textAnswerParam;
        return ResponseEntity.ok(interviewService.processAiResponse(effectiveSessionId, effectiveTextAnswer, expectedField, lastQuestion, language, audioFile));
    }

    

    @PostMapping("/ai/start")
    @Operation(summary = "Start AI-driven dynamic LLM clinical interview")
    public ResponseEntity<Map<String, Object>> startAiInterview(@RequestParam(required = false) String sessionId, @RequestParam(defaultValue = "en") String language) {
        String effectiveSessionId = (sessionId != null && !sessionId.isBlank()) ? sessionId : java.util.UUID.randomUUID().toString();
        return ResponseEntity.ok(interviewService.startAiInterview(effectiveSessionId, language));
    }

    @PostMapping("/ai/respond")
    @Operation(summary = "Submit patient answer to AI LLM interview")
    public ResponseEntity<Map<String, Object>> submitAiResponse(
            @RequestParam String sessionId,
            @RequestParam(required = false) String answerText,
            @RequestParam(required = false) String expectedField,
            @RequestParam(required = false) String lastQuestion,
            @RequestParam(defaultValue = "en") String language,
            @RequestPart(required = false) org.springframework.web.multipart.MultipartFile audioFile) {
        return ResponseEntity.ok(interviewService.processAiResponse(sessionId, answerText, expectedField, lastQuestion, language, audioFile));
    }

    @GetMapping("/ai/summary/{sessionId}")
    @Operation(summary = "Generate final AI clinical summary report")
    public ResponseEntity<Map<String, Object>> getAiSummary(@PathVariable String sessionId, @RequestParam(defaultValue = "en") String language) {
        return ResponseEntity.ok(interviewService.getAiSummary(sessionId, language));
    }
}
package com.medikiosk.model.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class D11CompletionStatusResponse {
    private UUID sessionId;
    private String patientName;
    private String consultationDuration;
    private String completionDate;
    private List<String> whatsSavedChecklist;
    private int completedPatientsToday;
    private int totalPatientsToday;
    private int remainingInQueue;
    private String nextPatientToken;
}
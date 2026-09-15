package com.medikiosk.model.dto.response;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InterviewStatusResponse {
    private String sessionId;
    private Integer totalQuestions;
    private Integer answeredQuestions;
    private Integer progress;
    private String status;
    private String currentQuestionId;
}
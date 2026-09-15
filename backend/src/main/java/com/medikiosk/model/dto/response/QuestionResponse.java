package com.medikiosk.model.dto.response;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionResponse {
    private String id;
    private String questionKey;
    private String questionText;
    private String questionType;
    private String category;
    private Boolean isMandatory;
    private Boolean isLastQuestion;
    private Integer progress;
}
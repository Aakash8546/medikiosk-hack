package com.medikiosk.model.entity;

import com.medikiosk.model.enums.QuestionType;
import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "interview_questions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class InterviewQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "question_key", unique = true, nullable = false)
    private String questionKey;

    @Column(name = "question_text_en", nullable = false, columnDefinition = "TEXT")
    private String questionTextEn;

    @Column(name = "question_text_hi", columnDefinition = "TEXT")
    private String questionTextHi;

    @Enumerated(EnumType.STRING)
    @Column(name = "question_type", nullable = false)
    private QuestionType questionType;

    @Column(nullable = false)
    private String category;

    @Column(name = "parent_question_key")
    private String parentQuestionKey;

    @Column(name = "trigger_value")
    private String triggerValue;

    @Builder.Default
    @Column(name = "sequence_order")
    private Integer sequenceOrder = 0;

    @Builder.Default
    @Column(name = "is_mandatory")
    private Boolean isMandatory = true;

    @Builder.Default
    @Column(name = "is_active")
    private Boolean isActive = true;

    @Builder.Default
    @Column(name = "applies_to")
    private String appliesTo = "BOTH";
}
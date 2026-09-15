package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "interview_responses")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class InterviewResponse {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private PatientSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private InterviewQuestion question;

    @Column(name = "answer_text", columnDefinition = "TEXT")
    private String answerText;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "answer_choices", columnDefinition = "text[]")
    private List<String> answerChoices;

    @Column(name = "answer_numeric")
    private java.math.BigDecimal answerNumeric;

    @Builder.Default
    @Column(name = "is_voice_input")
    private Boolean isVoiceInput = false;

    @Column(name = "raw_transcript", columnDefinition = "TEXT")
    private String rawTranscript;

    @Column(name = "confidence_score")
    private Double confidenceScore;

    @Builder.Default
    @Column(name = "answered_at")
    private LocalDateTime answeredAt = LocalDateTime.now();

    @Builder.Default
    private String language = "en";
}
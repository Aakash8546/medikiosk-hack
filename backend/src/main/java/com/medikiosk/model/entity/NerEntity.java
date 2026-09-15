package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "ner_entities")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NerEntity {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(name = "UUID", strategy = "org.hibernate.id.UUIDGenerator")
    private UUID id;

    @Column(name = "session_id", nullable = false)
    private UUID sessionId;

    @Column(name = "question_id")
    private UUID questionId;

    @Column(name = "entity_label", nullable = false, length = 50)
    private String entityLabel;

    @Column(name = "entity_value", nullable = false)
    private String entityValue;

    @Column(name = "confidence")
    private Double confidence;

    @Builder.Default
    @Column(name = "source", length = 20)
    private String source = "llm";

    @Builder.Default
    @Column(name = "language", length = 10)
    private String language = "en";

    @Column(name = "extracted_at")
    private LocalDateTime extractedAt;

    @PrePersist
    void prePersist() {
        if (extractedAt == null) extractedAt = LocalDateTime.now();
    }
}
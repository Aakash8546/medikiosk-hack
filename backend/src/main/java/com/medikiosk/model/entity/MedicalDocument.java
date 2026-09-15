package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;


@Entity
@Table(name = "medical_documents")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class MedicalDocument {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private PatientSession session;

    @Column(name = "source_filename")
    private String sourceFilename;

    @Column(name = "document_type")
    private String documentType;

    
    @Column(name = "document_date")
    private String documentDate;

    
    @Column(name = "normalized_date")
    private LocalDate normalizedDate;

    @Builder.Default
    @Column(name = "page_number")
    private Integer pageNumber = 1;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "diagnoses", columnDefinition = "jsonb")
    private List<String> diagnoses;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "medications", columnDefinition = "jsonb")
    private List<Map<String, Object>> medications;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "lab_values", columnDefinition = "jsonb")
    private List<Map<String, Object>> labValues;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "procedures", columnDefinition = "jsonb")
    private List<String> procedures;

    @Column(name = "raw_text", columnDefinition = "TEXT")
    private String rawText;

    @Builder.Default
    @Column(name = "ocr_status")
    private String ocrStatus = "EXTRACTED";

    @Column(name = "ocr_confidence_note", columnDefinition = "TEXT")
    private String ocrConfidenceNote;

    
    @Column(name = "image_url")
    private String imageUrl;

    @Builder.Default
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
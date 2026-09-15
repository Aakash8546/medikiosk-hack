package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "clinical_summary_overrides")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ClinicalSummaryOverride {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false, unique = true)
    private PatientSession session;

    @Column(name = "history_of_present_illness", columnDefinition = "TEXT")
    private String historyOfPresentIllness;

    @Column(name = "past_medical_history", columnDefinition = "TEXT")
    private String pastMedicalHistory;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "family_history", columnDefinition = "text[]")
    private List<String> familyHistory;

    @Column(name = "ayush_observations", columnDefinition = "TEXT")
    private String ayushObservations;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "review_of_systems_checked", columnDefinition = "text[]")
    private List<String> reviewOfSystemsChecked;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "differential_diagnoses", columnDefinition = "text[]")
    private List<String> differentialDiagnoses;

    @Builder.Default
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
}
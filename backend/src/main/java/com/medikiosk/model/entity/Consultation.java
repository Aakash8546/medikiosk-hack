package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "consultations")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Consultation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false, unique = true)
    private PatientSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(name = "clinical_impression", columnDefinition = "TEXT")
    private String clinicalImpression;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "icd10_codes", columnDefinition = "text[]")
    private List<String> icd10Codes;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "icd_tm2_codes", columnDefinition = "text[]")
    private List<String> icdTm2Codes;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "investigations_ordered", columnDefinition = "text[]")
    private List<String> investigationsOrdered;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "drug_interaction_warnings", columnDefinition = "text[]")
    private List<String> drugInteractionWarnings;

    @Builder.Default
    @Column(name = "follow_up_days")
    private Integer followUpDays = 0;

    @Column(name = "follow_up_notes", columnDefinition = "TEXT")
    private String followUpNotes;

    @Builder.Default
    @Column(nullable = false)
    private String status = "COMPLETED";

    @Builder.Default
    @Column(name = "completed_at")
    private LocalDateTime completedAt = LocalDateTime.now();

    @Builder.Default
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "consultation", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Prescription> prescriptions = new java.util.ArrayList<>();
}
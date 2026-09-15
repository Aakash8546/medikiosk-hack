package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "clinical_histories")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ClinicalHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false, unique = true)
    private PatientSession session;

    
    @Column(name = "chief_complaint", columnDefinition = "TEXT")
    private String chiefComplaint;

    @Column(name = "complaint_duration")
    private String complaintDuration;

    @Column(name = "complaint_severity")
    private String complaintSeverity;

    
    @Column(name = "hpi_onset")
    private String hpiOnset;

    @Column(name = "hpi_character", columnDefinition = "TEXT")
    private String hpiCharacter;

    @Column(name = "hpi_radiation", columnDefinition = "TEXT")
    private String hpiRadiation;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "hpi_associated_sx", columnDefinition = "text[]")
    private List<String> hpiAssociatedSymptoms;

    @Column(name = "hpi_exacerbating", columnDefinition = "TEXT")
    private String hpiExacerbating;

    @Column(name = "hpi_relieving", columnDefinition = "TEXT")
    private String hpiRelieving;

    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "past_medical", columnDefinition = "jsonb")
    private List<Map<String, Object>> pastMedical;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "past_surgical", columnDefinition = "jsonb")
    private List<Map<String, Object>> pastSurgical;

    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "current_medications", columnDefinition = "jsonb")
    private List<Map<String, Object>> currentMedications;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "known_allergies", columnDefinition = "jsonb")
    private List<Map<String, Object>> knownAllergies;

    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "family_history", columnDefinition = "jsonb")
    private List<Map<String, Object>> familyHistory;

    
    @Column(name = "smoking_status")
    private String smokingStatus;

    @Column(name = "alcohol_status")
    private String alcoholStatus;

    @Column(name = "tobacco_chewing")
    private String tobaccoChewing;

    
    @Column(name = "ros_cardiovascular", columnDefinition = "TEXT")
    private String rosCardiovascular;

    @Column(name = "ros_respiratory", columnDefinition = "TEXT")
    private String rosRespiratory;

    @Column(name = "ros_gastrointestinal", columnDefinition = "TEXT")
    private String rosGastrointestinal;

    @Column(name = "ros_neurological", columnDefinition = "TEXT")
    private String rosNeurological;

    
    @Builder.Default
    @Column(name = "completeness_score")
    private Integer completenessScore = 0;

    @Builder.Default
    @Column(name = "is_finalized")
    private Boolean isFinalized = false;

    @Builder.Default
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
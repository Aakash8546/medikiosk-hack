package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "session_vitals")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SessionVitals {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false, unique = true)
    private PatientSession session;

    @Column(name = "blood_pressure")
    private String bloodPressure;

    private Double temperature;

    @Column(name = "heart_rate")
    private Integer heartRate;

    private Integer spo2;

    @Column(name = "respiratory_rate")
    private Integer respiratoryRate;

    private Double weight;
    private Double height;

    @Column(name = "blood_glucose")
    private Double bloodGlucose;

    @Column(name = "pain_scale")
    private Integer painScale;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "additional_vitals", columnDefinition = "jsonb")
    private Map<String, String> additionalVitals;

    @Builder.Default
    @Column(name = "recorded_at")
    private LocalDateTime recordedAt = LocalDateTime.now();

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
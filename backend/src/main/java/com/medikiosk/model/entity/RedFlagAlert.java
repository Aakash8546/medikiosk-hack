package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "red_flag_alerts")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RedFlagAlert {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private PatientSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rule_id", nullable = false)
    private RedFlagRule rule;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Column(nullable = false) private String severity;
    @Builder.Default @Column(nullable = false) private String status = "ACTIVE";
    @Column(name = "triggered_by") private String triggeredBy;
    @Column(name = "triage_notes") private String triageNotes;
    @Column(name = "acknowledged_by") private UUID acknowledgedBy;
    @Column(name = "acknowledged_at") private LocalDateTime acknowledgedAt;
    @Builder.Default @Column(name = "created_at") private LocalDateTime createdAt = LocalDateTime.now();
}
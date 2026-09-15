package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity
@Table(name = "prescriptions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Prescription {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "consultation_id", nullable = false)
    private Consultation consultation;

    @Column(name = "medicine_name", nullable = false)
    private String medicineName;

    private String dosage;
    private String timing;

    @Builder.Default
    @Column(name = "duration_days")
    private Integer durationDays = 0;

    @Builder.Default
    @Column(name = "is_ayurvedic")
    private Boolean isAyurvedic = false;
}
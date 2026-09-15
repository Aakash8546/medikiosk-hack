package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;

@Entity @Table(name = "drug_interactions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DrugInteraction {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "drug_a", nullable = false) private String drugA;
    @Column(name = "drug_b", nullable = false) private String drugB;
    @Column(nullable = false) private String severity;
    @Column(nullable = false) private String description;
    @Column(name = "clinical_effect") private String clinicalEffect;
    private String recommendation;
    private String source;
    @Builder.Default @Column(name = "is_active") private Boolean isActive = true;
}
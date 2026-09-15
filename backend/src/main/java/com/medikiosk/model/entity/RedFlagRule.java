package com.medikiosk.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity @Table(name = "red_flag_rules")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class RedFlagRule {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "rule_code", unique = true, nullable = false)
    private String ruleCode;

    @Column(nullable = false)
    private String name;

    private String description;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "trigger_conditions", nullable = false, columnDefinition = "jsonb")
    private List<String> triggerConditions;

    @Column(name = "min_age") private Integer minAge;
    @Column(name = "max_age") private Integer maxAge;
    @Column(name = "gender_filter") private String genderFilter;

    @Column(nullable = false) private String severity;
    @Column(nullable = false) private String action;

    @Builder.Default @Column(name = "is_active") private Boolean isActive = true;
    @Builder.Default @Column(name = "created_at") private LocalDateTime createdAt = LocalDateTime.now();
}
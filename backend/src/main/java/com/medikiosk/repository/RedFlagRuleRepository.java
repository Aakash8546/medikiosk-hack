package com.medikiosk.repository;

import com.medikiosk.model.entity.RedFlagRule;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.List;

public interface RedFlagRuleRepository extends JpaRepository<RedFlagRule, UUID> {
    List<RedFlagRule> findByIsActiveTrue();
}
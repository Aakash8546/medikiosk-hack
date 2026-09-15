package com.medikiosk.repository;

import com.medikiosk.model.entity.DrugInteraction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DrugInteractionRepository extends JpaRepository<DrugInteraction, UUID> {
    
    Optional<DrugInteraction> findByDrugAAndDrugB(String drugA, String drugB);

    @Query("SELECT d FROM DrugInteraction d WHERE d.isActive = true AND " +
           "((LOWER(d.drugA) IN :drugs AND LOWER(d.drugB) IN :drugs))")
    List<DrugInteraction> findInteractionsForDrugs(@Param("drugs") List<String> drugs);
}
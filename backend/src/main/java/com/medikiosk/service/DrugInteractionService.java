package com.medikiosk.service;

import com.medikiosk.model.dto.request.DrugCheckRequest;
import com.medikiosk.model.dto.response.DrugInteractionResponse;
import com.medikiosk.model.entity.DrugInteraction;
import com.medikiosk.repository.DrugInteractionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DrugInteractionService {

    private final DrugInteractionRepository repository;

    public List<DrugInteractionResponse> checkInteractions(DrugCheckRequest request) {
        if (request == null || request.getDrugs() == null || request.getDrugs().isEmpty()) {
            return Collections.emptyList();
        }

        
        List<String> cleanDrugs = request.getDrugs().stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(s -> !s.isBlank())
                .map(String::toLowerCase)
                .distinct()
                .collect(Collectors.toList());

        if (cleanDrugs.size() < 2) {
            log.info("💊 [DRUG CHECK] Less than 2 valid drugs provided ({}), skipping interaction check.", cleanDrugs);
            return Collections.emptyList();
        }

        log.info("💊 [DRUG CHECK] Evaluating interactions for {} drugs: {}", cleanDrugs.size(), cleanDrugs);

        
        List<DrugInteraction> interactions = repository.findInteractionsForDrugs(cleanDrugs);

        
        List<DrugInteractionResponse> responseList = interactions.stream()
                .sorted(Comparator.comparingInt(this::getSeverityWeight))
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        log.info("⚠️ [DRUG CHECK] Found {} interaction warnings.", responseList.size());
        return responseList;
    }

    private int getSeverityWeight(DrugInteraction d) {
        if (d.getSeverity() == null) return 3;
        switch (d.getSeverity().toUpperCase()) {
            case "CRITICAL":
            case "MAJOR": return 1;
            case "MODERATE": return 2;
            case "MINOR": return 3;
            default: return 4;
        }
    }

    private DrugInteractionResponse mapToResponse(DrugInteraction d) {
        return DrugInteractionResponse.builder()
                .id(d.getId())
                .drugA(d.getDrugA())
                .drugB(d.getDrugB())
                .severity(d.getSeverity())
                .description(d.getDescription())
                .clinicalEffect(d.getClinicalEffect())
                .recommendation(d.getRecommendation())
                .build();
    }
}
package com.medikiosk.model.dto.response;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AyushAssessmentResponse {
    private UUID id;
    private UUID sessionId;
    private String patientName;
    
    
    private Integer vataScore;
    private Integer pittaScore;
    private Integer kaphaScore;
    private Double vataPercentage;
    private Double pittaPercentage;
    private Double kaphaPercentage;
    private Double prakritiPercentage;
    private String prakritiResult;
    private String prakritiDescription;
    
    
    private Integer agniScore;
    private Double agniGauge;
    private String agniType;
    private String agniDescription;
    private String koshthaType;
    
    
    private Integer lifestyleScore;
    private String lifestyleBadge;
    private List<String> tastePreference;
    private String waterIntake;
    private Map<String, Object> aharaVihara;
    
    
    private Map<String, Object> vikritiSummary;
    
    
    private Map<String, Object> dashavidhaDetails;
    private List<Map<String, Object>> saraAssessment;
    private String samhanana;
    private String pramana;
    private String satmya;
    private String sattva;
    private String aharaShakti;
    private String vyayamaShakti;
    private String vaya;
    
    
    private String nidana;
    private List<String> icdTm2Codes;
    
    
    private List<String> doctorsQuickView;
    private List<String> suggestedFocusAreas;
    private List<String> dietRecommendations;
    private List<String> lifestyleRecommendations;
    private List<String> recommendedYoga;
    
    private Integer completenessScore;
    private Boolean isFinalized;
    private LocalDateTime createdAt;

    public UUID getId() { return id; }
    public UUID getSessionId() { return sessionId; }
    public String getPatientName() { return patientName; }
    public Integer getVataScore() { return vataScore; }
    public Integer getPittaScore() { return pittaScore; }
    public Integer getKaphaScore() { return kaphaScore; }
    public Double getVataPercentage() { return vataPercentage; }
    public Double getPittaPercentage() { return pittaPercentage; }
    public Double getKaphaPercentage() { return kaphaPercentage; }
    public Double getPrakritiPercentage() { return prakritiPercentage; }
    public String getPrakritiResult() { return prakritiResult; }
    public String getPrakritiDescription() { return prakritiDescription; }
    public Integer getAgniScore() { return agniScore; }
    public Double getAgniGauge() { return agniGauge; }
    public String getAgniType() { return agniType; }
    public String getAgniDescription() { return agniDescription; }
    public String getKoshthaType() { return koshthaType; }
    public Integer getLifestyleScore() { return lifestyleScore; }
    public String getLifestyleBadge() { return lifestyleBadge; }
    public List<String> getTastePreference() { return tastePreference; }
    public String getWaterIntake() { return waterIntake; }
    public Map<String, Object> getAharaVihara() { return aharaVihara; }
    public Map<String, Object> getVikritiSummary() { return vikritiSummary; }
    public Map<String, Object> getDashavidhaDetails() { return dashavidhaDetails; }
    public List<Map<String, Object>> getSaraAssessment() { return saraAssessment; }
    public String getSamhanana() { return samhanana; }
    public String getPramana() { return pramana; }
    public String getSatmya() { return satmya; }
    public String getSattva() { return sattva; }
    public String getAharaShakti() { return aharaShakti; }
    public String getVyayamaShakti() { return vyayamaShakti; }
    public String getVaya() { return vaya; }
    public String getNidana() { return nidana; }
    public List<String> getIcdTm2Codes() { return icdTm2Codes; }
    public List<String> getDoctorsQuickView() { return doctorsQuickView; }
    public List<String> getSuggestedFocusAreas() { return suggestedFocusAreas; }
    public List<String> getDietRecommendations() { return dietRecommendations; }
    public List<String> getLifestyleRecommendations() { return lifestyleRecommendations; }
    public List<String> getRecommendedYoga() { return recommendedYoga; }
    public Integer getCompletenessScore() { return completenessScore; }
    public Boolean getIsFinalized() { return isFinalized; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
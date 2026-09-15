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

@Entity @Table(name = "ayush_assessments")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AyushAssessment {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false, unique = true)
    private PatientSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @Builder.Default private Integer vataScore = 0;
    @Builder.Default private Integer pittaScore = 0;
    @Builder.Default private Integer kaphaScore = 0;
    @Column(name = "prakriti_result") private String prakritiResult;

    @Column(name = "agni_type") private String agniType;
    @Column(name = "agni_description") private String agniDescription;
    @Column(name = "koshtha_type") private String koshthaType;
    @Column(name = "vikriti_summary") private String vikritiSummary;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "raw_responses", columnDefinition = "jsonb")
    private Map<String, Object> rawResponses;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "sara_assessment", columnDefinition = "jsonb")
    private List<Map<String, Object>> saraAssessment;

    private String samhanana;
    private String pramana;
    private String satmya;
    private String sattva;
    
    @Column(name = "ahara_shakti") private String aharaShakti;
    @Column(name = "vyayama_shakti") private String vyayamaShakti;
    private String vaya;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "ahara_vihara", columnDefinition = "jsonb")
    private Map<String, Object> aharaVihara;

    private String nidana;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "icd_tm2_codes", columnDefinition = "text[]")
    private List<String> icdTm2Codes;

    @Builder.Default @Column(name = "completeness_score") private Integer completenessScore = 0;
    @Builder.Default @Column(name = "is_finalized") private Boolean isFinalized = false;
    @Builder.Default @Column(name = "created_at") private LocalDateTime createdAt = LocalDateTime.now();
    @UpdateTimestamp @Column(name = "updated_at") private LocalDateTime updatedAt;

    
    public UUID getId() { return id; }
    public PatientSession getSession() { return session; }
    public Patient getPatient() { return patient; }
    public Integer getVataScore() { return vataScore; }
    public Integer getPittaScore() { return pittaScore; }
    public Integer getKaphaScore() { return kaphaScore; }
    public String getPrakritiResult() { return prakritiResult; }
    public String getAgniType() { return agniType; }
    public String getAgniDescription() { return agniDescription; }
    public String getKoshthaType() { return koshthaType; }
    public String getVikritiSummary() { return vikritiSummary; }
    public Map<String, Object> getRawResponses() { return rawResponses; }
    public List<Map<String, Object>> getSaraAssessment() { return saraAssessment; }
    public String getSamhanana() { return samhanana; }
    public String getPramana() { return pramana; }
    public String getSatmya() { return satmya; }
    public String getSattva() { return sattva; }
    public String getAharaShakti() { return aharaShakti; }
    public String getVyayamaShakti() { return vyayamaShakti; }
    public String getVaya() { return vaya; }
    public Map<String, Object> getAharaVihara() { return aharaVihara; }
    public String getNidana() { return nidana; }
    public List<String> getIcdTm2Codes() { return icdTm2Codes; }
    public Integer getCompletenessScore() { return completenessScore; }
    public Boolean getIsFinalized() { return isFinalized; }
    public Boolean getFinalized() { return isFinalized; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    public void setVataScore(Integer vataScore) { this.vataScore = vataScore; }
    public void setPittaScore(Integer pittaScore) { this.pittaScore = pittaScore; }
    public void setKaphaScore(Integer kaphaScore) { this.kaphaScore = kaphaScore; }
    public void setPrakritiResult(String prakritiResult) { this.prakritiResult = prakritiResult; }
    public void setAgniType(String agniType) { this.agniType = agniType; }
    public void setAgniDescription(String agniDescription) { this.agniDescription = agniDescription; }
    public void setKoshthaType(String koshthaType) { this.koshthaType = koshthaType; }
    public void setVikritiSummary(String vikritiSummary) { this.vikritiSummary = vikritiSummary; }
    public void setSamhanana(String samhanana) { this.samhanana = samhanana; }
    public void setPramana(String pramana) { this.pramana = pramana; }
    public void setSatmya(String satmya) { this.satmya = satmya; }
    public void setSattva(String sattva) { this.sattva = sattva; }
    public void setAharaShakti(String aharaShakti) { this.aharaShakti = aharaShakti; }
    public void setVyayamaShakti(String vyayamaShakti) { this.vyayamaShakti = vyayamaShakti; }
    public void setVaya(String vaya) { this.vaya = vaya; }
    public void setAharaVihara(Map<String, Object> aharaVihara) { this.aharaVihara = aharaVihara; }
    public void setCompletenessScore(Integer completenessScore) { this.completenessScore = completenessScore; }
    public void setIsFinalized(Boolean isFinalized) { this.isFinalized = isFinalized; }
}
package com.medikiosk.model.dto.request;

import lombok.Data;
import java.util.UUID;
import java.util.Map;
import java.util.List;

@Data
public class AyushAssessmentRequest {
    private UUID sessionId;
    
    
    private String bodyFrame;  
    private String skinType;   
    
    
    private List<String> physicalSymptoms; 
    private List<String> mentalSymptoms;   
    
    
    private String appetite;       

    
    private Map<String, String> prakritiAnswers;   
    private VikritiRequest vikriti;                 
    private Map<String, String> agniAnswers;       
    private Map<String, Object> aharaAnswers;      
    private Map<String, String> viharaAnswers;     
    private Map<String, String> dashavidhaAnswers; 

    
    private Integer vataScore;
    private Integer pittaScore;
    private Integer kaphaScore;
    private String agniType;
    private String agniDescription;
    private String koshthaType;
    private List<Map<String, Object>> saraAssessment;
    private String samhanana;
    private String pramana;
    private String satmya;
    private String sattva;
    private String aharaShakti;
    private String vyayamaShakti;
    private String vaya;
    private Map<String, Object> aharaVihara;
    private String nidana;
    private List<String> icdTm2Codes;

    @Data
    public static class VikritiRequest {
        private List<String> doshas;       
        private List<String> symptoms;     
        private String severity;           
        private String duration;           
    }

    public String getKoshthaType() { return koshthaType; }
    public String getSamhanana() { return samhanana; }
    public String getPramana() { return pramana; }
    public String getSatmya() { return satmya; }
    public String getSattva() { return sattva; }
    public String getAharaShakti() { return aharaShakti; }
    public String getVyayamaShakti() { return vyayamaShakti; }
    public String getVaya() { return vaya; }
}
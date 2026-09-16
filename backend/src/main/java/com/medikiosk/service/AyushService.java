package com.medikiosk.service;

import com.medikiosk.exception.MediKioskException;
import com.medikiosk.exception.ResourceNotFoundException;
import com.medikiosk.model.dto.request.AyushAssessmentRequest;
import com.medikiosk.model.dto.response.AyushAssessmentResponse;
import com.medikiosk.model.entity.AyushAssessment;
import com.medikiosk.model.entity.Patient;
import com.medikiosk.model.entity.PatientSession;
import com.medikiosk.repository.AyushAssessmentRepository;
import com.medikiosk.repository.PatientRepository;
import com.medikiosk.repository.PatientSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class AyushService {

    private final AyushAssessmentRepository repository;
    private final PatientSessionRepository sessionRepository;
    private final PatientRepository patientRepository;
    private final ConsentService consentService;
    private final AyushPdfService pdfService;

    
    
    
    private static final Map<String, String> PRAKRITI_MAP = Map.ofEntries(
        
        Map.entry("q1_thin", "VATA"), Map.entry("q1_medium", "PITTA"), Map.entry("q1_large", "KAPHA"),
        
        Map.entry("q2_dry", "VATA"), Map.entry("q2_normal", "PITTA"), Map.entry("q2_oily", "KAPHA"),
        
        Map.entry("q3_low", "VATA"), Map.entry("q3_high", "PITTA"), Map.entry("q3_moderate", "KAPHA"),
        
        Map.entry("q4_irregular", "VATA"), Map.entry("q4_strong", "PITTA"), Map.entry("q4_slow", "KAPHA"),
        
        Map.entry("q5_variable", "VATA"), Map.entry("q5_high", "PITTA"), Map.entry("q5_low", "KAPHA"),
        
        Map.entry("q6_cold hands", "VATA"), Map.entry("q6_warm body", "PITTA"), Map.entry("q6_balanced", "KAPHA"),
        
        Map.entry("q7_light", "VATA"), Map.entry("q7_moderate", "PITTA"), Map.entry("q7_deep", "KAPHA"),
        
        Map.entry("q8_active", "VATA"), Map.entry("q8_moderate", "PITTA"), Map.entry("q8_low", "KAPHA"),
        
        Map.entry("q9_minimal", "VATA"), Map.entry("q9_moderate", "PITTA"), Map.entry("q9_excessive", "KAPHA"),
        
        Map.entry("q10_quick learn", "VATA"), Map.entry("q10_sharp", "PITTA"), Map.entry("q10_slow steady", "KAPHA"),
        
        Map.entry("q11_anxious", "VATA"), Map.entry("q11_irritable", "PITTA"), Map.entry("q11_calm", "KAPHA"),
        
        Map.entry("q12_adaptable", "VATA"), Map.entry("q12_outgoing", "PITTA"), Map.entry("q12_reserved", "KAPHA"),
        
        Map.entry("q13_dry & frizzy", "VATA"), Map.entry("q13_fine & oily", "PITTA"), Map.entry("q13_thick & wavy", "KAPHA"),
        
        Map.entry("q14_small & dry", "VATA"), Map.entry("q14_sharp & bright", "PITTA"), Map.entry("q14_large & calm", "KAPHA"),
        
        Map.entry("q15_narrow", "VATA"), Map.entry("q15_medium", "PITTA"), Map.entry("q15_round", "KAPHA"),
        
        Map.entry("q16_fast & talkative", "VATA"), Map.entry("q16_clear & direct", "PITTA"), Map.entry("q16_soft & steady", "KAPHA"),
        
        Map.entry("q17_variety", "VATA"), Map.entry("q17_spicy & salty", "PITTA"), Map.entry("q17_sweet & mild", "KAPHA"),
        
        Map.entry("q18_warm", "VATA"), Map.entry("q18_cool", "PITTA"), Map.entry("q18_any", "KAPHA"),
        
        Map.entry("q19_irregular", "VATA"), Map.entry("q19_regular", "PITTA"), Map.entry("q19_loose", "KAPHA"),
        
        Map.entry("q20_low", "VATA"), Map.entry("q20_medium", "PITTA"), Map.entry("q20_high", "KAPHA"),
        
        Map.entry("q21_hard gain", "VATA"), Map.entry("q21_stable", "PITTA"), Map.entry("q21_easy gain", "KAPHA"),
        
        Map.entry("q22_variable", "VATA"), Map.entry("q22_high", "PITTA"), Map.entry("q22_steady", "KAPHA"),
        
        Map.entry("q23_cold & windy", "VATA"), Map.entry("q23_hot & humid", "PITTA"), Map.entry("q23_all climate", "KAPHA"),
        
        Map.entry("q24_vata", "VATA"), Map.entry("q24_pitta", "PITTA"), Map.entry("q24_kapha", "KAPHA")
    );

    @Transactional
    public AyushAssessmentResponse submitAssessment(AyushAssessmentRequest req) {
        UUID sessionId = req.getSessionId();
        if (sessionId == null) {
            throw new MediKioskException("Session ID is required for AYUSH assessment.");
        }

        PatientSession session = sessionRepository.findById(sessionId)
                .orElseGet(() -> {
                    log.warn("[AYUSH] Session not found in DB for ID: {}. Auto-healing patient session...", sessionId);
                    Patient patient = patientRepository.findAll().stream().findFirst().orElseGet(() -> {
                        Patient p = Patient.builder()
                                .abhaId("DEMO-ABHA-" + UUID.randomUUID().toString().substring(0, 8))
                                .fullName("Ayush Patient")
                                .gender("M")
                                .build();
                        return patientRepository.save(p);
                    });
                    PatientSession newSession = PatientSession.builder()
                            .id(sessionId)
                            .patient(patient)
                            .sessionType(com.medikiosk.model.enums.SessionType.AYUSH)
                            .status(com.medikiosk.model.enums.SessionStatus.STARTED)
                            .startedAt(java.time.LocalDateTime.now())
                            .lastActivity(java.time.LocalDateTime.now())
                            .build();
                    return sessionRepository.save(newSession);
                });

        if (session.getPatient() == null) {
            Patient patient = patientRepository.findAll().stream().findFirst().orElseGet(() -> {
                Patient p = Patient.builder()
                        .abhaId("DEMO-ABHA-" + UUID.randomUUID().toString().substring(0, 8))
                        .fullName("Ayush Patient")
                        .gender("M")
                        .build();
                return patientRepository.save(p);
            });
            session.setPatient(patient);
            session = sessionRepository.save(session);
        }

        if (!consentService.hasRequiredConsents(sessionId)) {
            log.info("[AYUSH] Required consents not found for session: {}", sessionId);
        }

        
        
        
        int vata = 0, pitta = 0, kapha = 0;
        Map<String, String> pAnswers = req.getPrakritiAnswers();

        if (pAnswers != null && !pAnswers.isEmpty()) {
            for (Map.Entry<String, String> entry : pAnswers.entrySet()) {
                String qKey = entry.getKey().toLowerCase().trim();
                String val = entry.getValue().toLowerCase().trim();
                String mapKey = qKey + "_" + val;

                String dosha = PRAKRITI_MAP.get(mapKey);
                if (dosha == null) {
                    if (val.contains("thin") || val.contains("dry") || val.contains("low") || val.contains("irregular") || val.contains("anxious") || val.contains("vata")) dosha = "VATA";
                    else if (val.contains("medium") || val.contains("normal") || val.contains("high") || val.contains("strong") || val.contains("irritable") || val.contains("pitta")) dosha = "PITTA";
                    else if (val.contains("large") || val.contains("oily") || val.contains("moderate") || val.contains("slow") || val.contains("calm") || val.contains("kapha")) dosha = "KAPHA";
                }

                if ("VATA".equals(dosha)) vata++;
                else if ("PITTA".equals(dosha)) pitta++;
                else if ("KAPHA".equals(dosha)) kapha++;
            }
        } else {
            vata = req.getVataScore() != null ? req.getVataScore() : 0;
            pitta = req.getPittaScore() != null ? req.getPittaScore() : 0;
            kapha = req.getKaphaScore() != null ? req.getKaphaScore() : 0;
        }

        double vataPct = (vata / 24.0) * 100.0;
        double pittaPct = (pitta / 24.0) * 100.0;
        double kaphaPct = (kapha / 24.0) * 100.0;

        String calculatedPrakriti = calculatePrakriti(vata, pitta, kapha);

        
        
        
        Map<String, String> agniAnswers = req.getAgniAnswers();
        int agniScore = 0;
        if (agniAnswers != null) {
            String app = agniAnswers.getOrDefault("appetite", "").toLowerCase();
            if (app.contains("mod")) agniScore += 1;
            else if (app.contains("str") || app.contains("high")) agniScore += 2;
            else if (app.contains("irreg")) agniScore += 3;

            String after = agniAnswers.getOrDefault("afterMeals", "").toLowerCase();
            if (after.contains("some") || after.contains("light")) agniScore += 1;
            else if (after.contains("often")) agniScore += 2;
            else if (after.contains("very")) agniScore += 3;

            String dig = agniAnswers.getOrDefault("digestion", "").toLowerCase();
            if (dig.contains("some") || dig.contains("slow")) agniScore += 1;
            else if (dig.contains("poor")) agniScore += 2;
            else if (dig.contains("very")) agniScore += 3;
        }

        String agniType;
        double agniGauge;
        if (agniScore <= 3) {
            agniType = "MANDAGNI";
            agniGauge = 0.2;
        } else if (agniScore <= 6) {
            agniType = "MADHYAMA_AGNI";
            agniGauge = 0.5;
        } else {
            agniType = "TIKSHNAGNI";
            agniGauge = 0.8;
        }

        
        
        
        int aharaScore = 0;
        Map<String, Object> aharaAns = req.getAharaAnswers();
        if (aharaAns != null) {
            String diet = String.valueOf(aharaAns.getOrDefault("diet", "")).toLowerCase();
            if (diet.contains("veg")) aharaScore += 2;
            else if (diet.contains("egg")) aharaScore += 1;

            String reg = String.valueOf(aharaAns.getOrDefault("mealRegularity", "")).toLowerCase();
            if (reg.contains("reg") && !reg.contains("irreg")) aharaScore += 2;
            else if (reg.contains("some")) aharaScore += 1;

            String qty = String.valueOf(aharaAns.getOrDefault("mealQuantity", "")).toLowerCase();
            if (qty.contains("mod")) aharaScore += 2;
            else aharaScore += 1;

            String qual = String.valueOf(aharaAns.getOrDefault("foodQuality", "")).toLowerCase();
            if (qual.contains("good") || qual.contains("excel")) aharaScore += 2;
            else if (qual.contains("avg")) aharaScore += 1;
        }

        int viharaScore = 0;
        Map<String, String> viharaAns = req.getViharaAnswers();
        if (viharaAns != null) {
            String act = viharaAns.getOrDefault("activity", "").toLowerCase();
            if (act.contains("light") || act.contains("mod")) viharaScore += 2;
            else if (act.contains("high")) viharaScore += 1;

            String sleep = viharaAns.getOrDefault("sleep", "").toLowerCase();
            if (sleep.contains("7-8")) viharaScore += 2;
            else if (sleep.contains("6-7")) viharaScore += 1;

            String stress = viharaAns.getOrDefault("stress", "").toLowerCase();
            if (stress.contains("low")) viharaScore += 2;
            else if (stress.contains("mod")) viharaScore += 1;

            String rout = viharaAns.getOrDefault("routine", "").toLowerCase();
            if (rout.contains("good") || rout.contains("excel")) viharaScore += 2;
            else if (rout.contains("avg")) viharaScore += 1;

            String hab = viharaAns.getOrDefault("habits", "").toLowerCase();
            if (hab.contains("none")) viharaScore += 2;
            else if (hab.contains("occ")) viharaScore += 1;
        }

        int totalLifestyle = aharaScore + viharaScore;
        String lifestyleBadge;
        if (totalLifestyle >= 16) lifestyleBadge = "Excellent";
        else if (totalLifestyle >= 10) lifestyleBadge = "Balanced";
        else if (totalLifestyle >= 5) lifestyleBadge = "Needs Attention";
        else lifestyleBadge = "Imbalanced";

        
        
        
        Map<String, Object> dashavidhaMap = new LinkedHashMap<>();
        Map<String, String> dashAnswers = req.getDashavidhaAnswers();

        
        dashavidhaMap.put("prakriti", Map.of("result", calculatedPrakriti, "vataScore", vata, "pittaScore", pitta, "kaphaScore", kapha));
        
        
        if (req.getVikriti() != null) {
            dashavidhaMap.put("vikriti", Map.of(
                "doshas", req.getVikriti().getDoshas() != null ? req.getVikriti().getDoshas() : List.of(),
                "symptoms", req.getVikriti().getSymptoms() != null ? req.getVikriti().getSymptoms() : List.of(),
                "severity", req.getVikriti().getSeverity() != null ? req.getVikriti().getSeverity() : "none",
                "duration", req.getVikriti().getDuration() != null ? req.getVikriti().getDuration() : "less-than-1-week"
            ));
        } else {
            dashavidhaMap.put("vikriti", Map.of("result", "Balanced"));
        }

        
        if (dashAnswers != null) {
            for (String param : List.of("sara", "samhanana", "pramana", "satmya", "satva", "vyayama")) {
                String val = dashAnswers.getOrDefault(param, "madhyama").toLowerCase();
                int score = val.contains("prav") || val.contains("excel") || val.contains("samyak") || val.contains("strong") || val.contains("supra") ? 3 : (val.contains("avar") || val.contains("poor") || val.contains("heena") || val.contains("weak") || val.contains("adhika") ? 1 : 2);
                dashavidhaMap.put(param, Map.of("grade", val, "score", score, "percentage", Math.round((score / 3.0) * 1000.0) / 10.0));
            }

            
            String abhy = dashAnswers.getOrDefault("abhyavaharana", "madhyama").toLowerCase();
            String jar = dashAnswers.getOrDefault("jarana", "madhyama").toLowerCase();
            int s1 = abhy.contains("prav") ? 3 : (abhy.contains("avar") ? 1 : 2);
            int s2 = jar.contains("prav") ? 3 : (jar.contains("avar") ? 1 : 2);
            double aharaShaktiAvg = (s1 + s2) / 2.0;
            dashavidhaMap.put("aharaShakti", Map.of("abhyavaharana", abhy, "jarana", jar, "score", aharaShaktiAvg, "percentage", Math.round((aharaShaktiAvg / 3.0) * 1000.0) / 10.0));

            
            String vayaVal = dashAnswers.getOrDefault("vaya", "madhyama").toLowerCase();
            dashavidhaMap.put("vaya", Map.of("category", vayaVal, "description", vayaVal.contains("bal") ? "Childhood" : (vayaVal.contains("vrid") ? "Old Age" : "Adult")));
        }

        
        List<String> tastePreferenceList = List.of();
        String waterIntakeVal = "adequate";
        if (aharaAns != null) {
            Object tasteObj = aharaAns.get("taste");
            if (tasteObj instanceof List<?>) {
                tastePreferenceList = ((List<?>) tasteObj).stream().map(Object::toString).toList();
            } else if (tasteObj instanceof String) {
                tastePreferenceList = List.of(tasteObj.toString());
            }

            if (aharaAns.get("water") != null) {
                waterIntakeVal = String.valueOf(aharaAns.get("water"));
            }
        }

        
        
        
        AyushAssessment assessment = repository.findBySessionId(sessionId)
                .orElse(AyushAssessment.builder()
                        .session(session)
                        .patient(session.getPatient())
                        .build());

        assessment.setVataScore(vata);
        assessment.setPittaScore(pitta);
        assessment.setKaphaScore(kapha);
        assessment.setPrakritiResult(calculatedPrakriti);

        String vikritiStr = "Imbalance: Vata=" + vata + ", Pitta=" + pitta + ", Kapha=" + kapha;
        assessment.setVikritiSummary(vikritiStr);

        assessment.setAgniType(agniType);
        assessment.setAgniDescription("Calculated Agni Score: " + agniScore + "/9 (Gauge: " + agniGauge + ")");
        assessment.setKoshthaType(req.getKoshthaType() != null ? req.getKoshthaType() : "MADHYAMA");

        assessment.setSamhanana(dashAnswers != null ? dashAnswers.get("samhanana") : req.getSamhanana());
        assessment.setPramana(dashAnswers != null ? dashAnswers.get("pramana") : req.getPramana());
        assessment.setSatmya(dashAnswers != null ? dashAnswers.get("satmya") : req.getSatmya());
        assessment.setSattva(dashAnswers != null ? dashAnswers.get("satva") : req.getSattva());
        assessment.setAharaShakti(dashAnswers != null ? dashAnswers.get("abhyavaharana") : req.getAharaShakti());
        assessment.setVyayamaShakti(dashAnswers != null ? dashAnswers.get("vyayama") : req.getVyayamaShakti());
        assessment.setVaya(dashAnswers != null ? dashAnswers.get("vaya") : req.getVaya());

        assessment.setAharaVihara(Map.of(
            "aharaScore", aharaScore,
            "viharaScore", viharaScore,
            "totalScore", totalLifestyle,
            "badge", lifestyleBadge,
            "tastePreference", tastePreferenceList,
            "waterIntake", waterIntakeVal
        ));

        assessment.setNidana(req.getNidana());
        assessment.setIcdTm2Codes(req.getIcdTm2Codes());

        assessment.setCompletenessScore(calculateCompletenessScore(assessment));
        assessment.setIsFinalized(true);

        AyushAssessment saved = repository.save(assessment);

        
        AyushAssessmentResponse response = mapToResponse(saved);
        response.setVataPercentage(Math.round(vataPct * 10.0) / 10.0);
        response.setPittaPercentage(Math.round(pittaPct * 10.0) / 10.0);
        response.setKaphaPercentage(Math.round(kaphaPct * 10.0) / 10.0);
        response.setAgniScore(agniScore);
        response.setAgniGauge(agniGauge);
        response.setLifestyleScore(totalLifestyle);
        response.setLifestyleBadge(lifestyleBadge);
        response.setTastePreference(tastePreferenceList);
        response.setWaterIntake(waterIntakeVal);
        response.setDashavidhaDetails(dashavidhaMap);

        if (req.getVikriti() != null) {
            response.setVikritiSummary(Map.of(
                "doshas", req.getVikriti().getDoshas() != null ? req.getVikriti().getDoshas() : List.of(),
                "symptoms", req.getVikriti().getSymptoms() != null ? req.getVikriti().getSymptoms() : List.of(),
                "severity", req.getVikriti().getSeverity() != null ? req.getVikriti().getSeverity() : "none",
                "duration", req.getVikriti().getDuration() != null ? req.getVikriti().getDuration() : "less-than-1-week"
            ));
        }

        return response;
    }

    @Transactional(readOnly = true)
    public AyushAssessmentResponse getAssessmentForSession(UUID sessionId) {
        AyushAssessment assessment = repository.findBySessionId(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("AYUSH assessment not found for session ID: " + sessionId));
        if (assessment.getIsFinalized() == null) {
            assessment.setIsFinalized(true);
        }
        return mapToResponse(assessment);
    }

    @Transactional(readOnly = true)
    public com.medikiosk.model.dto.response.AyushRecommendationsResponse getRecommendationsForSession(UUID sessionId) {
        AyushAssessmentResponse fullResp = getAssessmentForSession(sessionId);
        return com.medikiosk.model.dto.response.AyushRecommendationsResponse.builder()
                .sessionId(fullResp.getSessionId())
                .prakritiResult(fullResp.getPrakritiResult())
                .vikritiSummary(fullResp.getVikritiSummary() != null ? fullResp.getVikritiSummary().toString() : "Balanced")
                .dietRecommendations(fullResp.getDietRecommendations())
                .lifestyleRecommendations(fullResp.getLifestyleRecommendations())
                .recommendedYoga(fullResp.getRecommendedYoga())
                .build();
    }

    @Transactional(readOnly = true)
    public byte[] generateSummaryPdf(UUID sessionId) {
        return generateSummaryPdf(sessionId, "en");
    }

    @Transactional(readOnly = true)
    public byte[] generateSummaryPdf(UUID sessionId, String lang) {
        AyushAssessmentResponse response = getAssessmentForSession(sessionId);
        return pdfService.generateAyushSummaryPdf(response, lang);
    }

    private String calculatePrakriti(int vata, int pitta, int kapha) {
        int maxScore = Math.max(vata, Math.max(pitta, kapha));
        if (maxScore == 0) return "Kapha - Pitta Prakriti";

        int threshold = Math.max(0, maxScore - 5);

        List<DoshaScore> dominantList = new ArrayList<>();
        if (vata >= threshold) dominantList.add(new DoshaScore("Vata", vata));
        if (pitta >= threshold) dominantList.add(new DoshaScore("Pitta", pitta));
        if (kapha >= threshold) dominantList.add(new DoshaScore("Kapha", kapha));

        dominantList.sort((a, b) -> Integer.compare(b.score, a.score));

        if (dominantList.size() >= 2) {
            return dominantList.get(0).name + " - " + dominantList.get(1).name + " Prakriti";
        } else if (dominantList.size() == 1) {
            return dominantList.get(0).name + " Dominant Prakriti";
        }

        return "Kapha - Pitta Prakriti";
    }

    private String calculateVikritiSummary(List<String> physical, List<String> mental) {
        if ((physical == null || physical.isEmpty()) && (mental == null || mental.isEmpty())) {
            return "Pitta & Kapha Imbalance";
        }
        int vImbalance = 0, pImbalance = 0, kImbalance = 0;
        
        if (physical != null) {
            for (String s : physical) {
                String upper = s.toUpperCase();
                if (upper.contains("GAS") || upper.contains("CONSTIPATION") || upper.contains("ACHE")) vImbalance++;
                if (upper.contains("ACIDITY") || upper.contains("FEVER") || upper.contains("SKIN")) pImbalance++;
                if (upper.contains("LOOSE") || upper.contains("FATIGUE")) kImbalance++;
            }
        }
        if (mental != null) {
            for (String s : mental) {
                String upper = s.toUpperCase();
                if (upper.contains("ANXIETY") || upper.contains("FOCUS") || upper.contains("SLEEP")) vImbalance++;
                if (upper.contains("STRESS") || upper.contains("IRRITABILITY")) pImbalance++;
                if (upper.contains("LOW_MOOD") || upper.contains("MOOD")) kImbalance++;
            }
        }

        List<String> imbs = new ArrayList<>();
        if (pImbalance >= vImbalance && pImbalance >= kImbalance) imbs.add("Pitta");
        if (kImbalance >= vImbalance) imbs.add("Kapha");
        if (vImbalance > pImbalance && vImbalance > kImbalance) imbs.add("Vata");

        if (imbs.isEmpty()) return "Pitta & Kapha Imbalance";
        return String.join(" & ", imbs) + " Imbalance";
    }

    private String deriveAgniType(String appetite, String fallbackAgni) {
        if (fallbackAgni != null) return fallbackAgni;
        if (appetite == null) return "Madhyama (Moderate)";

        String upper = appetite.toUpperCase();
        if (upper.contains("STRONG")) return "Tikshnagni (Strong)";
        if (upper.contains("LOW")) return "Mandagni (Low)";
        if (upper.contains("IRREGULAR")) return "Vishamagni (Irregular)";
        return "Samagni / Madhyama (Moderate)";
    }

    private int calculateCompletenessScore(AyushAssessment a) {
        int filled = 0;
        int total = 16;

        if (a.getVataScore() != null && a.getVataScore() > 0) filled++;
        if (a.getPittaScore() != null && a.getPittaScore() > 0) filled++;
        if (a.getKaphaScore() != null && a.getKaphaScore() > 0) filled++;
        if (a.getPrakritiResult() != null) filled++;
        if (a.getAgniType() != null) filled++;
        if (a.getKoshthaType() != null) filled++;
        if (a.getSamhanana() != null) filled++;
        if (a.getPramana() != null) filled++;
        if (a.getSatmya() != null) filled++;
        if (a.getSattva() != null) filled++;
        if (a.getAharaShakti() != null) filled++;
        if (a.getVyayamaShakti() != null) filled++;
        if (a.getVaya() != null) filled++;
        if (a.getAharaVihara() != null && !a.getAharaVihara().isEmpty()) filled++;
        if (a.getNidana() != null && !a.getNidana().isBlank()) filled++;
        if (a.getIcdTm2Codes() != null && !a.getIcdTm2Codes().isEmpty()) filled++;

        return (filled * 100) / total;
    }

    private AyushAssessmentResponse mapToResponse(AyushAssessment a) {
        int v = a.getVataScore() != null ? a.getVataScore() : 25;
        int p = a.getPittaScore() != null ? a.getPittaScore() : 35;
        int k = a.getKaphaScore() != null ? a.getKaphaScore() : 40;
        int total = Math.max(1, v + p + k);

        double vPct = Math.round((v * 100.0 / total) * 10.0) / 10.0;
        double pPct = Math.round((p * 100.0 / total) * 10.0) / 10.0;
        double kPct = Math.round((k * 100.0 / total) * 10.0) / 10.0;

        String prakritiResult = a.getPrakritiResult() != null ? a.getPrakritiResult() : "Kapha - Pitta Prakriti";
        String prakritiDesc = "You have " + prakritiResult + " constitution. You may have strong stamina, good immunity, and sharp metabolism.";
        String vikritiSummary = a.getVikritiSummary() != null ? a.getVikritiSummary() : "Pitta & Kapha Imbalance";

        
        List<String> quickView;
        List<String> focusAreas;
        List<String> dietRecs;
        List<String> lifestyleRecs;
        List<String> yogaRecs;

        if (vPct > pPct && vPct > kPct) {
            quickView = List.of(
                "Vata dominance observed with high mobility",
                "Digestive fire variable (Vishamagni)",
                "Watch for joint dryness, cold sensitivity and anxiety"
            );
            focusAreas = List.of(
                "Warm & grounding diet",
                "Regular daily sleep routine",
                "Warm oil massage (Abhyanga)",
                "Stress management & hydration"
            );
            dietRecs = List.of("Warm cooked foods", "Favor sweet, sour and salty tastes");
            lifestyleRecs = List.of("Maintain regular routine", "Protect from cold winds");
            yogaRecs = List.of("Balasana", "Bhujangasana", "Nadi Shodhana");
        } else if (kPct > pPct && kPct > vPct) {
            quickView = List.of(
                "Kapha dominance with heavy physical frame",
                "Metabolic rate slow (Mandagni)",
                "Watch for lethargy, mucus build-up and weight gain"
            );
            focusAreas = List.of(
                "Light & spicy diet",
                "Active daily exercise",
                "Avoid daytime sleep",
                "Stay warm and active"
            );
            dietRecs = List.of("Warm light dry foods", "Pungent and bitter tastes");
            lifestyleRecs = List.of("Daily vigorous exercise", "Avoid day sleep");
            yogaRecs = List.of("Surya Namaskar", "Trikonasana", "Kapalabhati");
        } else {
            
            quickView = List.of(
                "Pitta dominance with Vata support",
                "Metabolic strength is moderate",
                "Watch for heat and dryness related issues",
                "Recommend cooling, grounding and nourishing practices"
            );
            focusAreas = List.of(
                "Cooling & calming diet",
                "Regular routine & hydration",
                "Stress management",
                "Adequate sleep"
            );
            dietRecs = List.of("Cooling foods", "Bitter and sweet tastes");
            lifestyleRecs = List.of("Avoid peak heat", "Maintain regular meal times");
            yogaRecs = List.of("Pavanmuktasana", "Vajrasana", "Anulom Vilom");
        }

        String pName = (a.getSession() != null && a.getSession().getPatient() != null)
                ? a.getSession().getPatient().getFullName()
                : "Patient";

        return AyushAssessmentResponse.builder()
                .id(a.getId())
                .sessionId(a.getSession().getId())
                .patientName(pName)
                .vataScore(v)
                .pittaScore(p)
                .kaphaScore(k)
                .vataPercentage(vPct)
                .pittaPercentage(pPct)
                .kaphaPercentage(kPct)
                .prakritiResult(prakritiResult)
                .prakritiDescription(prakritiDesc)
                .agniType(a.getAgniType() != null ? a.getAgniType() : "Madhyama (Moderate)")
                .agniDescription(a.getAgniDescription())
                .koshthaType(a.getKoshthaType() != null ? a.getKoshthaType() : "Madhyama")
                .vikritiSummary(Map.of("summary", vikritiSummary))
                .saraAssessment(a.getSaraAssessment())
                .samhanana(a.getSamhanana())
                .pramana(a.getPramana())
                .satmya(a.getSatmya())
                .sattva(a.getSattva())
                .aharaShakti(a.getAharaShakti())
                .vyayamaShakti(a.getVyayamaShakti())
                .vaya(a.getVaya())
                .aharaVihara(a.getAharaVihara())
                .nidana(a.getNidana())
                .icdTm2Codes(a.getIcdTm2Codes())
                .doctorsQuickView(quickView)
                .suggestedFocusAreas(focusAreas)
                .dietRecommendations(dietRecs)
                .lifestyleRecommendations(lifestyleRecs)
                .recommendedYoga(yogaRecs)
                .completenessScore(a.getCompletenessScore())
                .isFinalized(a.getIsFinalized())
                .createdAt(a.getCreatedAt())
                .build();
    }

    private static class DoshaScore {
        String name;
        int score;

        DoshaScore(String name, int score) {
            this.name = name;
            this.score = score;
        }
    }
}
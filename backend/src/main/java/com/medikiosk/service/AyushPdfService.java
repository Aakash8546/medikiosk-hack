package com.medikiosk.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.medikiosk.model.dto.response.AyushAssessmentResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.awt.Color;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class AyushPdfService {

    public byte[] generateAyushSummaryPdf(AyushAssessmentResponse response) {
        return generateAyushSummaryPdf(response, "en");
    }

    public byte[] generateAyushSummaryPdf(AyushAssessmentResponse response, String lang) {
        String cleanLang = lang != null ? lang.toLowerCase().trim() : "en";
        log.info("[AYUSH PDF SERVICE] Generating PDF Summary Report for Session: {}, lang: {}", response.getSessionId(), cleanLang);

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 40, 40);

        try {
            PdfWriter.getInstance(document, out);
            document.open();

            
            Color primaryColor = new Color(0, 107, 84);
            Color darkColor = new Color(30, 41, 59);
            Color lightBgColor = new Color(241, 245, 249);
            Color accentOrange = new Color(234, 88, 12);

            
            boolean isNonEnglish = !"en".equals(cleanLang);
            BaseFont customBaseFont = isNonEnglish ? getBaseFontForLang(cleanLang) : null;

            Font titleFont;
            Font sectionFont;
            Font boldFont;
            Font bodyFont;
            Font italicFont;

            if (customBaseFont != null) {
                titleFont = new Font(customBaseFont, 18, Font.BOLD, primaryColor);
                sectionFont = new Font(customBaseFont, 12, Font.BOLD, primaryColor);
                boldFont = new Font(customBaseFont, 10, Font.BOLD, darkColor);
                bodyFont = new Font(customBaseFont, 9, Font.NORMAL, darkColor);
                italicFont = new Font(customBaseFont, 8, Font.ITALIC, Color.GRAY);
            } else {
                titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, primaryColor);
                sectionFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, primaryColor);
                boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, darkColor);
                bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 10, darkColor);
                italicFont = FontFactory.getFont(FontFactory.HELVETICA, 9, Font.ITALIC, Color.GRAY);
            }

            
            PdfPTable headerTable = new PdfPTable(1);
            headerTable.setWidthPercentage(100);
            PdfPCell cell = new PdfPCell();
            cell.setBackgroundColor(lightBgColor);
            cell.setPadding(12);
            cell.setBorder(Rectangle.NO_BORDER);

            String titleText = getTitleText(cleanLang);
            String subTitleText = getSubTitleText(cleanLang);

            Paragraph pTitle = new Paragraph(titleText, titleFont);
            Paragraph pSub = new Paragraph(subTitleText, italicFont);
            cell.addElement(pTitle);
            cell.addElement(pSub);
            headerTable.addCell(cell);
            document.add(headerTable);

            document.add(Chunk.NEWLINE);

            
            PdfPTable metaTable = new PdfPTable(2);
            metaTable.setWidthPercentage(100);
            metaTable.setWidths(new float[]{1, 1});

            String dateStr = "N/A";
            try {
                if (response.getCreatedAt() != null) {
                    dateStr = response.getCreatedAt().format(DateTimeFormatter.ofPattern("dd-MMM-yyyy HH:mm"));
                }
            } catch (Exception e) {
                log.warn("Could not format createdAt date: {}", e.getMessage());
            }

            String pName = response.getPatientName() != null && !response.getPatientName().isBlank()
                    ? response.getPatientName()
                    : getLabel("default_patient_name", cleanLang);

            addMetaCell(metaTable, getLabel("patient_name", cleanLang), pName, boldFont, bodyFont);
            addMetaCell(metaTable, getLabel("session_id", cleanLang), safe(response.getSessionId()), boldFont, bodyFont);
            addMetaCell(metaTable, getLabel("date", cleanLang), dateStr, boldFont, bodyFont);
            addMetaCell(metaTable, getLabel("completeness", cleanLang), (response.getCompletenessScore() != null ? response.getCompletenessScore() : 100) + "%", boldFont, bodyFont);

            document.add(metaTable);
            document.add(Chunk.NEWLINE);

            
            String sec1Title = getLabel("sec1_title", cleanLang);
            document.add(new Paragraph(sec1Title, sectionFont));
            document.add(new Paragraph("---", italicFont));

            PdfPTable doshaTable = new PdfPTable(3);
            doshaTable.setWidthPercentage(100);

            String vataStr = response.getVataPercentage() != null ? String.format("%.0f%%", response.getVataPercentage()) : "25%";
            String pittaStr = response.getPittaPercentage() != null ? String.format("%.0f%%", response.getPittaPercentage()) : "35%";
            String kaphaStr = response.getKaphaPercentage() != null ? String.format("%.0f%%", response.getKaphaPercentage()) : "40%";

            addDoshaCell(doshaTable, getLabel("vata", cleanLang), vataStr, new Color(59, 130, 246), boldFont, customBaseFont);
            addDoshaCell(doshaTable, getLabel("pitta", cleanLang), pittaStr, accentOrange, boldFont, customBaseFont);
            addDoshaCell(doshaTable, getLabel("kapha", cleanLang), kaphaStr, new Color(16, 185, 129), boldFont, customBaseFont);

            document.add(doshaTable);

            String prakritiResult = response.getPrakritiResult() != null ? response.getPrakritiResult() : "Kapha-Pitta Prakriti";
            String prakritiResultDisplay = translatePrakriti(prakritiResult, cleanLang);
            Paragraph prakritiText = new Paragraph(getLabel("dominant_prakriti", cleanLang) + prakritiResultDisplay, boldFont);
            prakritiText.setSpacingBefore(6);
            document.add(prakritiText);

            String prakritiDescStr = response.getPrakritiDescription() != null
                    ? response.getPrakritiDescription()
                    : String.format(getPrakritiDescTemplate(cleanLang), prakritiResultDisplay);
            Paragraph prakritiDesc = new Paragraph(prakritiDescStr, bodyFont);
            prakritiDesc.setSpacingAfter(10);
            document.add(prakritiDesc);

            
            String sec2Title = getLabel("sec2_title", cleanLang);
            document.add(new Paragraph(sec2Title, sectionFont));
            document.add(new Paragraph("---", italicFont));

            PdfPTable paramTable = new PdfPTable(2);
            paramTable.setWidthPercentage(100);
            paramTable.setSpacingBefore(6);

            
            String vikritiDisplay = getBalancedText(cleanLang);
            if (response.getVikritiSummary() != null) {
                Object vs = response.getVikritiSummary();
                if (vs instanceof Map) {
                    Object summaryVal = ((Map<?, ?>) vs).get("summary");
                    vikritiDisplay = summaryVal != null ? summaryVal.toString() : vs.toString();
                } else {
                    vikritiDisplay = vs.toString();
                }
                vikritiDisplay = translateVikriti(vikritiDisplay, cleanLang);
            }

            String agniDisplay = translateAgni(response.getAgniType(), cleanLang);
            String koshthaDisplay = translateKoshtha(response.getKoshthaType(), cleanLang);
            String lifestyleBadge = translateBadge(response.getLifestyleBadge(), cleanLang);

            addMetaCell(paramTable, getLabel("vikriti_label", cleanLang), vikritiDisplay, boldFont, bodyFont);
            addMetaCell(paramTable, getLabel("agni_label", cleanLang), agniDisplay, boldFont, bodyFont);
            addMetaCell(paramTable, getLabel("koshtha_label", cleanLang), koshthaDisplay, boldFont, bodyFont);
            addMetaCell(paramTable, getLabel("lifestyle_label", cleanLang), lifestyleBadge, boldFont, bodyFont);

            document.add(paramTable);
            document.add(Chunk.NEWLINE);

            
            String sec3Title = getLabel("sec3_title", cleanLang);
            document.add(new Paragraph(sec3Title, sectionFont));
            document.add(new Paragraph("---", italicFont));

            
            Paragraph dietTitle = new Paragraph(getLabel("diet_title", cleanLang), boldFont);
            dietTitle.setSpacingBefore(6);
            document.add(dietTitle);
            document.add(buildBulletList(response.getDietRecommendations(), getDefaultDiet(cleanLang), bodyFont));

            
            Paragraph lifeTitle = new Paragraph(getLabel("lifestyle_title", cleanLang), boldFont);
            lifeTitle.setSpacingBefore(6);
            document.add(lifeTitle);
            document.add(buildBulletList(response.getLifestyleRecommendations(), getDefaultLifestyle(cleanLang), bodyFont));

            
            Paragraph yogaTitle = new Paragraph(getLabel("yoga_title", cleanLang), boldFont);
            yogaTitle.setSpacingBefore(6);
            document.add(yogaTitle);
            document.add(buildBulletList(response.getRecommendedYoga(), getDefaultYoga(cleanLang), bodyFont));

            
            document.add(Chunk.NEWLINE);
            Paragraph footer = new Paragraph(getFooterText(cleanLang), italicFont);
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);

            document.close();
            log.info("[AYUSH PDF SERVICE] PDF generated successfully in {} mode, size: {} bytes", cleanLang, out.size());
            return out.toByteArray();

        } catch (Exception e) {
            log.error("[AYUSH PDF SERVICE] Failed to generate PDF for lang {}: {}", cleanLang, e.getMessage(), e);
            throw new RuntimeException("Could not generate AYUSH summary PDF report: " + e.getMessage(), e);
        }
    }

    private BaseFont getBaseFontForLang(String lang) {
        String cleanLang = lang != null ? lang.toLowerCase().trim() : "en";

        
        if ("hi".equals(cleanLang) || "mr".equals(cleanLang)) {
            try (InputStream is = getClass().getResourceAsStream("/fonts/NotoSansDevanagari-Regular.ttf")) {
                if (is != null) {
                    byte[] fontBytes = is.readAllBytes();
                    return BaseFont.createFont("NotoSansDevanagari-Regular.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, true, fontBytes, null);
                }
            } catch (Exception e) {
                log.warn("[AYUSH PDF SERVICE] Failed to load Devanagari TTF font: {}", e.getMessage());
            }
        }

        
        if ("bn".equals(cleanLang)) {
            String[] fontPaths = {
                "/System/Library/Fonts/Supplemental/Bangla Sangam MN.ttc,0",
                "/System/Library/Fonts/KohinoorBangla.ttc,0",
                "/System/Library/Fonts/Supplemental/Bangla MN.ttc,0"
            };
            for (String path : fontPaths) {
                try {
                    return BaseFont.createFont(path, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
                } catch (Exception ignored) {}
            }
        } else if ("ta".equals(cleanLang)) {
            String[] fontPaths = {
                "/System/Library/Fonts/Supplemental/Tamil Sangam MN.ttc,0",
                "/System/Library/Fonts/Supplemental/Tamil MN.ttc,0"
            };
            for (String path : fontPaths) {
                try {
                    return BaseFont.createFont(path, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
                } catch (Exception ignored) {}
            }
        } else if ("kn".equals(cleanLang)) {
            String[] fontPaths = {
                "/System/Library/Fonts/Supplemental/Kannada Sangam MN.ttc,0",
                "/System/Library/Fonts/Supplemental/Kannada MN.ttc,0",
                "/System/Library/Fonts/NotoSansKannada.ttc,0"
            };
            for (String path : fontPaths) {
                try {
                    return BaseFont.createFont(path, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
                } catch (Exception ignored) {}
            }
        }

        
        try (InputStream is = getClass().getResourceAsStream("/fonts/NotoSansDevanagari-Regular.ttf")) {
            if (is != null) {
                byte[] fontBytes = is.readAllBytes();
                return BaseFont.createFont("NotoSansDevanagari-Regular.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, true, fontBytes, null);
            }
        } catch (Exception ignored) {}

        return null;
    }

    private String getTitleText(String lang) {
        return switch (lang) {
            case "hi" -> "मेडीकियोस्क - आयुष सारांश रिपोर्ट";
            case "mr" -> "मेडीकियोस्क - आयुष सारांश अहवाल";
            case "bn" -> "মেডিকিয়স্ক - আয়ুশ সারাংশ রিপোর্ট";
            case "ta" -> "மெடிகியோஸ்க் - ஆயுஷ் சுருக்க அறிக்கை";
            case "kn" -> "ಮೆಡಿಕಿಯಾಸ್ಕ್ - ಆಯುಷ್ ಸಾರಾಂಶ ವರದಿ";
            default -> "MediKiosk - AYUSH Summary Report";
        };
    }

    private String getSubTitleText(String lang) {
        return switch (lang) {
            case "hi" -> "आयुर्वेदिक प्रकृति, विकृति असंतुलन एवं व्यक्तिगत स्वास्थ्य परामर्श";
            case "mr" -> "आयुर्वेदिक प्रकृति, विकृती असंतुलन आणि वैयक्तिक आरोग्य सल्ला";
            case "bn" -> "আয়ুর্বেদিক প্রকৃতি, বিকৃতি ভারসাম্যহীনতা এবং ব্যক্তিগত স্বাস্থ্য পরামর্শ";
            case "ta" -> "ஆயுர்வேத பிரகிருதி, விகிருதி சமநிலையின்மை மற்றும் தனிப்பட்ட சுகாதார ஆலோசனைகள்";
            case "kn" -> "ಆಯುರ್ವೇದ ಪ್ರಕೃತಿ, ವಿಕೃತಿ ಅಸಮತೋಲನ ಮತ್ತು ವೈಯಕ್ತಿಕ ಆರೋಗ್ಯ ಸಲಹೆಗಳು";
            default -> "Ayurvedic Constitution (Prakriti), Imbalances (Vikriti) & Personalized Recommendations";
        };
    }

    private String getLabel(String key, String lang) {
        return switch (key) {
            case "patient_name" -> switch (lang) {
                case "hi" -> "मरीज़ का नाम:";
                case "mr" -> "रुग्णाचे नाव:";
                case "bn" -> "রোগীর নাম:";
                case "ta" -> "நோயாளி பெயர்:";
                case "kn" -> "ರೋಗಿಯ ಹೆಸರು:";
                default -> "Patient Name:";
            };
            case "default_patient_name" -> switch (lang) {
                case "hi" -> "मरीज़";
                case "mr" -> "रुग्ण";
                case "bn" -> "রোগী";
                case "ta" -> "நோயாளி";
                case "kn" -> "ರೋಗಿ";
                default -> "Patient";
            };
            case "session_id" -> switch (lang) {
                case "hi" -> "सत्र आईडी:";
                case "mr" -> "सत्र आयडी:";
                case "bn" -> "সেশন আইডি:";
                case "ta" -> "அமர்வு ஐடி:";
                case "kn" -> "ಸೆಷನ್ ಐಡಿ:";
                default -> "Session ID:";
            };
            case "date" -> switch (lang) {
                case "hi", "mr" -> "दिनांक:";
                case "bn" -> "তারিখ:";
                case "ta" -> "தேதி:";
                case "kn" -> "ದಿನಾಂಕ:";
                default -> "Date:";
            };
            case "completeness" -> switch (lang) {
                case "hi", "mr" -> "मूल्यांकन पूर्णता:";
                case "bn" -> "মূল্যায়ন সম্পূর্ণতা:";
                case "ta" -> "மதிப்பீட்டின் முழுமை:";
                case "kn" -> "ಮೌಲ್ಯಮಾಪನ ಪೂರ್ಣತೆ:";
                default -> "Completeness:";
            };
            case "sec1_title" -> switch (lang) {
                case "hi" -> "1. शरीर प्रकृति एवं दोष संतुलन (Prakriti & Vikriti)";
                case "mr" -> "1. शरीर प्रकृति आणि दोष असंतुलन (Prakriti & Vikriti)";
                case "bn" -> "1. শারীরিক প্রকৃতি ও দোষ ভারসাম্যহীনতা (Prakriti & Vikriti)";
                case "ta" -> "1. உடல் பிரகிருதி மற்றும் தோஷ சமநிலையின்மை (Prakriti & Vikriti)";
                case "kn" -> "1. ಶರೀರ ಪ್ರಕೃತಿ ಮತ್ತು ದೋಷ ಅಸಮತೋಲನ (Prakriti & Vikriti)";
                default -> "1. Constitution & Imbalances (Prakriti & Vikriti)";
            };
            case "vata" -> switch (lang) {
                case "hi", "mr" -> "वात दोष";
                case "bn" -> "বাত দোষ";
                case "ta" -> "வாதா தோஷம்";
                case "kn" -> "ವಾತ ದೋಷ";
                default -> "Vata Dosha";
            };
            case "pitta" -> switch (lang) {
                case "hi", "mr" -> "पित्त दोष";
                case "bn" -> "পিত দোষ";
                case "ta" -> "பித்தா தோஷம்";
                case "kn" -> "ಪಿತ್ತ ದೋಷ";
                default -> "Pitta Dosha";
            };
            case "kapha" -> switch (lang) {
                case "hi", "mr" -> "कफ दोष";
                case "bn" -> "কফ দোষ";
                case "ta" -> "கபா தோஷம்";
                case "kn" -> "ಕಫ ದೋಷ";
                default -> "Kapha Dosha";
            };
            case "dominant_prakriti" -> switch (lang) {
                case "hi", "mr" -> "प्रमुख प्रकृति: ";
                case "bn" -> "প্রধান প্রকৃতি: ";
                case "ta" -> "முதன்மை பிரகிருதி: ";
                case "kn" -> "ಪ್ರಮುಖ ಪ್ರಕೃತಿ: ";
                default -> "Dominant Prakriti: ";
            };
            case "sec2_title" -> switch (lang) {
                case "hi" -> "2. अग्नि, कोष्ठ एवं जीवनशैली स्थिति";
                case "mr" -> "2. अग्नि, कोष्ठ आणि जीवनशैली स्थिती";
                case "bn" -> "2. অগ্নি, কোষ্ঠ ও জীবনযাত্রার অবস্থান";
                case "ta" -> "2. அக்னி, கோஷ்டா மற்றும் வாழ்க்கை முறை அளவுருக்கள்";
                case "kn" -> "2. ಅಗ್ನಿ, ಕೋಷ್ಠ ಮತ್ತು ಜೀವನಶೈಲಿ ಸ್ಥಿತಿ";
                default -> "2. Digestive Strength & Lifestyle Parameters";
            };
            case "vikriti_label" -> switch (lang) {
                case "hi" -> "विकृति असंतुलन:";
                case "mr" -> "विकृती असंतुलन:";
                case "bn" -> "বিকৃতি ভারসাম্যহীনতা:";
                case "ta" -> "விகிருதி சமநிலையின்மை:";
                case "kn" -> "ವಿಕೃತಿ ಅಸಮತೋಲನ:";
                default -> "Vikriti Imbalance:";
            };
            case "agni_label" -> switch (lang) {
                case "hi" -> "अग्नि (पाचन क्षमता):";
                case "mr" -> "अग्नि (पाचन क्षमता):";
                case "bn" -> "অগ্নি (পাচন ক্ষমতা):";
                case "ta" -> "அக்னி (செரிமான சக்தி):";
                case "kn" -> "ಅಗ್ನಿ (ಜೀರ್ಣ ಶಕ್ತಿ):";
                default -> "Agni (Digestive Fire):";
            };
            case "koshtha_label" -> switch (lang) {
                case "hi" -> "कोष्ठ (मल निष्कासन):";
                case "mr" -> "कोष्ठ (मल विसर्जन):";
                case "bn" -> "কোষ্ঠ (মল নিষ্কাশন):";
                case "ta" -> "கோஷ்டா (குடல் இயல்பு):";
                case "kn" -> "ಕೋಷ್ಠ (ಮಲ ವಿಸರ್ಜನೆ):";
                default -> "Koshtha (Bowel Nature):";
            };
            case "lifestyle_label" -> switch (lang) {
                case "hi", "mr" -> "जीवनशैली स्कोर:";
                case "bn" -> "জীবনযাত্রা স্কোর:";
                case "ta" -> "வாழ்க்கை முறை மதிப்பெண்:";
                case "kn" -> "ಜೀವನಶೈಲಿ ಸ್ಕೋರ್:";
                default -> "Lifestyle Score:";
            };
            case "sec3_title" -> switch (lang) {
                case "hi" -> "3. व्यक्तिगत आयुर्वेदिक परामर्श एवं सुझाव";
                case "mr" -> "3. वैयक्तिक आयुर्वेदिक सल्ला व शिफारसी";
                case "bn" -> "3. ব্যক্তিগত আয়ুর্বেদিক পরামর্শ ও নির্দেশিকা";
                case "ta" -> "3. தனிப்பட்ட ஆயுர்வேத ஆலோசனைகள்";
                case "kn" -> "3. ವೈಯಕ್ತಿಕ ಆಯುರ್ವೇದ ಸಲಹೆಗಳು";
                default -> "3. Personalized Ayurvedic Recommendations";
            };
            case "diet_title" -> switch (lang) {
                case "hi" -> "आहार परामर्श:";
                case "mr" -> "आहार सल्ला:";
                case "bn" -> "আহার পরামর্শ:";
                case "ta" -> "உணவு ஆலோசனைகள்:";
                case "kn" -> "ಆಹಾರ ಸಲಹೆಗಳು:";
                default -> "Diet Recommendations:";
            };
            case "lifestyle_title" -> switch (lang) {
                case "hi" -> "विहार (जीवनशैली) परामर्श:";
                case "mr" -> "विहार (जीवनशैली) सल्ला:";
                case "bn" -> "জীবনযাত্রা परामर्श:";
                case "ta" -> "வாழ்க்கை முறை ஆலோசனைகள்:";
                case "kn" -> "ಜೀವನಶೈಲಿ ಸಲಹೆಗಳು:";
                default -> "Lifestyle Recommendations:";
            };
            case "yoga_title" -> switch (lang) {
                case "hi" -> "अनुशंसित योग एवं प्राणायाम:";
                case "mr" -> "शिफारस केलेले योग व प्राणायाम:";
                case "bn" -> "সুপারিশকৃত যোগ এবং প্রাণায়াম:";
                case "ta" -> "பரிந்துரைக்கப்பட்ட யோகாசனங்கள் & பிராணாயாமம்:";
                case "kn" -> "ಶಿಫಾರಸು ಮಾಡಿದ ಯೋಗಾಸನ ಮತ್ತು ಪ್ರಾಣಾಯಾಮ:";
                default -> "Recommended Yoga Asanas & Pranayama:";
            };
            default -> "";
        };
    }

    private String getPrakritiDescTemplate(String lang) {
        return switch (lang) {
            case "hi" -> "आपकी मुख्य प्रकृति %s है।";
            case "mr" -> "तुमची मुख्य प्रकृति %s आहे.";
            case "bn" -> "আপনার প্রধান প্রকৃতি হলো %s।";
            case "ta" -> "உங்கள் முதன்மை பிரகிருதி %s ஆகும்.";
            case "kn" -> "ನಿಮ್ಮ ಪ್ರಮುಖ ಪ್ರಕೃತಿ %s ಆಗಿದೆ.";
            default -> "You have %s constitution.";
        };
    }

    private String translatePrakriti(String text, String lang) {
        if (text == null) text = "Kapha-Pitta Prakriti";
        return switch (lang) {
            case "hi", "mr" -> text.replace("Vata", "वात")
                    .replace("Pitta", "पित्त")
                    .replace("Kapha", "कफ")
                    .replace("Prakriti", "प्रकृति")
                    .replace("Dominant", "प्रमुख");
            case "bn" -> text.replace("Vata", "বাত")
                    .replace("Pitta", "পিত")
                    .replace("Kapha", "কফ")
                    .replace("Prakriti", "প্রকৃতি")
                    .replace("Dominant", "প্রধান");
            case "ta" -> text.replace("Vata", "வாதா")
                    .replace("Pitta", "பித்தா")
                    .replace("Kapha", "கபா")
                    .replace("Prakriti", "பிரகிருதி")
                    .replace("Dominant", "முதன்மை");
            case "kn" -> text.replace("Vata", "ವಾತ")
                    .replace("Pitta", "ಪಿತ್ತ")
                    .replace("Kapha", "ಕಫ")
                    .replace("Prakriti", "ಪ್ರಕೃತಿ")
                    .replace("Dominant", "ಪ್ರಮುಖ");
            default -> text;
        };
    }

    private String translateVikriti(String text, String lang) {
        if (text == null) return getBalancedText(lang);
        if (text.equalsIgnoreCase("Balanced")) return getBalancedText(lang);
        return switch (lang) {
            case "hi", "mr" -> text.replace("Vata", "वात")
                    .replace("Pitta", "पित्त")
                    .replace("Kapha", "कफ")
                    .replace("Imbalance", "असंतुलन");
            case "bn" -> text.replace("Vata", "বাত")
                    .replace("Pitta", "পিত")
                    .replace("Kapha", "কফ")
                    .replace("Imbalance", "ভারসাম্যহীনতা");
            case "ta" -> text.replace("Vata", "வாதா")
                    .replace("Pitta", "பித்தா")
                    .replace("Kapha", "கபா")
                    .replace("Imbalance", "சமநிலையின்மை");
            case "kn" -> text.replace("Vata", "ವಾತ")
                    .replace("Pitta", "ಪಿತ್ತ")
                    .replace("Kapha", "ಕಫ")
                    .replace("Imbalance", "ಅಸಮತೋಲನ");
            default -> text;
        };
    }

    private String getBalancedText(String lang) {
        return switch (lang) {
            case "hi", "mr" -> "संतुलित";
            case "bn" -> "ভারসাম্যপূর্ণ (Balanced)";
            case "ta" -> "சீரானது (Balanced)";
            case "kn" -> "ಸಮತೋಲಿತ (Balanced)";
            default -> "Balanced";
        };
    }

    private String translateAgni(String text, String lang) {
        if (text == null) text = "Madhyama (Moderate)";
        if ("en".equals(lang)) return text;

        String lower = text.toLowerCase();
        if (lower.contains("manda")) {
            return switch (lang) {
                case "hi", "mr" -> "मंद अग्नि (Sluggish)";
                case "bn" -> "মন্দ অগ্নি (Sluggish)";
                case "ta" -> "மந்த அக்னி (Sluggish)";
                case "kn" -> "ಮಂದ ಅಗ್ನಿ (Sluggish)";
                default -> "Mandagni (Sluggish)";
            };
        } else if (lower.contains("tikshna")) {
            return switch (lang) {
                case "hi", "mr" -> "तीक्ष्ण अग्नि (Intense)";
                case "bn" -> "তীক্ষ্ণ অগ্নি (Intense)";
                case "ta" -> "தீக்ஷ்ண அக்னி (Intense)";
                case "kn" -> "ತೀಕ್ಷ್ಣ ಅಗ್ನಿ (Intense)";
                default -> "Tikshnagni (Intense)";
            };
        } else if (lower.contains("vishama")) {
            return switch (lang) {
                case "hi", "mr" -> "विषम अग्नि (Irregular)";
                case "bn" -> "বিষম অগ্নি (Irregular)";
                case "ta" -> "விஷம அக்னி (Irregular)";
                case "kn" -> "ವಿಷಮ ಅಗ್ನಿ (Irregular)";
                default -> "Vishamagni (Irregular)";
            };
        } else {
            return switch (lang) {
                case "hi", "mr" -> "मध्यम अग्नि / सम अग्नि (Moderate)";
                case "bn" -> "মধ্যম অগ্নি (Moderate)";
                case "ta" -> "சம அக்னி (Moderate)";
                case "kn" -> "ಮಧ್ಯಮ ಅಗ್ನಿ (Moderate)";
                default -> "Samagni / Madhyama (Moderate)";
            };
        }
    }

    private String translateKoshtha(String text, String lang) {
        if (text == null) text = "Madhyama";
        if ("en".equals(lang)) return text;

        String lower = text.toLowerCase();
        if (lower.contains("krura")) {
            return switch (lang) {
                case "hi", "mr" -> "क्रूर कोष्ठ (Hard)";
                case "bn" -> "ক্রূর কোষ্ঠ (Hard)";
                case "ta" -> "க்ரூர கோஷ்டா (Hard)";
                case "kn" -> "ಕ್ರೂರ ಕೋಷ್ಠ (Hard)";
                default -> "Krura Koshtha (Hard)";
            };
        } else if (lower.contains("mridu")) {
            return switch (lang) {
                case "hi", "mr" -> "मृदु कोष्ठ (Soft)";
                case "bn" -> "মৃদু কোষ্ঠ (Soft)";
                case "ta" -> "மிருது கோஷ்டா (Soft)";
                case "kn" -> "ಮೃದು ಕೋಷ್ಠ (Soft)";
                default -> "Mridu Koshtha (Soft)";
            };
        } else {
            return switch (lang) {
                case "hi", "mr" -> "मध्यम कोष्ठ (Moderate)";
                case "bn" -> "मध्यम কোষ্ঠ (Moderate)";
                case "ta" -> "மத்தியம கோஷ்டா (Moderate)";
                case "kn" -> "ಮಧ್ಯಮ ಕೋಷ್ಠ (Moderate)";
                default -> "Madhyama Koshtha (Moderate)";
            };
        }
    }

    private String translateBadge(String text, String lang) {
        if (text == null) return getBalancedText(lang);
        if ("en".equals(lang)) return text;
        if (text.equalsIgnoreCase("Balanced")) return getBalancedText(lang);
        if (text.equalsIgnoreCase("Optimal") || text.equalsIgnoreCase("Excellent")) {
            return switch (lang) {
                case "hi", "mr" -> "उत्कृष्ट";
                case "bn" -> "উৎকৃষ্ট";
                case "ta" -> "சிறந்தது";
                case "kn" -> "ಉತ್ತಮ";
                default -> "Optimal";
            };
        }
        if (text.equalsIgnoreCase("Needs Attention")) {
            return switch (lang) {
                case "hi", "mr" -> "ध्यान योग्य";
                case "bn" -> "মনোযোগ প্রয়োজন";
                case "ta" -> "கவனம் தேவை";
                case "kn" -> "ಗಮನ ಬೇಕು";
                default -> "Needs Attention";
            };
        }
        return text;
    }

    private List<String> getDefaultDiet(String lang) {
        return switch (lang) {
            case "hi" -> List.of("सुपाच्य, ताज़ा एवं गर्म भोजन का सेवन करें", "अत्यधिक मसालेदार, तला हुआ व खट्टा भोजन न लें", "मधुर एवं तिक्त (कड़वे) रस युक्त आहार लें");
            case "mr" -> List.of("पचायला हलके, ताजे आणि गरम अन्न घ्या", "जास्त तिखट, तळलेले आणि आंबट अन्न टाळा", "गोड आणि कडू चवीचा आहारात समावेश करा");
            case "bn" -> List.of("সহজপাচ্য, তাজা ও গরম খাবার গ্রহণ করুন", "অতিরিক্ত মশলাযুক্ত, ভাজা ও টক খাবার এড়িয়ে চলুন", "মিষ্টি ও তিক্ত রসযুক্ত খাবার খাদ্যতালিকায় রাখুন");
            case "ta" -> List.of("மிதமான, சூடான மற்றும் எளிதில் செரிமானம் ஆகும் உணவை உட்கொள்ளவும்", "அதிக காரமான, பொரித்த மற்றும் புளிப்பான உணவுகளைத் தவிர்க்கவும்", "இனிப்பு மற்றும் கசப்பு சுவை கொண்ட உணவுகளைச் சேர்க்கவும்");
            case "kn" -> List.of("ಸುಲಭವಾಗಿ ಜೀರ್ಣವಾಗುವ, ತಾಜಾ ಮತ್ತು ಬಿಸಿ ಆಹಾರ ಸೇವಿಸಿ", "ಹೆಚ್ಚು ಖಾರ, ಕರಿದ ಮತ್ತು ಹುಳಿ ಆಹಾರವನ್ನು ತಪ್ಪಿಸಿ", "ಸಿಹಿ ಮತ್ತು ಕಹಿ ರಸಯುಕ್ತ ಆಹಾರವನ್ನು ಸೇರಿಸಿ");
            default -> List.of("Prefer warm, light, easily digestible food", "Avoid oily, spicy and sour food", "Include bitter and sweet tastes");
        };
    }

    private List<String> getDefaultLifestyle(String lang) {
        return switch (lang) {
            case "hi" -> List.of("भोजन का समय नियमित रखें", "दिन में सोने (दिवा स्वप्न) से बचें", "प्रतिदिन हल्का व्यायाम व योग करें");
            case "mr" -> List.of("जेवणाची वेळ नियमित ठेवा", "दिवसा झोपणे (दिवा स्वप्न) टाळा", "रोज हलका व्यायाम आणि योग करा");
            case "bn" -> List.of("খাবারের সময় নিয়মিত রাখুন", "দিনে ঘুমানো এড়িয়ে চলুন", "প্রতিদিন হালকা ব্যায়াম ও যোগব্যায়াম করুন");
            case "ta" -> List.of("உணவு உண்ணும் நேரத்தை சீராகப் பராமரிக்கவும்", "பகல் நேரத் தூக்கத்தைத் தவிர்க்கவும்", "தினமும் லேசான உடற்பயிற்சி அல்லது யோகா செய்யவும்");
            case "kn" -> List.of("ಆಹಾರ ಸೇವನೆಯ ಸಮಯವನ್ನು ನಿಯಮಿತವಾಗಿರಿಸಿ", "ಹಗಲು ನಿದ್ರೆಯನ್ನು ತಪ್ಪಿಸಿ", "ದಿನವೂ ಹಗುರವಾದ ವ್ಯಾಯಾಮ ಅಥವಾ ಯೋಗ ಮಾಡಿ");
            default -> List.of("Maintain regular meal timings", "Avoid day sleep (Diva Swapna)", "Practice mild exercise / yoga daily");
        };
    }

    private List<String> getDefaultYoga(String lang) {
        return switch (lang) {
            case "hi" -> List.of("पवनमुक्तासन", "वज्रासन (भोजन के बाद)", "अनुलोम-विलोम प्राणायाम");
            case "mr" -> List.of("पवनमुक्तासन", "वज्रासन (जेवणानंतर)", "अनुलोम-विलोम प्राणायाम");
            case "bn" -> List.of("পবনমুক্তাসন", "বজ্রাসন (খাবারের পর)", "অনুলোম-বিলোম প্রাণায়াম");
            case "ta" -> List.of("பவனமுத்தாசனம்", "வஜிராசனம் (உணவுக்குப் பின்)", "அனுலோம் விலோம் பிராணாயாமம்");
            case "kn" -> List.of("ಪವನಮುಕ್ತಾಸನ", "ವಜ್ರಾಸನ (ಊಟದ ನಂತರ)", "ಅನುಲೋಮ-ವಿಲೋಮ ಪ್ರಾಣಾಯಾಮ");
            default -> List.of("Pavanmuktasana", "Vajrasana (post meals)", "Anulom Vilom Pranayama");
        };
    }

    private String getFooterText(String lang) {
        return switch (lang) {
            case "hi" -> "यह मेडीकियोस्क द्वारा जनरेटेड एआई-सहायक आयुष रिपोर्ट है। कृपया चिकित्सकीय निदान हेतु आयुर्वेद चिकित्सक से परामर्श लें।";
            case "mr" -> "हे मेडीकियोस्कद्वारे तयार केलेले एआय-सहाय्यित आयुष अहवाल आहे. वैद्यकीय निदानासाठी कृपया आयुर्वेद तज्ञांचा सल्ला घ्या.";
            case "bn" -> "এটি মেডিকিয়স্ক দ্বারা তৈরি এআই-সহায়তা প্রাপ্ত আয়ুশ রিপোর্ট। চিকিৎসা সংক্রান্ত পরামর্শের জন্য আয়ুর্বেদিক চিকিৎসকের পরামর্শ নিন।";
            case "ta" -> "இது மெடிகியோஸ்க் மூலம் உருவாக்கப்பட்ட AI-உதவி ஆயுஷ் அறிக்கையாகும். மருத்துவ நோயறிதலுக்கு ஆயுர்வேத மருத்துவரை அணுகவும்.";
            case "kn" -> "ಇದು ಮೆಡಿಕಿಯಾಸ್ಕ್‌ನಿಂದ ರಚಿಸಲಾದ ಎಐ-ಸಹಾಯಿತ ಆಯುಷ್ ವರದಿಯಾಗಿದೆ. ವೈದ್ಯಕೀಯ ರೋಗನಿರ್ಣಯಕ್ಕೆ ದಯವಿಟ್ಟು ಆಯುರ್ವೇದ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ.";
            default -> "This is an AI-assisted AYUSH clinical summary generated by MediKiosk. Please consult an Ayurvedic Practitioner for clinical diagnosis.";
        };
    }

    private String safe(Object obj) {
        return obj != null ? obj.toString() : "N/A";
    }

    private com.lowagie.text.List buildBulletList(java.util.List<String> items, java.util.List<String> defaults, Font font) {
        com.lowagie.text.List list = new com.lowagie.text.List(com.lowagie.text.List.UNORDERED);
        java.util.List<String> source = (items != null && !items.isEmpty()) ? items : defaults;
        for (String item : source) {
            list.add(new ListItem(item != null ? item : "", font));
        }
        return list;
    }

    private void addMetaCell(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell cLabel = new PdfPCell(new Phrase(label, labelFont));
        cLabel.setBorder(Rectangle.NO_BORDER);
        cLabel.setPadding(4);

        PdfPCell cVal = new PdfPCell(new Phrase(value != null ? value : "N/A", valueFont));
        cVal.setBorder(Rectangle.NO_BORDER);
        cVal.setPadding(4);

        table.addCell(cLabel);
        table.addCell(cVal);
    }

    private void addDoshaCell(PdfPTable table, String title, String val, Color color, Font boldFont, BaseFont customBaseFont) {
        PdfPCell c = new PdfPCell();
        c.setPadding(8);
        c.setBackgroundColor(new Color(248, 250, 252));

        Font cFont = (customBaseFont != null)
                ? new Font(customBaseFont, 14, Font.BOLD, color)
                : FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, color);

        Paragraph p1 = new Paragraph(title, boldFont);
        Paragraph p2 = new Paragraph(val, cFont);
        p1.setAlignment(Element.ALIGN_CENTER);
        p2.setAlignment(Element.ALIGN_CENTER);

        c.addElement(p1);
        c.addElement(p2);
        table.addCell(c);
    }
}
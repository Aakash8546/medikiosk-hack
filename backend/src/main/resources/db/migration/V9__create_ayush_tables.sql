-- AYUSH/Ayurvedic assessment per session
CREATE TABLE ayush_assessments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id          UUID UNIQUE NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    patient_id          UUID NOT NULL REFERENCES patients(id),

    -- Prakriti (Body Constitution) — scored 0-10 each
    vata_score          INT DEFAULT 0,
    pitta_score         INT DEFAULT 0,
    kapha_score         INT DEFAULT 0,
    prakriti_result     VARCHAR(50),     -- VATA, PITTA, KAPHA, VATA_PITTA, etc.

    -- Agni (Digestive Fire)
    agni_type           VARCHAR(30),     -- TIKSHNA, MANDA, VISHAMA, SAMA
    agni_description    TEXT,

    -- Koshtha (Bowel Pattern)
    koshtha_type        VARCHAR(30),     -- KRURA, MRUDU, MADHYAMA

    -- Sara (Tissue Quality) — JSONB for flexibility
    sara_assessment     JSONB,           -- [{sara_type, quality, notes}]

    -- Dashavidha Pariksha (10-fold examination)
    samhanana           VARCHAR(50),     -- PRAVARA, MADHYAMA, AVARA (body compactness)
    pramana             VARCHAR(50),     -- body proportion assessment
    satmya              VARCHAR(50),     -- adaptability
    sattva              VARCHAR(50),     -- mental strength: PRAVARA, MADHYAMA, AVARA
    ahara_shakti        VARCHAR(50),     -- digestive capacity
    vyayama_shakti      VARCHAR(50),     -- exercise capacity
    vaya                VARCHAR(20),     -- BALA, MADHYA, VRIDDHA (age category)

    -- Diet & Lifestyle
    ahara_vihara        JSONB,           -- {diet_type, meal_times, food_habits}

    -- Nidana (Causative Factors)
    nidana              TEXT,

    -- NAMASTE/ICD-11 TM2 Coding
    icd_tm2_codes       TEXT[],          -- Array of ICD-11 TM2 codes

    -- Meta
    completeness_score  INT DEFAULT 0,
    is_finalized        BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_ayush_session ON ayush_assessments(session_id);
CREATE INDEX idx_ayush_prakriti ON ayush_assessments(prakriti_result);

-- Seed Prakriti questionnaire (Ayurvedic body constitution assessment)
-- These are added to the existing interview_questions table
INSERT INTO interview_questions (question_key, question_text_en, question_text_hi, question_type, category, sequence_order, applies_to, is_mandatory) VALUES
('PRAKRITI_BODY_FRAME', 'What best describes your body frame?', 'आपके शरीर की बनावट कैसी है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 20, 'AYUSH', true),
('PRAKRITI_SKIN_TYPE', 'How would you describe your skin?', 'आपकी त्वचा कैसी है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 21, 'AYUSH', true),
('PRAKRITI_APPETITE', 'How is your appetite generally?', 'आमतौर पर आपकी भूख कैसी होती है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 22, 'AYUSH', true),
('PRAKRITI_SLEEP', 'How is your sleep pattern?', 'आपकी नींद कैसी है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 23, 'AYUSH', true),
('PRAKRITI_TEMPERAMENT', 'How would you describe your temperament?', 'आपका स्वभाव कैसा है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 24, 'AYUSH', true),
('PRAKRITI_DIGESTION', 'How is your digestion?', 'आपका पाचन कैसा है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 25, 'AYUSH', true),
('PRAKRITI_STRESS_RESPONSE', 'How do you typically respond to stress?', 'तनाव में आप कैसे प्रतिक्रिया करते हैं?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 26, 'AYUSH', true),
('AGNI_ASSESSMENT', 'How would you describe your hunger pattern?', 'आपकी भूख का पैटर्न कैसा है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 27, 'AYUSH', true),
('KOSHTHA_ASSESSMENT', 'How are your bowel movements generally?', 'आपका मल-त्याग आमतौर पर कैसा होता है?', 'SINGLE_CHOICE', 'REVIEW_OF_SYSTEMS', 28, 'AYUSH', true),
('NIDANA_FACTORS', 'What do you think caused or worsened your current problem?', 'आपको क्या लगता है कि आपकी वर्तमान समस्या का कारण क्या है?', 'VOICE', 'REVIEW_OF_SYSTEMS', 29, 'AYUSH', true);

-- Normalized, structured clinical history derived from interview responses
CREATE TABLE clinical_histories (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id          UUID UNIQUE NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    -- Chief complaint
    chief_complaint     TEXT,
    complaint_duration  VARCHAR(100),
    complaint_severity  VARCHAR(20),    -- MILD, MODERATE, SEVERE
    -- History of present illness (structured)
    hpi_onset           VARCHAR(100),
    hpi_character       TEXT,
    hpi_radiation       TEXT,
    hpi_associated_sx   TEXT[],
    hpi_timing          TEXT,
    hpi_exacerbating    TEXT,
    hpi_relieving       TEXT,
    -- Past history (JSONB for flexibility)
    past_medical        JSONB,         -- [{condition, year, status}]
    past_surgical       JSONB,
    past_hospitalization JSONB,
    -- Medications & Allergies
    current_medications JSONB,         -- [{name, dose, frequency, route}]
    known_allergies     JSONB,         -- [{allergen, reaction, severity}]
    -- Family history
    family_history      JSONB,         -- [{relation, condition}]
    -- Personal & lifestyle
    smoking_status      VARCHAR(30),   -- NEVER, CURRENT, FORMER
    alcohol_status      VARCHAR(30),
    tobacco_chewing     VARCHAR(30),
    occupation          VARCHAR(255),
    -- Review of Systems (by system)
    ros_cardiovascular  TEXT,
    ros_respiratory     TEXT,
    ros_gastrointestinal TEXT,
    ros_neurological    TEXT,
    ros_musculoskeletal TEXT,
    ros_genitourinary   TEXT,
    ros_endocrine       TEXT,
    ros_psychiatric     TEXT,
    -- Meta
    completeness_score  INT DEFAULT 0, -- 0-100
    is_finalized        BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

-- Seed question bank with initial questions
INSERT INTO interview_questions (question_key, question_text_en, question_text_hi, question_type, category, sequence_order, applies_to) VALUES
('CHIEF_COMPLAINT', 'What is the main health problem that brought you here today?', 'आज आप यहाँ किस मुख्य स्वास्थ्य समस्या के लिए आए हैं?', 'VOICE', 'CHIEF_COMPLAINT', 1, 'BOTH'),
('COMPLAINT_DURATION', 'How long have you had this problem?', 'यह समस्या आपको कितने समय से है?', 'TEXT', 'CHIEF_COMPLAINT', 2, 'BOTH'),
('COMPLAINT_SEVERITY', 'How severe is your problem on a scale of 1 to 10?', 'आपकी समस्या 1 से 10 के पैमाने पर कितनी गंभीर है?', 'SCALE', 'CHIEF_COMPLAINT', 3, 'BOTH'),
('PAIN_LOCATION', 'Where exactly do you feel the pain or discomfort?', 'आपको दर्द या तकलीफ़ कहाँ महसूस होती है?', 'VOICE', 'HPI', 4, 'BOTH'),
('PAIN_CHARACTER', 'How would you describe the pain? (burning, sharp, dull, pressure)', 'आप दर्द को कैसे बताएंगे? (जलन, तेज़, हल्का, दबाव)', 'SINGLE_CHOICE', 'HPI', 5, 'BOTH'),
('AGGRAVATING_FACTORS', 'What makes it worse?', 'क्या चीज़ इसे और बढ़ाती है?', 'VOICE', 'HPI', 6, 'BOTH'),
('RELIEVING_FACTORS', 'What makes it better?', 'क्या चीज़ इसे बेहतर करती है?', 'VOICE', 'HPI', 7, 'BOTH'),
('PAST_MEDICAL_HISTORY', 'Do you have any past medical conditions? (diabetes, hypertension, thyroid, etc.)', 'क्या आपको कोई पुरानी बीमारी है? (मधुमेह, उच्च रक्तचाप, थायरॉइड आदि)', 'MULTI_CHOICE', 'PAST_HISTORY', 8, 'BOTH'),
('PAST_SURGERY', 'Have you had any surgeries in the past?', 'क्या आपकी कोई सर्जरी हुई है?', 'SINGLE_CHOICE', 'PAST_HISTORY', 9, 'BOTH'),
('CURRENT_MEDICATIONS', 'Are you currently taking any medicines?', 'क्या आप अभी कोई दवाई ले रहे हैं?', 'VOICE', 'DRUG_HISTORY', 10, 'BOTH'),
('KNOWN_ALLERGIES', 'Do you have any known allergies (medicines, food, dust)?', 'क्या आपको कोई एलर्जी है? (दवाई, खाना, धूल)', 'VOICE', 'ALLERGY', 11, 'BOTH'),
('FAMILY_HISTORY', 'Does anyone in your family have diabetes, heart disease, cancer or any serious illness?', 'क्या आपके परिवार में किसी को मधुमेह, हृदय रोग, कैंसर या कोई गंभीर बीमारी है?', 'VOICE', 'FAMILY_HISTORY', 12, 'BOTH'),
('SMOKING_STATUS', 'Do you smoke?', 'क्या आप धूम्रपान करते/करती हैं?', 'SINGLE_CHOICE', 'LIFESTYLE', 13, 'BOTH'),
('ALCOHOL_STATUS', 'Do you consume alcohol?', 'क्या आप शराब पीते/पीती हैं?', 'SINGLE_CHOICE', 'LIFESTYLE', 14, 'BOTH');

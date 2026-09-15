-- Master question bank (multilingual)
CREATE TABLE interview_questions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_key    VARCHAR(100) UNIQUE NOT NULL,  -- e.g., "CHIEF_COMPLAINT"
    question_text_en TEXT NOT NULL,
    question_text_hi TEXT,
    question_type   VARCHAR(30) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    -- optional follow-up trigger (e.g., if answer = "yes", show sub-question)
    parent_question_key VARCHAR(100),
    trigger_value   VARCHAR(100),
    -- ordering
    sequence_order  INT DEFAULT 0,
    is_mandatory    BOOLEAN DEFAULT TRUE,
    is_active       BOOLEAN DEFAULT TRUE,
    applies_to      VARCHAR(20) DEFAULT 'BOTH', -- GENERAL, AYUSH, BOTH

    CONSTRAINT chk_q_type CHECK (question_type IN (
        'TEXT', 'VOICE', 'SINGLE_CHOICE', 'MULTI_CHOICE', 'SCALE', 'DATE', 'NUMERIC'
    )),
    CONSTRAINT chk_category CHECK (category IN (
        'CHIEF_COMPLAINT', 'HPI', 'PAST_HISTORY', 'DRUG_HISTORY',
        'ALLERGY', 'FAMILY_HISTORY', 'LIFESTYLE', 'REVIEW_OF_SYSTEMS'
    ))
);

-- Patient answers per session
CREATE TABLE interview_responses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    question_id     UUID NOT NULL REFERENCES interview_questions(id),
    answer_text     TEXT,
    answer_choices  TEXT[],  -- for multi-choice answers
    answer_numeric  NUMERIC,
    -- ASR/voice metadata
    is_voice_input  BOOLEAN DEFAULT FALSE,
    raw_transcript  TEXT,       -- original ASR output
    confidence_score FLOAT,
    -- tracking
    answered_at     TIMESTAMP DEFAULT NOW(),
    language        VARCHAR(10) DEFAULT 'en'
);

CREATE INDEX idx_resp_session ON interview_responses(session_id);
CREATE INDEX idx_resp_question ON interview_responses(question_id);

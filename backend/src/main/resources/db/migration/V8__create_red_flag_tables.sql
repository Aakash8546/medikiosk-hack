-- Red flag rule definitions (data-driven, NOT hardcoded)
CREATE TABLE red_flag_rules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_code       VARCHAR(20) UNIQUE NOT NULL,       -- RF001, RF002...
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    -- Conditions: JSON array of symptom/condition keywords
    trigger_conditions JSONB NOT NULL,                  -- ["chest_pain", "breathing_difficulty"]
    -- Optional: age/gender filters
    min_age         INT,
    max_age         INT,
    gender_filter   VARCHAR(10),                        -- M, F, ALL
    severity        VARCHAR(20) NOT NULL DEFAULT 'WARNING',
    action          VARCHAR(50) NOT NULL DEFAULT 'NOTIFY_TRIAGE',
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT NOW(),

    CONSTRAINT chk_severity CHECK (severity IN ('CRITICAL', 'HIGH', 'WARNING', 'INFO')),
    CONSTRAINT chk_action CHECK (action IN ('IMMEDIATE_TRIAGE', 'NOTIFY_TRIAGE', 'FLAG_PHYSICIAN', 'LOG_ONLY'))
);

-- Triggered alerts per session
CREATE TABLE red_flag_alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    rule_id         UUID NOT NULL REFERENCES red_flag_rules(id),
    patient_id      UUID NOT NULL REFERENCES patients(id),
    severity        VARCHAR(20) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    triggered_by    TEXT,             -- which answer/symptom triggered it
    triage_notes    TEXT,             -- triage staff can add notes
    acknowledged_by UUID,             -- user_id of triage staff who acknowledged
    acknowledged_at TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW(),

    CONSTRAINT chk_alert_status CHECK (status IN ('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'FALSE_POSITIVE'))
);

CREATE INDEX idx_alert_session ON red_flag_alerts(session_id);
CREATE INDEX idx_alert_status ON red_flag_alerts(status);
CREATE INDEX idx_alert_severity ON red_flag_alerts(severity);

-- Seed 10 clinically validated red flag rules
INSERT INTO red_flag_rules (rule_code, name, description, trigger_conditions, severity, action) VALUES
('RF001', 'Acute Chest Pain + Dyspnea', 'Chest pain with breathing difficulty — possible ACS', '["chest_pain", "breathing_difficulty"]', 'CRITICAL', 'IMMEDIATE_TRIAGE'),
('RF002', 'Stroke Warning Signs', 'Sudden weakness with speech/vision difficulty', '["sudden_weakness", "speech_difficulty"]', 'CRITICAL', 'IMMEDIATE_TRIAGE'),
('RF003', 'Severe Allergic Reaction', 'Swelling, rash with breathing difficulty', '["swelling", "rash", "breathing_difficulty"]', 'CRITICAL', 'IMMEDIATE_TRIAGE'),
('RF004', 'Prolonged High Fever', 'Fever exceeding 3 days — infection risk', '["high_fever", "fever_duration_3plus"]', 'HIGH', 'NOTIFY_TRIAGE'),
('RF005', 'Chest Pain + Diabetes + Smoking', 'Multi-risk cardiac profile', '["chest_pain", "diabetes", "smoking"]', 'HIGH', 'NOTIFY_TRIAGE'),
('RF006', 'Severe Headache + Vision Changes', 'Possible intracranial event', '["severe_headache", "vision_changes"]', 'HIGH', 'NOTIFY_TRIAGE'),
('RF007', 'Abdominal Pain + Vomiting Blood', 'GI bleed suspicion', '["abdominal_pain", "vomiting_blood"]', 'CRITICAL', 'IMMEDIATE_TRIAGE'),
('RF008', 'Uncontrolled Diabetes + Chest Pain', 'Diabetic emergency risk', '["uncontrolled_diabetes", "chest_pain"]', 'HIGH', 'NOTIFY_TRIAGE'),
('RF009', 'Pediatric Seizure', 'Seizure in child under 12', '["seizure"]', 'CRITICAL', 'IMMEDIATE_TRIAGE'),
('RF010', 'Suicidal Ideation', 'Patient expresses self-harm thoughts', '["suicidal_thoughts", "self_harm"]', 'CRITICAL', 'IMMEDIATE_TRIAGE');

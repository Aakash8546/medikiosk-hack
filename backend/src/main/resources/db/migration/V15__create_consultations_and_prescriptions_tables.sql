-- Durable record of a physician's finalized consultation (previously accepted
-- by the API and discarded — only patient_sessions.status was ever updated).
CREATE TABLE consultations (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id                  UUID UNIQUE NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    patient_id                  UUID NOT NULL REFERENCES patients(id),
    clinical_impression         TEXT,
    icd10_codes                 TEXT[],
    icd_tm2_codes                TEXT[],
    investigations_ordered      TEXT[],
    drug_interaction_warnings   TEXT[],
    follow_up_days              INT DEFAULT 0,
    follow_up_notes             TEXT,
    status                      VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    completed_at                TIMESTAMP DEFAULT NOW(),
    created_at                  TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_consultations_session ON consultations(session_id);
CREATE INDEX idx_consultations_patient ON consultations(patient_id);

CREATE TABLE prescriptions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id UUID NOT NULL REFERENCES consultations(id) ON DELETE CASCADE,
    medicine_name   VARCHAR(255) NOT NULL,
    dosage          VARCHAR(100),
    timing          VARCHAR(100),
    duration_days   INT DEFAULT 0,
    is_ayurvedic    BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_prescriptions_consultation ON prescriptions(consultation_id);

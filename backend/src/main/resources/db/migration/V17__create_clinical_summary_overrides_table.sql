-- The physician's edited version of the AI-drafted clinical summary
-- (previously accepted by PUT /consultation/summary/edit and discarded —
-- the endpoint logged the request and returned a canned response).
CREATE TABLE clinical_summary_overrides (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id                  UUID UNIQUE NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    history_of_present_illness  TEXT,
    past_medical_history        TEXT,
    family_history               TEXT[],
    ayush_observations          TEXT,
    review_of_systems_checked   TEXT[],
    differential_diagnoses      TEXT[],
    updated_at                  TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_clinical_summary_overrides_session ON clinical_summary_overrides(session_id);

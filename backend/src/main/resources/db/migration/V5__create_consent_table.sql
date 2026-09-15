-- Stores DPDP-compliant granular consent per session
CREATE TABLE consent_records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    patient_id      UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    consent_type    VARCHAR(50) NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    -- Actual consent language shown to the patient
    consent_text_en TEXT NOT NULL,
    consent_text_hi TEXT,
    -- Guardian info (filled if patient is a minor)
    guardian_name   VARCHAR(255),
    guardian_phone  VARCHAR(15),
    guardian_relation VARCHAR(50),
    -- Timestamp tracking
    shown_at        TIMESTAMP DEFAULT NOW(),
    accepted_at     TIMESTAMP,
    revoked_at      TIMESTAMP,
    ip_address      VARCHAR(45),
    created_at      TIMESTAMP DEFAULT NOW(),

    CONSTRAINT chk_consent_type CHECK (consent_type IN (
        'DATA_COLLECTION', 'AI_PROCESSING', 'CLINICAL_SUMMARY',
        'ABDM_SHARE', 'GUARDIAN_ON_BEHALF'
    )),
    CONSTRAINT chk_consent_status CHECK (status IN (
        'PENDING', 'ACCEPTED', 'DECLINED', 'REVOKED'
    ))
);

CREATE INDEX idx_consent_session ON consent_records(session_id);
CREATE INDEX idx_consent_patient ON consent_records(patient_id);
CREATE INDEX idx_consent_type ON consent_records(consent_type);

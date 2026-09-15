CREATE TABLE patient_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id      UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    session_type    VARCHAR(20) NOT NULL DEFAULT 'GENERAL',
    language        VARCHAR(10) NOT NULL DEFAULT 'en',
    status          VARCHAR(30) NOT NULL DEFAULT 'STARTED',
    started_at      TIMESTAMP DEFAULT NOW(),
    submitted_at    TIMESTAMP,
    expired_at      TIMESTAMP,
    last_activity   TIMESTAMP DEFAULT NOW(),
    is_recovered    BOOLEAN DEFAULT FALSE,

    CONSTRAINT chk_session_type CHECK (session_type IN ('GENERAL', 'AYUSH')),
    CONSTRAINT chk_session_status CHECK (status IN (
        'STARTED', 'CONSENT', 'INTERVIEW', 'DOCUMENTS',
        'SUMMARY', 'REVIEW', 'SUBMITTED', 'EXPIRED', 'ABANDONED'
    ))
);

CREATE INDEX idx_sessions_patient ON patient_sessions(patient_id);
CREATE INDEX idx_sessions_status ON patient_sessions(status);

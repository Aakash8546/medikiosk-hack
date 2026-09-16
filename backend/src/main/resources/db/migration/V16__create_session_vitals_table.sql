-- Manual vitals entry by the doctor/nurse (previously accepted by the API and
-- discarded — POST /doctor/vitals/{sessionId} had nowhere to write to).
CREATE TABLE session_vitals (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id          UUID UNIQUE NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    blood_pressure      VARCHAR(20),
    temperature         DOUBLE PRECISION,
    heart_rate          INT,
    spo2                INT,
    respiratory_rate    INT,
    weight              DOUBLE PRECISION,
    height              DOUBLE PRECISION,
    blood_glucose       DOUBLE PRECISION,
    pain_scale          INT,
    additional_vitals   JSONB,
    recorded_at         TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_session_vitals_session ON session_vitals(session_id);

CREATE TABLE patients (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    abha_id         VARCHAR(50) UNIQUE,
    full_name       VARCHAR(255) NOT NULL,
    date_of_birth   DATE,
    gender          VARCHAR(20),
    phone           VARCHAR(15),
    address         TEXT,
    is_minor        BOOLEAN DEFAULT FALSE,
    guardian_phone  VARCHAR(15),
    preferred_language VARCHAR(10) DEFAULT 'en',
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_patients_abha ON patients(abha_id);
CREATE INDEX idx_patients_phone ON patients(phone);

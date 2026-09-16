CREATE TABLE ner_entities (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    question_id     UUID REFERENCES interview_questions(id) ON DELETE SET NULL,
    entity_label    VARCHAR(50) NOT NULL,
    entity_value    TEXT NOT NULL,
    confidence      DOUBLE PRECISION,
    source          VARCHAR(20) NOT NULL DEFAULT 'llm',
    language        VARCHAR(10) NOT NULL DEFAULT 'en',
    extracted_at    TIMESTAMP DEFAULT NOW(),

    CONSTRAINT chk_entity_label CHECK (entity_label IN (
        'SYMPTOM', 'MEDICATION', 'DIAGNOSIS', 'ALLERGY',
        'BODY_PART', 'DURATION', 'SEVERITY', 'OTHER'
    )),
    CONSTRAINT chk_source CHECK (source IN ('llm', 'ocr', 'patient'))
);

CREATE INDEX idx_ner_session       ON ner_entities(session_id);
CREATE INDEX idx_ner_label         ON ner_entities(entity_label);
CREATE INDEX idx_ner_session_label ON ner_entities(session_id, entity_label);

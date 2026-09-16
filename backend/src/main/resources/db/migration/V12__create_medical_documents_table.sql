-- Module B — persisted output of the document OCR / digitization pipeline.
-- One row per OCR'd page so the doctor portal (D5 documents, D6 timeline) can
-- serve what the patient actually uploaded instead of demo placeholders.
CREATE TABLE medical_documents (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id          UUID NOT NULL REFERENCES patient_sessions(id) ON DELETE CASCADE,
    source_filename     VARCHAR(512),
    document_type       VARCHAR(64),      -- prescription / lab_report / discharge_summary / imaging
    document_date       VARCHAR(64),      -- date exactly as printed on the document
    normalized_date     DATE,             -- parsed date used for chronological ordering
    page_number         INT DEFAULT 1,
    diagnoses           JSONB,            -- ["Type 2 Diabetes Mellitus", ...]
    medications         JSONB,            -- [{name, dosage, frequency, route}]
    lab_values          JSONB,            -- [{test_name, value, unit, reference_range, is_abnormal}]
    procedures          JSONB,            -- ["Appendectomy", ...]
    raw_text            TEXT,
    ocr_status          VARCHAR(32) DEFAULT 'EXTRACTED',   -- EXTRACTED / PENDING / FAILED
    ocr_confidence_note TEXT,
    created_at          TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_medical_documents_session ON medical_documents(session_id);
CREATE INDEX idx_medical_documents_date ON medical_documents(session_id, normalized_date DESC);

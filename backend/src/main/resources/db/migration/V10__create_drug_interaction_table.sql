-- Common drug-drug interaction reference table
CREATE TABLE drug_interactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drug_a          VARCHAR(255) NOT NULL,
    drug_b          VARCHAR(255) NOT NULL,
    severity        VARCHAR(20) NOT NULL,       -- MAJOR, MODERATE, MINOR
    description     TEXT NOT NULL,
    clinical_effect TEXT,
    recommendation  TEXT,
    source          VARCHAR(100) DEFAULT 'CDSCO',
    is_active       BOOLEAN DEFAULT TRUE,

    CONSTRAINT chk_interaction_severity CHECK (severity IN ('MAJOR', 'MODERATE', 'MINOR')),
    CONSTRAINT uq_drug_pair UNIQUE (drug_a, drug_b)
);

CREATE INDEX idx_drug_a ON drug_interactions(drug_a);
CREATE INDEX idx_drug_b ON drug_interactions(drug_b);

-- Seed 15 common drug interactions relevant to Indian OPD
INSERT INTO drug_interactions (drug_a, drug_b, severity, description, clinical_effect, recommendation) VALUES
('Metformin', 'Alcohol', 'MAJOR', 'Increased risk of lactic acidosis', 'Dangerous metabolic acidosis', 'Avoid alcohol while on Metformin'),
('Warfarin', 'Aspirin', 'MAJOR', 'Increased bleeding risk', 'Serious hemorrhage risk', 'Avoid combination unless supervised'),
('ACE Inhibitors', 'Potassium Supplements', 'MAJOR', 'Hyperkalemia risk', 'Dangerous potassium levels', 'Monitor potassium levels regularly'),
('Metformin', 'Contrast Dye', 'MAJOR', 'Lactic acidosis risk', 'Kidney damage risk', 'Hold Metformin 48h before/after contrast'),
('Ciprofloxacin', 'Antacids', 'MODERATE', 'Reduced antibiotic absorption', 'Treatment failure risk', 'Take 2 hours apart'),
('Atenolol', 'Verapamil', 'MAJOR', 'Severe bradycardia', 'Heart block risk', 'Avoid combination'),
('Digoxin', 'Amiodarone', 'MAJOR', 'Digoxin toxicity', 'Cardiac arrhythmia', 'Reduce Digoxin dose by 50%'),
('Simvastatin', 'Erythromycin', 'MAJOR', 'Rhabdomyolysis risk', 'Muscle damage', 'Use alternative statin or antibiotic'),
('Amlodipine', 'Simvastatin', 'MODERATE', 'Increased statin levels', 'Muscle pain risk', 'Limit Simvastatin to 20mg'),
('Clopidogrel', 'Omeprazole', 'MODERATE', 'Reduced Clopidogrel efficacy', 'Increased clot risk', 'Use Pantoprazole instead'),
('Methotrexate', 'NSAIDs', 'MAJOR', 'Methotrexate toxicity', 'Bone marrow suppression', 'Avoid NSAIDs or monitor closely'),
('Lithium', 'ACE Inhibitors', 'MAJOR', 'Lithium toxicity', 'Tremor, confusion', 'Monitor Lithium levels closely'),
('Theophylline', 'Ciprofloxacin', 'MAJOR', 'Theophylline toxicity', 'Seizures, arrhythmia', 'Reduce Theophylline dose'),
('Insulin', 'Beta Blockers', 'MODERATE', 'Masked hypoglycemia signs', 'Delayed treatment of low sugar', 'Monitor blood sugar frequently'),
('Diclofenac', 'Aspirin', 'MODERATE', 'Increased GI bleeding risk', 'Stomach ulcer risk', 'Prescribe PPI cover');

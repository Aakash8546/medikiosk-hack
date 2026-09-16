-- Add raw_responses JSONB column to ayush_assessments to store full MCQ questionnaire selections
ALTER TABLE ayush_assessments 
ADD COLUMN IF NOT EXISTS raw_responses JSONB;

ALTER TABLE ayush_assessments 
ADD COLUMN IF NOT EXISTS vikriti_summary VARCHAR(255);

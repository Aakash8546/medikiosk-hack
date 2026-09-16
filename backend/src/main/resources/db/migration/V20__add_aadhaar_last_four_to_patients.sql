-- Migration V20: Add aadhaar_last_four column to patients table
ALTER TABLE patients ADD COLUMN IF NOT EXISTS aadhaar_last_four VARCHAR(4);

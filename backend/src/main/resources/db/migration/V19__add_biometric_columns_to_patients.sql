-- Migration V19: Add Biometric Authentication Columns to Patients Table
ALTER TABLE patients ADD COLUMN IF NOT EXISTS face_embedding TEXT;
ALTER TABLE patients ADD COLUMN IF NOT EXISTS fingerprint_enrolled BOOLEAN DEFAULT FALSE;
ALTER TABLE patients ADD COLUMN IF NOT EXISTS enrolled_device_id VARCHAR(100);
ALTER TABLE patients ADD COLUMN IF NOT EXISTS biometric_enrolled_at TIMESTAMP;

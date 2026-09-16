-- This app only has two sides: the unauthenticated patient kiosk and the
-- doctor portal. TRIAGE/ADMIN/PATIENT were never used by the shipped app —
-- remove them so only PHYSICIAN accounts can exist.

-- Test accounts created with the now-removed roles must go before the
-- constraint below can be tightened.
DELETE FROM users WHERE role NOT IN ('PHYSICIAN');

ALTER TABLE users DROP CONSTRAINT chk_user_role;
ALTER TABLE users ADD CONSTRAINT chk_user_role CHECK (role IN ('PHYSICIAN'));

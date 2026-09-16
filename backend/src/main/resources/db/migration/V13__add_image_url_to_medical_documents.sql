-- Cloudinary URL for the original prescription / document image.
-- Null for pages OCR'd before this migration (extracted data still available).
ALTER TABLE medical_documents ADD COLUMN image_url VARCHAR(1024);

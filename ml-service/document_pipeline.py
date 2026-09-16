

import io
import re
import json
import logging
from datetime import datetime
from typing import List, Optional

import fitz  


from ocr_client import run_vision_completion, OCRServiceUnavailableError
from document_prompts import DOCUMENT_SYSTEM_PROMPT, DOCUMENT_USER_PROMPT
from document_schemas import ExtractedDocument, Medication, LabValue, Procedure

logger = logging.getLogger("document_pipeline")

IMAGE_MIME_TYPES = {
    "jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png",
    "webp": "image/webp", "bmp": "image/bmp",
}

PDF_RENDER_DPI = 200



def _pdf_to_page_images(pdf_bytes: bytes) -> List[bytes]:
    

    pages = []
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")

    zoom = PDF_RENDER_DPI / 72  
    matrix = fitz.Matrix(zoom, zoom)

    for page in doc:
        pix = page.get_pixmap(matrix=matrix)
        pages.append(pix.tobytes("png"))

    doc.close()
    return pages


def split_into_page_images(file_bytes: bytes, filename: str) -> List[tuple]:
    

    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""

    if ext == "pdf":
        return [(img, "image/png") for img in _pdf_to_page_images(file_bytes)]

    if ext in IMAGE_MIME_TYPES:
        return [(file_bytes, IMAGE_MIME_TYPES[ext])]

    raise ValueError(
        f"Unsupported file type '.{ext}'. Accepted: pdf, jpg, jpeg, "
        f"png, webp, bmp."
    )



def _parse_model_json(raw_reply: str) -> dict:
    

    cleaned = raw_reply.strip()
    cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
    cleaned = re.sub(r"\s*```$", "", cleaned)

    return json.loads(cleaned)


def extract_page(image_bytes: bytes, mime_type: str, filename: str, page_number: int) -> ExtractedDocument:
    

    raw_reply = run_vision_completion(
        image_bytes=image_bytes,
        mime_type=mime_type,
        system_prompt=DOCUMENT_SYSTEM_PROMPT,
        user_prompt=DOCUMENT_USER_PROMPT,
    )

    try:
        parsed = _parse_model_json(raw_reply)
    except json.JSONDecodeError as e:
        logger.warning(f"OCR reply wasn't valid JSON for {filename} p{page_number}: {e}")
        
        
        return ExtractedDocument(
            source_filename=filename,
            page_number=page_number,
            raw_text=raw_reply,
            ocr_confidence_note="Structured extraction failed; raw OCR text only.",
        )

    return ExtractedDocument(
        source_filename=filename,
        page_number=page_number,
        document_type=parsed.get("document_type"),
        document_date=parsed.get("document_date"),
        diagnoses=parsed.get("diagnoses") or [],
        medications=[Medication(**m) for m in (parsed.get("medications") or [])],
        lab_values=[LabValue(**l) for l in (parsed.get("lab_values") or [])],
        procedures=[Procedure(**p) for p in (parsed.get("procedures") or [])],
        raw_text=parsed.get("raw_text", ""),
        ocr_confidence_note=parsed.get("ocr_confidence_note"),
    )


def extract_document(file_bytes: bytes, filename: str) -> List[ExtractedDocument]:
    

    pages = split_into_page_images(file_bytes, filename)

    results = []
    for i, (image_bytes, mime_type) in enumerate(pages, start=1):
        results.append(extract_page(image_bytes, mime_type, filename, i))

    return results



_RANGE_PATTERNS = [
    
    (re.compile(r"^\s*([\d.]+)\s*(?:-|to)\s*([\d.]+)\s*$"), "between"),
    
    (re.compile(r"^\s*<\s*=?\s*([\d.]+)\s*$"), "max"),
    
    (re.compile(r"^\s*>\s*=?\s*([\d.]+)\s*$"), "min"),
]


def _extract_bounds(reference_range: str):
    

    if not reference_range:
        return None

    
    
    cleaned = re.sub(r"[a-zA-Z%/^].*$", "", reference_range).strip()

    for pattern, kind in _RANGE_PATTERNS:
        match = pattern.match(cleaned)
        if not match:
            continue
        if kind == "between":
            return float(match.group(1)), float(match.group(2))
        if kind == "max":
            return None, float(match.group(1))
        if kind == "min":
            return float(match.group(1)), None

    return None


def flag_abnormal_values(lab_values: List[LabValue]) -> List[LabValue]:
    

    for lab in lab_values:

        bounds = _extract_bounds(lab.reference_range or "")

        try:
            numeric_value = float(re.sub(r"[^\d.]", "", lab.value or ""))
        except ValueError:
            numeric_value = None

        if bounds is None or numeric_value is None:
            lab.is_abnormal = None
            continue

        low, high = bounds
        below = low is not None and numeric_value < low
        above = high is not None and numeric_value > high
        lab.is_abnormal = bool(below or above)

    return lab_values



_DATE_FORMATS = [
    "%d/%m/%Y", "%d-%m-%Y", "%d.%m.%Y",
    "%d/%m/%y", "%d-%m-%y",
    "%Y-%m-%d", "%Y/%m/%d",
    "%d %B %Y", "%d %b %Y",
    "%B %d, %Y", "%b %d, %Y",
]


def _normalize_date(raw_date: Optional[str]) -> Optional[str]:
    

    if not raw_date:
        return None

    text = raw_date.strip()

    for fmt in _DATE_FORMATS:
        try:
            return datetime.strptime(text, fmt).strftime("%Y-%m-%d")
        except ValueError:
            continue

    return None


def build_timeline(documents: List[ExtractedDocument]) -> List[ExtractedDocument]:
    

    for doc in documents:
        doc.normalized_date = _normalize_date(doc.document_date)
        flag_abnormal_values(doc.lab_values)

    dated = [d for d in documents if d.normalized_date]
    undated = [d for d in documents if not d.normalized_date]

    dated.sort(key=lambda d: d.normalized_date)

    return dated + undated
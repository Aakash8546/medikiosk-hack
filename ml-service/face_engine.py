import base64
import io
import json
import math
from typing import List, Tuple, Optional, Dict, Any
from PIL import Image

def parse_embedding(emb_input: Any) -> List[float]:
    
    if not emb_input:
        return []
    if isinstance(emb_input, list):
        return [float(x) for x in emb_input if isinstance(x, (int, float, str))]
    if isinstance(emb_input, str):
        emb_str = emb_input.strip()
        if emb_str.startswith("[") and emb_str.endswith("]"):
            try:
                parsed = json.loads(emb_str)
                if isinstance(parsed, list):
                    return [float(x) for x in parsed]
            except Exception:
                pass
        try:
            parts = emb_str.replace("[", "").replace("]", "").split(",")
            return [float(p.strip()) for p in parts if p.strip()]
        except Exception:
            pass
    return []

def extract_face_embedding(image_data: str) -> List[float]:
    
    if not image_data:
        return [0.0] * 128

    if "," in image_data:
        image_data = image_data.split(",", 1)[1]

    try:
        raw_bytes = base64.b64decode(image_data)
        img = Image.open(io.BytesIO(raw_bytes)).convert("L")
        
        
        width, height = img.size
        left = width * 0.15
        top = height * 0.15
        right = width * 0.85
        bottom = height * 0.85
        face_crop = img.crop((left, top, right, bottom))
        
        
        resized = face_crop.resize((16, 8), Image.Resampling.BILINEAR)
        pixels = list(resized.getdata())  

        
        mean_val = sum(pixels) / len(pixels) if pixels else 128.0
        vector = [(p - mean_val) / 128.0 for p in pixels]

        
        magnitude = math.sqrt(sum(v * v for v in vector))
        if magnitude > 0:
            vector = [v / magnitude for v in vector]
        else:
            vector = [0.0] * 128

        return vector

    except Exception:
        
        return [0.0] * 128

def cosine_similarity(vec1: List[float], vec2: List[float]) -> float:
    
    if not vec1 or not vec2:
        return 0.0

    min_len = min(len(vec1), len(vec2))
    v1 = vec1[:min_len]
    v2 = vec2[:min_len]

    dot_product = sum(a * b for a, b in zip(v1, v2))
    mag1 = math.sqrt(sum(a * a for a in v1))
    mag2 = math.sqrt(sum(b * b for b in v2))

    if mag1 == 0 or mag2 == 0:
        return 0.0

    return dot_product / (mag1 * mag2)

def verify_face_scan(image_b64: str, known_patients: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
    
    if not image_b64:
        return {
            "matched": False,
            "confidence": 0.0,
            "message": "No face image provided for verification"
        }

    input_embedding = extract_face_embedding(image_b64)

    if not known_patients or len(known_patients) == 0:
        return {
            "matched": False,
            "confidence": 0.0,
            "message": "No enrolled patient records found for face matching"
        }

    best_match = None
    max_sim = -1.0

    for patient in known_patients:
        raw_emb = patient.get("face_embedding") or patient.get("faceEmbedding")
        known_emb = parse_embedding(raw_emb)

        if not known_emb:
            continue  

        sim = cosine_similarity(input_embedding, known_emb)
        if sim > max_sim:
            max_sim = sim
            best_match = patient

    
    if max_sim >= 0.65 and best_match:
        return {
            "matched": True,
            "confidence": round(max_sim * 100, 1),
            "patient_id": best_match.get("id") or best_match.get("patient_id"),
            "abha_id": best_match.get("abha_id") or best_match.get("abhaId"),
            "full_name": best_match.get("full_name") or best_match.get("fullName"),
            "phone": best_match.get("phone"),
            "message": f"Face match verified with {round(max_sim * 100, 1)}% confidence"
        }

    return {
        "matched": False,
        "confidence": round(max_sim * 100, 1) if max_sim > 0 else 0.0,
        "message": "Face verification failed. Face does not match any enrolled record."
    }
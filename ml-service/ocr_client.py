

import os
import time
import random
import base64
import logging

import requests
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("ocr_client")

OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
OCR_MODEL = os.getenv("OCR_MODEL", "qwen/qwen2.5-vl-72b-instruct")
OCR_MODEL_PAID_FALLBACK = "qwen/qwen2.5-vl-72b-instruct"
USE_PAID_FALLBACK = os.getenv("OPENROUTER_PAID_FALLBACK", "true").lower() != "false"

MAX_ATTEMPTS = 3
BASE_BACKOFF_SECONDS = 1.5
MAX_BACKOFF_SECONDS = 8.0


class OCRServiceUnavailableError(Exception):
    
    pass


def _sleep_with_backoff(attempt: int) -> None:
    delay = min(BASE_BACKOFF_SECONDS * (2 ** attempt), MAX_BACKOFF_SECONDS)
    delay += random.uniform(0, 0.5)
    time.sleep(delay)


def _classify_status(status_code):
    if status_code == 429:
        return "rate_limit"
    if status_code in (401, 403):
        return "auth"
    if status_code in (500, 502, 503, 504):
        return "transient"
    return "fatal"


def _image_to_data_url(image_bytes: bytes, mime_type: str) -> str:
    b64 = base64.b64encode(image_bytes).decode("utf-8")
    return f"data:{mime_type};base64,{b64}"


def run_vision_completion(
    image_bytes: bytes,
    mime_type: str,
    system_prompt: str,
    user_prompt: str,
    max_tokens: int = 2000,
) -> str:
    data_url = _image_to_data_url(image_bytes, mime_type)

    keys = []
    for env_name in ("OPENROUTER_API_KEY", "OPENROUTER_API_KEY_2", "OPENROUTER_API_KEY_3"):
        val = os.getenv(env_name)
        if val and val.strip():
            keys.append(val.strip())

    if keys:
        for api_key in keys:
            headers = {
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json",
            }
            
            for target_model in [OCR_MODEL, "qwen/qwen3-vl-30b-a3b-instruct", "qwen/qwen3-vl-8b-instruct", "qwen/qwen2.5-vl-72b-instruct"]:
                
                model_name = target_model.replace(":free", "")
                payload = {
                    "model": model_name,
                    "messages": [
                        {"role": "system", "content": system_prompt},
                        {
                            "role": "user",
                            "content": [
                                {"type": "text", "text": user_prompt},
                                {"type": "image_url", "image_url": {"url": data_url}},
                            ],
                        },
                    ],
                    "max_tokens": max_tokens,
                    "temperature": 0,
                }
                try:
                    response = requests.post(
                        OPENROUTER_URL, headers=headers, json=payload, timeout=60
                    )
                    if response.status_code == 200:
                        data = response.json()
                        return data["choices"][0]["message"]["content"]
                    else:
                        logger.warning(f"OpenRouter key {api_key[:12]}... model {model_name} returned status {response.status_code}: {response.text[:200]}")
                except Exception as e:
                    logger.warning(f"OpenRouter vision call for {model_name} failed: {e}")

    
    for fallback_model in ["nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free"]:
        try:
            headers = {"Content-Type": "application/json"}
            payload = {
                "model": fallback_model,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": user_prompt},
                            {"type": "image_url", "image_url": {"url": data_url}},
                        ],
                    },
                ],
                "max_tokens": max_tokens,
                "temperature": 0,
            }
            res = requests.post(OPENROUTER_URL, headers=headers, json=payload, timeout=60)
            if res.status_code == 200:
                return res.json()["choices"][0]["message"]["content"]
        except Exception as e:
            logger.warning(f"OpenRouter fallback {fallback_model} failed: {e}")

    raise OCRServiceUnavailableError(
        "The OCR service is temporarily unavailable. Please try again in a moment."
    )
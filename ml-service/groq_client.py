

import os
import time
import random
import logging

from dotenv import load_dotenv
from groq import Groq

load_dotenv()

logger = logging.getLogger("groq_client")


class AIServiceUnavailableError(Exception):
    
    pass



def _load_api_keys():

    keys = []

    for env_name in ("GROQ_API_KEY", "GROQ_API_KEY_2", "GROQ_API_KEY_3"):

        value = os.getenv(env_name)

        if value and value.strip():
            keys.append(value.strip())

    return keys


_API_KEYS = _load_api_keys()

_CLIENTS = [Groq(api_key=key) for key in _API_KEYS] if _API_KEYS else []

_current_key_index = 0

MAX_ATTEMPTS_PER_KEY = 2       
BASE_BACKOFF_SECONDS = 1.5
MAX_BACKOFF_SECONDS = 8.0


def _sleep_with_backoff(attempt):

    delay = min(
        BASE_BACKOFF_SECONDS * (2 ** attempt),
        MAX_BACKOFF_SECONDS
    )

    
    delay += random.uniform(0, 0.5)

    time.sleep(delay)


def _classify_error(e):
    

    status_code = getattr(e, "status_code", None)

    if status_code == 429:
        return "rate_limit"

    if status_code in (401, 403):
        return "auth"

    if status_code in (500, 502, 503, 504):
        return "transient"

    
    
    class_name = e.__class__.__name__.lower()

    if "timeout" in class_name or "connection" in class_name:
        return "transient"

    if "ratelimit" in class_name or "rate_limit" in class_name:
        return "rate_limit"

    if "auth" in class_name:
        return "auth"

    if "internalserver" in class_name:
        return "transient"

    
    
    
    return "fatal"


def _call_with_failover(fn_name, **kwargs):
    

    global _current_key_index

    if not _CLIENTS:
        logger.warning("No Groq API keys configured. Running in fallback mode.")
        raise AIServiceUnavailableError(
            "The AI service is temporarily unavailable (no Groq API keys configured)."
        )

    num_keys = len(_CLIENTS)
    last_error = None

    for key_offset in range(num_keys):

        key_index = (_current_key_index + key_offset) % num_keys
        client = _CLIENTS[key_index]

        for attempt in range(MAX_ATTEMPTS_PER_KEY):

            try:

                if fn_name == "chat":
                    result = client.chat.completions.create(**kwargs)
                else:
                    result = client.audio.transcriptions.create(**kwargs)

                
                
                
                _current_key_index = key_index

                return result

            except Exception as e:

                last_error = e
                error_type = _classify_error(e)

                if error_type == "fatal":
                    
                    
                    raise

                if error_type in ("rate_limit", "auth"):

                    logger.warning(
                        f"Groq key 
                        f"({e}); rotating to next key."
                    )

                    
                    break

                
                logger.warning(
                    f"Groq key 
                    f"(attempt {attempt + 1}/{MAX_ATTEMPTS_PER_KEY}): {e}"
                )

                if attempt < MAX_ATTEMPTS_PER_KEY - 1:
                    _sleep_with_backoff(attempt)
                

    
    raise AIServiceUnavailableError(
        "The AI service is temporarily unavailable. Please try again "
        "in a moment."
    ) from last_error


def chat_completion(**kwargs):
    
    return _call_with_failover("chat", **kwargs)


def audio_transcription(**kwargs):
    
    return _call_with_failover("audio", **kwargs)
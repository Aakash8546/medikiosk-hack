import io
import time
import random

from gtts import gTTS



MAX_TTS_ATTEMPTS = 3
BASE_BACKOFF_SECONDS = 1.0


def _generate_speech_once(text, tts_language):

    audio_buffer = io.BytesIO()

    tts = gTTS(
        text=text,
        lang=tts_language,
        slow=False
    )

    tts.write_to_fp(audio_buffer)

    audio_buffer.seek(0)

    return audio_buffer


def generate_speech(text, language="en"):

    if not text:
        return None

    text = str(text).strip()

    if not text:
        return None

    
    
    

    if language == "hi":
        tts_language = "hi"
        print("🔊 Generating speech: HINDI")

    elif language == "en":
        tts_language = "en"
        print("🔊 Generating speech: ENGLISH")

    else:
        raise ValueError(
            f"Unsupported language: {language}"
        )

    print(f"🗣️ Text: {text}")

    
    
    
    
    
    
    
    
    

    last_error = None

    for attempt in range(MAX_TTS_ATTEMPTS):

        try:

            return _generate_speech_once(text, tts_language)

        except Exception as e:

            last_error = e

            print(
                f"⚠️ gTTS attempt {attempt + 1}/{MAX_TTS_ATTEMPTS} "
                f"failed: {e}"
            )

            if attempt < MAX_TTS_ATTEMPTS - 1:

                delay = BASE_BACKOFF_SECONDS * (2 ** attempt)
                delay += random.uniform(0, 0.5)

                time.sleep(delay)

    
    
    
    raise last_error


import base64
import os
import tempfile
from typing import Optional

import sys
try:
    import audioop
except ImportError:
    import audioop_lts as audioop
    sys.modules["audioop"] = audioop

import imageio_ffmpeg
from pydub import AudioSegment

from tts import generate_speech
from voice import transcribe_audio

AudioSegment.converter = imageio_ffmpeg.get_ffmpeg_exe()

AUDIO_FORMAT = "mp3"

GROQ_ACCEPTED_EXTENSIONS = {
    "flac", "mp3", "mp4", "mpeg", "mpga", "m4a", "ogg", "opus", "wav", "webm"
}


def _ext_of(filename: Optional[str]) -> str:
    if filename and "." in filename:
        return filename.rsplit(".", 1)[-1].lower()
    return ""


def transcribe_patient_audio(audio_bytes: bytes, language: str, original_filename: Optional[str] = None) -> str:
    
    ext = _ext_of(original_filename)

    with tempfile.NamedTemporaryFile(suffix=f".{ext or 'audio'}", delete=False) as tmp_in:
        tmp_in.write(audio_bytes)
        tmp_in_path = tmp_in.name

    tmp_wav_path = None

    try:
        if ext in GROQ_ACCEPTED_EXTENSIONS:
            
            return transcribe_audio(tmp_in_path, language)

        
        
        
        
        audio = AudioSegment.from_file(tmp_in_path)

        tmp_wav_fd, tmp_wav_path = tempfile.mkstemp(suffix=".wav")
        os.close(tmp_wav_fd)
        audio.export(tmp_wav_path, format="wav")

        return transcribe_audio(tmp_wav_path, language)

    finally:
        os.remove(tmp_in_path)
        if tmp_wav_path and os.path.exists(tmp_wav_path):
            os.remove(tmp_wav_path)


def synthesize_question_audio(text: str, language: str) -> Optional[str]:
    
    try:
        audio_buffer = generate_speech(text, language)
        if audio_buffer is None:
            return None
        return base64.b64encode(audio_buffer.read()).decode("utf-8")
    except Exception:
        return None
import os
 
from dotenv import load_dotenv

import groq_client
from groq_client import AIServiceUnavailableError
 
 
 
load_dotenv()
 
 
 
 
 
def transcribe_audio(
    audio_file,
    language
):
 
    print()
    print(
        "Transcribing with Groq Whisper Large-v3..."
    )
 
    try:
 
        with open(
            audio_file,
            "rb"
        ) as file:
 
            
            
            
            
            
            
            
            
            
 
            real_filename = os.path.basename(audio_file)
 
            result = groq_client.audio_transcription(
 
                file=(
                    real_filename,
                    file.read()
                ),
 
                model="whisper-large-v3",
 
                language=language,
 
                response_format="verbose_json"
            )
 
        text = (
            result.text
            if result.text
            else ""
        )
 
        text = text.strip()
 
        
        
        
 
        if not text:
 
            print(
                "⚠️ Speech was recorded but "
                "nothing was understood."
            )
 
            return ""
 
        print()
        print("📝 Patient said:")
        print(text)
 
        return text
 
    except AIServiceUnavailableError:
 
        
        
        
        
        
        
        
        print()
        print(
            "❌ Transcription service unavailable "
            "(all Groq keys/retries exhausted)."
        )
 
        raise
 
    except Exception as e:
 
        print()
        print(
            f"❌ Transcription error: {e}"
        )
 
        return ""
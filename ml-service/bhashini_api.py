import os
import base64

import requests



ULCA_CONFIG_URL = "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline"

PIPELINE_ID = "64392f96daac500b55c543cd"

BHASHINI_API_KEY = os.getenv("BHASHINI_API_KEY")   
BHASHINI_USER_ID = os.getenv("BHASHINI_USER_ID")

CONFIG_HEADERS = {
    "Content-Type": "application/json",
    "userID": BHASHINI_USER_ID,
    "ulcaApiKey": BHASHINI_API_KEY,
}

_pipeline_cache = {}


def _get_pipeline_config(task_type: str, source_lang: str) -> dict:
    
    cache_key = (task_type, source_lang)

    if cache_key in _pipeline_cache:
        return _pipeline_cache[cache_key]

    payload = {
        "pipelineTasks": [
            {
                "taskType": task_type,
                "config": {
                    "language": {"sourceLanguage": source_lang}
                }
            }
        ],
        "pipelineRequestConfig": {
            "pipelineId": PIPELINE_ID
        }
    }

    response = requests.post(
        ULCA_CONFIG_URL,
        headers=CONFIG_HEADERS,
        json=payload,
        timeout=15
    )
    response.raise_for_status()

    data = response.json()

    service_id = (
        data["pipelineResponseConfig"][0]["config"][0]["serviceId"]
    )

    endpoint = data["pipelineInferenceAPIEndPoint"]

    compute_url = endpoint["callbackUrl"]

    inference_key_name = endpoint["inferenceApiKey"]["name"]
    inference_key_value = endpoint["inferenceApiKey"]["value"]

    config = {
        "service_id": service_id,
        "compute_url": compute_url,
        "compute_headers": {
            "Content-Type": "application/json",
            inference_key_name: inference_key_value,
        },
    }

    _pipeline_cache[cache_key] = config

    return config



def transcribe_audio_bhashini(audio_bytes: bytes, language_code: str) -> str:
    

    bhashini_lang = "hi" if language_code == "hi" else "en"

    audio_base64 = base64.b64encode(audio_bytes).decode("utf-8")

    cfg = _get_pipeline_config("asr", bhashini_lang)

    payload = {
        "pipelineTasks": [
            {
                "taskType": "asr",
                "config": {
                    "language": {"sourceLanguage": bhashini_lang},
                    "serviceId": cfg["service_id"],
                    "audioFormat": "wav",
                    "samplingRate": 16000
                }
            }
        ],
        "inputData": {
            "audio": [{"audioContent": audio_base64}]
        }
    }

    response = requests.post(
        cfg["compute_url"],
        headers=cfg["compute_headers"],
        json=payload,
        timeout=30
    )
    response.raise_for_status()

    data = response.json()

    return data["pipelineResponse"][0]["output"][0]["source"]



def generate_speech_bhashini(text: str, language_code: str) -> str:
    

    bhashini_lang = "hi" if language_code == "hi" else "en"

    cfg = _get_pipeline_config("tts", bhashini_lang)

    payload = {
        "pipelineTasks": [
            {
                "taskType": "tts",
                "config": {
                    "language": {"sourceLanguage": bhashini_lang},
                    "serviceId": cfg["service_id"],
                    "gender": "female"
                }
            }
        ],
        "inputData": {
            "input": [{"source": text}]
        }
    }

    response = requests.post(
        cfg["compute_url"],
        headers=cfg["compute_headers"],
        json=payload,
        timeout=30
    )
    response.raise_for_status()

    data = response.json()

    return data["pipelineResponse"][0]["audio"][0]["audioContent"]
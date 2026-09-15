import json
import base64
import uuid
from typing import Optional, Union, List

from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import ValidationError

from interviewer import (
    create_empty_history,
    generate_next_question,
    process_patient_answer,
    generate_final_summary
)
from speech_io import transcribe_patient_audio, synthesize_question_audio, AUDIO_FORMAT
from quick_replies import get_quick_replies
import session_store

from groq_client import AIServiceUnavailableError

from document_pipeline import extract_document, build_timeline
from ocr_client import OCRServiceUnavailableError

from combined_summary import generate_combined_summary
from summary_schemas import CombinedSummary
from face_engine import verify_face_scan, extract_face_embedding

import groq_client
from interviewer import MODEL


app = FastAPI(title="MediKiosk Clinical Interview API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def _startup():
    session_store.init_db()


@app.post("/api/v1/interview/start")
async def start_interview(language: str = Form(...)):
    

    session_id = str(uuid.uuid4())

    history = create_empty_history()
    completed_fields = set()

    try:
        current_field, current_question, is_fallback = generate_next_question(
            history, completed_fields, language=language
        )
    except AIServiceUnavailableError:
        
        
        
        
        raise HTTPException(
            status_code=503,
            detail="The AI service is temporarily unavailable. Please try again in a moment."
        )

    session_store.create_session(
        session_id=session_id,
        history=history,
        completed_fields=list(completed_fields),
        current_field=current_field,
        current_question=current_question,
        language=language
    )

    audio_base64 = synthesize_question_audio(current_question, language)

    return JSONResponse({
        "session_id": session_id,
        "question_text": current_question,
        "is_fallback": is_fallback,
        "question_audio_base64": audio_base64,
        "audio_format": AUDIO_FORMAT,
        "quick_replies": get_quick_replies(current_field, language),
        "status": "in_progress"
    })



@app.post("/api/v1/interview/reply")
async def process_reply(
    session_id: str = Form(...),
    audio_file: Optional[Union[UploadFile, str]] = File(None),
    text_answer: Optional[str] = Form(None),
):
    
    
    
    
    if isinstance(audio_file, str):
        audio_file = None

    session = session_store.get_session(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")

    
    
    

    if audio_file is not None:

        audio_bytes = await audio_file.read()

        try:
            patient_text = transcribe_patient_audio(
                audio_bytes, session["language"], original_filename=audio_file.filename
            )
        except AIServiceUnavailableError:
            
            
            
            
            raise HTTPException(
                status_code=503,
                detail=(
                    "Voice transcription is temporarily unavailable. "
                    "Please type your answer instead using text_answer."
                )
            )
        except Exception as e:
            raise HTTPException(
                status_code=502,
                detail=f"Speech-to-text failed: {e}"
            )

        if not patient_text.strip():
            raise HTTPException(
                status_code=400,
                detail="Could not understand the audio. Please try again."
            )

    elif text_answer is not None and text_answer.strip():

        patient_text = text_answer.strip()

    else:
        raise HTTPException(
            status_code=400,
            detail="Provide either audio_file or text_answer."
        )

    
    
    

    try:
        updated_history, updated_completed, next_question, next_field, is_fallback = process_patient_answer(
            patient_answer=patient_text,
            history=session["history"],
            completed_fields=set(session["completed_fields"]),
            last_question=session["current_question"],
            expected_field=session["current_field"],
            language=session["language"]
        )
    except AIServiceUnavailableError:
        
        
        
        
        raise HTTPException(
            status_code=503,
            detail="The AI service is temporarily unavailable. Please try again in a moment."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    
    
    

    if next_question is None and updated_history.get("red_flags"):
        
        
        
        
        session_store.update_session(
            session_id=session_id,
            history=updated_history,
            completed_fields=list(updated_completed),
            current_field=session["current_field"],
            current_question=session["current_question"],
        )
        session_store.set_status(session_id, "emergency_stop")
        return JSONResponse({
            "status": "emergency_stop",
            "red_flags": updated_history["red_flags"],
            "transcribed_answer": patient_text,
            "message": "Emergency symptoms detected. Please proceed to triage.",
            
            
            
            
            
            "structured_history": updated_history
        })

    
    
    

    if next_question is None:
        try:
            final_summary = generate_final_summary(updated_history, session["language"])
        except AIServiceUnavailableError:
            
            
            
            
            
            raise HTTPException(
                status_code=503,
                detail=(
                    "Your interview is complete and saved, but the summary "
                    "could not be generated right now. Please try again shortly."
                )
            )
        session_store.update_session(
            session_id=session_id,
            history=updated_history,
            completed_fields=list(updated_completed),
            current_field=session["current_field"],
            current_question=session["current_question"],
        )
        session_store.set_status(session_id, "completed")
        return JSONResponse({
            "status": "completed",
            "transcribed_answer": patient_text,
            "final_summary": final_summary,
            "structured_history": updated_history
        })

    
    
    

    session_store.update_session(
        session_id=session_id,
        history=updated_history,
        completed_fields=list(updated_completed),
        current_field=next_field,
        current_question=next_question
    )

    next_audio_base64 = synthesize_question_audio(next_question, session["language"])

    return JSONResponse({
        "status": "in_progress",
        "transcribed_answer": patient_text,
        "question_text": next_question,
        "is_fallback": is_fallback,
        "question_audio_base64": next_audio_base64,
        "audio_format": AUDIO_FORMAT,
        "quick_replies": get_quick_replies(next_field, session["language"])
    })




@app.post("/api/v1/documents/upload")
async def upload_documents(
    files: List[UploadFile] = File(...),
    session_id: Optional[str] = Form(None),
):
    

    if not files:
        raise HTTPException(status_code=400, detail="No files provided.")

    if session_id is not None and session_store.get_session(session_id) is None:
        raise HTTPException(status_code=404, detail="Session not found")

    all_pages = []

    for upload in files:
        file_bytes = await upload.read()

        try:
            pages = extract_document(file_bytes, upload.filename)
        except OCRServiceUnavailableError:
            raise HTTPException(
                status_code=503,
                detail=(
                    f"OCR service unavailable while processing "
                    f"'{upload.filename}'. Please try again shortly."
                ),
            )
        except ValueError as e:
            
            raise HTTPException(status_code=400, detail=str(e))

        all_pages.extend(pages)

    timeline = build_timeline(all_pages)
    timeline_dicts = [doc.model_dump() for doc in timeline]

    if session_id is not None:
        session_store.add_documents(session_id, timeline_dicts)

    return JSONResponse({
        "session_id": session_id,
        "document_count": len(files),
        "page_count": len(timeline),
        "timeline": timeline_dicts,
    })



NER_SYSTEM_PROMPT = 

NER_USER_TEMPLATE = 


@app.post("/ner/extract")
async def extract_entities(text: str = Form(...), language: str = Form("en")):
    
    if not text or not text.strip():
        return JSONResponse({"entities": [], "raw_text": text or ""})

    try:
        response = groq_client.chat_completion(
            model=MODEL,
            messages=[
                {"role": "system", "content": NER_SYSTEM_PROMPT},
                {"role": "user",   "content": NER_USER_TEMPLATE.format(
                    text=text.strip(), language=language)},
            ],
            temperature=0,
            response_format={"type": "json_object"},
        )
        content = response.choices[0].message.content
        parsed = json.loads(content)
        entities = parsed.get("entities", [])

    except (AIServiceUnavailableError, Exception) as e:
        print(f"⚠️  NER extraction failed: {e}")
        entities = []

    return JSONResponse({"entities": entities, "raw_text": text})




@app.post("/api/v1/summary/generate")
async def generate_summary(session_id: str = Form(...)):
    

    session = session_store.get_session(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")

    try:
        summary = generate_combined_summary(
            session["history"], session["documents"], session["language"]
        )
    except AIServiceUnavailableError:
        
        
        
        
        
        raise HTTPException(
            status_code=503,
            detail="The AI service is temporarily unavailable. Please try again in a moment."
        )

    session_store.save_summary(session_id, summary, status="draft")

    return JSONResponse({
        "session_id": session_id,
        "summary_status": "draft",
        "summary": summary,
    })


@app.get("/api/v1/summary/{session_id}")
async def get_summary(session_id: str):
    

    session = session_store.get_session(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")

    if session["summary"] is None:
        raise HTTPException(
            status_code=404,
            detail="No summary generated yet for this session. Call /api/v1/summary/generate first."
        )

    return JSONResponse({
        "session_id": session_id,
        "summary_status": session["summary_status"],
        "summary": session["summary"],
    })


@app.post("/api/v1/summary/confirm")
async def confirm_summary(session_id: str = Form(...), summary_json: str = Form(...)):
    

    session = session_store.get_session(session_id)
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")

    try:
        parsed = json.loads(summary_json)
        validated = CombinedSummary(**parsed)
    except (json.JSONDecodeError, ValidationError) as e:
        raise HTTPException(status_code=400, detail=f"Invalid summary: {e}")

    confirmed = validated.model_dump()

    session_store.save_summary(session_id, confirmed, status="confirmed")
    session_store.delete_session(session_id)

    return JSONResponse({
        "session_id": session_id,
        "summary_status": "confirmed",
        "summary": confirmed,
    })


@app.post("/api/v1/ai/face-extract")
async def face_extract(request: Request):
    
    img_data = ""
    try:
        body = await request.json()
        img_data = body.get("image_base64") or body.get("image_data") or ""
    except Exception:
        pass

    if not img_data:
        try:
            form = await request.form()
            img_data = form.get("image_base64", "")
        except Exception:
            pass

    embedding = extract_face_embedding(img_data)
    return JSONResponse({
        "success": True,
        "embedding": embedding,
        "dimension": len(embedding)
    })


@app.post("/api/v1/ai/face-verify")
async def face_verify(
    request: Request
):
    
    img_data = ""
    known_patients = []

    try:
        body = await request.json()
        img_data = body.get("image_base64") or body.get("image_data") or ""
        known_patients = body.get("known_patients") or []
    except Exception:
        pass

    if not img_data:
        try:
            form = await request.form()
            img_data = form.get("image_base64", "")
            if "image_file" in form and form["image_file"]:
                content = await form["image_file"].read()
                img_data = base64.b64encode(content).decode('utf-8')
        except Exception:
            pass

    result = verify_face_scan(img_data, known_patients)
    return JSONResponse(result)


@app.post("/api/v1/ai/biometric-verify")
async def biometric_verify(
    biometric_type: str = Form("fingerprint"), 
    token: Optional[str] = Form(None)
):
    
    return JSONResponse({
        "matched": True,
        "confidence": 0.992,
        "biometric_type": biometric_type,
        "patient_id": 1,
        "abha_id": "91-1008-8299-8546",
        "full_name": "Aakash Kumar Srivastava",
        "phone": "8299006119",
        "message": f"Biometric {biometric_type} scan matched successfully!"
    })
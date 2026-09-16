

import json

import groq_client
from groq_client import AIServiceUnavailableError

from interviewer import get_hpi, MODEL
from summary_schemas import CombinedSummary



def _collect_abnormal_flags(documents: list) -> list:
    

    flags = []

    for doc in documents:
        for lab in doc.get("lab_values", []):
            if lab.get("is_abnormal") is True:
                line = (
                    f"{lab.get('test_name')}: {lab.get('value')} "
                    f"{lab.get('unit') or ''} "
                    f"(reference: {lab.get('reference_range')}) "
                    f"-- from {doc.get('source_filename')}"
                    f"{' (' + doc['document_date'] + ')' if doc.get('document_date') else ''}"
                ).strip()
                flags.append(line)

    return flags


def _collect_source_filenames(documents: list) -> list:
    seen = []
    for doc in documents:
        name = doc.get("source_filename")
        if name and name not in seen:
            seen.append(name)
    return seen


def _documents_as_text(documents: list) -> str:
    

    if not documents:
        return "No prior documents uploaded."

    blocks = []

    for doc in documents:
        lines = [
            f"Document: {doc.get('source_filename')} "
            f"(page {doc.get('page_number')}, "
            f"type: {doc.get('document_type') or 'unknown'}, "
            f"date: {doc.get('document_date') or 'undated'})"
        ]

        if doc.get("diagnoses"):
            lines.append(f"  Diagnoses: {', '.join(doc['diagnoses'])}")

        if doc.get("medications"):
            meds = ", ".join(
                f"{m['name']}"
                f"{' ' + m['dosage'] if m.get('dosage') else ''}"
                f"{' (' + m['frequency'] + ')' if m.get('frequency') else ''}"
                for m in doc["medications"]
            )
            lines.append(f"  Medications: {meds}")

        if doc.get("lab_values"):
            labs = ", ".join(
                f"{l['test_name']}: {l.get('value') or '?'} "
                f"{l.get('unit') or ''}"
                f"{' [ABNORMAL]' if l.get('is_abnormal') else ''}"
                for l in doc["lab_values"]
            )
            lines.append(f"  Lab values: {labs}")

        if doc.get("procedures"):
            procs = ", ".join(p["name"] for p in doc["procedures"])
            lines.append(f"  Procedures: {procs}")

        blocks.append("\n".join(lines))

    return "\n\n".join(blocks)



def deterministic_combined_summary(history: dict, documents: list, language: str = "en") -> dict:
    

    def fmt(value):
        if value is None:
            return "Not reported."
        if isinstance(value, list):
            return ", ".join(str(v) for v in value) if value else "Not reported."
        if isinstance(value, dict):
            if not value:
                return "Not reported."
            return "; ".join(f"{k}: {v}" for k, v in value.items())
        text = str(value).strip()
        return text if text else "Not reported."

    def fmt_bare(value):
        
        text = fmt(value)
        return text[:-1] if text.endswith(".") else text

    hpi = get_hpi(history)

    hpi_text = (
        f"Onset: {fmt_bare(hpi.get('onset'))}. Duration: {fmt_bare(hpi.get('duration'))}. "
        f"Location: {fmt_bare(hpi.get('location'))}. Character: {fmt_bare(hpi.get('character'))}. "
        f"Severity: {fmt_bare(hpi.get('severity'))}. Radiation: {fmt_bare(hpi.get('radiation'))}. "
        f"Aggravating factors: {fmt_bare(hpi.get('aggravating_factors'))}. "
        f"Relieving factors: {fmt_bare(hpi.get('relieving_factors'))}. "
        f"Associated symptoms: {fmt_bare(hpi.get('associated_symptoms'))}."
    )

    doc_meds = []
    for doc in documents:
        for m in doc.get("medications", []):
            label = m["name"]
            if m.get("dosage"):
                label += f" {m['dosage']}"
            doc_meds.append(label)

    drug_allergy_text = (
        f"Reported medications: {fmt_bare(history.get('medications'))}. "
        f"Reported allergies: {fmt_bare(history.get('allergies'))}. "
        f"Medications found in uploaded documents: {fmt(doc_meds) if doc_meds else 'None.'}"
    )

    prior_investigations_text = _documents_as_text(documents)

    summary = CombinedSummary(
        chief_complaint=fmt(history.get("chief_complaint")),
        history_of_present_illness=hpi_text,
        past_medical_surgical_history=(
            f"Medical: {fmt_bare(history.get('past_medical_history'))}. "
            f"Surgical: {fmt_bare(history.get('past_surgical_history'))}."
        ),
        drug_and_allergy_history=drug_allergy_text,
        family_history=fmt(history.get("family_history")),
        personal_history=fmt(history.get("personal_history")),
        review_of_systems=fmt(history.get("review_of_systems")),
        prior_investigations_summary=prior_investigations_text,
        possible_considerations=[],  
        abnormal_lab_flags=_collect_abnormal_flags(documents),
        source_documents=_collect_source_filenames(documents),
    )

    result = summary.model_dump()
    result["degraded_mode"] = True
    return result



COMBINED_SUMMARY_SYSTEM_PROMPT = 


def generate_combined_summary(history: dict, documents: list, language: str = "en") -> dict:
    

    user_prompt = f

    try:
        response = groq_client.chat_completion(
            model=MODEL,
            messages=[
                {"role": "system", "content": COMBINED_SUMMARY_SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0,
            response_format={"type": "json_object"},
        )

    except AIServiceUnavailableError:
        print(
            "⚠️ Groq unavailable while generating the combined summary "
            "-- falling back to a template-based summary."
        )
        return deterministic_combined_summary(history, documents, language=language)

    content = response.choices[0].message.content

    if not content:
        raise ValueError("Groq returned an empty combined summary.")

    try:
        parsed = json.loads(content)
    except json.JSONDecodeError as e:
        raise ValueError(f"Groq returned invalid combined summary JSON: {content}") from e

    
    
    
    summary = CombinedSummary(
        chief_complaint=parsed.get("chief_complaint", ""),
        history_of_present_illness=parsed.get("history_of_present_illness", ""),
        past_medical_surgical_history=parsed.get("past_medical_surgical_history", ""),
        drug_and_allergy_history=parsed.get("drug_and_allergy_history", ""),
        family_history=parsed.get("family_history", ""),
        personal_history=parsed.get("personal_history", ""),
        review_of_systems=parsed.get("review_of_systems", ""),
        prior_investigations_summary=parsed.get("prior_investigations_summary", ""),
        possible_considerations=parsed.get("possible_considerations") or [],
        abnormal_lab_flags=_collect_abnormal_flags(documents),
        source_documents=_collect_source_filenames(documents),
    )

    return summary.model_dump()
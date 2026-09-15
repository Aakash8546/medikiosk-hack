from pydantic import BaseModel
from typing import List


class CombinedSummary(BaseModel):
    

    chief_complaint: str = ""
    history_of_present_illness: str = ""
    past_medical_surgical_history: str = ""
    drug_and_allergy_history: str = ""
    family_history: str = ""
    personal_history: str = ""
    review_of_systems: str = ""
    prior_investigations_summary: str = ""

    possible_considerations: List[str] = []
    abnormal_lab_flags: List[str] = []
    source_documents: List[str] = []
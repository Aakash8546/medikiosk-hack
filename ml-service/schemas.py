from pydantic import BaseModel
from typing import Optional, List


class HPI(BaseModel):
    onset: Optional[str] = None
    duration: Optional[str] = None
    location: Optional[str] = None
    character: Optional[str] = None
    severity: Optional[str] = None
    radiation: List[str] = []
    aggravating_factors: List[str] = []
    relieving_factors: List[str] = []
    associated_symptoms: List[str] = []


class PatientHistory(BaseModel):
    chief_complaint: Optional[str] = None
    history_of_present_illness: HPI = HPI()
    past_medical_history: List[str] = []
    past_surgical_history: List[str] = []
    medications: List[str] = []
    allergies: List[str] = []
    family_history: List[str] = []
    personal_history: dict = {}
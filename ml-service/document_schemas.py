from pydantic import BaseModel
from typing import Optional, List


class Medication(BaseModel):
    name: Optional[str] = None
    dosage: Optional[str] = None       
    frequency: Optional[str] = None    
    route: Optional[str] = None        


class LabValue(BaseModel):
    test_name: Optional[str] = None
    value: Optional[str] = None
    unit: Optional[str] = None
    reference_range: Optional[str] = None   
    is_abnormal: Optional[bool] = None      


class Procedure(BaseModel):
    name: Optional[str] = None
    date: Optional[str] = None         



class ExtractedDocument(BaseModel):
    source_filename: str
    document_type: Optional[str] = None    
    document_date: Optional[str] = None    
    normalized_date: Optional[str] = None  
    diagnoses: List[str] = []
    medications: List[Medication] = []
    lab_values: List[LabValue] = []
    procedures: List[Procedure] = []
    raw_text: str = ""                     
    page_number: int = 1
    ocr_confidence_note: Optional[str] = None  
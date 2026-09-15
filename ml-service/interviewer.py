import os
import json
from copy import deepcopy

from dotenv import load_dotenv

import groq_client
from groq_client import AIServiceUnavailableError

from prompts import SYSTEM_PROMPT
from red_flags import detect_red_flags



load_dotenv()


MODEL = "openai/gpt-oss-120b"



def create_empty_history():

    return {
        "chief_complaint": None,

        "history_of_present_illness": {
            "onset": None,
            "duration": None,
            "location": None,
            "character": None,
            "severity": None,
            "temperature": None,
            "radiation": [],
            "aggravating_factors": [],
            "relieving_factors": [],
            "associated_symptoms": []
        },

        "past_medical_history": [],
        "past_surgical_history": [],
        "medications": [],
        "allergies": [],
        "family_history": [],
        "personal_history": {},
        "review_of_systems": [],
        "red_flags": []
    }



VALID_FIELDS = {

    "chief_complaint",

    "onset",
    "duration",
    "location",
    "character",
    "severity",
    "temperature",
    "radiation",
    "aggravating_factors",
    "relieving_factors",
    "associated_symptoms",

    "past_medical_history",
    "past_surgical_history",
    "medications",
    "allergies",
    "family_history",
    "personal_history",
    "review_of_systems"
}



HPI_FIELDS = {

    "onset",
    "duration",
    "location",
    "character",
    "severity",
    "temperature",
    "radiation",
    "aggravating_factors",
    "relieving_factors",
    "associated_symptoms"
}



HPI_PRIORITY = [

    "onset",
    "duration",
    "location",
    "character",
    "severity",
    "associated_symptoms",
    "temperature",
    "radiation",
    "aggravating_factors",
    "relieving_factors"
]



COMPLAINT_PLANS = {

    "headache": {

        "required": [
            "onset",
            "duration",
            "location",
            "character",
            "severity",
            "associated_symptoms"
        ],

        "conditional": [
            "aggravating_factors",
            "relieving_factors",
            "radiation",
            "temperature"
        ],

        "general": [
            "past_medical_history",
            "medications",
            "allergies"
        ]
    },


    "fever": {

        "required": [
            "onset",
            "duration",
            "temperature",
            "associated_symptoms"
        ],

        "conditional": [
            "aggravating_factors",
            "relieving_factors"
        ],

        "general": [
            "medications",
            "allergies",
            "past_medical_history"
        ]
    },


    "stomach pain": {

        "required": [
            "onset",
            "duration",
            "location",
            "character",
            "severity",
            "associated_symptoms"
        ],

        "conditional": [
            "radiation",
            "aggravating_factors",
            "relieving_factors",
            "temperature"
        ],

        "general": [
            "past_medical_history",
            "past_surgical_history",
            "medications",
            "allergies"
        ]
    },


    "abdominal pain": {

        "required": [
            "onset",
            "duration",
            "location",
            "character",
            "severity",
            "associated_symptoms"
        ],

        "conditional": [
            "radiation",
            "aggravating_factors",
            "relieving_factors",
            "temperature"
        ],

        "general": [
            "past_medical_history",
            "past_surgical_history",
            "medications",
            "allergies"
        ]
    },


    "chest pain": {

        "required": [
            "onset",
            "duration",
            "location",
            "character",
            "severity",
            "associated_symptoms"
        ],

        "conditional": [
            "radiation",
            "aggravating_factors",
            "relieving_factors",
            "temperature"
        ],

        "general": [
            "past_medical_history",
            "medications",
            "allergies"
        ]
    },


    "cough": {

        "required": [
            "onset",
            "duration",
            "associated_symptoms"
        ],

        "conditional": [
            "temperature",
            "aggravating_factors",
            "relieving_factors"
        ],

        "general": [
            "medications",
            "allergies",
            "past_medical_history"
        ]
    },


    "back pain": {

        "required": [
            "onset",
            "duration",
            "location",
            "character",
            "severity",
            "associated_symptoms"
        ],

        "conditional": [
            "radiation",
            "aggravating_factors",
            "relieving_factors",
            "temperature"
        ],

        "general": [
            "past_medical_history",
            "medications",
            "allergies"
        ]
    }
}



GENERAL_FIELDS = [

    "past_medical_history",
    "past_surgical_history",
    "medications",
    "allergies",
    "family_history",
    "personal_history",
    "review_of_systems"
]



def normalize_language(language):

    language = str(language or "en").lower().strip()

    if language not in {"en", "hi"}:
        return "en"

    return language


def normalize_completed_fields(completed_fields):

    if not isinstance(completed_fields, set):

        completed_fields = set(
            completed_fields or []
        )

    return {
        field
        for field in completed_fields
        if field in VALID_FIELDS
    }


def get_hpi(history):

    hpi = history.get(
        "history_of_present_illness",
        {}
    )

    if not isinstance(hpi, dict):

        hpi = {}

    return hpi


def field_has_value(history, field):

    if field == "chief_complaint":

        value = history.get(
            "chief_complaint"
        )

    elif field in HPI_FIELDS:

        value = get_hpi(history).get(field)

    else:

        value = history.get(field)

    if value is None:

        return False

    if isinstance(value, str):

        return value.strip() != ""

    if isinstance(value, list):

        return len(value) > 0

    if isinstance(value, dict):

        return len(value) > 0

    return True


def set_field(history, field, value):

    if field == "chief_complaint":

        history["chief_complaint"] = value

    elif field in HPI_FIELDS:

        history.setdefault(
            "history_of_present_illness",
            {}
        )

        history[
            "history_of_present_illness"
        ][field] = value

    else:

        history[field] = value



def get_complaint_plan(history):

    complaint = history.get(
        "chief_complaint"
    )

    if not complaint:

        return None

    complaint = str(
        complaint
    ).lower().strip()

    
    if complaint in COMPLAINT_PLANS:

        return COMPLAINT_PLANS[
            complaint
        ]

    
    if "headache" in complaint:

        return COMPLAINT_PLANS[
            "headache"
        ]

    if "fever" in complaint:

        return COMPLAINT_PLANS[
            "fever"
        ]

    if "stomach" in complaint and "pain" in complaint:

        return COMPLAINT_PLANS[
            "stomach pain"
        ]

    if "abdominal" in complaint and "pain" in complaint:

        return COMPLAINT_PLANS[
            "abdominal pain"
        ]

    if "chest pain" in complaint:

        return COMPLAINT_PLANS[
            "chest pain"
        ]

    if "vomiting" in complaint or "vomit" in complaint or "nausea" in complaint:

        return {
            "required": [
                "onset",
                "duration",
                "character",
                "associated_symptoms"
            ],
            "conditional": [
                "location",
                "aggravating_factors",
                "relieving_factors",
                "temperature"
            ],
            "general": [
                "medications",
                "allergies",
                "past_medical_history"
            ]
        }

    if "cough" in complaint:

        return COMPLAINT_PLANS[
            "cough"
        ]

    if "back pain" in complaint:

        return COMPLAINT_PLANS[
            "back pain"
        ]

    
    if any(
        word in complaint
        for word in [
            "बुखार",
            "bukhar",
            "fever"
        ]
    ):

        return COMPLAINT_PLANS[
            "fever"
        ]

    if any(
        word in complaint
        for word in [
            "सिर दर्द",
            "सिरदर्द",
            "sir dard",
            "sir dard"
        ]
    ):

        return COMPLAINT_PLANS[
            "headache"
        ]

    if any(
        word in complaint
        for word in [
            "खांसी",
            "खाँसी",
            "khansi"
        ]
    ):

        return COMPLAINT_PLANS[
            "cough"
        ]

    if any(
        word in complaint
        for word in [
            "पेट दर्द",
            "पेट में दर्द",
            "pet dard"
        ]
    ):

        return COMPLAINT_PLANS[
            "abdominal pain"
        ]

    if any(
        word in complaint
        for word in [
            "सीने में दर्द",
            "सीने का दर्द",
            "chest pain"
        ]
    ):

        return COMPLAINT_PLANS[
            "chest pain"
        ]

    if any(
        word in complaint
        for word in [
            "कमर दर्द",
            "पीठ दर्द",
            "back pain"
        ]
    ):

        return COMPLAINT_PLANS[
            "back pain"
        ]

    return None



def validate_history_structure(history):

    if not isinstance(history, dict):

        raise ValueError(
            "History must be a dictionary."
        )

    if "red_flags" not in history:

        history["red_flags"] = []

    if "chief_complaint" not in history:

        history["chief_complaint"] = None

    if "history_of_present_illness" not in history:

        history[
            "history_of_present_illness"
        ] = {}

    hpi = history[
        "history_of_present_illness"
    ]

    if not isinstance(hpi, dict):

        history[
            "history_of_present_illness"
        ] = {}

        hpi = history[
            "history_of_present_illness"
        ]

    for field in HPI_FIELDS:

        if field not in hpi:

            if field in {
                "aggravating_factors",
                "relieving_factors",
                "associated_symptoms",
                "radiation"
            }:

                hpi[field] = []

            else:

                hpi[field] = None

    for field in [
        "past_medical_history",
        "past_surgical_history",
        "medications",
        "allergies",
        "family_history"
    ]:

        if field not in history:

            history[field] = []

    if "personal_history" not in history:

        history["personal_history"] = {}

    if "review_of_systems" not in history:

        history["review_of_systems"] = []

    return history



def preserve_history(
    old_history,
    new_history
):

    old_history = deepcopy(
        old_history
    )

    new_history = deepcopy(
        new_history
    )

    validate_history_structure(
        old_history
    )

    validate_history_structure(
        new_history
    )

    result = deepcopy(
        old_history
    )

    
    
    

    if (
        new_history.get("chief_complaint")
        and not result.get("chief_complaint")
    ):

        result["chief_complaint"] = new_history[
            "chief_complaint"
        ]

    
    
    

    old_hpi = result[
        "history_of_present_illness"
    ]

    new_hpi = new_history[
        "history_of_present_illness"
    ]

    for field in HPI_FIELDS:

        old_value = old_hpi.get(field)
        new_value = new_hpi.get(field)

        if new_value is None:
            continue

        if isinstance(old_value, list):

            if (
                isinstance(new_value, list)
                and len(new_value) > 0
            ):

                old_hpi[field] = new_value

            continue

        if (
            old_value is not None
            and str(old_value).strip() != ""
        ):

            continue

        old_hpi[field] = new_value

    
    
    

    for field in [
        "past_medical_history",
        "past_surgical_history",
        "medications",
        "allergies",
        "family_history",
        "personal_history",
        "review_of_systems"
    ]:

        old_value = result.get(field)
        new_value = new_history.get(field)

        if new_value is None:
            continue

        if isinstance(old_value, list):

            if (
                isinstance(new_value, list)
                and len(new_value) > 0
            ):

                result[field] = new_value

        elif isinstance(old_value, dict):

            if (
                isinstance(new_value, dict)
                and len(new_value) > 0
            ):

                result[field] = new_value

        else:

            if not field_has_value(
                result,
                field
            ):

                result[field] = new_value

    return result



def ask_groq(prompt):

    response = groq_client.chat_completion(

        model=MODEL,

        messages=[
            {
                "role": "system",
                "content": SYSTEM_PROMPT
            },
            {
                "role": "user",
                "content": prompt
            }
        ],

        temperature=0,

        response_format={
            "type": "json_object"
        }
    )

    content = (
        response
        .choices[0]
        .message
        .content
    )

    if not content:

        raise ValueError(
            "Groq returned an empty response."
        )

    try:

        return json.loads(
            content
        )

    except json.JSONDecodeError as e:

        raise ValueError(
            f"Groq returned invalid JSON: {content}"
        ) from e



def validate_field(field):

    if field not in VALID_FIELDS:

        raise ValueError(
            f"Invalid clinical field: {field}"
        )



def required_fields_complete(
    history,
    completed_fields
):

    plan = get_complaint_plan(history)

    if plan is None:
        return False

    for field in plan["required"]:

        if field not in completed_fields:
            return False

    return True



def plan_fields_complete(
    history,
    completed_fields
):

    plan = get_complaint_plan(history)

    if plan is None:
        return False

    all_fields = (
        plan["required"]
        + plan["conditional"]
        + plan["general"]
    )

    return all(
        field in completed_fields
        for field in all_fields
    )



def prioritize_missing_fields(
    history,
    completed_fields
):

    completed_fields = normalize_completed_fields(
        completed_fields
    )

    
    
    

    if (
        "chief_complaint" not in completed_fields
        and not field_has_value(
            history,
            "chief_complaint"
        )
    ):

        return ["chief_complaint"]

    
    
    

    plan = get_complaint_plan(history)

    
    
    

    if plan is None:

        for field in HPI_PRIORITY:

            if field not in completed_fields:
                return [field]

        for field in GENERAL_FIELDS:

            if field not in completed_fields:
                return [field]

        return []

    
    
    

    for field in plan.get("required", []):

        if (
            field in VALID_FIELDS
            and field not in completed_fields
        ):

            return [field]

    
    
    

    conditional = get_relevant_conditional_fields(
        history,
        completed_fields,
        plan
    )

    for field in conditional:

        if (
            field in VALID_FIELDS
            and field not in completed_fields
        ):

            return [field]

    
    
    

    for field in plan.get("general", []):

        if (
            field in VALID_FIELDS
            and field not in completed_fields
        ):

            return [field]

    
    
    

    for field in GENERAL_FIELDS:

        if (
            field in VALID_FIELDS
            and field not in completed_fields
        ):

            return [field]

    return []



def get_relevant_conditional_fields(
    history,
    completed_fields,
    plan
):

    complaint = str(
        history.get(
            "chief_complaint",
            ""
        )
    ).lower()

    relevant = []

    for field in plan["conditional"]:

        
        
        

        if field == "temperature":

            if any(
                word in complaint
                for word in [
                    "fever",
                    "bukhar",
                    "बुखार"
                ]
            ):

                relevant.append(field)

            elif any(
                word in complaint
                for word in [
                    "headache",
                    "stomach",
                    "abdominal",
                    "cough",
                    "chest",
                    "back",
                    "सिर दर्द",
                    "पेट दर्द",
                    "खांसी",
                    "सीने में दर्द"
                ]
            ):

                symptoms = get_hpi(
                    history
                ).get(
                    "associated_symptoms",
                    []
                )

                symptom_text = str(
                    symptoms
                ).lower()

                if any(
                    word in symptom_text
                    for word in [
                        "fever",
                        "chills",
                        "cold",
                        "infection",
                        "बुखार",
                        "ठंड"
                    ]
                ):

                    relevant.append(field)

        
        
        

        elif field == "radiation":

            if any(
                word in complaint
                for word in [
                    "pain",
                    "headache",
                    "chest",
                    "back",
                    "abdominal",
                    "stomach",
                    "दर्द"
                ]
            ):

                relevant.append(field)

        
        
        

        elif field == "aggravating_factors":

            if any(
                word in complaint
                for word in [
                    "pain",
                    "headache",
                    "cough",
                    "दर्द",
                    "खांसी",
                    "खाँसी"
                ]
            ):

                relevant.append(field)

        
        
        

        elif field == "relieving_factors":

            if any(
                word in complaint
                for word in [
                    "pain",
                    "headache",
                    "cough",
                    "दर्द",
                    "खांसी",
                    "खाँसी"
                ]
            ):

                relevant.append(field)

    return relevant



def generate_question_for_field(
    history,
    completed_fields,
    field,
    language="en"
):

    validate_field(field)

    language = normalize_language(language)

    completed_fields = normalize_completed_fields(
        completed_fields
    )

    if field in completed_fields:

        raise ValueError(
            f"Cannot generate question for completed field: "
            f"{field}"
        )

    
    
    
    
    
    

    duration_context = ""

    if field == "duration":

        known_onset = get_hpi(history).get("onset")

        duration_context = (
            "\n============================================================\n"
            "IMPORTANT -- DURATION vs ONSET\n"
            "============================================================\n\n"
            "The patient already told you WHEN the symptom started (onset):\n\n"
            + str(known_onset) + "\n\n"
            "Do NOT ask \"when did it start\" or \"how long ago did it begin\"\n"
            "again -- that has already been answered.\n\n"
            "Instead, ask ONLY whether the symptom has been CONSTANT/\n"
            "CONTINUOUS since then, or whether it comes and goes\n"
            "(intermittent). This is genuinely new information, not a\n"
            "restatement of onset.\n"
        )

    prompt = f

    try:

        result = ask_groq(prompt)

    except AIServiceUnavailableError:

        
        
        
        
        
        print(
            "⚠️ Groq unavailable while generating a question -- "
            "falling back to a deterministic question."
        )

        return None

    question = result.get(
        "next_question"
    )

    if not isinstance(
        question,
        str
    ):

        return None

    question = question.strip()

    if not question:
        return None

    return question



def deterministic_question(
    field,
    language="en"
):

    language = normalize_language(language)

    english_questions = {

        "chief_complaint":
            "What problem are you experiencing?",

        "onset":
            "When did this problem start?",

        "duration":
            "Has it been constant since it started, or does it come and go?",

        "location":
            "Where exactly do you feel it?",

        "character":
            "How would you describe it?",

        "severity":
            "How severe is it on a scale of 0 to 10?",

        "temperature":
            "Have you measured your temperature recently?",

        "radiation":
            "Does the pain spread or move to another area?",

        "aggravating_factors":
            "What makes it worse?",

        "relieving_factors":
            "What makes it better?",

        "associated_symptoms":
            "Are you experiencing any other symptoms?",

        "medications":
            "Are you currently taking any medicines?",

        "allergies":
            "Do you have any known allergies?",

        "past_medical_history":
            "Do you have any medical conditions or chronic illnesses?",

        "past_surgical_history":
            "Have you had any surgeries or medical procedures?",

        "family_history":
            "Does anyone in your family have any important medical conditions?",

        "personal_history":
            "Are there any lifestyle factors that would be important to know about?",

        "review_of_systems":
            "Are there any other health symptoms you would like to mention?"
    }

    hindi_questions = {

        "chief_complaint":
            "आपको अभी मुख्य रूप से क्या समस्या या लक्षण हो रहा है?",

        "onset":
            "यह समस्या कब शुरू हुई?",

        "duration":
            "क्या यह शुरू होने के बाद से लगातार बना हुआ है, या यह आता-जाता रहता है?",

        "location":
            "आपको यह समस्या शरीर के किस हिस्से में महसूस होती है?",

        "character":
            "आप इस समस्या को किस तरह महसूस करते हैं?",

        "severity":
            "यह समस्या 0 से 10 के पैमाने पर कितनी गंभीर है?",

        "temperature":
            "क्या आपने हाल ही में अपना तापमान मापा है?",

        "radiation":
            "क्या यह दर्द शरीर के किसी दूसरे हिस्से तक फैलता है?",

        "aggravating_factors":
            "किस चीज़ से यह समस्या बढ़ जाती है?",

        "relieving_factors":
            "किस चीज़ से आपको इसमें आराम मिलता है?",

        "associated_symptoms":
            "क्या इसके साथ आपको कोई और लक्षण भी हो रहे हैं?",

        "medications":
            "क्या आप अभी कोई दवाइयाँ ले रहे हैं?",

        "allergies":
            "क्या आपको किसी दवा या चीज़ से एलर्जी है?",

        "past_medical_history":
            "क्या आपको पहले से कोई बीमारी या पुरानी स्वास्थ्य समस्या है?",

        "past_surgical_history":
            "क्या आपकी पहले कभी कोई सर्जरी या मेडिकल प्रक्रिया हुई है?",

        "family_history":
            "क्या आपके परिवार में किसी को कोई महत्वपूर्ण बीमारी है?",

        "personal_history":
            "क्या आपकी जीवनशैली से जुड़ी कोई ऐसी बात है जो जानना ज़रूरी हो?",

        "review_of_systems":
            "क्या आपको कोई और स्वास्थ्य संबंधी लक्षण हैं जो आप बताना चाहते हैं?"
    }

    if language == "hi":

        return hindi_questions.get(field)

    return english_questions.get(field)



def generate_next_question(
    history,
    completed_fields,
    language="en"
):

    language = normalize_language(language)

    completed_fields = normalize_completed_fields(
        completed_fields
    )

    
    
    

    priority_fields = prioritize_missing_fields(
        history,
        completed_fields
    )

    selected_field = None

    for field in priority_fields:

        if (
            field in VALID_FIELDS
            and field not in completed_fields
        ):

            selected_field = field
            break

    
    
    

    if selected_field is None:

        return None, None, False

    
    
    

    if selected_field in completed_fields:

        raise ValueError(
            "Internal safety error: selected field "
            "is already completed."
        )

    
    
    

    is_fallback = False
    question = generate_question_for_field(
        history,
        completed_fields,
        selected_field,
        language=language
    )

    
    
    

    if question is None:

        is_fallback = True
        question = deterministic_question(
            selected_field,
            language=language
        )

    if not question:

        raise ValueError(
            f"Could not generate question for "
            f"field: {selected_field}"
        )

    return (
        selected_field,
        question,
        is_fallback
    )




def process_patient_answer(
    patient_answer,
    history,
    completed_fields,
    last_question,
    expected_field=None,
    language="en"
):

    language = normalize_language(language)

    completed_fields = normalize_completed_fields(
        completed_fields
    )

    
    
    

    if not isinstance(
        patient_answer,
        str
    ):

        patient_answer = str(
            patient_answer
        )

    patient_answer = patient_answer.strip()

    if not patient_answer:

        return (
            history,
            completed_fields,
            last_question,
            expected_field
        )

    
    
    

    if expected_field is None:

        raise ValueError(
            "Expected field was not provided."
        )

    validate_field(
        expected_field
    )

    if expected_field in completed_fields:

        raise ValueError(
            f"Field '{expected_field}' was already "
            f"completed before this answer."
        )

    
    
    

    red_flag_result = detect_red_flags(
        patient_answer,
        history
    )

    
    
    

    if red_flag_result["red_flag"]:

        history.setdefault(
            "red_flags",
            []
        )

        history["red_flags"].append(
            {
                "rule": red_flag_result["rule"],
                "alert": red_flag_result["alert"],
                "matched_symptoms":
                    red_flag_result["matched_symptoms"],
                "patient_answer":
                    patient_answer
            }
        )

        

        if expected_field == "chief_complaint":

            set_field(
                history,
                expected_field,
                patient_answer
            )

        elif expected_field in HPI_FIELDS:

            if patient_answer.lower() in {
                "no",
                "nahi",
                "nahin",
                "nothing",
                "none",
                "not really"
            }:

                if expected_field in {
                    "aggravating_factors",
                    "relieving_factors",
                    "associated_symptoms",
                    "radiation"
                }:

                    set_field(
                        history,
                        expected_field,
                        []
                    )

                else:

                    set_field(
                        history,
                        expected_field,
                        "none"
                    )

            else:

                set_field(
                    history,
                    expected_field,
                    patient_answer
                )

        else:

            set_field(
                history,
                expected_field,
                patient_answer
            )

        completed_fields.add(
            expected_field
        )

        completed_fields = normalize_completed_fields(
            completed_fields
        )

        validate_history_structure(
            history
        )

        print()
        print("🚨 RED FLAG DETECTED")

        print(
            f"Rule: {red_flag_result['rule']}"
        )

        print(
            f"Alert: {red_flag_result['alert']}"
        )

        print(
            "Matched symptoms:",
            red_flag_result["matched_symptoms"]
        )

        print()

        if red_flag_result.get(
            "action"
        ) == "urgent_attention":

            print(
                "🚨 URGENT MEDICAL ATTENTION MAY BE REQUIRED."
            )

            print(
                "The interview will stop for safety."
            )

            print()

            return (
                history,
                completed_fields,
                None,
                None
            )

    
    
    

    extraction_prompt = f

    degraded_mode = False

    try:

        extraction_result = ask_groq(
            extraction_prompt
        )

        updated_history = extraction_result.get(
            "updated_history"
        )

        if not isinstance(
            updated_history,
            dict
        ):

            raise ValueError(
                "Groq returned invalid updated_history."
            )

    except AIServiceUnavailableError:

        
        
        
        
        
        
        
        
        
        
        
        
        
        

        print(
            "⚠️ Groq unavailable during extraction -- "
            "continuing in degraded mode (raw-answer capture only)."
        )

        degraded_mode = True
        updated_history = deepcopy(history)

    
    
    
    

    if not field_has_value(
        updated_history,
        expected_field
    ):

        if expected_field in {
            "aggravating_factors",
            "relieving_factors",
            "associated_symptoms",
            "radiation"
        }:

            if patient_answer.lower() in {
                "no",
                "nahi",
                "nahin",
                "nothing",
                "none",
                "not really"
            }:

                set_field(
                    updated_history,
                    expected_field,
                    []
                )

            else:

                set_field(
                    updated_history,
                    expected_field,
                    [patient_answer]
                )

        else:

            set_field(
                updated_history,
                expected_field,
                patient_answer
            )

    
    
    

    updated_history = preserve_history(
        history,
        updated_history
    )

    validate_history_structure(
        updated_history
    )

    
    
    

    completed_fields.add(
        expected_field
    )

    completed_fields = normalize_completed_fields(
        completed_fields
    )

    
    
    

    next_field, next_question, is_fallback = (
        generate_next_question(
            updated_history,
            completed_fields,
            language=language
        )
    )

    
    
    

    if next_field is None:

        return (
            updated_history,
            completed_fields,
            None,
            None,
            False
        )

    
    
    

    if next_field in completed_fields:

        raise ValueError(
            f"SAFETY FAILURE: AI tried to ask "
            f"completed field: {next_field}"
        )

    if next_field not in VALID_FIELDS:

        raise ValueError(
            f"SAFETY FAILURE: Invalid next field: "
            f"{next_field}"
        )

    if not next_question:

        raise ValueError(
            f"Could not generate question for "
            f"field: {next_field}"
        )

    return (
        updated_history,
        completed_fields,
        next_question,
        next_field,
        is_fallback
    )




def deterministic_summary(history, language="en"):

    language = normalize_language(language)

    not_reported_en = "Not reported."
    not_reported_hi = "उपलब्ध नहीं।"

    not_reported = (
        not_reported_hi
        if language == "hi"
        else not_reported_en
    )

    def fmt(value):

        if value is None:
            return not_reported

        if isinstance(value, list):

            if not value:
                return not_reported

            return ", ".join(str(v) for v in value)

        value = str(value).strip()

        return value if value else not_reported

    hpi = get_hpi(history)

    if language == "hi":

        lines = [
            f"मुख्य समस्या: {fmt(history.get('chief_complaint'))}",
            f"शुरुआत: {fmt(hpi.get('onset'))}",
            f"अवधि: {fmt(hpi.get('duration'))}",
            f"स्थान: {fmt(hpi.get('location'))}",
            f"प्रकृति: {fmt(hpi.get('character'))}",
            f"गंभीरता: {fmt(hpi.get('severity'))}",
            f"तापमान: {fmt(hpi.get('temperature'))}",
            f"फैलाव: {fmt(hpi.get('radiation'))}",
            f"बढ़ाने वाले कारक: {fmt(hpi.get('aggravating_factors'))}",
            f"कम करने वाले कारक: {fmt(hpi.get('relieving_factors'))}",
            f"साथ के लक्षण: {fmt(hpi.get('associated_symptoms'))}",
            f"पूर्व चिकित्सा इतिहास: {fmt(history.get('past_medical_history'))}",
            f"पूर्व शल्य चिकित्सा इतिहास: {fmt(history.get('past_surgical_history'))}",
            f"दवाइयाँ: {fmt(history.get('medications'))}",
            f"एलर्जी: {fmt(history.get('allergies'))}",
            f"पारिवारिक इतिहास: {fmt(history.get('family_history'))}",
            f"प्रणाली समीक्षा: {fmt(history.get('review_of_systems'))}",
        ]

        summary = (
            "यह सारांश AI सहायता के बिना, सीधे एकत्रित जानकारी से "
            "स्वतः तैयार किया गया है (AI सेवा अस्थायी रूप से "
            "अनुपलब्ध थी):\n\n" + "\n".join(lines)
        )

    else:

        lines = [
            f"Chief complaint: {fmt(history.get('chief_complaint'))}",
            f"Onset: {fmt(hpi.get('onset'))}",
            f"Duration: {fmt(hpi.get('duration'))}",
            f"Location: {fmt(hpi.get('location'))}",
            f"Character: {fmt(hpi.get('character'))}",
            f"Severity: {fmt(hpi.get('severity'))}",
            f"Temperature: {fmt(hpi.get('temperature'))}",
            f"Radiation: {fmt(hpi.get('radiation'))}",
            f"Aggravating factors: {fmt(hpi.get('aggravating_factors'))}",
            f"Relieving factors: {fmt(hpi.get('relieving_factors'))}",
            f"Associated symptoms: {fmt(hpi.get('associated_symptoms'))}",
            f"Past medical history: {fmt(history.get('past_medical_history'))}",
            f"Past surgical history: {fmt(history.get('past_surgical_history'))}",
            f"Medications: {fmt(history.get('medications'))}",
            f"Allergies: {fmt(history.get('allergies'))}",
            f"Family history: {fmt(history.get('family_history'))}",
            f"Review of systems: {fmt(history.get('review_of_systems'))}",
        ]

        summary = (
            "This summary was auto-generated directly from the "
            "collected information, without AI assistance (the AI "
            "service was temporarily unavailable):\n\n" + "\n".join(lines)
        )

    return {
        "summary": summary,
        "possible_considerations": [],
        "degraded_mode": True
    }



def generate_final_summary(
    history,
    language="en"
):

    language = normalize_language(language)

    
    
    

    report_system_prompt = 

    
    
    

    report_prompt = f

    
    
    

    try:

        response = groq_client.chat_completion(

            model=MODEL,

            messages=[
                {
                    "role": "system",
                    "content": report_system_prompt
                },
                {
                    "role": "user",
                    "content": report_prompt
                }
            ],

            temperature=0,

            response_format={
                "type": "json_object"
            }
        )

    except AIServiceUnavailableError:

        
        
        
        
        
        print(
            "⚠️ Groq unavailable while generating the final summary "
            "-- falling back to a template-based summary."
        )

        return deterministic_summary(
            history,
            language=language
        )

    content = (
        response
        .choices[0]
        .message
        .content
    )

    if not content:

        raise ValueError(
            "Groq returned an empty final report."
        )

    try:

        result = json.loads(
            content
        )

    except json.JSONDecodeError as e:

        raise ValueError(
            f"Groq returned invalid final report JSON: {content}"
        ) from e

    
    
    

    summary = result.get(
        "summary"
    )

    considerations = result.get(
        "possible_considerations"
    )

    if not isinstance(
        summary,
        str
    ):

        raise ValueError(
            "Final report does not contain a valid summary."
        )

    if not isinstance(
        considerations,
        list
    ):

        considerations = []

    return {
        "summary": summary.strip(),
        "possible_considerations": considerations
    }
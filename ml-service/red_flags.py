
RED_FLAG_RULES = {

    
    
    

    "chest_pain_with_breathlessness": {

        "required_groups": [

            [
                "chest pain",
                "chest pain hai",
                "seene mein dard",
                "seene me dard",
                "seene mein pain",
                "seene me pain"
            ],

            [
                "difficulty breathing",
                "shortness of breath",
                "breathlessness",
                "saans lene mein dikkat",
                "saans lene me dikkat",
                "saans lene me dikkt",
                "saans lene mein dikkt",
                "saans ki dikkat",
                "saans ki dikkt",
                "saans phoolna",
                "saans phool rahi"
            ]
        ],

        "alert":
            "Possible emergency: chest pain associated with breathing difficulty.",
        "action": "urgent_attention"
    },


    
    
    

    "stroke_warning": {

        "symptoms": [

            "face drooping",
            "facial weakness",
            "arm weakness",
            "leg weakness",
            "slurred speech",
            "difficulty speaking",
            "sudden weakness",
            "sudden numbness",

            
            "muh tedha",
            "munh tedha",
            "haath mein kamzori",
            "haath me kamzori",
            "haath achanak kamzor",
            "haath achanak kamzor ho gaya",
            "haath achanak kamzor ho gayi",
            "pair mein kamzori",
            "pair me kamzori",
            "pair achanak kamzor",
            "bolne mein dikkat",
            "bolne me dikkat",
            "bolne mein problem",
            "bolne me problem",
            "achanak kamzori",
            "achanak sunn",
            "haath sunn ho gaya",
            "haath sun ho gaya",
            "pair sunn ho gaya",
            "pair sun ho gaya"
        ],

        "alert":
            "Possible stroke warning signs detected.",
        "action": "urgent_attention"
    },

    

    "sudden_severe_headache": {

        "symptoms": [

        "sudden severe headache",
        "sudden severe headache started",
        "worst headache",
        "worst headache of my life",
        "severe headache suddenly",
        "headache suddenly started",

        
        "achanak bahut tez headache",
        "achanak bahut tez sar dard",
        "achanak bahut zyada headache",
        "achanak bahut zyada sar dard",
        "achanak tez sar dard",
        "achanak se bahut tez headache",
        "achanak se bahut tez sar dard",
        "bahut tez headache achanak",
        "bahut tez sar dard achanak",
        "sar dard achanak shuru hua",
        "headache achanak shuru hua",
        "achanak headache shuru hua"
        ],

    "alert":
        "Sudden severe headache detected. Urgent medical evaluation may be required.",

    "action":
        "urgent_attention"
    },


    
    
    

    

    "severe_breathing_problem": {

       "symptoms": [

        
        
        

        "cannot breathe",
        "can't breathe",
        "can not breathe",

        "unable to breathe",
        "not able to breathe",

        "i cannot breathe",
        "i can't breathe",
        "i can not breathe",

        "i am unable to breathe",
        "i'm unable to breathe",

        "i am not able to breathe",
        "i'm not able to breathe",

        "i cannot breath",
        "i can't breath",
        "unable to breath",
        "not able to breath",

        "severe difficulty breathing",
        "extreme breathlessness",
        "severe breathlessness",

        "breathing heavily",
        "struggling to breathe",
        "struggling to breath",

        "having trouble breathing",
        "having difficulty breathing",

        "difficulty breathing badly",
        "very difficult to breathe",

        "i am having difficulty breathing",
        "i'm having difficulty breathing",

        "i am having trouble breathing",
        "i'm having trouble breathing",

        "i am struggling to breathe",
        "i'm struggling to breathe",

        "i cannot catch my breath",
        "i can't catch my breath",
        "cannot catch my breath",
        "can't catch my breath",

        "shortness of breath",
        "severe shortness of breath",

        
        
        

        "saans nahi aa rahi",
        "saans nahi aa raha",

        "saans nahi le pa raha",
        "saans nahi le paa raha",

        "saans nahi le pa rahi",
        "saans nahi le paa rahi",

        "saans lene mein dikkat",
        "saans lene me dikkat",

        "saans lene mein dikkt",
        "saans lene me dikkt",

        "saans ki dikkat",
        "saans ki dikkt",

        "bahut saans phool rahi hai",
        "bahut saans phool rahi",

        "bahut zyada saans phool rahi",

        "saans phool rahi hai",
        "saans phool rahi",

        "saans phool raha hai",
        "saans phool raha",

        "saans lene mein bahut dikkat",
        "saans lene me bahut dikkat",

        "bahut mushkil se saans",
        "saans lene mein bahut problem",
        "saans lene me bahut problem"
        ],

    "alert":
        "Severe breathing difficulty detected.",

    "action":
        "urgent_attention"
    },

    
    
    

    "loss_of_consciousness": {

        "symptoms": [

            "unconscious",
            "passed out",
            "lost consciousness",
            "fainted",

            "behosh",
            "behosh ho gaya",
            "behosh ho gayi",
            "behosh ho raha",
            "behosh ho rahi"
        ],

        "alert":
            "Loss of consciousness detected.",
        "action": "urgent_attention"
    },


    
    
    

    "severe_bleeding": {

        "symptoms": [

            "heavy bleeding",
            "severe bleeding",
            "bleeding heavily",

            "bahut khoon",
            "zyada khoon",
            "bahut zyada khoon",
            "khoon nahi ruk raha",
            "khoon nahi ruk rahi"
        ],

        "alert":
            "Severe bleeding may require immediate attention.",
        "action": "urgent_attention"
    }
}



NEGATION_CUES = {
    "no", "not", "never", "without", "denies", "denied", "deny",
    "dont", "doesnt", "didnt", "cant", "cannot", "wasnt", "isnt",
    "nahi", "nahin", "nahiin", "nai", "naa", "na"
}

NEGATION_WINDOW_CHARS = 35


def _is_negated(text, start, end):

    window_start = max(0, start - NEGATION_WINDOW_CHARS)
    window_end = min(len(text), end + NEGATION_WINDOW_CHARS)

    surrounding = text[window_start:start] + " " + text[end:window_end]

    
    
    if "n't" in surrounding:
        return True

    tokens = (
        surrounding
        .replace(",", " ")
        .replace(".", " ")
        .replace("'", "")
        .split()
    )

    return any(token in NEGATION_CUES for token in tokens)


def _phrase_present(text, phrase):
    

    phrase = phrase.lower()
    search_from = 0

    while True:

        idx = text.find(phrase, search_from)

        if idx == -1:
            return False

        end = idx + len(phrase)

        if not _is_negated(text, idx, end):
            return True

        search_from = end



def _history_to_searchable_text(history):

    if not history:
        return ""

    parts = []

    def _add(value):

        if not value:
            return

        if isinstance(value, list):
            parts.extend(str(v) for v in value)
        else:
            parts.append(str(value))

    _add(history.get("chief_complaint"))
    _add(history.get("review_of_systems"))

    hpi = history.get("history_of_present_illness", {}) or {}

    _add(hpi.get("character"))
    _add(hpi.get("location"))
    _add(hpi.get("associated_symptoms"))

    return " ".join(parts).lower()



def detect_red_flags(patient_answer, history=None):

    
    
    

    if not patient_answer:

        return {
            "red_flag": False,
            "rule": None,
            "alert": None,
            "action": None,
            "matched_symptoms": []
        }

    current_text = str(
        patient_answer
    ).lower().strip()

    
    
    
    
    history_text = _history_to_searchable_text(history)

    text = (
        f"{history_text} {current_text}".strip()
        if history_text
        else current_text
    )

    
    
    

    for rule_name, rule in RED_FLAG_RULES.items():

        
        
        
        

        if rule_name == "chest_pain_with_breathlessness":

            matched_groups = []

            for group in rule["required_groups"]:

                group_match = None

                for symptom in group:

                    if _phrase_present(text, symptom):

                        group_match = symptom
                        break

                if group_match:

                    matched_groups.append(
                        group_match
                    )

            

            if len(matched_groups) == 2:

                return {
                    "red_flag": True,
                    "rule": rule_name,
                    "alert": rule["alert"],
                    "action": rule["action"],
                    "matched_symptoms": matched_groups
                }

            continue


        
        
        

        matched_symptoms = []

        for symptom in rule["symptoms"]:

            if _phrase_present(text, symptom):

                matched_symptoms.append(
                    symptom
                )

        if matched_symptoms:

            return {
                "red_flag": True,
                "rule": rule_name,
                "alert": rule["alert"],
                "action": rule["action"],
                "matched_symptoms": matched_symptoms
            }


    
    
    

    return {
        "red_flag": False,
        "rule": None,
        "alert": None,
        "action": None,
        "matched_symptoms": []
    }
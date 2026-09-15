

QUICK_REPLIES = {

    "en": {
        "radiation": ["No", "Yes"],
        "severity": ["Mild", "Moderate", "Severe"],
        "onset": ["Today", "Yesterday", "2-3 days ago", "About a week ago", "More than a week ago"],
        "duration": ["Less than a day", "1-3 days", "4-7 days", "More than a week"],
        "associated_symptoms": ["None"],
        "aggravating_factors": ["Nothing"],
        "relieving_factors": ["Nothing"],
        "medications": ["No", "Yes"],
        "allergies": ["No", "Yes"],
        "past_medical_history": ["No", "Yes"],
        "past_surgical_history": ["No", "Yes"],
        "family_history": ["No", "Yes"],
        "review_of_systems": ["No", "Yes"],
    },

    "hi": {
        "radiation": ["नहीं", "हाँ"],
        "severity": ["हल्का", "मध्यम", "गंभीर"],
        "onset": ["आज", "कल", "2-3 दिन पहले", "करीब एक हफ्ता पहले", "एक हफ्ते से ज्यादा"],
        "duration": ["एक दिन से कम", "1-3 दिन", "4-7 दिन", "एक हफ्ते से ज्यादा"],
        "associated_symptoms": ["कुछ नहीं"],
        "aggravating_factors": ["कुछ नहीं"],
        "relieving_factors": ["कुछ नहीं"],
        "medications": ["नहीं", "हाँ"],
        "allergies": ["नहीं", "हाँ"],
        "past_medical_history": ["नहीं", "हाँ"],
        "past_surgical_history": ["नहीं", "हाँ"],
        "family_history": ["नहीं", "हाँ"],
        "review_of_systems": ["नहीं", "हाँ"],
    },
}


def get_quick_replies(field, language):
    
    if not field:
        return []

    lang_key = "hi" if language == "hi" else "en"

    return QUICK_REPLIES.get(lang_key, {}).get(field, [])
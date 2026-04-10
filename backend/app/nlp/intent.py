import spacy

nlp_intent = spacy.load(str(__import__("pathlib").Path(__file__).parent / "intent_model_v2"))    
nlp_lang = spacy.load("en_core_web_sm")        


EMERGENCY_KEYWORDS = {
    "emergency",
    "urgent",
    "immediately",
    "right now",
    "critical",
    "serious",
    "help now",
}

FIRST_AID_PHRASES = {
    "first aid",
    "what should i do",
    "how to treat",
    "how to help",
    "how to stop",
    "treatment for",
}

STRONG_FIRST_AID_WORDS = {
    "burn",
    "cut",
    "fracture",
    "choke",
    "choking",
    "bleed",
    "bleeding",
    "snake",
    "dog",
    "bite",
    "seizure",
    "stroke",
    "heart attack",
    "unconscious",
    "drown",
    "poison",
    "shock",
    "injury",
}

FIRST_AID_CASES = {
    "Burns",  "Burns (Severe)",
    "Scald (Hot Water Burn)",
    "Chemical Burn", "Electric Shock",
    "Minor Cut","Deep Cut", "Bleeding (Severe)", "Nosebleed","Animal Bite", "Dog Bite",
    "Snake Bite", "Insect Sting", "Severe Allergic Reaction",
    "Choking (Adult)", "Choking (Infant)", "Fracture (Suspected)", "Sprain", "Strain", "Dislocation","Head Injury (Minor)", "Head Injury (Severe)",
    "Concussion", "Fainting", "Heat Stroke","Heat Exhaustion", "Dehydration", "Hypothermia",  "Frostbite","Asthma Attack",
    "Heart Attack (Suspected)", "Stroke (Suspected)", "Seizure",  "Drowning",
    "Poisoning (General)", "Food Poisoning",
    "Eye Injury (Foreign Object)","Eye Chemical Exposure",
    "Tooth Knocked Out", "Broken Tooth", "Back Injury", "Spinal Injury","Chest Pain", "Abdominal Injury",
    "Internal Bleeding (Suspected)","Diabetic Emergency (Low Sugar)", "Diabetic Emergency (High Sugar)", "Panic Attack", "Hyperventilation", "Shock",
    "Bruise", "Blister",
    "Splinter", "Sunburn","Nose Injury", "Ear Injury", "Electric Burn", "Gas Inhalation",  "Carbon Monoxide Exposure", "Severe Vomiting",
    "Severe Diarrhea", "Bee Sting Allergy", "Nail Injury", "Crushed Finger",
    "Shoulder Injury","Knee Injury", "Hip Injury", "Severe Headache (Sudden)", "Unconscious Person", "Vomiting Blood",
    "Severe Burn from Fire","Glass Cut", "Torn Ligament", "Shock from Trauma",
    "Unknown Severe Injury", "Minor Burn from Iron", "Boiling Water Spill",
    "Finger Cut (Kitchen)","Scalp Cut","Lip Cut",
    "Tongue Bite",
    "Finger Slammed in Door","Nose Foreign Object (Child)","Ear Foreign Object",
    "Mild Smoke Inhalation","Mild Food Choking (Able to Cough)","Boil on Skin",
    "Nail Cut Too Deep","Paper Cut","Razor Cut","Mild Back Strain", "Leg Cramp",
    "Foot Blister (From Shoes)", "Ingrown Toenail (Mild)",
    "Minor Eye Irritation (Dust)","Contact Lens Irritation", "Mild Dehydration (Exercise)",
    "Mild Heat Rash",
    "Cold Exposure (Mild)","Mild Sunstroke",
    "Minor Electric Static Shock","Small Skin Abrasion","Minor Fall Without Injury", "Bruised Toenail",
    "Small Splashed Chemical on Skin (Non-corrosive)",
    "Mild Motion Sickness","Mild Anxiety Episode",
    "Mild Nose Congestion","Mild Sore Throat",
    "Mild Cough","Minor Finger Burn from Cooking",
    "Small Thorn Prick", "Minor Muscle Bruise from Sports",
    "Minor Head Bump (No Symptoms)","Mild Toothache",
}
HEALTH_KEYWORDS = {
    "bmi",
    "body mass index",
    "health metrics",
    "health assessment",
    "check my health",
    "analyze my health",
    "check bmi",
    "calculate bmi",
    "body metrics",
    "vitals",
}
VALID_SYMPTOMS = {
"abdominal_pain","abnormal_menstruation","acidity","acute_liver_failure",
"altered_sensorium","anxiety","back_pain","belly_pain","blackheads",
"bladder_discomfort","blister","blood_in_sputum","bloody_stool",
"blurred_and_distorted_vision","breathlessness","brittle_nails","bruising",
"burning_micturition","chest_pain","chills","cold_hands_and_feets","coma",
"congestion","constipation","continuous_feel_of_urine","continuous_sneezing",
"cough","cramps","dark_urine","dehydration","depression","diarrhoea",
"dischromic_patches","distention_of_abdomen","dizziness",
"drying_and_tingling_lips","enlarged_thyroid","excessive_hunger",
"extra_marital_contacts","family_history","fast_heart_rate","fatigue",
"fluid_overload","foul_smell_of_urine","headache","high_fever",
"hip_joint_pain","history_of_alcohol_consumption","increased_appetite",
"indigestion","inflammatory_nails","internal_itching","irregular_sugar_level",
"irritability","irritation_in_anus","itching","joint_pain","knee_pain",
"lack_of_concentration","lethargy","loss_of_appetite","loss_of_balance",
"loss_of_smell","malaise","mild_fever","mood_swings","movement_stiffness",
"mucoid_sputum","muscle_pain","muscle_wasting","muscle_weakness","nausea",
"neck_pain","nodal_skin_eruptions","obesity","pain_behind_the_eyes",
"pain_during_bowel_movements","pain_in_anal_region","painful_walking",
"palpitations","passage_of_gases","patches_in_throat","phlegm","polyuria",
"prominent_veins_on_calf","puffy_face_and_eyes","pus_filled_pimples",
"receiving_blood_transfusion","receiving_unsterile_injections",
"red_sore_around_nose","red_spots_over_body","redness_of_eyes",
"restlessness","runny_nose","rusty_sputum","scurring","shivering",
"silver_like_dusting","sinus_pressure","skin_peeling","skin_rash",
"slurred_speech","small_dents_in_nails","spinning_movements",
"spotting_urination","stiff_neck","stomach_bleeding","stomach_pain",
"sunken_eyes","sweating","swelled_lymph_nodes","swelling_joints",
"swelling_of_stomach","swollen_blood_vessels","swollen_extremeties",
"swollen_legs","throat_irritation","toxic_look_(typhos)",
"ulcers_on_tongue","unsteadiness","visual_disturbances","vomiting",
"watering_from_eyes","weakness_in_limbs","weakness_of_one_body_side",
"weight_gain","weight_loss","yellow_crust_ooze","yellow_urine",
"yellowing_of_eyes","yellowish_skin"
}

SYMPTOM_SYNONYMS = {
    "tired": "fatigue",
    "very tired": "fatigue",
    "exhausted": "fatigue",
    "low energy": "fatigue",
    "no energy": "fatigue",
    "lethargic": "lethargy",
    "feeling weak": "weakness_in_limbs",
    "weak": "weakness_in_limbs",

    "body ache": "muscle_pain",
    "body aches": "muscle_pain",
    "whole body pain": "muscle_pain",
    "muscle ache": "muscle_pain",
    "muscle aches": "muscle_pain",
    "aching": "muscle_pain",
    "joint aches": "joint_pain",
    "knees hurt": "knee_pain",
    "back ache": "back_pain",
    "neck ache": "neck_pain",

    "high temperature": "high_fever",
    "running fever": "high_fever",
    "feverish": "high_fever",
    "mild temperature": "mild_fever",

    "head spinning": "spinning_movements",
    "room spinning": "spinning_movements",
    "dizzy": "dizziness",
    "lightheaded": "dizziness",
    "feeling faint": "dizziness",
    "migraine": "headache",
    "bad headache": "headache",
    "severe headache": "headache",

    "stomach ache": "stomach_pain",
    "tummy pain": "belly_pain",
    "belly ache": "belly_pain",
    "loose motion": "diarrhoea",
    "loose motions": "diarrhoea",
    "loose stools": "diarrhoea",
    "throwing up": "vomiting",
    "vomit": "vomiting",
    "feel like vomiting": "nausea",
    "loss of hunger": "loss_of_appetite",

    "burning urine": "burning_micturition",
    "burning while urinating": "burning_micturition",
    "pain while urinating": "burning_micturition",
    "urinating often": "continuous_feel_of_urine",
    "frequent urination": "continuous_feel_of_urine",
    "bad urine smell": "foul_smell_of_urine",

    "shortness of breath": "breathlessness",
    "breathing difficulty": "breathlessness",
    "difficulty breathing": "breathlessness",
    "sore throat": "throat_irritation",
    "throat pain": "throat_irritation",
    "itchy throat": "throat_irritation",
    "blocked nose": "congestion",
    "runny nose": "runny_nose",
    "phlegm": "phlegm",
    "mucus cough": "mucoid_sputum",

    "itchy skin": "itching",
    "skin itching": "itching",
    "red patches": "skin_rash",
    "rashes": "skin_rash",
    "yellow skin": "yellowish_skin",
    "yellow eyes": "yellowing_of_eyes",

    "chest tightness": "chest_pain",
    "pressure in chest": "chest_pain",
    "heart racing": "fast_heart_rate",
    "fast heartbeat": "fast_heart_rate",
    "irregular heartbeat": "palpitations",

    "feeling anxious": "anxiety",
    "panic feeling": "anxiety",
    "feeling depressed": "depression",
    "mood changes": "mood_swings",

    "blurred vision": "blurred_and_distorted_vision",
    "watery eyes": "watering_from_eyes",
    "red eyes": "redness_of_eyes",

    "shaking": "shivering",
    "sweaty": "sweating",
    "loss of smell": "loss_of_smell",

    "severe burn": "Burns (Severe)",
    "bad burn": "Burns (Severe)",
    "deep burn": "Burns (Severe)",
    "burn injury": "Burns",
    "burn wound": "Burns",
    "burned skin": "Burns",
    "scalded": "Scald (Hot Water Burn)",
    "hot water burn": "Scald (Hot Water Burn)",
    "chemical splash burn": "Chemical Burn",
    "electric burn": "Electric Burn",
    "shock from current": "Electric Shock",

    "cut my finger": "Minor Cut",
    "cut in my finger": "Minor Cut",
    "deep wound": "Deep Cut",
    "heavy bleeding": "Bleeding (Severe)",
    "bleeding a lot": "Bleeding (Severe)",
    "blood not stopping": "Bleeding (Severe)",
    "nose bleeding": "Nosebleed",
    "bleeding from nose": "Nosebleed",

    "bitten by dog": "Dog Bite",
    "dog attacked": "Dog Bite",
    "snake bit me": "Snake Bite",
    "snake poison": "Snake Bite",
    "bee sting reaction": "Bee Sting Allergy",
    "allergic to bee": "Bee Sting Allergy",
    "insect bite swelling": "Insect Sting",

    "broken bone": "Fracture (Suspected)",
    "bone crack": "Fracture (Suspected)",
    "twisted ankle": "Sprain",
    "twisted knee": "Sprain",
    "pulled muscle": "Strain",
    "shoulder dislocated": "Dislocation",
    "joint popped out": "Dislocation",
    "torn muscle": "Torn Ligament",

    "hit my head": "Head Injury (Minor)",
    "serious head injury": "Head Injury (Severe)",
    "lost consciousness": "Unconscious Person",
    "passed out": "Fainting",
    "collapsed suddenly": "Unconscious Person",
    "convulsions": "Seizure",
    "fits": "Seizure",
    "brain stroke": "Stroke (Suspected)",
    "cardiac arrest": "Heart Attack (Suspected)",

    "overheated": "Heat Stroke",
    "too much heat": "Heat Exhaustion",
    "heat sickness": "Heat Exhaustion",
    "extreme dehydration": "Dehydration",
    "very cold exposure": "Hypothermia",
    "skin freezing": "Frostbite",

    "ate something bad": "Food Poisoning",
    "food infection": "Food Poisoning",
    "inhaled gas": "Gas Inhalation",
    "carbon monoxide poisoning": "Carbon Monoxide Exposure",
    "swallowed poison": "Poisoning (General)",

    "something in my eye": "Eye Injury (Foreign Object)",
    "chemical in eye": "Eye Chemical Exposure",
    "dust in eye": "Minor Eye Irritation (Dust)",
    "object stuck in ear": "Ear Foreign Object",
    "child put something in nose": "Nose Foreign Object (Child)",

    "tooth fell out": "Tooth Knocked Out",
    "cracked tooth": "Broken Tooth",
    "broken teeth": "Broken Tooth",

    "very high fever": "high_fever",
    "fever": "high_fever",
    "persistent fever": "high_fever",
    "extreme fatigue": "fatigue",
    "chills and fever": "chills",
    "dry cough": "cough",
    "productive cough": "phlegm",
    "tight chest": "chest_pain",
    "sharp chest pain": "chest_pain",
    "vomiting blood": "vomiting",
    "bloody vomit": "vomiting",
    "severe diarrhea": "diarrhoea",
    "continuous vomiting": "vomiting",

    "heart pounding": "fast_heart_rate",
    "heart beating fast": "fast_heart_rate",
    "panic attack": "anxiety",
    "breathing fast": "hyperventilation",
    "short breath": "breathlessness",

    "feels cold": "chills",
    "body shaking": "shivering",
    "weak legs": "weakness_in_limbs",
    "loss of balance": "loss_of_balance",
    "cannot walk properly": "unsteadiness",
    "no appetite": "loss_of_appetite",
    "blur vision": "blurred_and_distorted_vision",
    "skin turning yellow": "yellowish_skin",

    "diarrhoea": "Severe Diarrhea",
    "diarrhea": "Severe Diarrhea",
    "severe diarrhea": "Severe Diarrhea",
    "severe diarrhoea": "Severe Diarrhea",
    "bad diarrhea": "Severe Diarrhea",
    "continuous diarrhea": "Severe Diarrhea",
    "non stop diarrhea": "Severe Diarrhea",
    "constant diarrhea": "Severe Diarrhea",
    "watery diarrhea": "Severe Diarrhea",
    "extreme loose motion": "Severe Diarrhea",
    "too many loose motions": "Severe Diarrhea",
    "frequent loose motion": "Severe Diarrhea",
    "motion many times": "Severe Diarrhea",
    "passing stool continuously": "Severe Diarrhea",
    "severe loose motion": "Severe Diarrhea",
    "diarrhea not stopping": "Severe Diarrhea",
    "loose motion not stopping": "Severe Diarrhea",
    "going toilet again and again": "Severe Diarrhea",
    "toilet frequently due to motion": "Severe Diarrhea",
    "very watery stool": "Severe Diarrhea",
    "excessive diarrhea": "Severe Diarrhea",
    "heavy diarrhea": "Severe Diarrhea",
    "bad loose motion": "Severe Diarrhea",

    "muscles ache": "muscle_pain",
    "muscle ache": "muscle_pain",
    "muscle pain": "muscle_pain",
    "my muscles ache": "muscle_pain",
    "muscles hurting": "muscle_pain",
    "muscle hurts": "muscle_pain",
    "body pain": "muscle_pain",
    "whole body pain": "muscle_pain",
    "body aches": "muscle_pain",
    "body ache": "muscle_pain",

    "very weak": "weakness_in_limbs",
    "extreme weakness": "weakness_in_limbs",
    "feeling weak": "weakness_in_limbs",
    "weak body": "weakness_in_limbs",
    "weak legs": "weakness_in_limbs",
    "cannot stand properly": "weakness_in_limbs",

    "loss of appetite": "loss_of_appetite",
    "no appetite": "loss_of_appetite",
    "not hungry": "loss_of_appetite",
    "cannot eat": "loss_of_appetite",
    "cant eat": "loss_of_appetite",
    "no hunger": "loss_of_appetite",
    "not feeling hungry": "loss_of_appetite",
    "lack of appetite": "loss_of_appetite",

    "very tired": "fatigue",
    "extreme fatigue": "fatigue",
    "feeling exhausted": "fatigue",
    "too tired": "fatigue",
    "low energy": "fatigue",
    "no energy": "fatigue",

    "throwing up": "vomiting",
    "vomit": "vomiting",
    "vomiting continuously": "vomiting",
    "keep vomiting": "vomiting",
    "cannot stop vomiting": "vomiting",

    "feeling nauseous": "nausea",
    "feel nauseous": "nausea",
    "stomach upset": "nausea",
    "feeling sick": "nausea",
    "sick to stomach": "nausea",
    "queasy": "nausea",
    
    "bmi": "bmi",
    "body mass index": "bmi",
    "calculate bmi": "bmi",
    "check bmi": "bmi",
    "measure bmi": "bmi",

    "height": "height",
    "height in cm": "height",
    "my height": "height",
    "tall": "height",

    "weight": "weight",
    "body weight": "weight",
    "my weight": "weight",
    "weigh": "weight",

    "sodium": "intake_sodium",
    "salt intake": "intake_sodium",
    "salt consumption": "intake_sodium",

    "fiber": "intake_fiber",
    "dietary fiber": "intake_fiber",

    "water intake": "intake_water",
    "daily water": "intake_water",
    "hydration": "intake_water",

    "calories": "intake_calories",
    "daily calories": "intake_calories",
    "calorie intake": "intake_calories",

    "protein intake": "intake_protein",
    "protein": "intake_protein",

    "carbohydrates": "intake_carbohydrates",
    "carbs": "intake_carbohydrates",

    "fat intake": "intake_fat",
    "dietary fat": "intake_fat",

    "glucose": "fasting_blood_glucose",
    "blood sugar": "fasting_blood_glucose",
    "fasting sugar": "fasting_blood_glucose",

    "cholesterol": "total_cholesterol",
    "blood cholesterol": "total_cholesterol",

    "hdl": "hdl",
    "ldl": "ldl",
    "triglycerides": "triglycerides",
}

def normalize_message(message: str):
    message = message.lower()

    for phrase in sorted(SYMPTOM_SYNONYMS, key=len, reverse=True):
        if phrase in message:
            message = message.replace(phrase, SYMPTOM_SYNONYMS[phrase])

    return message

def detect_first_aid(message: str):

    doc = nlp_lang(message)
    user_words = {
        token.lemma_.lower()
        for token in doc
        if not token.is_punct and not token.is_stop
    }

    if user_words & STRONG_FIRST_AID_WORDS:
        return True

    best_score = 0

    for case in FIRST_AID_CASES:
        case_doc = nlp_lang(case)
        case_words = {
            token.lemma_.lower()
            for token in case_doc
            if not token.is_punct and not token.is_stop
        }

        overlap = len(user_words & case_words)

        if overlap > best_score:
            best_score = overlap

    if best_score >= 2:
        return True

    return False

def contains_valid_symptom(message: str):

    message = normalize_message(message)
    doc = nlp_lang(message)

    lemmas = [token.lemma_.lower() for token in doc if not token.is_punct]

    for symptom in VALID_SYMPTOMS:
        symptom_parts = symptom.split("_")

        if all(part in lemmas for part in symptom_parts):
            return True

    return False

def detect_intent(message: str):

    message_lower = message.lower()

    if any(word in message_lower for word in EMERGENCY_KEYWORDS):
        return "first_aid"

    if any(phrase in message_lower for phrase in FIRST_AID_PHRASES):
        return "first_aid"
    
    if any(word in message_lower for word in HEALTH_KEYWORDS):
        return "health_assessment"

    if contains_valid_symptom(message):
       return "disease_prediction"
    
    if detect_first_aid(message):
        return "first_aid"

    doc = nlp_intent(message)
    scores = doc.cats

    if not scores:
        return "unknown"

    predicted_intent = max(scores, key=scores.get)

    if scores[predicted_intent] < 0.5:
        return "unknown"

    return predicted_intent
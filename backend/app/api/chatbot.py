import spacy
from fastapi import APIRouter
from pydantic import BaseModel
from app.nlp.intent import detect_intent, normalize_message
from app.ml.rfcdisease import predict_top3, valid_symptoms
from app.ml.first_aid_handler import get_first_aid
from app.ml.health_metrics import get_assessment_for_api

router = APIRouter()
nlp = spacy.load("en_core_web_sm")


def extract_symptoms_from_text(message: str):
    message = normalize_message(message)
    doc = nlp(message)
    lemmas = [token.lemma_.lower() for token in doc if not token.is_punct]
    extracted = []
    for symptom in valid_symptoms:
        symptom_parts = symptom.split("_")
        if all(part in lemmas for part in symptom_parts):
            extracted.append(symptom)
    return extracted


last_disease = None
health_mode = False
health_data = {}


def _build_assessment_payload() -> dict:
    return {k: v for k, v in health_data.items() if k != "optional"}


def _start_health_mode() -> str:
    global health_mode, health_data
    health_mode = True
    health_data = {}
    return "Please enter your Age."


def chatbot_response(message: str):
    global last_disease, health_mode, health_data

    message = normalize_message(message)
    message_lower = message.lower()

    if message_lower in ["check my health", "health metrics", "health assessment", "check bmi"]:
        return _start_health_mode()

    if health_mode:
        if "age" not in health_data:
            try:
                health_data["age"] = int(message)
                return "Enter your gender (male/female)."
            except ValueError:
                return "Please enter a valid age (numbers only)."

        if "gender" not in health_data:
            if message_lower in ["male", "female"]:
                health_data["gender"] = message_lower
                return "Enter your height in cm."
            return "Please type male or female."

        if "height_cm" not in health_data:
            try:
                health_data["height_cm"] = float(message)
                return "Enter your weight in kg."
            except ValueError:
                return "Please enter a valid height."

        if "weight_kg" not in health_data:
            try:
                health_data["weight_kg"] = float(message)
                return "Enter activity level (sedentary/moderate/active)."
            except ValueError:
                return "Please enter a valid weight."

        if "activity_level" not in health_data:
            if message_lower not in ["sedentary", "moderate", "active"]:
                return "Please type sedentary, moderate, or active."
            health_data["activity_level"] = message_lower
            return "Would you like to add nutrition or lab values for deeper analysis? (yes/no)"

        if "optional" not in health_data:
            if message_lower in ["yes", "ok", "sure"]:
                health_data["optional"] = True
                return "Enter daily sodium intake in mg (or type skip)."

            if message_lower in ["no", "skip"]:
                result = get_assessment_for_api(**_build_assessment_payload())
                health_mode = False
                snapshot = result["health_snapshot"]
                return (
                    f"Health Assessment Result:\n"
                    f"BMI: {snapshot['bmi']} ({snapshot['bmi_category']})\n"
                    f"Recommended Calories: {snapshot['calorie_target_kcal']} kcal/day\n"
                    f"Protein Target: {snapshot['protein_target_g']} g\n"
                    f"Fat Target: {snapshot['fat_target_g']} g\n"
                    f"Carbohydrates Target: {snapshot['carbs_target_g']} g"
                )
            return "Please type yes or no."

        if "intake_sodium" not in health_data:
            if message_lower != "skip":
                try:
                    health_data["intake_sodium"] = float(message)
                except ValueError:
                    return "Please enter sodium in mg or type skip."
            else:
                health_data["intake_sodium"] = None
            return "Enter fiber intake in grams (or type skip)."

        if "intake_fiber" not in health_data:
            if message_lower != "skip":
                try:
                    health_data["intake_fiber"] = float(message)
                except ValueError:
                    return "Please enter fiber amount or type skip."
            else:
                health_data["intake_fiber"] = None
            return "Enter daily water intake in liters (or type skip)."

        if "intake_water" not in health_data:
            if message_lower != "skip":
                try:
                    health_data["intake_water"] = float(message)
                except ValueError:
                    return "Please enter water intake in liters or type skip."
            else:
                health_data["intake_water"] = None
            return "Enter fasting blood glucose (mg/dL) or type skip."

        if "fasting_blood_glucose" not in health_data:
            if message_lower != "skip":
                try:
                    health_data["fasting_blood_glucose"] = float(message)
                except ValueError:
                    return "Please enter glucose value or type skip."
            else:
                health_data["fasting_blood_glucose"] = None
            return "Enter total cholesterol (mg/dL) or type skip."

        if "total_cholesterol" not in health_data:
            if message_lower != "skip":
                try:
                    health_data["total_cholesterol"] = float(message)
                except ValueError:
                    return "Please enter cholesterol value or type skip."
            else:
                health_data["total_cholesterol"] = None

            result = get_assessment_for_api(**_build_assessment_payload())
            health_mode = False
            snapshot = result["health_snapshot"]
            alerts = result["risk_alerts"]

            response = (
                f"Health Assessment Result:\n"
                f"BMI: {snapshot['bmi']} ({snapshot['bmi_category']})\n"
                f"Recommended Calories: {snapshot['calorie_target_kcal']} kcal/day\n"
                f"Protein Target: {snapshot['protein_target_g']} g\n"
                f"Fat Target: {snapshot['fat_target_g']} g\n"
                f"Carbohydrates Target: {snapshot['carbs_target_g']} g\n"
                f"Hydration Target: {result['hydration_target_liters']} L/day\n"
            )
            if alerts:
                response += "\n⚠ Health Alerts:\n"
                for a in alerts:
                    response += f"- {a}\n"
            return response

    if message_lower in ["exit", "quit", "bye"]:
        return "Goodbye! Stay healthy!"

    if message_lower in ["yes", "yes please", "sure"]:
        if last_disease:
            return f"First Aid for {last_disease}:\n{get_first_aid(last_disease)}"
        return "Please specify the condition you need first aid for."

    if message_lower in ["no", "nope", "nah", "not now"]:
        if last_disease:
            last_disease = None
            return "Alright. Let me know if you need anything else."
        return "Okay. Let me know if you need anything else."

    intent = detect_intent(message)

    if intent == "greeting":
        return "Hello! Please describe your symptoms."

    if intent == "thanks":
        return "You're welcome! Stay healthy."

    if intent == "health_assessment":
        return _start_health_mode()

    if intent == "first_aid":
        if message_lower.strip() in ["first aid", "firstaid"]:
            if last_disease:
                return f"First Aid for {last_disease}:\n{get_first_aid(last_disease)}"
            return "Please specify the condition."
        return f"First Aid Instructions:\n{get_first_aid(message)}"

    if intent == "disease_prediction":
        symptoms = extract_symptoms_from_text(message)
        if not symptoms:
            return "I could not detect valid symptoms."

        predictions = predict_top3(symptoms)
        if not predictions:
            return "Unable to determine disease."

        top_disease, confidence = predictions[0]
        last_disease = top_disease

        response = "Detected symptoms: " + ", ".join(symptoms) + "\n\n"
        response += "Possible Conditions:\n"
        for i, (disease, conf) in enumerate(predictions, start=1):
            response += f"{i}. {disease} – {conf:.2f}%\n"

        if len(symptoms) <= 2:
            response += (
                "\n!!Only a few symptoms were provided!!"
                "\nProviding more symptoms may improve prediction accuracy.\n"
            )

        response += f"\nThis is a preliminary prediction!\nWould you like first aid advice for {top_disease}?"
        return response

    return "I did not understand. Please describe your symptoms clearly."

class ChatRequest(BaseModel):
    message: str

@router.post("/")
def chat(request: ChatRequest):
    response = chatbot_response(request.message)
    return {"response": response}
import numpy as np
import pickle
import os

MODEL_DIR = os.path.dirname(__file__)

# Load trained models
with open(os.path.join(MODEL_DIR, "rf_model.pkl"), "rb") as f:
    model = pickle.load(f)

with open(os.path.join(MODEL_DIR, "label_encoder.pkl"), "rb") as f:
    label_encoder = pickle.load(f)

with open(os.path.join(MODEL_DIR, "mlb.pkl"), "rb") as f:
    mlb = pickle.load(f)

valid_symptoms = set(mlb.classes_)


def predict_top3(symptom_list):

    cleaned_symptoms = [
        s.strip().replace(" ", "_")
        for s in symptom_list
        if s.strip().replace(" ", "_") in valid_symptoms
    ]

    if not cleaned_symptoms:
        return []

    input_vector = mlb.transform([cleaned_symptoms])

    probs = model.predict_proba(input_vector)[0]

    temperature = 0.6
    probs = np.power(probs, 1 / temperature)
    probs = probs / probs.sum()

    top3_indices = probs.argsort()[-3:][::-1]

    results = []

    for idx in top3_indices:
        disease_name = label_encoder.inverse_transform([idx])[0]
        confidence = probs[idx] * 100
        results.append((disease_name, confidence))

    return results
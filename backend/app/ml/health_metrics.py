
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class AssessmentInput:
    age: int
    gender: str                  # "male" | "female"
    height_cm: float
    weight_kg: float
    activity_level: str          # "sedentary" | "moderate" | "active"
    bmi: Optional[float] = None  # Auto-calculated if not provided

    # Optional lab values
    triglycerides: Optional[float] = None
    total_cholesterol: Optional[float] = None
    hdl: Optional[float] = None
    ldl: Optional[float] = None
    fasting_blood_glucose: Optional[float] = None
    serum_uric_acid: Optional[float] = None
    serum_creatinine: Optional[float] = None

    # Optional daily intake values
    intake_calories: Optional[float] = None
    intake_protein: Optional[float] = None
    intake_carbohydrates: Optional[float] = None
    intake_fat: Optional[float] = None
    intake_sodium: Optional[float] = None
    intake_fiber: Optional[float] = None
    intake_water: Optional[float] = None
    intake_iron: Optional[float] = None
    intake_calcium: Optional[float] = None
    intake_vitamin_d: Optional[float] = None

    def __post_init__(self):
        self.gender = self.gender.lower().strip()
        self.activity_level = self.activity_level.lower().strip()
        if self.bmi is None:
            self.bmi = round(self.weight_kg / ((self.height_cm / 100) ** 2), 1)


# ===========================================================================
# OUTPUT SCHEMA
# ===========================================================================

@dataclass
class AssessmentOutput:
    # Step 1
    bmi: float = 0.0
    bmi_category: str = ""

    # Step 2
    bmr: float = 0.0

    # Step 3 & 4
    tdee: float = 0.0
    recommended_calories: float = 0.0

    # Step 5
    macronutrients: dict = field(default_factory=dict)

    # Step 6
    micronutrient_targets: dict = field(default_factory=dict)

    # Step 7 & 8
    lab_analysis: dict = field(default_factory=dict)
    intake_analysis: dict = field(default_factory=dict)

    # Step 9
    dietary_suggestions: list = field(default_factory=list)
    hydration_guidance: list = field(default_factory=list)
    risk_alerts: list = field(default_factory=list)
    general_advice: list = field(default_factory=list)

    def to_dict(self) -> dict:
        # Concise API response — mirrors the print_report structure
        m = self.macronutrients
        t = self.micronutrient_targets

        # Nutrition gaps
        too_high = [k.replace("_", " ").title()
                    for k, v in self.intake_analysis.items()
                    if "Above" in v.get("status", "") or "Critical High" in v.get("status", "")]
        too_low  = [k.replace("_", " ").title()
                    for k, v in self.intake_analysis.items()
                    if "Below" in v.get("status", "") or "Critical Low" in v.get("status", "")]

        # Compact lab status
        lab_status = {
            k: {
                "value": v.get("value_mg_dL"),
                "status": v.get("status"),
                "is_critical": v.get("is_critical", False),
            }
            for k, v in self.lab_analysis.items()
        }

        return {
            "health_snapshot": {
                "bmi": self.bmi,
                "bmi_category": self.bmi_category,
                "calorie_target_kcal": round(self.recommended_calories, 1),
                "protein_target_g": f"{m['protein']['min_g']}–{m['protein']['max_g']}",
                "fat_target_g": f"{m['fat']['min_g']}–{m['fat']['max_g']}",
                "carbs_target_g": m["carbohydrates"]["g"],
            },
            "micronutrient_targets": {
                "sodium_max_mg": t["sodium"]["max_mg"],
                "fiber_g": f"{t['fiber']['min_g']}–{t['fiber']['max_g']}",
                "water_liters": t["water"]["liters"],
                "iron_mg": t["iron"]["mg"],
                "calcium_mg": t["calcium"]["mg"],
                "vitamin_d_iu": f"{t['vitamin_d']['min_iu']}–{t['vitamin_d']['max_iu']}",
            },
            "lab_status": lab_status,
            "nutrition_gaps": {
                "too_high": too_high,
                "too_low": too_low,
            },
            "key_risk_flags": [
                a for a in self.risk_alerts
                if "CRITICAL" in a.upper() or "WARNING" in a.upper() or "HIGH" in a.upper()
            ],
            "risk_alerts": self.risk_alerts,
            "hydration_target_liters": t["water"]["liters"],
        }


# ===========================================================================
# MAIN ENGINE
# ===========================================================================

def run_assessment(inp: AssessmentInput) -> AssessmentOutput:
    out = AssessmentOutput()

    _step1_bmi_classification(inp, out)
    _step2_calculate_bmr(inp, out)
    _step3_activity_adjustment(inp, out)
    _step4_calorie_goal(inp, out)
    _step5_macronutrients(inp, out)
    _step6_micronutrient_targets(inp, out)
    _step7_lab_classification(inp, out)
    _step8_intake_comparison(inp, out)
    _step9_suggestions(inp, out)

    return out


# ===========================================================================
# STEP 1: BMI Classification
# ===========================================================================

def _step1_bmi_classification(inp: AssessmentInput, out: AssessmentOutput):
    bmi = inp.bmi
    out.bmi = bmi

    if bmi < 18.5:
        out.bmi_category = "Underweight"
    elif bmi < 25.0:
        out.bmi_category = "Normal"
    elif bmi < 30.0:
        out.bmi_category = "Overweight"
    else:
        out.bmi_category = "Obese"


# ===========================================================================
# STEP 2: BMR — Mifflin-St Jeor
# ===========================================================================

def _step2_calculate_bmr(inp: AssessmentInput, out: AssessmentOutput):
    w = inp.weight_kg
    h = inp.height_cm
    a = inp.age

    if inp.gender == "male":
        out.bmr = (10 * w) + (6.25 * h) - (5 * a) + 5
    else:
        out.bmr = (10 * w) + (6.25 * h) - (5 * a) - 161


# ===========================================================================
# STEP 3: Activity Level Adjustment → TDEE
# ===========================================================================

def _step3_activity_adjustment(inp: AssessmentInput, out: AssessmentOutput):
    if inp.activity_level == "sedentary":
        out.tdee = out.bmr * 1.2
    elif inp.activity_level == "moderate":
        out.tdee = out.bmr * 1.55
    elif inp.activity_level == "active":
        out.tdee = out.bmr * 1.725
    else:
        # Default to sedentary if unknown
        out.tdee = out.bmr * 1.2


# ===========================================================================
# STEP 4: Calorie Goal Based on BMI
# ===========================================================================

def _step4_calorie_goal(inp: AssessmentInput, out: AssessmentOutput):
    if out.bmi_category == "Underweight":
        out.recommended_calories = out.tdee + 300
    elif out.bmi_category == "Normal":
        out.recommended_calories = out.tdee
    elif out.bmi_category == "Overweight":
        out.recommended_calories = out.tdee - 300
    else:  # Obese
        out.recommended_calories = out.tdee - 500

    # Hard floor — never below 1200 kcal (medically conservative)
    if out.recommended_calories < 1200:
        out.recommended_calories = 1200
        out.risk_alerts.append(
            "Calculated calorie goal fell below 1200 kcal. "
            "Minimum threshold applied. Consult a dietitian."
        )


# ===========================================================================
# STEP 5: Macronutrient Distribution
# ===========================================================================

def _step5_macronutrients(inp: AssessmentInput, out: AssessmentOutput):
    w = inp.weight_kg
    cal = out.recommended_calories

    # --- Protein ---
    if out.bmi_category in ("Overweight", "Obese"):
        protein_min_g = round(w * 1.2, 1)
        protein_max_g = round(w * 1.5, 1)
        protein_note = "Higher protein (1.2–1.5 g/kg) to preserve lean mass during fat loss."
    else:
        protein_min_g = round(w * 1.0, 1)
        protein_max_g = round(w * 1.0, 1)
        protein_note = "Standard protein (1.0 g/kg body weight)."

    # Use midpoint for calorie math
    protein_g = (protein_min_g + protein_max_g) / 2
    protein_kcal = protein_g * 4

    # --- Fat (25–30% of total calories) ---
    fat_min_g = round((cal * 0.25) / 9, 1)
    fat_max_g = round((cal * 0.30) / 9, 1)
    fat_kcal = ((fat_min_g + fat_max_g) / 2) * 9

    # --- Carbohydrates (remaining calories) ---
    remaining_kcal = cal - protein_kcal - fat_kcal
    carb_g = round(remaining_kcal / 4, 1)
    if carb_g < 0:
        carb_g = 0

    out.macronutrients = {
        "protein": {
            "min_g": protein_min_g,
            "max_g": protein_max_g,
            "note": protein_note,
        },
        "fat": {
            "min_g": fat_min_g,
            "max_g": fat_max_g,
            "note": "25–30% of total daily calories. Prioritise unsaturated fats.",
        },
        "carbohydrates": {
            "g": carb_g,
            "note": "Remaining calories after protein and fat. Prefer whole grains, legumes, vegetables.",
        },
    }


# ===========================================================================
# STEP 6: Micronutrient Targets
# ===========================================================================

def _step6_micronutrient_targets(inp: AssessmentInput, out: AssessmentOutput):
    g = inp.gender
    a = inp.age

    # Sodium
    sodium_max = 2300
    if inp.bmi >= 30 or a >= 60:
        sodium_max = 1500
        sodium_note = "Reduced limit due to obesity/age — lower sodium lowers cardiovascular risk."
    else:
        sodium_note = "Stay below 2300 mg/day. Read food labels carefully."

    # Fiber
    if g == "male":
        fiber_min, fiber_max = 30, 38
    else:
        fiber_min, fiber_max = 25, 25
    if a >= 50:
        fiber_min = fiber_min - 3
        fiber_max = fiber_max - 5 if fiber_max > 5 else fiber_max
    fiber_note = "Soluble and insoluble fiber from whole grains, legumes, fruits, vegetables."

    # Water
    if g == "male":
        water_l = 3.7
        water_note = "3.7 L/day total water intake (beverages + food). Increase if active."
    else:
        water_l = 2.7
        water_note = "2.7 L/day total water intake (beverages + food). Increase if active."

    # Iron
    if g == "male":
        iron_mg = 8
        iron_note = "Standard adult male requirement."
    elif g == "female" and a <= 50:
        iron_mg = 18
        iron_note = "Pre-menopausal women have higher iron needs due to menstrual losses."
    else:
        iron_mg = 8
        iron_note = "Post-menopausal women require less iron."

    # Calcium
    if a < 51:
        calcium_mg = 1000
        calcium_note = "Standard adult requirement."
    else:
        calcium_mg = 1200
        calcium_note = "Older adults need more calcium to prevent osteoporosis."

    # Vitamin D
    if a < 70:
        vit_d_min, vit_d_max = 600, 800
    else:
        vit_d_min, vit_d_max = 800, 1000
    if inp.bmi >= 30:
        vit_d_min += 200
        vit_d_max += 400
        vit_d_note = "Obesity impairs Vitamin D absorption — supplementation often needed."
    else:
        vit_d_note = "Sunlight exposure + dietary sources. Supplement if deficient."

    out.micronutrient_targets = {
        "sodium":    {"max_mg": sodium_max, "note": sodium_note},
        "fiber":     {"min_g": fiber_min, "max_g": fiber_max, "note": fiber_note},
        "water":     {"liters": water_l, "note": water_note},
        "iron":      {"mg": iron_mg, "note": iron_note},
        "calcium":   {"mg": calcium_mg, "note": calcium_note},
        "vitamin_d": {"min_iu": vit_d_min, "max_iu": vit_d_max, "note": vit_d_note},
    }


# ===========================================================================
# STEP 7 & 8: Lab Classification + Intake Comparison
# ===========================================================================

def _classify(value: float, label: str, normal_min: float, normal_max: float,
               critical_low: Optional[float] = None,
               critical_high: Optional[float] = None) -> dict:
    """
    Universal classifier for a single marker.
    Returns status, value, range, and a flag if critical.
    """
    if critical_low is not None and value < critical_low:
        status = "Critical Low"
    elif critical_high is not None and value > critical_high:
        status = "Critical High"
    elif value < normal_min:
        status = "Low"
    elif value > normal_max:
        status = "High"
    else:
        status = "Normal"

    return {
        "value": value,
        "normal_range": f"{normal_min} – {normal_max}",
        "status": status,
        "is_critical": status.startswith("Critical"),
    }


def _step7_lab_classification(inp: AssessmentInput, out: AssessmentOutput):
    labs = {}

    # --- Triglycerides ---
    if inp.triglycerides is not None:
        v = inp.triglycerides
        if v < 150:
            status = "Normal"
        elif v < 200:
            status = "Borderline High"
        elif v < 500:
            status = "High"
        else:
            status = "Very High"
        labs["triglycerides"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": "<150 Normal | 150–199 Borderline | 200–499 High | ≥500 Very High",
            "is_critical": v >= 500,
        }
        if v >= 500:
            out.risk_alerts.append(
                f"CRITICAL: Triglycerides {v} mg/dL (≥500). "
                "Risk of pancreatitis. Seek immediate medical attention."
            )
        elif v >= 200:
            out.risk_alerts.append(
                f"HIGH: Triglycerides {v} mg/dL. Consult a physician."
            )

    # --- Total Cholesterol ---
    if inp.total_cholesterol is not None:
        v = inp.total_cholesterol
        if v < 200:
            status = "Desirable"
        elif v < 240:
            status = "Borderline High"
        else:
            status = "High"
        labs["total_cholesterol"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": "<200 Desirable | 200–239 Borderline High | ≥240 High",
            "is_critical": v >= 240,
        }
        if v >= 240:
            out.risk_alerts.append(
                f"HIGH: Total Cholesterol {v} mg/dL. Cardiovascular risk elevated. "
                "Consult a healthcare professional."
            )

    # --- HDL ---
    if inp.hdl is not None:
        v = inp.hdl
        if inp.gender == "male":
            low_threshold = 40
        else:
            low_threshold = 50

        if v < low_threshold:
            status = "Low (Risk)"
            is_critical = True
            out.risk_alerts.append(
                f"LOW HDL: {v} mg/dL. Low HDL increases cardiovascular risk. "
                "Increase physical activity and healthy fats."
            )
        elif v >= 60:
            status = "Protective"
            is_critical = False
        else:
            status = "Normal"
            is_critical = False

        labs["hdl"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": f"Low: <{'40' if inp.gender == 'male' else '50'} | Protective: ≥60",
            "is_critical": is_critical,
        }

    # --- LDL ---
    if inp.ldl is not None:
        v = inp.ldl
        if v < 100:
            status = "Optimal"
        elif v < 130:
            status = "Near Optimal"
        elif v < 160:
            status = "Borderline High"
        elif v < 190:
            status = "High"
        else:
            status = "Very High"
        labs["ldl"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": "<100 Optimal | 100–129 Near Optimal | 130–159 Borderline | 160–189 High | ≥190 Very High",
            "is_critical": v >= 190,
        }
        if v >= 190:
            out.risk_alerts.append(
                f"CRITICAL LDL: {v} mg/dL. Very high cardiovascular risk. "
                "Consult a cardiologist immediately."
            )
        elif v >= 160:
            out.risk_alerts.append(
                f"HIGH LDL: {v} mg/dL. Consider dietary changes and medical review."
            )

    # --- Fasting Blood Glucose ---
    if inp.fasting_blood_glucose is not None:
        v = inp.fasting_blood_glucose
        if v < 100:
            status = "Normal"
        elif v < 126:
            status = "Prediabetes"
        else:
            status = "Diabetes Range"
        labs["fasting_blood_glucose"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": "<100 Normal | 100–125 Prediabetes | ≥126 Diabetes Range",
            "is_critical": v >= 126,
        }
        if v >= 126:
            out.risk_alerts.append(
                f"CRITICAL: Fasting Blood Glucose {v} mg/dL — Diabetes Range. "
                "Consult an endocrinologist immediately."
            )
        elif v >= 100:
            out.risk_alerts.append(
                f"WARNING: Fasting Blood Glucose {v} mg/dL — Prediabetes. "
                "Lifestyle changes can reverse this."
            )

    # --- Serum Uric Acid ---
    if inp.serum_uric_acid is not None:
        v = inp.serum_uric_acid
        if inp.gender == "male":
            high_threshold = 7.0
        else:
            high_threshold = 6.0
        if v > high_threshold:
            status = "High"
            is_critical = True
            out.risk_alerts.append(
                f"HIGH Uric Acid: {v} mg/dL. Risk of gout and kidney stones. "
                "Reduce red meat, alcohol, and high-fructose foods."
            )
        else:
            status = "Normal"
            is_critical = False
        labs["serum_uric_acid"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": f"High: >{'7.0' if inp.gender == 'male' else '6.0'} mg/dL",
            "is_critical": is_critical,
        }

    # --- Serum Creatinine ---
    if inp.serum_creatinine is not None:
        v = inp.serum_creatinine
        if inp.gender == "male":
            high_threshold = 1.3
        else:
            high_threshold = 1.1
        if v > high_threshold:
            status = "High"
            is_critical = True
            out.risk_alerts.append(
                f"HIGH Creatinine: {v} mg/dL. Possible kidney impairment. "
                "Consult a nephrologist."
            )
        else:
            status = "Normal"
            is_critical = False
        labs["serum_creatinine"] = {
            "value_mg_dL": v,
            "status": status,
            "reference": f"High: >{'1.3' if inp.gender == 'male' else '1.1'} mg/dL",
            "is_critical": is_critical,
        }

    out.lab_analysis = labs


def _step8_intake_comparison(inp: AssessmentInput, out: AssessmentOutput):
    """Compare user's reported daily intake against calculated targets."""
    intake = {}
    rec_cal = out.recommended_calories
    targets = out.micronutrient_targets
    macros = out.macronutrients

    def status_label(value, low, high, critical_low=None, critical_high=None):
        if critical_low is not None and value < critical_low:
            return "Critical Low"
        if critical_high is not None and value > critical_high:
            return "Critical High"
        if value < low:
            return "Below Target"
        if value > high:
            return "Above Target"
        return "On Target"

    # Calories
    if inp.intake_calories is not None:
        status = status_label(
            inp.intake_calories,
            rec_cal * 0.90, rec_cal * 1.10,
            critical_low=800, critical_high=rec_cal * 1.5
        )
        intake["calories"] = {
            "intake_kcal": inp.intake_calories,
            "target_kcal": round(rec_cal, 1),
            "status": status,
        }
        if status == "Critical Low":
            out.risk_alerts.append(
                f"CRITICAL: Daily calorie intake ({inp.intake_calories} kcal) is dangerously low."
            )
        elif status == "Critical High":
            out.risk_alerts.append(
                f"WARNING: Daily calorie intake ({inp.intake_calories} kcal) far exceeds target."
            )

    # Protein
    if inp.intake_protein is not None:
        p_min = macros["protein"]["min_g"]
        p_max = macros["protein"]["max_g"]
        status = status_label(inp.intake_protein, p_min, p_max)
        intake["protein"] = {
            "intake_g": inp.intake_protein,
            "target_range_g": f"{p_min} – {p_max}",
            "status": status,
        }

    # Carbohydrates
    if inp.intake_carbohydrates is not None:
        carb_target = macros["carbohydrates"]["g"]
        status = status_label(inp.intake_carbohydrates, carb_target * 0.85, carb_target * 1.15)
        intake["carbohydrates"] = {
            "intake_g": inp.intake_carbohydrates,
            "target_g": carb_target,
            "status": status,
        }

    # Fat
    if inp.intake_fat is not None:
        f_min = macros["fat"]["min_g"]
        f_max = macros["fat"]["max_g"]
        status = status_label(inp.intake_fat, f_min, f_max)
        intake["fat"] = {
            "intake_g": inp.intake_fat,
            "target_range_g": f"{f_min} – {f_max}",
            "status": status,
        }

    # Sodium
    if inp.intake_sodium is not None:
        sodium_max = targets["sodium"]["max_mg"]
        status = status_label(inp.intake_sodium, 500, sodium_max, critical_high=3500)
        intake["sodium"] = {
            "intake_mg": inp.intake_sodium,
            "target_max_mg": sodium_max,
            "status": status,
        }
        if inp.intake_sodium > 3500:
            out.risk_alerts.append(
                f"CRITICAL: Sodium intake ({inp.intake_sodium} mg) is dangerously high. "
                "Severely elevated hypertension risk."
            )

    # Fiber
    if inp.intake_fiber is not None:
        f_min = targets["fiber"]["min_g"]
        f_max = targets["fiber"]["max_g"]
        status = status_label(inp.intake_fiber, f_min, f_max)
        intake["fiber"] = {
            "intake_g": inp.intake_fiber,
            "target_range_g": f"{f_min} – {f_max}",
            "status": status,
        }

    # Water
    if inp.intake_water is not None:
        water_target = targets["water"]["liters"]
        status = status_label(inp.intake_water, water_target * 0.85, water_target * 1.2,
                               critical_low=1.0)
        intake["water"] = {
            "intake_liters": inp.intake_water,
            "target_liters": water_target,
            "status": status,
        }
        if inp.intake_water < 1.0:
            out.risk_alerts.append(
                f"CRITICAL: Water intake ({inp.intake_water} L) is dangerously low. "
                "Risk of dehydration and kidney issues."
            )

    # Iron
    if inp.intake_iron is not None:
        iron_target = targets["iron"]["mg"]
        status = status_label(inp.intake_iron, iron_target * 0.8, iron_target * 2.0,
                               critical_high=45)
        intake["iron"] = {
            "intake_mg": inp.intake_iron,
            "target_mg": iron_target,
            "status": status,
        }
        if inp.intake_iron > 45:
            out.risk_alerts.append(
                f"CRITICAL: Iron intake ({inp.intake_iron} mg) exceeds safe upper limit (45 mg). "
                "Risk of iron toxicity."
            )

    # Calcium
    if inp.intake_calcium is not None:
        cal_target = targets["calcium"]["mg"]
        status = status_label(inp.intake_calcium, cal_target * 0.8, 2500, critical_high=2500)
        intake["calcium"] = {
            "intake_mg": inp.intake_calcium,
            "target_mg": cal_target,
            "status": status,
        }
        if inp.intake_calcium > 2500:
            out.risk_alerts.append(
                f"CRITICAL: Calcium intake ({inp.intake_calcium} mg) exceeds 2500 mg safe limit. "
                "Risk of hypercalcemia."
            )

    # Vitamin D
    if inp.intake_vitamin_d is not None:
        vd_min = targets["vitamin_d"]["min_iu"]
        vd_max = targets["vitamin_d"]["max_iu"]
        status = status_label(inp.intake_vitamin_d, vd_min, 4000, critical_high=4000)
        intake["vitamin_d"] = {
            "intake_iu": inp.intake_vitamin_d,
            "target_range_iu": f"{vd_min} – {vd_max}",
            "status": status,
        }
        if inp.intake_vitamin_d > 4000:
            out.risk_alerts.append(
                f"CRITICAL: Vitamin D intake ({inp.intake_vitamin_d} IU) exceeds 4000 IU safe limit. "
                "Risk of vitamin D toxicity."
            )

    out.intake_analysis = intake


# ===========================================================================
# STEP 9: Personalised Dietary Suggestions, Hydration, Recommendations
# ===========================================================================

def _step9_suggestions(inp: AssessmentInput, out: AssessmentOutput):

    # --- BMI-based dietary suggestions ---
    if out.bmi_category == "Underweight":
        out.dietary_suggestions.extend([
            "Increase caloric intake with nutrient-dense foods: nuts, avocados, whole dairy, legumes.",
            "Eat 5–6 smaller meals throughout the day rather than 3 large ones.",
            "Add healthy calorie boosters: nut butters, olive oil, dried fruits.",
            "Prioritise protein at every meal to build lean muscle mass.",
            "Avoid filling up on low-calorie, high-volume foods (e.g., plain salads).",
        ])

    elif out.bmi_category == "Normal":
        out.dietary_suggestions.extend([
            "Maintain a balanced diet with all food groups represented.",
            "Follow the plate method: ½ vegetables, ¼ lean protein, ¼ whole grains.",
            "Limit ultra-processed foods, added sugars, and refined carbohydrates.",
            "Continue regular physical activity (≥150 min/week moderate intensity).",
        ])

    elif out.bmi_category == "Overweight":
        out.dietary_suggestions.extend([
            "Reduce portion sizes by 10–15% without skipping meals.",
            "Replace refined carbohydrates (white rice, bread) with whole grain alternatives.",
            "Increase vegetable and legume intake for satiety with fewer calories.",
            "Limit sugary beverages — replace with water, herbal tea, or black coffee.",
            "Avoid late-night eating (after 8 PM). Aim for 12-hour overnight fasting.",
            "Increase dietary fiber to promote fullness and gut health.",
        ])

    else:  # Obese
        out.dietary_suggestions.extend([
            "Consult a registered dietitian for a structured, personalised meal plan.",
            "Target a gradual weight loss of 0.5–1 kg per week — avoid crash diets.",
            "Significantly reduce processed foods, fast food, fried items, and sugary snacks.",
            "Adopt a caloric deficit of 500 kcal/day from a combination of diet and exercise.",
            "Prioritise protein intake to preserve muscle mass during weight loss.",
            "Consider a Mediterranean-style or DASH diet pattern — both are evidence-based.",
            "Track food intake using an app (MyFitnessPal etc.) to maintain awareness.",
        ])

    # --- Lab-based dietary suggestions ---
    if inp.triglycerides is not None and inp.triglycerides >= 150:
        out.dietary_suggestions.extend([
            "Reduce sugar, refined carbs, and alcohol — these directly raise triglycerides.",
            "Increase omega-3 fatty acids: fatty fish (salmon, mackerel), flaxseeds, walnuts.",
            "Avoid trans fats entirely (hydrogenated oils, margarine, packaged snacks).",
        ])

    if inp.total_cholesterol is not None and inp.total_cholesterol >= 200:
        out.dietary_suggestions.extend([
            "Reduce saturated fat intake (fatty meats, full-fat dairy, coconut oil).",
            "Increase soluble fiber: oats, barley, psyllium, apples, flaxseeds.",
            "Use olive oil or avocado oil instead of butter or lard.",
        ])

    if inp.hdl is not None:
        low_hdl = (inp.gender == "male" and inp.hdl < 40) or \
                  (inp.gender == "female" and inp.hdl < 50)
        if low_hdl:
            out.dietary_suggestions.extend([
                "Increase monounsaturated fats: olive oil, avocados, almonds.",
                "Regular aerobic exercise is one of the best ways to raise HDL.",
                "Quit smoking if applicable — it significantly lowers HDL.",
            ])

    if inp.ldl is not None and inp.ldl >= 130:
        out.dietary_suggestions.extend([
            "Limit dietary cholesterol (egg yolks, organ meats) to <200 mg/day.",
            "Include plant sterols/stanols found in fortified foods.",
            "Increase consumption of legumes (lentils, chickpeas, kidney beans).",
        ])

    if inp.fasting_blood_glucose is not None and inp.fasting_blood_glucose >= 100:
        out.dietary_suggestions.extend([
            "Choose low glycemic index (GI) carbohydrates: lentils, oats, sweet potato.",
            "Pair carbohydrates with protein or fat to blunt blood sugar spikes.",
            "Avoid sugary drinks, fruit juices, and refined sweets entirely.",
            "Distribute carbohydrate intake evenly across meals — avoid large carb loads.",
            "Walk for 10–15 minutes after meals to lower postprandial blood glucose.",
        ])

    if inp.serum_uric_acid is not None:
        high_ua = (inp.gender == "male" and inp.serum_uric_acid > 7) or \
                  (inp.gender == "female" and inp.serum_uric_acid > 6)
        if high_ua:
            out.dietary_suggestions.extend([
                "Limit high-purine foods: red meat, organ meats, shellfish, sardines.",
                "Avoid alcohol, especially beer and spirits.",
                "Reduce high-fructose corn syrup (soft drinks, processed foods).",
                "Drink plenty of water to help excrete uric acid via kidneys.",
            ])

    if inp.serum_creatinine is not None:
        high_cr = (inp.gender == "male" and inp.serum_creatinine > 1.3) or \
                  (inp.gender == "female" and inp.serum_creatinine > 1.1)
        if high_cr:
            out.dietary_suggestions.extend([
                "Reduce excessive protein intake if creatinine is elevated — consult a nephrologist.",
                "Avoid creatine supplements until creatinine normalises.",
                "Limit NSAIDs (ibuprofen) — they can worsen kidney function.",
                "Stay well hydrated to support kidney filtration.",
            ])

    # --- Age-specific suggestions ---
    if inp.age >= 60:
        out.dietary_suggestions.extend([
            "Ensure adequate Vitamin D and Calcium to prevent osteoporosis and fractures.",
            "Include protein at every meal to combat age-related muscle loss (sarcopenia).",
            "Eat soft, easy-to-chew high-nutrient foods if dental issues are present.",
        ])

    if inp.gender == "female" and 45 <= inp.age <= 60:
        out.dietary_suggestions.extend([
            "Peri-menopausal: increase Calcium and Vitamin D intake.",
            "Phytoestrogens (soy, flaxseed) may help manage hormonal fluctuations.",
        ])

    # --- Hydration guidance ---
    water_target = out.micronutrient_targets["water"]["liters"]
    out.hydration_guidance.extend([
        f"Target daily water intake: {water_target} L (includes all beverages and ~20% from food).",
        "Start the day with a glass of water before any other beverage.",
        "Drink a glass of water before each meal — helps with portion control.",
        "Carry a reusable water bottle and sip consistently throughout the day.",
    ])
    if inp.bmi >= 30:
        out.hydration_guidance.append(
            "Obesity raises the risk of dehydration — prioritise water over all other beverages."
        )
    if inp.activity_level == "active":
        out.hydration_guidance.append(
            "Add 0.5–1 L of water per hour of vigorous exercise. Consider electrolytes for sessions >1 hour."
        )
    if inp.fasting_blood_glucose is not None and inp.fasting_blood_glucose >= 100:
        out.hydration_guidance.append(
            "High blood glucose increases fluid loss — monitor hydration carefully."
        )

    # --- General advice ---
    out.general_advice.extend([
        "This assessment is informational only — it does not replace clinical diagnosis.",
        "Consult a registered dietitian or physician before making significant dietary changes.",
        "Abnormal lab values require medical evaluation — do not self-medicate.",
        "Recheck lab values after 3 months of dietary/lifestyle changes.",
        "Regular physical activity is synergistic with dietary changes for all health markers.",
    ])


# ===========================================================================
# CONCISE CLINICAL SUMMARY REPORT
# ===========================================================================

def _status_icon(status: str) -> str:
    """Return a compact icon for a lab/intake status."""
    s = status.lower()
    if "critical" in s:
        return "🔴"
    if "high" in s or "above" in s or "borderline" in s:
        return "🟠"
    if "low" in s or "below" in s:
        return "🟡"
    if "normal" in s or "optimal" in s or "desirable" in s or "on target" in s or "protective" in s:
        return "🟢"
    return "⚪"


def _build_priority_actions(out: AssessmentOutput, inp: AssessmentInput) -> list:
    """
    Pick the top 5 most impactful actions based on what is actually wrong.
    Priority order: critical labs → high labs → bmi → intake gaps.
    """
    actions = []

    # Critical lab flags first
    if inp.fasting_blood_glucose is not None and inp.fasting_blood_glucose >= 126:
        actions.append("See a doctor immediately — blood sugar is in diabetes range.")
    if inp.triglycerides is not None and inp.triglycerides >= 500:
        actions.append("Seek urgent medical care — triglycerides risk pancreatitis.")
    if inp.ldl is not None and inp.ldl >= 190:
        actions.append("Consult a cardiologist — LDL is critically high.")
    if inp.serum_creatinine is not None:
        if (inp.gender == "male" and inp.serum_creatinine > 1.3) or \
           (inp.gender == "female" and inp.serum_creatinine > 1.1):
            actions.append("See a nephrologist — creatinine suggests kidney stress.")

    # High-priority metabolic
    if inp.fasting_blood_glucose is not None and 100 <= inp.fasting_blood_glucose < 126:
        actions.append("Cut refined carbs and walk 15 min after meals — prediabetes is reversible.")
    if inp.hdl is not None:
        if (inp.gender == "male" and inp.hdl < 40) or (inp.gender == "female" and inp.hdl < 50):
            actions.append("Raise HDL with daily exercise and replace bad fats with olive oil/nuts.")
    if inp.triglycerides is not None and 150 <= inp.triglycerides < 500:
        actions.append("Eliminate sugary drinks and alcohol to lower triglycerides.")
    if inp.serum_uric_acid is not None:
        if (inp.gender == "male" and inp.serum_uric_acid > 7) or \
           (inp.gender == "female" and inp.serum_uric_acid > 6):
            actions.append("Reduce red meat and alcohol — uric acid is high (gout risk).")

    # BMI-based
    if out.bmi_category == "Obese":
        actions.append(f"Target {round(out.recommended_calories)} kcal/day with a 500 kcal deficit — see a dietitian.")
    elif out.bmi_category == "Overweight":
        actions.append(f"Eat {round(out.recommended_calories)} kcal/day and add 30 min of daily walking.")
    elif out.bmi_category == "Underweight":
        actions.append(f"Eat {round(out.recommended_calories)} kcal/day — add nuts, dairy, and protein to each meal.")

    # Intake gaps
    if "sodium" in out.intake_analysis:
        s = out.intake_analysis["sodium"]["status"]
        if "Above" in s or "Critical" in s:
            actions.append("Cut sodium below target — avoid processed/packaged foods and table salt.")
    if "fiber" in out.intake_analysis:
        s = out.intake_analysis["fiber"]["status"]
        if "Below" in s:
            actions.append("Increase fiber — add lentils, oats, or vegetables to daily meals.")
    if "water" in out.intake_analysis:
        s = out.intake_analysis["water"]["status"]
        if "Below" in s or "Critical" in s:
            actions.append("Drink more water — aim for your daily target consistently.")
    if "calories" in out.intake_analysis:
        s = out.intake_analysis["calories"]["status"]
        if "Critical Low" in s:
            actions.append("Caloric intake is dangerously low — increase food intake immediately.")

    # Default if nothing notable
    if not actions:
        actions.append("Maintain current healthy habits — diet and activity level look good.")
        actions.append("Get annual bloodwork to monitor key markers.")
        actions.append("Stay hydrated and keep up regular physical activity.")

    return actions[:5]  # Max 5


def print_report(out: AssessmentOutput, inp: AssessmentInput):
    """Concise, scannable clinical nutrition summary."""
    W = 60
    SEP = "─" * W

    print(f"\n{'═' * W}")
    print(f"  🏥  HEALTH SUMMARY  —  {inp.gender.upper()}, {inp.age} YRS")
    print(f"{'═' * W}")

    # ── HEALTH SNAPSHOT ──────────────────────────────────────────
    print(f"\n🔎 HEALTH SNAPSHOT")
    print(SEP)
    bmi_icon = {"Underweight": "🟡", "Normal": "🟢", "Overweight": "🟠", "Obese": "🔴"}.get(out.bmi_category, "⚪")
    print(f"  • BMI         {out.bmi}  →  {bmi_icon} {out.bmi_category}")
    print(f"  • Calorie Target   {round(out.recommended_calories)} kcal/day")
    m = out.macronutrients
    p_min = m["protein"]["min_g"]
    p_max = m["protein"]["max_g"]
    if p_min == p_max:
        print(f"  • Protein Target   {p_min} g/day")
    else:
        print(f"  • Protein Target   {p_min}–{p_max} g/day")
    print(f"  • Fat Target       {m['fat']['min_g']}–{m['fat']['max_g']} g/day")
    print(f"  • Carbs Target     {m['carbohydrates']['g']} g/day")

    # ── KEY RISK FLAGS ────────────────────────────────────────────
    critical_alerts = [a for a in out.risk_alerts if "CRITICAL" in a.upper() or "WARNING" in a.upper()]
    if critical_alerts:
        print(f"\n🚨 KEY RISK FLAGS")
        print(SEP)
        for alert in critical_alerts[:6]:
            # Strip the prefix label for cleanliness
            clean = alert.replace("CRITICAL: ", "").replace("WARNING: ", "").replace("HIGH: ", "").replace("LOW ", "Low ")
            print(f"  ► {clean}")

    # ── LAB STATUS ───────────────────────────────────────────────
    if out.lab_analysis:
        print(f"\n📊 LAB STATUS")
        print(SEP)
        for key, val in out.lab_analysis.items():
            label = key.replace("_", " ").title()
            v     = val.get("value_mg_dL", "")
            status = val.get("status", "")
            icon  = _status_icon(status)
            # Only show reference range if abnormal
            if status.lower() not in ("normal", "optimal", "desirable", "protective", "near optimal"):
                print(f"  {icon} {label:<26} {v}  →  {status}")
            else:
                print(f"  {icon} {label:<26} {v}  →  {status}")

    # ── NUTRITION GAPS ────────────────────────────────────────────
    gaps = {k: v for k, v in out.intake_analysis.items()
            if v.get("status", "On Target") != "On Target"}
    if gaps:
        print(f"\n🍽  NUTRITION GAPS")
        print(SEP)
        too_high = []
        too_low  = []
        for key, val in gaps.items():
            label  = key.replace("_", " ").title()
            status = val.get("status", "")
            if "Above" in status or "Critical High" in status:
                too_high.append(label)
            elif "Below" in status or "Critical Low" in status:
                too_low.append(label)
        if too_high:
            print(f"  🔺 Too High  :  {',  '.join(too_high)}")
        if too_low:
            print(f"  🔻 Too Low   :  {',  '.join(too_low)}")

    # ── TOP 5 PRIORITY ACTIONS ────────────────────────────────────
    print(f"\n🎯 TOP 5 PRIORITY ACTIONS")
    print(SEP)
    actions = _build_priority_actions(out, inp)
    for i, action in enumerate(actions, 1):
        print(f"  {i}. {action}")

    # ── HYDRATION NOTE ────────────────────────────────────────────
    water_target = out.micronutrient_targets["water"]["liters"]
    print(f"\n💧 HYDRATION")
    print(SEP)
    print(f"  Target: {water_target} L/day.", end=" ")
    if inp.activity_level == "active":
        print("Add 0.5–1 L per hour of exercise.")
    elif inp.bmi >= 30:
        print("Prioritise water — obesity increases dehydration risk.")
    else:
        print("Sip consistently throughout the day.")

    # ── MEDICAL DISCLAIMER ────────────────────────────────────────
    print(f"\n⚠  DISCLAIMER")
    print(SEP)
    print("  This is informational only — not a clinical diagnosis.")
    print("  Consult a doctor or dietitian before acting on abnormal values.")
    print(f"\n{'═' * W}\n")


# ===========================================================================
# FastAPI-READY FUNCTION
# ===========================================================================

def get_assessment_for_api(
    age: int,
    gender: str,
    height_cm: float,
    weight_kg: float,
    activity_level: str,
    bmi: Optional[float] = None,
    triglycerides: Optional[float] = None,
    total_cholesterol: Optional[float] = None,
    hdl: Optional[float] = None,
    ldl: Optional[float] = None,
    fasting_blood_glucose: Optional[float] = None,
    serum_uric_acid: Optional[float] = None,
    serum_creatinine: Optional[float] = None,
    intake_calories: Optional[float] = None,
    intake_protein: Optional[float] = None,
    intake_carbohydrates: Optional[float] = None,
    intake_fat: Optional[float] = None,
    intake_sodium: Optional[float] = None,
    intake_fiber: Optional[float] = None,
    intake_water: Optional[float] = None,
    intake_iron: Optional[float] = None,
    intake_calcium: Optional[float] = None,
    intake_vitamin_d: Optional[float] = None,
) -> dict:
    """
    Drop-in function for a FastAPI route. Returns a JSON-serialisable dict.

    Example route in vitals.py:
    ----------------------------
    from fastapi import APIRouter
    from app.ml.health_assessment import get_assessment_for_api

    router = APIRouter(prefix="/vitals", tags=["Vitals"])

    @router.post("/full-assessment")
    def full_assessment(
        age: int, gender: str, height_cm: float, weight_kg: float,
        activity_level: str,
        triglycerides: float = None, total_cholesterol: float = None,
        hdl: float = None, ldl: float = None,
        fasting_blood_glucose: float = None,
        serum_uric_acid: float = None, serum_creatinine: float = None,
        intake_calories: float = None, intake_protein: float = None,
        intake_carbohydrates: float = None, intake_fat: float = None,
        intake_sodium: float = None, intake_fiber: float = None,
        intake_water: float = None, intake_iron: float = None,
        intake_calcium: float = None, intake_vitamin_d: float = None,
    ):
        return get_assessment_for_api(**locals())
    """
    inp = AssessmentInput(
        age=age, gender=gender, height_cm=height_cm, weight_kg=weight_kg,
        activity_level=activity_level, bmi=bmi,
        triglycerides=triglycerides, total_cholesterol=total_cholesterol,
        hdl=hdl, ldl=ldl, fasting_blood_glucose=fasting_blood_glucose,
        serum_uric_acid=serum_uric_acid, serum_creatinine=serum_creatinine,
        intake_calories=intake_calories, intake_protein=intake_protein,
        intake_carbohydrates=intake_carbohydrates, intake_fat=intake_fat,
        intake_sodium=intake_sodium, intake_fiber=intake_fiber,
        intake_water=intake_water, intake_iron=intake_iron,
        intake_calcium=intake_calcium, intake_vitamin_d=intake_vitamin_d,
    )
    result = run_assessment(inp)
    return result.to_dict()


# ===========================================================================
# CLI
# ===========================================================================

def _prompt_optional_float(label: str) -> Optional[float]:
    raw = input(f"  {label} (press Enter to skip): ").strip()
    return float(raw) if raw else None


if __name__ == "__main__":
    print("\n" + "=" * 65)
    print("   CLINICAL NUTRITION & BIOCHEMICAL ASSESSMENT ENGINE")
    print("=" * 65)

    try:
        age    = int(input("\nAge: "))
        gender = input("Gender (male/female): ").strip().lower()
        height = float(input("Height (cm): "))
        weight = float(input("Weight (kg): "))
        act    = input("Activity Level (sedentary/moderate/active): ").strip().lower()

        print("\n--- Lab Values (optional — press Enter to skip each) ---")
        trig   = _prompt_optional_float("Triglycerides (mg/dL)")
        tchol  = _prompt_optional_float("Total Cholesterol (mg/dL)")
        hdl_v  = _prompt_optional_float("HDL (mg/dL)")
        ldl_v  = _prompt_optional_float("LDL (mg/dL)")
        fbg    = _prompt_optional_float("Fasting Blood Glucose (mg/dL)")
        ua     = _prompt_optional_float("Serum Uric Acid (mg/dL)")
        cr     = _prompt_optional_float("Serum Creatinine (mg/dL)")

        print("\n--- Daily Intake Values (optional — press Enter to skip each) ---")
        i_cal  = _prompt_optional_float("Calories (kcal)")
        i_pro  = _prompt_optional_float("Protein (g)")
        i_carb = _prompt_optional_float("Carbohydrates (g)")
        i_fat  = _prompt_optional_float("Fat (g)")
        i_sod  = _prompt_optional_float("Sodium (mg)")
        i_fib  = _prompt_optional_float("Fiber (g)")
        i_wat  = _prompt_optional_float("Water (L)")
        i_iro  = _prompt_optional_float("Iron (mg)")
        i_cal2 = _prompt_optional_float("Calcium (mg)")
        i_vd   = _prompt_optional_float("Vitamin D (IU)")

        inp = AssessmentInput(
            age=age, gender=gender, height_cm=height, weight_kg=weight,
            activity_level=act,
            triglycerides=trig, total_cholesterol=tchol,
            hdl=hdl_v, ldl=ldl_v, fasting_blood_glucose=fbg,
            serum_uric_acid=ua, serum_creatinine=cr,
            intake_calories=i_cal, intake_protein=i_pro,
            intake_carbohydrates=i_carb, intake_fat=i_fat,
            intake_sodium=i_sod, intake_fiber=i_fib, intake_water=i_wat,
            intake_iron=i_iro, intake_calcium=i_cal2, intake_vitamin_d=i_vd,
        )

        result = run_assessment(inp)
        print_report(result, inp)

    except ValueError as e:
        print(f"\nInvalid input: {e}")
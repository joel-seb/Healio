import pandas as pd
import os
import re

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FILE_PATH = os.path.join(BASE_DIR, "first_aid.csv")

first_aid_df = pd.read_csv(FILE_PATH)
first_aid_df.columns = first_aid_df.columns.str.strip()

first_aid_df["Accident"] = first_aid_df["Accident"].str.strip().str.lower()


def clean_accident_name(accident: str):
    accident = re.sub(r"\(.*?\)", "", accident)

    accident = accident.strip()

    if accident.endswith("s"):
        accident = accident[:-1]

    return accident


def get_first_aid(message: str):

    message_clean = re.sub(r"[^\w\s]", "", message.lower()).strip()

    for _, row in first_aid_df.iterrows():
        accident = row["Accident"]

        accident_clean = clean_accident_name(accident).lower()

        # Match only full words using regex word boundaries
        pattern = r"\b" + re.escape(accident_clean) + r"\b"

        if re.search(pattern, message_clean):
            return row["Appropriate Measures"]

    return "No specific first aid instructions found for this situation."

import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.tables import Vitals
from app.schemas.user import VitalsCreate, VitalsResponse
from typing import List

router = APIRouter()


@router.post("/{user_id}", response_model=VitalsResponse)
def save_vitals(user_id: int, vitals: VitalsCreate, db: Session = Depends(get_db)):
    record = Vitals(
        user_id=user_id,
        heart_rate=vitals.heart_rate,
        systolic=vitals.systolic,
        diastolic=vitals.diastolic,
        blood_sugar=vitals.blood_sugar,
        post_meal_sugar=vitals.post_meal_sugar,
        body_temp=vitals.body_temp,
        spo2=vitals.spo2,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return _serialize(record)


@router.get("/{user_id}/latest", response_model=VitalsResponse)
def get_latest_vitals(user_id: int, db: Session = Depends(get_db)):
    records = (
        db.query(Vitals)
        .filter(Vitals.user_id == user_id)
        .order_by(Vitals.id.desc())
        .all()
    )
    if not records:
        raise HTTPException(status_code=404, detail="No vitals found")

    # Merge: pick the latest non-null value for each field across all rows
    fields = ["heart_rate", "systolic", "diastolic", "blood_sugar", "post_meal_sugar", "body_temp", "spo2"]
    merged = {f: None for f in fields}
    for record in records:  # already ordered newest-first
        for f in fields:
            if merged[f] is None and getattr(record, f) is not None:
                merged[f] = getattr(record, f)
        if all(merged[f] is not None for f in fields):
            break  # all fields found, no need to scan further

    latest = records[0]
    return {
        "id": latest.id,
        "user_id": latest.user_id,
        "heart_rate": merged["heart_rate"],
        "systolic": merged["systolic"],
        "diastolic": merged["diastolic"],
        "blood_sugar": merged["blood_sugar"],
        "post_meal_sugar": merged["post_meal_sugar"],
        "body_temp": merged["body_temp"],
        "spo2": merged["spo2"],
        "recorded_at": str(latest.recorded_at) if latest.recorded_at else None,
    }


@router.get("/{user_id}/history", response_model=List[VitalsResponse])
def get_vitals_history(user_id: int, limit: int = 20, db: Session = Depends(get_db)):
    records = (
        db.query(Vitals)
        .filter(Vitals.user_id == user_id)
        .order_by(Vitals.id.desc())
        .limit(limit)
        .all()
    )
    return [_serialize(r) for r in records]


def _serialize(record: Vitals) -> dict:
    return {
        "id": record.id,
        "user_id": record.user_id,
        "heart_rate": record.heart_rate,
        "systolic": record.systolic,
        "diastolic": record.diastolic,
        "blood_sugar": record.blood_sugar,
        "post_meal_sugar": record.post_meal_sugar,
        "body_temp": record.body_temp,
        "spo2": record.spo2,
        "recorded_at": str(record.recorded_at) if record.recorded_at else None,
    }

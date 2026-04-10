import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.tables import Medication
from app.schemas.user import MedicationCreate, MedicationResponse
from typing import List

router = APIRouter()


@router.post("/{user_id}", response_model=MedicationResponse)
def add_medication(user_id: int, med: MedicationCreate, db: Session = Depends(get_db)):
    record = Medication(
        user_id=user_id,
        name=med.name,
        dose=med.dose,
        times=json.dumps(med.times) if med.times else None,
        start_date=med.start_date,
        end_date=med.end_date,
        prescribed_by=med.prescribed_by,
        instructions=med.instructions,
        notes=med.notes,
        icon_color=med.icon_color or '0xFF20B2AA',
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return _serialize(record)


@router.get("/{user_id}", response_model=List[MedicationResponse])
def get_medications(user_id: int, db: Session = Depends(get_db)):
    records = db.query(Medication).filter(Medication.user_id == user_id).all()
    return [_serialize(r) for r in records]


@router.delete("/{user_id}/{med_id}")
def delete_medication(user_id: int, med_id: int, db: Session = Depends(get_db)):
    record = db.query(Medication).filter(
        Medication.id == med_id, Medication.user_id == user_id
    ).first()
    if not record:
        raise HTTPException(status_code=404, detail="Medication not found")
    db.delete(record)
    db.commit()
    return {"message": "Deleted"}


@router.put("/{user_id}/{med_id}", response_model=MedicationResponse)
def update_medication(user_id: int, med_id: int, med: MedicationCreate, db: Session = Depends(get_db)):
    record = db.query(Medication).filter(
        Medication.id == med_id, Medication.user_id == user_id
    ).first()
    if not record:
        raise HTTPException(status_code=404, detail="Medication not found")
    record.name = med.name
    record.dose = med.dose
    record.times = json.dumps(med.times) if med.times else None
    record.start_date = med.start_date
    record.end_date = med.end_date
    record.prescribed_by = med.prescribed_by
    record.instructions = med.instructions
    record.notes = med.notes
    record.icon_color = med.icon_color or '0xFF20B2AA'
    db.commit()
    db.refresh(record)
    return _serialize(record)


def _serialize(record: Medication) -> dict:
    return {
        "id": record.id,
        "user_id": record.user_id,
        "name": record.name,
        "dose": record.dose,
        "times": json.loads(record.times) if record.times else [],
        "start_date": record.start_date,
        "end_date": record.end_date,
        "prescribed_by": record.prescribed_by,
        "instructions": record.instructions,
        "notes": record.notes,
        "icon_color": record.icon_color or '0xFF20B2AA',
    }

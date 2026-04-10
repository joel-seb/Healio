from pydantic import BaseModel, EmailStr
from typing import Optional, List


# ── Auth ──────────────────────────────────────────────────────────────────────

class UserCreate(BaseModel):
    name: str
    age: int
    email: EmailStr
    password: str
    blood_type: Optional[str] = "O+"
    height: Optional[float] = None
    weight: Optional[float] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    name: str
    age: int
    email: EmailStr
    blood_type: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    blood_type: Optional[str] = None
    height: Optional[float] = None
    weight: Optional[float] = None


class LoginResponse(BaseModel):
    message: str
    user_id: int
    name: str
    token: str
    user: UserResponse


# ── Vitals ────────────────────────────────────────────────────────────────────

class VitalsCreate(BaseModel):
    heart_rate: Optional[int] = None
    systolic: Optional[int] = None
    diastolic: Optional[int] = None
    blood_sugar: Optional[float] = None
    post_meal_sugar: Optional[float] = None
    body_temp: Optional[float] = None
    spo2: Optional[int] = None


class VitalsResponse(VitalsCreate):
    id: int
    user_id: int
    recorded_at: Optional[str] = None

    class Config:
        from_attributes = True


# ── Medications ───────────────────────────────────────────────────────────────

class MedicationCreate(BaseModel):
    name: str
    dose: Optional[str] = None
    times: Optional[List[str]] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    prescribed_by: Optional[str] = None
    instructions: Optional[str] = None
    notes: Optional[str] = None
    icon_color: Optional[str] = '0xFF20B2AA'


class MedicationResponse(BaseModel):
    id: int
    user_id: int
    name: str
    dose: Optional[str] = None
    times: Optional[List[str]] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    prescribed_by: Optional[str] = None
    instructions: Optional[str] = None
    notes: Optional[str] = None
    icon_color: Optional[str] = '0xFF20B2AA'

    class Config:
        from_attributes = True

from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base


class Vitals(Base):
    __tablename__ = "vitals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    heart_rate = Column(Integer, nullable=True)
    systolic = Column(Integer, nullable=True)
    diastolic = Column(Integer, nullable=True)
    blood_sugar = Column(Float, nullable=True)
    post_meal_sugar = Column(Float, nullable=True)
    body_temp = Column(Float, nullable=True)
    spo2 = Column(Integer, nullable=True)
    recorded_at = Column(DateTime(timezone=True), server_default=func.now())


class Medication(Base):
    __tablename__ = "medications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False)
    dose = Column(String, nullable=True)
    times = Column(String, nullable=True)
    start_date = Column(String, nullable=True)
    end_date = Column(String, nullable=True)
    prescribed_by = Column(String, nullable=True)
    instructions = Column(String, nullable=True)
    notes = Column(String, nullable=True)
    icon_color = Column(String, nullable=True, default='0xFF20B2AA')
    created_at = Column(DateTime(timezone=True), server_default=func.now())

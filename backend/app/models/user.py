from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from app.db.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)
    age = Column(Integer, nullable=True)
    blood_type = Column(String, nullable=True)
    height = Column(Float, nullable=True)   # cm
    weight = Column(Float, nullable=True)   # kg
    created_at = Column(DateTime(timezone=True), server_default=func.now())

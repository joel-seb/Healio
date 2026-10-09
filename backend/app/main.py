from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, chatbot
from app.api import vitals, medications
from app.db.database import engine, Base

from app.models import user as user_model       
from app.db import tables as db_tables          

app = FastAPI(
    title="Healio – Healthcare Assistant API",
    version="2.0.0",
    description="Backend for the Healio Flutter health app",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router,        prefix="/auth",        tags=["Auth"])
app.include_router(chatbot.router,     prefix="/chatbot",     tags=["Chatbot"])
app.include_router(vitals.router,      prefix="/vitals",      tags=["Vitals"])
app.include_router(medications.router, prefix="/medications", tags=["Medications"])

Base.metadata.create_all(bind=engine)


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "Healio API"}

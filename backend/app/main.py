from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, chatbot
from app.api import vitals, medications
from app.db.database import engine, Base

# Import all models so their tables are created
from app.models import user as user_model       # noqa: F401
from app.db import tables as db_tables          # noqa: F401

app = FastAPI(
    title="Healio – Healthcare Assistant API",
    version="2.0.0",
    description="Backend for the Healio Flutter health app",
)

# ── CORS (allow Flutter mobile / emulator origins) ────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth.router,        prefix="/auth",        tags=["Auth"])
app.include_router(chatbot.router,     prefix="/chatbot",     tags=["Chatbot"])
app.include_router(vitals.router,      prefix="/vitals",      tags=["Vitals"])
app.include_router(medications.router, prefix="/medications", tags=["Medications"])

# ── DB bootstrap ──────────────────────────────────────────────────────────────
Base.metadata.create_all(bind=engine)


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "Healio API"}

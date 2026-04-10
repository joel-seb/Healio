import hashlib
import secrets
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse, UserUpdate, LoginResponse

router = APIRouter()

# Simple token store (in production use Redis or a proper token table)
_token_store: dict[str, int] = {}


def _hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


def _generate_token(user_id: int) -> str:
    token = secrets.token_hex(32)
    _token_store[token] = user_id
    return token


def get_user_id_from_token(token: str) -> int | None:
    return _token_store.get(token)


# ── Register ──────────────────────────────────────────────────────────────────

@router.post("/register", response_model=LoginResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        name=user.name,
        age=user.age,
        email=user.email,
        password=_hash_password(user.password),
        blood_type=user.blood_type,
        height=user.height,
        weight=user.weight,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    token = _generate_token(new_user.id)
    return LoginResponse(
        message="Registration successful",
        user_id=new_user.id,
        name=new_user.name,
        token=token,
        user=UserResponse.model_validate(new_user),
    )


# ── Login ─────────────────────────────────────────────────────────────────────

@router.post("/login", response_model=LoginResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or db_user.password != _hash_password(user.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = _generate_token(db_user.id)
    return LoginResponse(
        message="Login successful",
        user_id=db_user.id,
        name=db_user.name,
        token=token,
        user=UserResponse.model_validate(db_user),
    )


# ── Profile ───────────────────────────────────────────────────────────────────

@router.get("/profile/{user_id}", response_model=UserResponse)
def get_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/profile/{user_id}", response_model=UserResponse)
def update_profile(user_id: int, update: UserUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if update.name is not None:
        user.name = update.name
    if update.age is not None:
        user.age = update.age
    if update.blood_type is not None:
        user.blood_type = update.blood_type
    if update.height is not None:
        user.height = update.height
    if update.weight is not None:
        user.weight = update.weight

    db.commit()
    db.refresh(user)
    return user

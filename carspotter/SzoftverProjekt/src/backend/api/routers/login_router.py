from fastapi import APIRouter, Depends, HTTPException
from api.models.request_models import LoginRequest
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import jwt
from db.database import get_db
from db.tables.models import User
from datetime import datetime, timedelta, timezone

login_router = APIRouter()

@login_router.post("/login")
def login_user(request: LoginRequest, db: Session = Depends(get_db)):
    try:
        user = db.query(User).filter(User.email == request.email).first()
        if not user:
            raise HTTPException(status_code=401, detail="Invalid email or password")

        if not verify_password(request.password, user.password):
            raise HTTPException(status_code=401, detail="Invalid email or password")

        access_token = create_access_token(data={"sub": user.id})

        return {"access_token": access_token, "token_type": "bearer", "user_id": user.id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")



SECRET_KEY = "y7s8FnQ37V6P7LrAyWm01P9oCw5M4EJrrjb61GTyG4w=" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "sub": data["sub"]})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
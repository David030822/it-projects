from fastapi import APIRouter, Depends, UploadFile, File, Form
from sqlalchemy.orm import Session
from db.database import get_db
from api.services.register_service import register_user_service
from api.repositories.save_file import save_file
from typing import Optional

register_router = APIRouter()

@register_router.post("/register")
async def register_user(
    first_name: str = Form(...),
    last_name: str = Form(...),
    email: str = Form(...),
    phone: str = Form(...),
    password: str = Form(...),
    dealer_inventory_name: Optional[str] = Form(None),
    profile_image: UploadFile = File(None), 
    db: Session = Depends(get_db),
):
   
    if profile_image:
        profile_image_path = save_file(profile_image)  
    else:
        profile_image_path = None

    new_user_data = {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "phone": phone,
        "password": password,
        "profile_image_path": profile_image_path,
        "dealer_inventory_name": dealer_inventory_name,
    }

    new_user = register_user_service(new_user_data, db)

    return {"message": "User registered successfully", "user_id": new_user["user_id"]}
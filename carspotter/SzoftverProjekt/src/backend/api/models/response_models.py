from pydantic import BaseModel
from typing import List, Optional
import os
import base64


class MonthlySalesData(BaseModel):
    month: str  
    sold_count: int  

class SalesData(BaseModel):
    day: str 
    sold_count: int

class StatisticsResponse(BaseModel):
    weekly_sales: List[SalesData]
    monthly_sales: List[MonthlySalesData]

class CarResponse(BaseModel):
    id: int
    model: str 
    km: int 
    year: int
    price: float 
    combustible: str 
    gearbox: str 
    body_type: str 
    cylinder_capacity: int 
    power: int 
    id_post: int
    img_url: str

class OwnCarResponse(BaseModel):
    id: int
    model: str 
    km: int 
    year: int 
    combustible: str 
    gearbox: str 
    body_type: str 
    engine_size: int 
    power: int 
    selling_for: float
    bought_for: Optional[float] = None
    sold_for: Optional[float] = None
    spent_on: Optional[float] = None
    img_url: str


    class Config:
        orm_mode = True

class UserDataResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    email: str
    phone: str
    profile_image: str 

    @staticmethod
    def from_user(user) ->"UserDataResponse":
        profile_image_path = user.profile_image_path
        if profile_image_path and os.path.exists(profile_image_path): 
            try:
                with open(profile_image_path, "rb") as image_file:
                    encoded_image = base64.b64encode(image_file.read()).decode("utf-8")
                    profile_image = f"data:image/jpeg;base64,{encoded_image}"
            except Exception as e:
                print(f"Error reading profile image: {e}. Using default image.")
                profile_image = _get_default_image()
        else:
            profile_image = _get_default_image() 

        return UserDataResponse(
            id=user.id,
            first_name=user.first_name,
            last_name=user.last_name,
            email=user.email,
            phone=user.phone,
            profile_image=profile_image,
        )


def _get_default_image() -> str:
    default_image_path = "uploads/profile_images\path_to_default_image.jpg"
    try:
        with open(default_image_path, "rb") as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode("utf-8")
            return f"data:image/jpeg;base64,{encoded_image}"
    except Exception as e:
        print(f"Error loading default image: {e}")
        return ""


from pydantic import BaseModel, EmailStr

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class UserUpdate(BaseModel):
    first_name: str
    last_name: str
    phone: str
    email: str

    class Config:
        orm_mode = True 


class NewOwnCarRequest(BaseModel):
    model: str 
    km: int 
    year: int 
    combustible: str 
    gearbox: str 
    body_type: str 
    engine_size: int 
    power: int 
    selling_for: float
    bought_for: float
    sold_for: float
    spent_on: float 
    img_url: str

class SellOwnCarRequest(BaseModel):
    own_car_id: int
    sell_for: float
from fastapi import HTTPException
from sqlalchemy.orm import Session
from api.repositories.user_repository import (
    get_user_by_email,
    get_user_by_dealer_id,
    create_user,
)
from api.repositories.dealer_car_repository import (
    get_dealer_by_inventory_name,
    get_cars_by_dealer_id,
    add_own_car,
)
from api.services.car_service import insert_cars_and_dealer_by_dealer_name
from passlib.context import CryptContext
from db.tables.models import OwnCar

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def register_user_service(request, db: Session):
    existing_user = get_user_by_email(db, request["email"])
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered.")

    new_user_data = {
        "first_name": request["first_name"],
        "last_name": request["last_name"],
        "email": request["email"],
        "phone": request["phone"],
        "password": hash_password(request["password"]),
        "profile_image_path": request["profile_image_path"] 
    }

    if request["dealer_inventory_name"] and request["dealer_inventory_name"].strip():
        dealer = get_dealer_by_inventory_name(db, request["dealer_inventory_name"])
        if not dealer:
            insert_cars_and_dealer_by_dealer_name(db,  request["dealer_inventory_name"])
            dealer = get_dealer_by_inventory_name(db,  request["dealer_inventory_name"])
            if not dealer:
                raise HTTPException(status_code=400, detail="Not a valid dealer.")

        existing_dealer_user = get_user_by_dealer_id(db, dealer.id)
        if existing_dealer_user:
            raise HTTPException(status_code=400, detail="Dealer name is already used by another user.")

        new_user_data["dealer_id"] = dealer.id
        new_user = create_user(db, new_user_data)

        cars = get_cars_by_dealer_id(db, dealer.id)
        for car in cars:
            own_car = OwnCar(
                user_id=new_user.id,
                model=car.model,
                km=car.km,
                year=car.year,
                selling_for=car.price,
                combustible=car.combustible,
                gearbox=car.gearbox,
                body_type=car.body_type,
                engine_size=car.cylinder_capacity,
                power=car.power,
                purchase_date=car.dateof_post,
                img_url=car.img_url
            )
            add_own_car(db, own_car)
    else:
        new_user = create_user(db, new_user_data)

    return {"message": "User registered successfully", "user_id": new_user.id}

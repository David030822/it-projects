import os
from fastapi import HTTPException
from sqlalchemy.orm import Session
from api.models.request_models import UserUpdate, NewOwnCarRequest
from api.repositories.dealer_car_repository import get_dealer_by_id
from pathlib import Path 
from api.repositories.user_repository import (
    add_following,
    delete_following,
    delete_own_car,
    get_favourite,
    add_favourite,
    get_following,
    get_own_car_by_id,
    get_sold_cars_by_dealer_id,
    is_followed,
    remove_favourite,
    get_user_by_id,
    get_own_cars_by_user,
    get_favourite_dealers_by_user,
    sell_own_car,
    update_own_car,
    update_user_repository,
    add_car_to_db
)

def add_favourite_service(user_id: int, dealer_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    dealer = get_dealer_by_id(db, dealer_id)
    if not dealer:
        raise HTTPException(status_code=404, detail="Dealer not found")
    if get_favourite(db, user_id, dealer_id):
        raise HTTPException(status_code=400, detail="Dealer is already in your favorites")
    
    add_favourite(db, user_id, dealer_id)
    return {"message": "Dealer added to favorites"}

def get_favourites_service(user_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    favourite_dealers = get_favourite_dealers_by_user(db, user_id)
    if not favourite_dealers:
        return {"message": "No favorite dealers found for this user."}

    return {"favorites": favourite_dealers}

def remove_favourite_service(user_id: int, dealer_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    dealer = get_dealer_by_id(db, dealer_id)
    if not dealer:
        raise HTTPException(status_code=404, detail="Dealer not found")
    
    favourite = get_favourite(db, user_id, dealer_id)
    if not favourite:
        raise HTTPException(status_code=400, detail="Dealer is not in your favorites")
    
    remove_favourite(db, favourite)
    return {"message": "Dealer removed from favorites"}

def get_own_cars_service(user_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    own_cars = get_own_cars_by_user(db, user_id)
    sold_cars = get_sold_own_cars_by_user_id_service(user_id=user_id, db=db)
    result = [car for car in own_cars if car not in sold_cars]
    return result

def get_user_data_service(user_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user


def update_user_data_service(user_id: int, user_data: UserUpdate, db: Session):
    existing_user = get_user_by_id(db,user_id)
    
    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    updated_user = update_user_repository(existing_user, user_data, db)
    
    return updated_user


def update_user_image_service(user_id: int, profile_image_path: str, db: Session):
    user = get_user_by_id(db,user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.profile_image_path:
        old_image_path = Path(user.profile_image_path)
        
        if old_image_path.exists() and old_image_path.is_file():
            try:
                os.remove(old_image_path)
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error deleting old image: {e}")

    user.profile_image_path = profile_image_path
    db.commit()
    db.refresh(user) 
    return user 


def add_own_car_service(user_id: int, car_data: NewOwnCarRequest, db: Session):
    user = get_user_by_id(db, user_id= user_id)
    if not user: 
        raise ValueError(f"User does not exist.")

    new_car = add_car_to_db(db, user_id, car_data)
    return {
        "message": "Car added successfully",
        "car_id": new_car.id,
        "model": new_car.model,
    }


def update_own_car_service(user_id: int, updated_own_car: NewOwnCarRequest, own_car_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    result = update_own_car(db=db, user_id=user_id, updated_own_car=updated_own_car, own_car_id=own_car_id)
    
    return result
def delete_own_car_service(user_id: int, own_car_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return delete_own_car(db, user_id, own_car_id)


def add_following_service(user_id: int, followed_id: int, db: Session):
    user = get_user_by_id(db, user_id= user_id)
    if not user: 
        raise ValueError(f"User does not exist.")
    followed = get_user_by_id(db, user_id=followed_id)
    if not followed: 
        raise ValueError(f"Followed user does not exist")
    
    is_followed_user = is_followed(user_id, followed_id, db)
    if is_followed_user:
        return {
            "message": "User is already followed"
        }   
    
    following = add_following(user_id= user_id, followed_id= followed_id, db=db)
    if not following:
        raise ValueError(f"Follow error")
    return {
        "message": "User followed successfully"
    }

def get_following_service(user_id: int, db: Session):
    user = get_user_by_id(db, user_id= user_id)
    if not user: 
        raise ValueError(f"User does not exist.")

    return get_following(user_id, db)


def delete_following_service(user_id: int, following_id: int, db: Session):
    user = delete_following(user_id, following_id, db)
    if not user: 
        raise ValueError(f"User does not exist.")
    return {"message": "Following deleted successfully"}

def is_followed_service(user_id: int, following_id: int, db: Session):
    user = get_user_by_id(db, user_id= user_id)
    if not user: 
        raise ValueError(f"User does not exist.")

    return is_followed(user_id, following_id, db)


def get_sold_cars_by_dealer_id_service(dealer_id: int, db: Session):
    dealer = get_dealer_by_id(db, dealer_id)
    if not dealer: 
        raise ValueError(f"dealer does not exist.")
    return get_sold_cars_by_dealer_id(dealer_id, db)

def get_sold_own_cars_by_user_id_service(user_id: int, db: Session):
    user = get_user_by_id(db, user_id)
    if not user: 
        raise ValueError(f"User does not exist.")
    own_cars =  get_own_cars_by_user(db=db, user_id=user_id)
    sold_own_car = []
    if not own_cars:
        return []
    for car in own_cars:
        print(car.sold_for)
        if car.sold_for and (car.sold_for != 0.0):
            sold_own_car.append(car)
    return sold_own_car


def sell_own_car_service(user_id: int, own_car_id: int, sell_for: float, db: Session):
    user = get_user_by_id(db, user_id)
    if not user: 
        raise ValueError(f"User does not exist.")
    car = get_own_car_by_id(db, own_car_id)
    if not car: 
        raise ValueError(f"Own car does not exist.")
    return sell_own_car(own_car_id=own_car_id, sell_for=sell_for, db=db)
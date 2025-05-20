from typing import List
from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy.orm import Session
from api.services.statistics_service import get_statistics_for_dealer_service, get_statistics_for_user_service
from db.tables.models import User
from db.database import get_db
from api.services.user_service import (
    add_favourite_service,
    delete_following_service,
    delete_own_car_service,
    get_favourites_service,
    get_following_service,
    get_sold_cars_by_dealer_id_service,
    get_sold_own_cars_by_user_id_service,
    is_followed_service,
    remove_favourite_service,
    get_own_cars_service,
    get_user_data_service,
    sell_own_car_service,
    update_own_car_service,
    update_user_data_service,
    update_user_image_service,
    add_own_car_service,
    add_following_service
)
from api.models.response_models import CarResponse, OwnCarResponse, StatisticsResponse, UserDataResponse
from api.models.request_models import SellOwnCarRequest, UserUpdate, NewOwnCarRequest
from api.repositories.save_file import save_file

user_router = APIRouter()

@user_router.post("/user/{user_id}/favorite/{dealer_id}")
def add_favourite(user_id: int, dealer_id: int, db: Session = Depends(get_db)):
    return add_favourite_service(user_id, dealer_id, db)

@user_router.get("/user/{user_id}/favorites")
def get_favourites(user_id: int, db: Session = Depends(get_db)):
    return get_favourites_service(user_id, db)

@user_router.delete("/user/{user_id}/favorite/{dealer_id}")
def remove_favourite(user_id: int, dealer_id: int, db: Session = Depends(get_db)):
    return remove_favourite_service(user_id, dealer_id, db)

@user_router.get("/user/{user_id}/owncars", response_model=List[OwnCarResponse])
def get_own_cars(user_id: int, db: Session = Depends(get_db)):
    return get_own_cars_service(user_id, db)

@user_router.get("/user/{user_id}", response_model=UserDataResponse)
def get_user_data(user_id: int, db: Session = Depends(get_db)):
    user = get_user_data_service(user_id, db)  
    return UserDataResponse.from_user(user)


@user_router.put("/user/{user_id}", response_model=UserUpdate)
def update_user_data(user_id: int, user_data: UserUpdate, db: Session = Depends(get_db)):
    updated_user = update_user_data_service(user_id, user_data, db)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return updated_user


@user_router.put("/user-image/{user_id}")
async def update_user_image(
    user_id: int,
    profile_image: UploadFile = File(None), 
    db: Session = Depends(get_db),
):
    if profile_image:
        profile_image_path = save_file(profile_image)  
    else:
        profile_image_path = None

    updated_user = update_user_image_service(user_id, profile_image_path, db)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return updated_user


@user_router.post("/user/{user_id}/newcar")
def add_new_own_car(user_id: int, own_car: NewOwnCarRequest, db: Session = Depends(get_db)):
    return add_own_car_service(user_id, own_car, db)


@user_router.post("/user/{user_id}/following/{following_id}")
def add_following(user_id: int, following_id: int, db: Session = Depends(get_db)):
    return add_following_service(user_id, following_id, db)



@user_router.get("/user/{user_id}/following", response_model=List[UserDataResponse])
def get_following(user_id: int, db: Session = Depends(get_db)):
    users = get_following_service(user_id, db)
    return [UserDataResponse.from_user(user) for user in users]


@user_router.delete("/user/{user_id}/following/{following_id}")
def delete_following(user_id: int, following_id: int, db: Session = Depends(get_db)):
    return delete_following_service(user_id, following_id, db)

@user_router.get("/following/{user_id}/{following_id}")
def is_following(user_id: int, following_id: int, db: Session = Depends(get_db)):
    return is_followed_service(user_id, following_id, db)

@user_router.get("/sold_cars/{dealer_id}", response_model=List[CarResponse])
def get_sold_cars_by_dealer_id(dealer_id: int, db: Session = Depends(get_db)):
    return get_sold_cars_by_dealer_id_service(dealer_id, db)

@user_router.get("/sold_owncars/{user_id}", response_model=List[OwnCarResponse])
def get_sold_own_cars_by_user_id(user_id: int, db: Session = Depends(get_db)):
    return get_sold_own_cars_by_user_id_service(user_id, db)

@user_router.put("/sell_owncar/{user_id}")
def sell_own_car(user_id: int, request: SellOwnCarRequest, db: Session = Depends(get_db)):
    return sell_own_car_service(user_id, request.own_car_id, request.sell_for, db)

@user_router.put("/user/{user_id}/owncar/{own_car_id}")
def update_own_car(user_id: int, own_car_id: int, updated_own_car: NewOwnCarRequest, db: Session = Depends(get_db)):
    result = update_own_car_service(user_id, updated_own_car, own_car_id, db)
    if not result:
        raise HTTPException(status_code=500, detail="Failed to update car")
    return result

@user_router.delete("/user/{user_id}/owncar/{own_car_id}")
def deletet_own_car(user_id: int, own_car_id: int, db: Session = Depends(get_db)):
    result = delete_own_car_service(user_id, own_car_id, db)
    if not result:
        raise HTTPException(status_code=500, detail="Failed to delete car")
    return result


@user_router.get("/search_users", response_model=List[UserDataResponse])
def search_users(
    query: str = Query(..., min_length=1, description="Search query for first or last name"),
    db: Session = Depends(get_db)
):
    keywords = query.split()
    
    if len(keywords) == 1:
        users = db.query(User).filter(
            (User.first_name.ilike(f"%{keywords[0]}%")) | 
            (User.last_name.ilike(f"%{keywords[0]}%"))
        ).all()
    elif len(keywords) >= 2:
        first_name_query = keywords[0]
        last_name_query = keywords[1]
        
        users = db.query(User).filter(
            (User.first_name.ilike(f"%{first_name_query}%")) & 
            (User.last_name.ilike(f"%{last_name_query}%"))
        ).all()
    else:
        users = []

    return [UserDataResponse.from_user(user) for user in users]


@user_router.get("/statistics/{user_id}", response_model=StatisticsResponse)
def get_statistics_for_user(user_id: int, db: Session = Depends(get_db)):
    try:
        statistics = get_statistics_for_user_service(user_id=user_id, db=db)
        return statistics
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
    

@user_router.get("/dealer_statistics/{dealer_id}", response_model=StatisticsResponse)
def get_statistics_for_dealer(dealer_id: int, db: Session = Depends(get_db)):
    try:
        statistics = get_statistics_for_dealer_service(dealer_id, db)
        return statistics
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=e)
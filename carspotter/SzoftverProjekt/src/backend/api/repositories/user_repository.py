from sqlalchemy import func
from sqlalchemy.orm import Session
from db.tables.models import Car, Followers, SoldCar, User,Favourite, OwnCar, Dealer
from api.models.request_models import UserUpdate,NewOwnCarRequest
from datetime import datetime

def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_dealer_id(db: Session, dealer_id: int):
    return db.query(User).filter(User.dealer_id == dealer_id).first()

def create_user(db: Session, user_data: dict):
    new_user = User(**user_data)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def get_favourite(db: Session, user_id: int, dealer_id: int = None):
    query = db.query(Favourite).filter(Favourite.user_id == user_id)
    if dealer_id:
        query = query.filter(Favourite.dealer_id == dealer_id)
    return query.first() if dealer_id else query.all()

def get_favourite_dealers_by_user(db: Session, user_id: int):
    return (
        db.query(Dealer)
        .join(Favourite, Dealer.id == Favourite.dealer_id)
        .filter(Favourite.user_id == user_id)
        .all()
    )

def add_favourite(db: Session, user_id: int, dealer_id: int):
    new_favourite = Favourite(user_id=user_id, dealer_id=dealer_id)
    db.add(new_favourite)
    db.commit()

def remove_favourite(db: Session, favourite: Favourite):
    db.delete(favourite)
    db.commit()


def get_own_cars_by_user(db: Session, user_id: int):
    return db.query(OwnCar).filter(OwnCar.user_id == user_id).all()

def update_own_car(db: Session, user_id: int, updated_own_car: NewOwnCarRequest, own_car_id: int):
    try:
        own_car = get_own_car_by_id(db, own_car_id).first()
        
        if not own_car or own_car.user_id != user_id:
            return {"message": "The car does not exist or does not belong to the user"}
        
        for key, value in updated_own_car.model_dump(exclude_unset=True).items():
            setattr(own_car, key, value)
        
        db.commit()
        db.refresh(own_car) 
        return {"message": "Car updated successfully", "car": own_car}
    
    except Exception as e:
        db.rollback()  # Rollback transaction on error
        return {"message": f"An error occurred: {str(e)}"}

def delete_own_car(db: Session, user_id: int, own_car_id: int):
    own_car = db.query(OwnCar).filter(OwnCar.id == own_car_id, OwnCar.user_id == user_id).first()
    if not own_car:
        return False 
    db.delete(own_car)
    db.commit()
    return True

def get_own_car_by_id(db: Session, car_id):
    return db.query(OwnCar).filter(OwnCar.id == car_id)

def update_user_repository(existing_user: User, user_data: UserUpdate, db: Session) -> User:
    existing_user.first_name = user_data.first_name
    existing_user.last_name = user_data.last_name
    existing_user.phone = user_data.phone
    existing_user.email = user_data.email

    db.commit()
    db.refresh(existing_user)
    return existing_user


def add_car_to_db(db: Session, user_id: int, car_data: NewOwnCarRequest) -> OwnCar:
    new_car = OwnCar(
        model=car_data.model,
        km=car_data.km,
        year=car_data.year,
        combustible=car_data.combustible,
        gearbox=car_data.gearbox,
        body_type=car_data.body_type,
        engine_size=car_data.engine_size,
        power=car_data.power,
        selling_for=car_data.selling_for,
        bought_for=car_data.bought_for,
        spent_on=car_data.spent_on,
        sold_for=car_data.sold_for,
        purchase_date=datetime.now().date(),
        img_url=car_data.img_url,
        user_id=user_id
    )
    db.add(new_car)
    db.commit()
    db.refresh(new_car) 
    return new_car

def add_following(user_id: int, followed_id: int, db: Session) -> Followers:
    following = Followers(
        follower_id=user_id,
        following_id=followed_id,
        date=datetime.now().date()
    )
    db.add(following)
    db.commit()
    db.refresh(following)
    return following

def get_following(user_id: int, db: Session):
    return (
        db.query(User)
        .join(Followers, Followers.following_id == User.id)
        .filter(Followers.follower_id == user_id)
        .all()
    )

def delete_following(user_id: int, following_id: int, db: Session):
    following = db.query(Followers).filter(
        Followers.follower_id == user_id, 
        Followers.following_id == following_id
    ).first()

    if not following:
        return None 
    db.delete(following)
    db.commit()
    return following  

def get_sold_cars_by_dealer_id(dealer_id: int, db: Session):
    return (
        db.query(Car)
        .join(SoldCar, SoldCar.car_id == Car.id)
        .filter(Car.dealer_id == dealer_id)
        .all()
    )

def is_followed(user_id: int, followed_id: int, db: Session) -> bool:
    result = db.query(Followers).filter(Followers.follower_id == user_id, Followers.following_id == followed_id).first()
    if result:
        return True
    return False

def sell_own_car(own_car_id: int, sell_for: float, db: Session):
    car = get_own_car_by_id(db, own_car_id).first()
    car.sold_for = sell_for
    db.commit()
    db.refresh(car)
    return car

def get_weekly_sales(user_id: int, start_of_previous_week: int, end_of_previous_week: int ,db: Session):
    return db.query(
        func.date(OwnCar.sold_date).label("day"),
        func.count(OwnCar.id).label("sold_count")
    ).filter(
        OwnCar.user_id == user_id,
        OwnCar.sold_date >= start_of_previous_week,
        OwnCar.sold_date <= end_of_previous_week
    ).group_by(func.date(OwnCar.sold_date)).all()

def get_monthly_sales(user_id: int, db: Session):
    today = datetime.now()
    first_day_of_current_year = today.replace(month=1, day=1)
    
    result = db.query(
        func.extract('month', OwnCar.sold_date).label("month"),
        func.count(OwnCar.id).label("sold_count")
    ).filter(
        OwnCar.user_id == user_id,
        OwnCar.sold_date >= first_day_of_current_year,
        OwnCar.sold_date <= today  
    ).group_by(func.extract('month', OwnCar.sold_date)).all()
    return result


def get_weekly_sales_dealer_cars(dealer_id: int, start_of_previous_week: int, end_of_previous_week: int ,db: Session):
    result =  db.query(
        func.date(SoldCar.sold_date).label("day"),
        func.count(SoldCar.id).label("sold_count")
    ).join(
        Car, Car.id == SoldCar.car_id
    ).filter(
        Car.dealer_id == dealer_id,
        SoldCar.sold_date >= start_of_previous_week,
        SoldCar.sold_date <= end_of_previous_week  
    ).group_by(func.date(SoldCar.sold_date)).all()
    return result

def get_monthly_sales_dealer_cars(dealer_id: int, db: Session):
    today = datetime.now()
    first_day_of_current_year = today.replace(month=1, day=1)
    result = db.query(
        func.extract('month', SoldCar.sold_date).label("month"),
        func.count(SoldCar.id).label("sold_count")
    ).join(
        Car, Car.id == SoldCar.car_id
    ).filter(
        Car.dealer_id == dealer_id,
        SoldCar.sold_date >= first_day_of_current_year,
        SoldCar.sold_date <= today  
    ).group_by(func.extract('month', SoldCar.sold_date)).all()
    return result
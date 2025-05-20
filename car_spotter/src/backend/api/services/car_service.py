from sqlalchemy.orm import Session
from api.repositories.dealer_car_repository import add_car, add_dealer, add_sold_car
from scraper.scripts.scrape_dealer_inventory import scrape_dealer_inventory
from db.tables.models import Car, Dealer, SoldCar
from sqlalchemy.sql import func

def insert_cars_and_dealer_by_dealer_name(db: Session, dealer_name: str):
    scraped_data = scrape_dealer_inventory(dealer_name)
    if type(scraped_data) == dict:
        raise ValueError(f"Error while scraping data: {scraped_data}")
    
    if not scraped_data:
        raise ValueError("No data retrieved from scraping.")
    
    car_list, dealer_data = scraped_data

    added_cars = 0  

    existing_dealer = db.query(Dealer).filter_by(inventory_name=dealer_data['inventory_name']).first()

    dealer = add_dealer(db, dealer_data['name'], dealer_data['inventory_name'], dealer_data['location'], dealer_data['active_since'], dealer_data['image_url'])

    if existing_dealer:
        existing_cars = db.query(Car).filter_by(dealer_id=dealer.id).all()
        existing_car_post_ids = {int(car.id_post) for car in existing_cars}
        incoming_car_post_ids = {int(car['id_post']) for car in car_list}
        sold_car_post_ids = existing_car_post_ids - incoming_car_post_ids

        for sold_car_post_id in sold_car_post_ids:
            car = db.query(Car).filter_by(id_post=sold_car_post_id).first()
            car_id = car.id
            price = car.price
            add_sold_car(db, car_id, price)

    for car_data in car_list:
        car_data['dealer_id'] = dealer.id

        existing_car = db.query(Car).filter_by(id_post=car_data['id_post']).first()
        if existing_car:
            continue
        if not car_data['km']:
            continue
        add_car(db, car_data)
        added_cars += 1

    return {
        "message": f"Dealer and associated cars processed.",
        "cars_added": added_cars,
        "total_scraped": len(car_list),
    }


def get_cars_and_dealer_by_dealer_name(db: Session, dealer_name: str):
    normalized_name = dealer_name.strip().lower().replace(" ", "")

    dealer = db.query(Dealer).filter(
        func.lower(func.replace(Dealer.name, " ", "")) == normalized_name
    or Dealer.inventory_name == normalized_name).first()

    if not dealer:
        insert_cars_and_dealer_by_dealer_name(db, dealer_name)
        dealer = db.query(Dealer).filter(
            func.lower(func.replace(Dealer.name, " ", "")) == normalized_name
        or Dealer.inventory_name == normalized_name).first()
        if not dealer:
            raise ValueError("Dealer not found.")

    cars = db.query(Car).filter_by(dealer_id=dealer.id).all()
    if not cars:
        raise ValueError(f"No cars found for dealer '{dealer_name}'.")
    
    sold_car_ids = [soldCar.car_id for soldCar in db.query(SoldCar)]
    cars = [car for car in cars if car.id not in sold_car_ids]

    return {
        "dealer": {
            "id": dealer.id,
            "name": dealer.name,
            "location": dealer.location,
            "active_since": dealer.active_since,
            "image_url": dealer.image_url,
        },
        "cars": [
            {
                "id": car.id,
                "model": car.model,
                "km": car.km,
                "year": car.year,
                "price": car.price,
                "combustible": car.combustible,
                "gearbox": car.gearbox,
                "body_type": car.body_type,
                "cylinder_capacity": car.cylinder_capacity,
                "power": car.power,
                "dateof_post": car.dateof_post,
                "id_post": car.id_post,
                "img_url": car.img_url,
            }
            for car in cars
        ]
    }

def get_cars_by_dealer_id(db: Session, dealer_id: int):

    cars = db.query(Car).filter_by(dealer_id=dealer_id).all()
    if not cars:
        raise ValueError(f"No cars found for dealer '{dealer_id}'.")
    
    sold_car_ids = [soldCar.car_id for soldCar in db.query(SoldCar)]
    cars = [car for car in cars if car.id not in sold_car_ids]
    return cars

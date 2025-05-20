from faker import Faker
from database import get_db
from tables.models import Dealer, User, Car
from sqlalchemy.orm import Session
import random
import datetime
import bcrypt

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed_password.decode('utf-8')

faker = Faker()

def generate_data(db: Session):
    for _ in range(10):  
        dealer = Dealer(
            name=faker.company(),
            inventory_name=faker.bs(),
            locality=faker.city(),
            active_since=str(faker.year()),
            image_url=faker.image_url()
        )
        db.add(dealer)
    db.commit()

    for _ in range(20):  

        plain_password = faker.password()
        hashed_password = hash_password(plain_password)

        user = User(
            first_name=faker.first_name(),
            last_name=faker.last_name(),
            dealer_id=random.randint(1, 10),  
            password= hashed_password, 
            email=faker.email(),
            phone=faker.random_number(digits=10, fix_len=True),
            profile_url=faker.image_url()
        )
        db.add(user)
    db.commit()

    for _ in range(50): 
        car = Car(
            model=faker.word(),
            km=random.uniform(5000, 200000),  
            year=random.randint(2000, 2023),  
            price=random.uniform(5000, 50000), 
            combustible=random.choice(["Petrol", "Diesel", "Electric"]),
            gearbox=random.choice(["Automatic", "Manual"]),
            body_type=random.choice(["SUV", "Sedan", "Hatchback", "Coupe"]),
            cylinder_capacity=random.randint(1000, 4000),
            power=random.randint(70, 300),
            dateof_post=faker.date_between(start_date="-2y", end_date="today"),
            id_post=faker.random_number(digits=6, fix_len=True),
            dealer_id=random.randint(1, 10),
            img_url=faker.image_url()
        )
        db.add(car)
    db.commit()

if __name__ == "__main__":
    db = next(get_db())
    generate_data(db)

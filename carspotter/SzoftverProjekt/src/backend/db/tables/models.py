from sqlalchemy import Column, String, Integer, BigInteger, Float, Date, LargeBinary, ForeignKey
from sqlalchemy.orm import relationship
from db.database import Base

class Dealer(Base):
    __tablename__ = 'Dealer'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    inventory_name = Column(String(255), nullable=True)  
    location = Column(String(255), nullable=True)        
    active_since = Column(String(255), nullable=True)     
    image_url = Column(String(255), nullable=True)     

    cars = relationship("Car", back_populates="dealer")
    favourites = relationship("Favourite", back_populates="dealer")


class User(Base):
    __tablename__ = 'User'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    first_name = Column(String(255), nullable=False)
    last_name = Column(String(255), nullable=False)
    dealer_id = Column(BigInteger, ForeignKey('Dealer.id'), nullable=True)
    password = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    phone = Column(String(20), nullable=False)
    profile_image_path = Column(String(255), nullable=True)

    favourites = relationship("Favourite", back_populates="user")
    own_cars = relationship("OwnCar", back_populates="user")
    app_logs = relationship("AppLog", back_populates="user")


class Car(Base):
    __tablename__ = 'Cars'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    model = Column(String(255), nullable=False)
    km = Column(BigInteger, nullable=False)
    year = Column(BigInteger, nullable=False)
    price = Column(Float, nullable=False)
    combustible = Column(String(255), nullable=False)
    gearbox = Column(String(255), nullable=False)
    body_type = Column(String(255), nullable=False)
    cylinder_capacity = Column(BigInteger, nullable=False)
    power = Column(BigInteger, nullable=False)
    dateof_post = Column(Date, nullable=False)
    id_post = Column(BigInteger, nullable=False)
    dealer_id = Column(BigInteger, ForeignKey('Dealer.id'), nullable=False)
    img_url = Column(String(500), nullable=False)

    dealer = relationship("Dealer", back_populates="cars")
    sold_cars = relationship("SoldCar", back_populates="car")


class SoldCar(Base):
    __tablename__ = 'SoldCars'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    car_id = Column(BigInteger, ForeignKey('Cars.id'), nullable=False)
    sold_date = Column(Date, nullable=False)
    sold_price = Column(Float, nullable=False)

    car = relationship("Car", back_populates="sold_cars")


class OwnCar(Base):
    __tablename__ = 'OwnCars'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    model = Column(String(255), nullable=False)
    km = Column(BigInteger, nullable=False)
    year = Column(BigInteger, nullable=False)
    combustible = Column(String(255), nullable=False)
    gearbox = Column(String(255), nullable=False)
    body_type = Column(String(255), nullable=False)
    engine_size = Column(BigInteger, nullable=False)
    power = Column(BigInteger, nullable=False)
    selling_for = Column(Float, nullable=False)
    bought_for = Column(Float, nullable=True)
    sold_for = Column(Float, nullable=True)
    spent_on = Column(Float, nullable=True)
    purchase_date = Column(Date, nullable=False)
    sold_date = Column(Date, nullable=True)
    img_url = Column(String(500), nullable=False)
    user_id = Column(BigInteger, ForeignKey('User.id'), nullable=False)

    user = relationship("User", back_populates="own_cars")


class AppLog(Base):
    __tablename__ = 'AppLogs'

    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(Date, nullable=False)
    user_id = Column(BigInteger, ForeignKey('User.id'), nullable=False)

    user = relationship("User", back_populates="app_logs")


class Favourite(Base):
    __tablename__ = 'Favourites'

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    dealer_id = Column(BigInteger, ForeignKey('Dealer.id'), nullable=False)
    user_id = Column(BigInteger, ForeignKey('User.id'), nullable=False)

    dealer = relationship("Dealer", back_populates="favourites")
    user = relationship("User", back_populates="favourites")

class Followers(Base):
    __tablename__ = 'Followers'

    id = id = Column(BigInteger, primary_key=True, autoincrement=True)
    follower_id = Column(BigInteger, ForeignKey('User.id'), nullable=False)
    following_id = Column(BigInteger, ForeignKey('User.id'), nullable=False)
    date = Column(Date, nullable=False)

    follower = relationship('User', foreign_keys=[follower_id])
    following = relationship('User', foreign_keys=[following_id])


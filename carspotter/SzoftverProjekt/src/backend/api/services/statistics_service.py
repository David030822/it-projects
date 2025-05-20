from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from api.repositories.user_repository import get_monthly_sales, get_monthly_sales_dealer_cars, get_user_by_id, get_weekly_sales, get_weekly_sales_dealer_cars
from api.repositories.dealer_car_repository import get_dealer_by_id
from db.tables.models import Car, Dealer, SoldCar

def calculate_sold_price_and_time_avereage(db: Session, dealer_name: str):
    dealer = db.query(Dealer).filter_by(name=dealer_name).first()
    if not dealer:
        raise ValueError(f"Dealer not found: '{dealer_name}'.")
    
    cars = (
        db.query(Car, SoldCar)
        .join(SoldCar, Car.id == SoldCar.car_id)
        .filter(Car.dealer_id == dealer.id)
        .all()
    )
    if not cars:
        return {"average_price": None, "average_sold_time": None, "number_of_solds": 0}
    
    total_price = 0
    number_of_solds = 0
    sold_time = 0
    for car, sold_car in cars:
        number_of_solds += 1
        total_price += sold_car.sold_price
        sold_time += (sold_car.sold_date - car.dateof_post).days
    
    average_price = total_price / number_of_solds if number_of_solds > 0 else 0
    average_sold_time = int(sold_time / number_of_solds)if number_of_solds > 0 else 0

    return {
        "average_price": average_price,
        "average_sold_time": average_sold_time,
        "number_of_solds": number_of_solds,
    }



def get_statistics_for_dealer_service(dealer_id: int ,db: Session):
    dealer = get_dealer_by_id(db, dealer_id)
    if not dealer: 
        raise ValueError(f"Dealer does not exist.")
    start_of_previous_week, end_of_previous_week = get_previous_week_dates()

    weekly_sales = get_weekly_sales_dealer_cars(dealer_id=dealer_id,
                                     start_of_previous_week=start_of_previous_week,
                                     end_of_previous_week=end_of_previous_week,
                                     db=db)
    monthly_sales = get_monthly_sales_dealer_cars(dealer_id=dealer_id,
                                      db=db)

    day_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

    weekly_sales_data = []
    for sale in weekly_sales:
        day_of_week = sale.day.weekday()
        day_name = day_names[day_of_week]  
        weekly_sales_data.append({"day": day_name, "sold_count": sale.sold_count})

    monthly_sales_data = []
    for sale in monthly_sales:
        month_num = int(sale.month)
        month_name = month_names[month_num - 1] 
        monthly_sales_data.append({"month": month_name, "sold_count": sale.sold_count})

    return {
        "weekly_sales": weekly_sales_data,
        "monthly_sales": monthly_sales_data
    }



def get_statistics_for_user_service(user_id: int ,db: Session):
    user = get_user_by_id(db, user_id= user_id)
    if not user: 
        raise ValueError(f"User does not exist.")
    start_of_previous_week, end_of_previous_week = get_previous_week_dates()

    weekly_sales = get_weekly_sales(user_id=user_id,
                                     start_of_previous_week=start_of_previous_week,
                                     end_of_previous_week=end_of_previous_week,
                                     db=db)
    monthly_sales = get_monthly_sales(user_id=user_id,
                                      db=db)

    day_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

    weekly_sales_data = []
    for sale in weekly_sales:
        day_of_week = sale.day.weekday()
        day_name = day_names[day_of_week]  
        weekly_sales_data.append({"day": day_name, "sold_count": sale.sold_count})

    monthly_sales_data = []
    for sale in monthly_sales:
        month_num = int(sale.month)
        month_name = month_names[month_num - 1] 
        monthly_sales_data.append({"month": month_name, "sold_count": sale.sold_count})

    return {
        "weekly_sales": weekly_sales_data,
        "monthly_sales": monthly_sales_data
    }

def get_previous_week_dates():
    today = datetime.now()
    start_of_week = today - timedelta(days=today.weekday())  
    start_of_previous_week = start_of_week - timedelta(weeks=1)  
    end_of_previous_week = start_of_previous_week + timedelta(days=6)  
    return start_of_previous_week, end_of_previous_week


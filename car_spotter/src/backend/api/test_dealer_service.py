from db.database import get_db
from api.services.car_service import insert_cars_and_dealer_by_dealer_name
from api.services.statistics_service import calculate_sold_price_and_time_avereage

def main():
 
    db = next(get_db())
    
    #dealer_name = "atp-exodus"
    dealer_name = "david bys cars"
    
    print(f"Processing dealer: {dealer_name}")
    result = insert_cars_and_dealer_by_dealer_name(db, dealer_name)
    #result = get_cars_and_dealer_by_dealer_name(db, dealer_name)
    #result = calculate_sold_price_and_time_avereage(db, "DAVID BYS CARS")
    print(result)

if __name__ == "__main__":
    main()
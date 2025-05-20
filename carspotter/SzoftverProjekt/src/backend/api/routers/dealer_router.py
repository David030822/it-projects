from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from api.services.car_service import insert_cars_and_dealer_by_dealer_name, get_cars_and_dealer_by_dealer_name, get_cars_by_dealer_id
from api.models.response_models import CarResponse
from db.database import get_db

dealer_router = APIRouter()

@dealer_router.post("/dealer/{dealer_name}/sync")
def sync_dealer_cars(dealer_name: str, db: Session = Depends(get_db)):
    try:
        result = insert_cars_and_dealer_by_dealer_name(db, dealer_name)
        return result
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")


@dealer_router.get("/dealer/{dealer_name}/cars")
def get_cars_by_dealer(dealer_name: str, db: Session = Depends(get_db)):
    try:
        result = get_cars_and_dealer_by_dealer_name(db, dealer_name)
        return result
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    

@dealer_router.get("/dealer_id/{dealer_id}/cars", response_model=List[CarResponse])
def get_cars_by_dealer(dealer_id: int, db: Session = Depends(get_db)):
    try:
        result = get_cars_by_dealer_id(db, dealer_id)
        return result
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    


    
    
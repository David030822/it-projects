import asyncio
from sqlalchemy.orm import Session
from db.database import SessionLocal
from api.services.car_service import insert_cars_and_dealer_by_dealer_name
from db.tables.models import Dealer

def insert_cars_and_dealer_by_dealer_name_sync(dealer_name: str, db: Session):
    return insert_cars_and_dealer_by_dealer_name(db, dealer_name)

async def insert_cars_and_dealer_by_dealer_name_async(dealer_name: str, db: Session):
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, insert_cars_and_dealer_by_dealer_name_sync, dealer_name, db)

async def process_dealers():
    print("Scheduled task started!")
    
    with SessionLocal() as db: 
        dealers = db.query(Dealer).all()
        for dealer in dealers:
            await insert_cars_and_dealer_by_dealer_name_async(dealer.inventory_name, db)
            print(f"Processing dealer: {dealer.inventory_name}")
    print("Scheduled task completed!")

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger

def start_scheduler():
    scheduler = AsyncIOScheduler()
    scheduler.add_job(
        process_dealers,
        trigger=IntervalTrigger(hours=24),
        id="process_dealers_task",
        replace_existing=True,
    )
    scheduler.start()
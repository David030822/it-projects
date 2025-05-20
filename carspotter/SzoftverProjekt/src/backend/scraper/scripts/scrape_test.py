import concurrent
import re
from datetime import datetime
import requests
from bs4 import BeautifulSoup
from concurrent.futures import ThreadPoolExecutor, as_completed
import time, random


HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
}

def fetch_car_details(car_link):

    time.sleep(random.uniform(1, 5))

    car_response = requests.get(car_link, headers=HEADERS)
    if car_response.status_code == 200:
        car_soup = BeautifulSoup(car_response.text, 'html.parser')
        price = car_soup.find('h3', class_='offer-price__number evnmei44 ooa-1kdys7g er34gjf0').text
        car_model = car_soup.find('h1', class_='offer-title big-text e12csvfg2 ooa-1dueukt er34gjf0').text.strip()

        details = car_soup.find_all('div', class_='ooa-1jqwucs ee3fiwr1')

        mileage = fuel_type = gearbox = body_type = engine_capacity = power = manufacturing_year = None

        if len(details) == 0:
            detail_elements = car_soup.find_all('div', class_='ooa-hiu112 eim4snj4')
            for item in detail_elements:
                children = item.find_all(recursive=False)
                text = children[0].text.strip()

                if "Anul producției" in text:
                    manufacturing_year = children[1].text.strip()

                if "Km" in text:
                    mileage = children[1].text.strip()

                if "Combustibil" in text:
                    fuel_type = children[1].text.strip()

                if "Cutie de viteze" in text:
                    gearbox = children[1].text.strip()

                if "Tip Caroserie" in text:
                    body_type = children[1].text.strip()

                if "Capacitate cilindrica" in text:
                    engine_capacity = children[1].text.strip()

                if "Putere" in text:
                    power = children[1].text.strip()
        else:
            mileage = details[0].find_all('p')[1].text.strip()
            fuel_type = details[1].find_all('p')[1].text.strip()
            gearbox = details[2].find_all('p')[1].text.strip()
            body_type = details[3].find_all('p')[1].text.strip()
            if len(details) == 6:
                engine_capacity = details[4].find_all('p')[1].text.strip()
                power = details[5].find_all('p')[1].text.strip()
            else:
                engine_capacity = None
                power = details[4].find_all('p')[1].text.strip()

            manufacturing_year_elements = car_soup.find_all('div', class_='ooa-162vy3d eyfqfx03')
            if len(manufacturing_year_elements) > 1:
                for item in manufacturing_year_elements:
                    children = item.find_all(recursive=False)
                    if "Anul producției" in children[0].text:
                        manufacturing_year = children[1].text.strip()
                        break
            else:
                year_text = car_soup.find('p', class_='e7ig7db0 ooa-1f1sue8').text.strip()
                year_match = re.search(r'\b\d{4}\b', year_text)
                if year_match:
                    manufacturing_year = year_match.group()

        post_date = car_soup.find('p', class_='e1jwj3576 ooa-193mje5').text.strip()
        post_id = car_soup.find('p', class_='e1n40z81 ooa-a4miog er34gjf0').text.strip()

        romanian_months = {
            'ianuarie': 'January', 'februarie': 'February', 'martie': 'March', 'aprilie': 'April',
            'mai': 'May', 'iunie': 'June', 'iulie': 'July', 'august': 'August', 'septembrie': 'September',
            'octombrie': 'October', 'noiembrie': 'November', 'decembrie': 'December'
        }

        for romanian, english in romanian_months.items():
            if romanian in post_date:
                post_date = post_date.replace(romanian, english)

        date_obj = datetime.strptime(post_date, "%d %B %Y la %H:%M")
        post_date = date_obj.strftime("%d.%m.%Y")

        post_id = re.findall(r'\d+', post_id)[0]
        images = car_soup.find('div', class_='ooa-12np8kw e142atj30').findChild('img')
        image_link = images['srcset'].split(" ")[0]
   
        return {
            'model': car_model,
            'year': manufacturing_year,
            'km': mileage,
            'combustible': fuel_type,
            'gearbox': gearbox,
            'body_type': body_type,
            'cylinder_capacity': engine_capacity,
            'power': power,
            'price': price,
            'dateof_post': post_date,
            'id_post': post_id,
            'img_url' : image_link
        }



def scrape_dealer_inventory(dealer_name, max_pages=None):
    dealer_name = dealer_name.lower()
    dealer_name = dealer_name.replace(" ", "")
    base_url = f'https://{dealer_name}.autovit.ro/inventory'
    
    car_list = []
    page = 1

    while True:
        url = f'{base_url}?page={page}'
        time.sleep(random.uniform(1, 5))

        response = requests.get(url, headers=HEADERS)

        if response.status_code == 200:
            try:
                soup = BeautifulSoup(response.text, 'html.parser')
                car_listings = soup.find_all('article', class_='ooa-c2v88x e1h1txg20')

                if page == 1:
                    dealer_info = soup.find_all('p', class_='ooa-tt0mq7 er34gjf0')
                    locality = dealer_info[0].text.strip()
                    since = dealer_info[1].text.strip()
                    since = since.split()[-1]

                    dealer_image_url = soup.find('img', class_='ooa-1buyf2q e1cm20ex1')['src']
                    d_name = soup.find('h1', class_='ewr9pr91 ooa-30flh9 er34gjf0').text.strip()

                if not car_listings:
                    print(f"No more cars found on page {page}.")
                    break

                car_links = [car.find('div', class_='ooa-1jlnwea e1h1txg22').find('a')['href'] for car in car_listings]


                max_workers = min(32, concurrent.futures.thread.ThreadPoolExecutor()._max_workers)
                with ThreadPoolExecutor(max_workers=max_workers) as executor:
                    futures = {executor.submit(fetch_car_details, link): link for link in car_links}

                    for future in as_completed(futures):
                        result = future.result()
                        if result:
                            car_list.append(result)

                page += 1

                if max_pages and page > max_pages:
                    print(f"Reached max page limit: {max_pages}")
                    break
            except Exception as e:
                return {'error': True, 'message': f"Failed to access dealer inventory"}
        else:
            print(f"Error accessing page {page}: {response.status_code}")
            return {'error': True, 'message': f"Failed to access page {page}. HTTP Status Code: {response.status_code}"}
        
    dealer_data = {
        'name': d_name,
        'inventory_name': dealer_name,
        'location': locality,
        'active_since': since,
        'image_url': dealer_image_url
    }
    if car_list:
        result = [car_list, dealer_data]
    else:
        result = None
    return result

# Példa használat
dealer_name = 'apaniasi'
# dealer_name = 'atp-exodus'

start_time = time.time()
scraped_data = scrape_dealer_inventory(dealer_name)
end_time = time.time()
if scraped_data:
    if type(scraped_data) == list:
        car_list, dealer_data = scraped_data

        print(f"Scraping completed in {end_time - start_time:.2f} seconds.")

        for i, car in enumerate(car_list, start=1):
            print(f"{i}. Car: {car['model']}, Price: {car['price']}, "
                f"Manufacturing Year: {car['year']}, Mileage: {car['km']}, "
                f"Fuel Type: {car['combustible']}, Gearbox: {car['gearbox']}, "
                f"Body Type: {car['body_type']}, Engine Capacity: {car['cylinder_capacity']}, "
                f"Power: {car['power']}, Post Date: {car['dateof_post']}, Post ID: {car['id_post']}, Image Link: {car['img_url']}")
            
        print(f"Name: {dealer_data['name']}, Inventory Name: {dealer_data['inventory_name']}, Locality: {dealer_data['location']}, Since: {dealer_data['active_since']}, Dealer image: {dealer_data['image_url']}")
    else:
        print(scraped_data)
else:
    print("No data found")
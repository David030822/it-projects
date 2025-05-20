CREATE TABLE Dealer (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE User (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    is_dealer BOOLEAN NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone BIGINT NOT NULL,
    profile_url VARCHAR(255) NOT NULL
);

CREATE TABLE Cars (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(255) NOT NULL,
    km FLOAT(53) NOT NULL,
    year BIGINT NOT NULL,
    price FLOAT(53) NOT NULL,
    combustible VARCHAR(255) NOT NULL,
    gearbox VARCHAR(255) NOT NULL,
    body_type VARCHAR(255) NOT NULL,
    cylinder_capacity BIGINT NOT NULL,
    power BIGINT NOT NULL,
    dateof_post DATE NOT NULL,
    id_post BIGINT NOT NULL,
    dealer_id BIGINT UNSIGNED NOT NULL, 
    img_url VARCHAR(255) NOT NULL,
    CONSTRAINT cars_dealer_id_foreign FOREIGN KEY(dealer_id) REFERENCES Dealer(id)
);

CREATE TABLE SoldCars (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    card_id BIGINT UNSIGNED NOT NULL, 
    sold_date DATE NOT NULL,
    sold_price FLOAT(53) NOT NULL,
    CONSTRAINT soldcars_card_id_foreign FOREIGN KEY(card_id) REFERENCES Cars(id)
);


CREATE TABLE OwnCars (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    car_id BIGINT UNSIGNED NOT NULL,  
    user_id BIGINT UNSIGNED NOT NULL,  
    purchase_date DATE NOT NULL,
    purchase_price FLOAT(53) NOT NULL,
    CONSTRAINT owncars_car_id_foreign FOREIGN KEY(car_id) REFERENCES Cars(id),
    CONSTRAINT owncars_user_id_foreign FOREIGN KEY(user_id) REFERENCES User(id)
);

CREATE TABLE AppLogs (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL, 
    CONSTRAINT applogs_user_id_foreign FOREIGN KEY(user_id) REFERENCES User(id)
);

CREATE TABLE Favourites (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    car_id BIGINT UNSIGNED NOT NULL, 
    user_id BIGINT UNSIGNED NULL, 
    CONSTRAINT favourites_car_id_foreign FOREIGN KEY(car_id) REFERENCES Cars(id),
    CONSTRAINT favourites_user_id_foreign FOREIGN KEY(user_id) REFERENCES User(id)
);


CREATE TABLE AppDevices (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    registered DATE NOT NULL,
    used BIGINT NOT NULL,
    lastUsage DATE NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,  
    CONSTRAINT appdevices_user_id_foreign FOREIGN KEY(user_id) REFERENCES User(id)
);
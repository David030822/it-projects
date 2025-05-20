CREATE TABLE `User`(
    `first_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL,
    `id` BIGINT NOT NULL,
    `dealer_id` BIGINT NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `phone` BIGINT NOT NULL,
    `profile_image` BINARY(16) NOT NULL,
    PRIMARY KEY(`id`)
);
CREATE TABLE `Cars`(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `model` VARCHAR(255) NOT NULL,
    `km` FLOAT(53) NOT NULL,
    `year` BIGINT NOT NULL,
    `price` FLOAT(53) NOT NULL,
    `combustible` VARCHAR(255) NOT NULL,
    `gearbox` VARCHAR(255) NOT NULL,
    `body_type` VARCHAR(255) NOT NULL,
    `cylinder_capacity` BIGINT NOT NULL,
    `power` BIGINT NOT NULL,
    `dateof_post` DATE NOT NULL,
    `id_post` BIGINT NOT NULL,
    `dealer_id` BIGINT NOT NULL,
    `img_url` VARCHAR(255) NOT NULL
);
ALTER TABLE
    `Cars` ADD UNIQUE `cars_dealer_id_unique`(`dealer_id`);
CREATE TABLE `AppLogs`(
    `id` INT NOT NULL,
    `date` DATE NOT NULL,
    `user_id` BIGINT NOT NULL,
    PRIMARY KEY(`id`)
);
ALTER TABLE
    `AppLogs` ADD UNIQUE `applogs_user_id_unique`(`user_id`);
CREATE TABLE `Favourites`(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `dealer_id` BIGINT NOT NULL,
    `user_id` BIGINT NULL
);
ALTER TABLE
    `Favourites` ADD INDEX `favourites_dealer_id_user_id_index`(`dealer_id`, `user_id`);
ALTER TABLE
    `Favourites` ADD UNIQUE `favourites_dealer_id_unique`(`dealer_id`);
ALTER TABLE
    `Favourites` ADD UNIQUE `favourites_user_id_unique`(`user_id`);
CREATE TABLE `OwnCars`(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `model` VARCHAR(255) NOT NULL,
    `user_id` BIGINT NOT NULL,
    `purchase_date` DATE NOT NULL,
    `purchase_price` FLOAT(53) NOT NULL,
    `year` BIGINT NOT NULL,
    `cilynder_capacity` BIGINT NOT NULL,
    `combustible` VARCHAR(255) NOT NULL,
    `gearbox` VARCHAR(255) NOT NULL,
    `body_type` VARCHAR(255) NOT NULL,
    `power` BIGINT NOT NULL,
    `car_image` BINARY(16) NOT NULL
);
ALTER TABLE
    `OwnCars` ADD UNIQUE `owncars_user_id_unique`(`user_id`);
CREATE TABLE `SoldCars`(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `car_id` BIGINT NOT NULL,
    `sold_date` DATE NOT NULL,
    `sold_price` FLOAT(53) NOT NULL
);
ALTER TABLE
    `SoldCars` ADD UNIQUE `soldcars_car_id_unique`(`car_id`);
CREATE TABLE `Dealer`(
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `inventory_name` VARCHAR(255) NOT NULL,
    `locality` VARCHAR(255) NOT NULL,
    `active_since` DATE NOT NULL,
    `image_url` VARCHAR(255) NOT NULL
);
CREATE TABLE `Followers`(
    `friend_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `date` DATE NOT NULL,
    `id` BIGINT NOT NULL,
    PRIMARY KEY(`id`)
);
ALTER TABLE
    `Followers` ADD UNIQUE `followers_user_id_unique`(`user_id`);
ALTER TABLE
    `Favourites` ADD CONSTRAINT `favourites_dealer_id_foreign` FOREIGN KEY(`dealer_id`) REFERENCES `Cars`(`id`);
ALTER TABLE
    `Favourites` ADD CONSTRAINT `favourites_user_id_foreign` FOREIGN KEY(`user_id`) REFERENCES `User`(`id`);
ALTER TABLE
    `User` ADD CONSTRAINT `user_dealer_id_foreign` FOREIGN KEY(`dealer_id`) REFERENCES `Dealer`(`id`);
ALTER TABLE
    `Followers` ADD CONSTRAINT `followers_friend_id_foreign` FOREIGN KEY(`friend_id`) REFERENCES `User`(`id`);
ALTER TABLE
    `OwnCars` ADD CONSTRAINT `owncars_user_id_foreign` FOREIGN KEY(`user_id`) REFERENCES `User`(`id`);
ALTER TABLE
    `SoldCars` ADD CONSTRAINT `soldcars_car_id_foreign` FOREIGN KEY(`car_id`) REFERENCES `Cars`(`id`);
ALTER TABLE
    `Cars` ADD CONSTRAINT `cars_dealer_id_foreign` FOREIGN KEY(`dealer_id`) REFERENCES `Dealer`(`id`);
ALTER TABLE
    `Followers` ADD CONSTRAINT `followers_user_id_foreign` FOREIGN KEY(`user_id`) REFERENCES `User`(`id`);
ALTER TABLE
    `User` ADD CONSTRAINT `user_id_foreign` FOREIGN KEY(`id`) REFERENCES `AppLogs`(`id`);
ALTER TABLE
    `Favourites` ADD CONSTRAINT `favourites_dealer_id_foreign` FOREIGN KEY(`dealer_id`) REFERENCES `Dealer`(`id`);
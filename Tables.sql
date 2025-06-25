CREATE DATABASE Hotels_Around_Bulgaria;
USE Hotels_Around_Bulgaria;

CREATE TABLE Hotels(
hotel_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(255) NOT NULL,
city VARCHAR(255) NOT NULL,
rating DECIMAL(2,1) CHECK (rating BETWEEN 1.0 AND 5.0)
);

CREATE TABLE Rooms(
room_id INT PRIMARY KEY AUTO_INCREMENT,
hotel_id INT NOT NULL,
room_type varchar(255) NOT NULL,
price_per_night DECIMAL(10,2) NOT NULL,
status ENUM('Available', 'Reserved') NOT NULL DEFAULT 'Available',

CONSTRAINT fk_Hotel_id
FOREIGN KEY (hotel_id)
REFERENCES Hotels(hotel_id)
);

CREATE TABLE Guests(
guest_id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(255) NOT NULL UNIQUE,
UCN VARCHAR(10) NOT NULL UNIQUE CHECK (LENGTH(UCN) = 9)
);

CREATE TABLE Bookings(
booking_id INT PRIMARY KEY AUTO_INCREMENT,
customer_id INT NOT NULL,
room_id INT NOT NULL,
check_in DATE NOT NULL,
check_out DATE NOT NULL,
phone_number VARCHAR(10) NOT NULL UNIQUE CHECK (LENGTH(phone_number) = 10),

CONSTRAINT fk_Reservor_id
FOREIGN KEY (customer_id)
REFERENCES Guests(guest_id),

CONSTRAINT fk_Room_id
FOREIGN KEY (room_id)
REFERENCES Rooms(room_id)
);

CREATE TABLE Bookings_guests(
booking_id INT NOT NULL,
guest_id INT NOT NULL,

CONSTRAINT fk_Booking_id
FOREIGN KEY (booking_id)
REFERENCES Bookings(booking_id),

CONSTRAINT fk_Guest_id
FOREIGN KEY (guest_id)
REFERENCES Guests(guest_id),

PRIMARY KEY (booking_id, guest_id)
);

CREATE TABLE Services(
service_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders(
booking_id INT NOT NULL,
service_id INT NOT NULL,

CONSTRAINT fr_bookings_services_booking
FOREIGN KEY (booking_id)
REFERENCES Bookings(booking_id),

CONSTRAINT fr_bookings_services_service
FOREIGN KEY (service_id)
REFERENCES Services(service_id),

PRIMARY KEY (booking_id, service_id)
);

CREATE TABLE service_hotel(
service_id INT NOT NULL,
hotel_id INT NOT NULL,

CONSTRAINT fk_service_hotel_service
FOREIGN KEY (service_id)
REFERENCES Services(service_id),

CONSTRAINT fk_service_hotel_hotel
FOREIGN KEY (hotel_id)
REFERENCES Hotels(hotel_id),

PRIMARY KEY (service_id, hotel_id)
);

DELIMITER $$
CREATE TRIGGER before_insert_check_if_service_is_at_the_hotel
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE new_hotel_id INT;
    SELECT r.hotel_id INTO new_hotel_id
    FROM Bookings b
    JOIN Rooms r ON b.room_id = r.room_id
    WHERE b.booking_id = NEW.booking_id;

    IF NEW.service_id NOT IN (SELECT sh.service_id 
                              FROM service_hotel sh
                              WHERE sh.hotel_id = new_hotel_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Service not available in the hotel';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER before_booking_insert
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF (SELECT status FROM Rooms r WHERE r.room_id = NEW.room_id) <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is not available for booking';
    END IF;

    UPDATE Rooms r
    SET status = 'Reserved'
    WHERE r.room_id = NEW.room_id;
END;
$$

DELIMITER $$
CREATE TRIGGER after_booking_delete
AFTER DELETE ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Rooms r
    SET status = 'Available'
    WHERE r.room_id = OLD.room_id;
END;
$$
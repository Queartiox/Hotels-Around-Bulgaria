USE Hotels_Around_Bulgaria;

-- 1. Топ 10 хотели с най-много рейтинг
SELECT Name, Rating
FROM hotels
ORDER BY rating DESC
LIMIT 10;

-- 2. Всички хотели в даден град (Пример: Варна)
SELECT Name, City 
FROM hotels
WHERE city = 'Varna'
ORDER BY name ASC;

-- 3. Всички 'Available' стаи
SELECT room_id AS Room, Room_type, Status 
FROM rooms
WHERE status = 'Available'
ORDER BY room_id ASC;

-- 4. Всички хора с дадено първо име (пример: Георги)
SELECT First_name, Last_name
FROM Guests
WHERE first_name LIKE 'Георги%';

-- 5. Всички стаи с нощувка над 200 лева
SELECT room_id AS Room, Room_type, Price_per_night, h.name AS 'Hotel name', h.city AS 'City' 
FROM rooms r
JOIN Hotels h ON r.hotel_id = h.hotel_id
WHERE price_per_night > 200 
ORDER BY price_per_night DESC;

-- 6. Всички услуги за хотели
SELECT  sh.hotel_id AS HotelID, 
		h.name AS Name, 
        GROUP_CONCAT(service_id SEPARATOR ' , ') AS Services 
FROM service_hotel sh
JOIN Hotels h ON sh.hotel_id = h.hotel_id
GROUP BY sh.hotel_id;

-- 7. Месецът на всяка една резервация
SELECT booking_id AS Reservation,
        CONCAT(g.first_name, ' ', g.last_name) AS Reserver, 
        MONTHNAME(b.check_in) AS MonthOfReservation 
FROM Bookings b
JOIN Guests g ON b.customer_id = g.guest_id
ORDER BY booking_id ASC;

-- 8. Всички резервации с услиуга
SELECT b.booking_id AS Reservation, GROUP_CONCAT(s.name SEPARATOR ', ') AS Services
FROM bookings b 
LEFT JOIN orders o ON o.booking_id = b.booking_id
JOIN services s ON s.service_id = o.service_id
GROUP BY o.booking_id
ORDER BY b.booking_id ASC;

-- 9. Услуги и гостите, които ги използват
SELECT 
    s.name AS Services,
    GROUP_CONCAT(DISTINCT g.guest_id ORDER BY g.guest_id ASC SEPARATOR ' , ') AS Guests
FROM guests g
JOIN Bookings b ON g.guest_id = b.customer_id
JOIN orders o ON o.booking_id = b.booking_id
JOIN Services s ON o.service_id = s.service_id
GROUP BY s.name
ORDER BY s.name ASC;


-- 10. Всички хора в резервация
SELECT 
    b.booking_id AS Reservation, 
    CONCAT(c.first_name, ' ', c.last_name) AS Reserver, 
    GROUP_CONCAT(CONCAT(g.first_name, ' ', g.last_name) SEPARATOR ', ') AS Reservation_members
FROM bookings b
JOIN bookings_guests bg ON bg.booking_id = b.booking_id
JOIN guests g ON g.guest_id = bg.guest_id
JOIN guests c ON c.guest_id = b.customer_id
GROUP BY b.booking_id;

-- 11. Обща цена на резервация
SELECT 
    b.booking_id AS Reservation, 
    DATEDIFF(b.check_out, b.check_in) * r.price_per_night * bg.guest_count + o.service_price AS Total_price
FROM bookings b

JOIN rooms r ON r.room_id = b.room_id

JOIN (
SELECT booking_id, COUNT(guest_id) + 1 AS guest_count
FROM bookings_guests
GROUP BY booking_id
) bg ON bg.booking_id = b.booking_id

JOIN (
SELECT booking_id, SUM(s.price) AS service_price
FROM orders o
JOIN services s ON s.service_id = o.service_id
group by o.booking_id
order by o.booking_id
) o ON o.booking_id = b.booking_id

ORDER BY b.booking_id ASC;

-- 12. Гости в хотели с рейтинг по-голям от 4.0
SELECT  b.booking_id AS Reservation, 
        h.hotel_id AS Hotel,
        h.Rating,
        CONCAT(c.first_name, ' ', c.last_name) AS Reserver, 
        GROUP_CONCAT(CONCAT(g.first_name, ' ', g.last_name) SEPARATOR ', ') AS Reservation_members
FROM bookings b
JOIN bookings_guests bg ON bg.booking_id = b.booking_id 
JOIN guests g ON g.guest_id = bg.guest_id 
JOIN guests c ON c.guest_id = b.customer_id 
JOIN Rooms r ON b.room_id = r.room_id
JOIN Hotels h ON r.hotel_id = h.hotel_id
WHERE h.rating > 4.0
GROUP BY b.booking_id
ORDER BY h.rating DESC;


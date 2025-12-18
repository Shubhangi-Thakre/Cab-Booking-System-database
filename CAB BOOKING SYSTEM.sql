CREATE DATABASE cab_booking;
USE cab_booking;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    phone VARCHAR(15),
    signup_date DATE
);

CREATE TABLE Drivers (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(50),
    vehicle_type VARCHAR(20),
    joining_date DATE
);

CREATE TABLE Cabs (
    cab_id INT PRIMARY KEY,
    driver_id INT,
    vehicle_model VARCHAR(50),
    vehicle_number VARCHAR(20),
    FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    customer_id INT,
    cab_id INT,
    booking_datetime DATETIME,
    pickup_location VARCHAR(50),
    drop_location VARCHAR(50),
    status VARCHAR(20), -- Completed, Cancelled, Ongoing
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (cab_id) REFERENCES Cabs(cab_id)
);

CREATE TABLE TripDetails (
    trip_id INT PRIMARY KEY,
    booking_id INT,
    trip_start DATETIME,
    trip_end DATETIME,
    distance_km DECIMAL(5,2),
    fare DECIMAL(10,2),
    driver_rating DECIMAL(2,1),
    waiting_minutes INT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY,
    booking_id INT,
    customer_id INT,
    cancellation_reason VARCHAR(100),
    comments VARCHAR(200),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Customers VALUES
(1, 'Aditi', '9876543210', '2024-01-10'),
(2, 'Rahul', '9090909090', '2024-02-05'),
(3, 'Priya', '8888888888', '2024-02-20'),
(4, 'Sanjay', '7777777777', '2024-03-01'),
(5, 'Meera', '9898989898', '2024-03-18');


INSERT INTO Drivers VALUES
(1, 'Vikram', 'Sedan', '2023-01-01'),
(2, 'Aman', 'SUV', '2023-05-12'),
(3, 'John', 'Sedan', '2023-06-25'),
(4, 'Sumit', 'Mini', '2024-01-09'),
(5, 'Tara', 'SUV', '2024-02-15');

INSERT INTO Cabs VALUES
(1, 1, 'Honda City', 'MH12AB1111'),
(2, 2, 'Toyota Fortuner', 'MH12CD2222'),
(3, 3, 'Hyundai Verna', 'MH12EF3333'),
(4, 4, 'Tata Tiago', 'MH12GH4444'),
(5, 5, 'Mahindra XUV', 'MH12IJ5555');

INSERT INTO Bookings VALUES
(1, 1, 1, '2025-01-10 09:00', 'Baner', 'Hinjewadi', 'Completed'),
(2, 1, 3, '2025-01-15 18:00', 'Hinjewadi', 'Kothrud', 'Cancelled'),
(3, 2, 2, '2025-01-12 08:00', 'Balewadi', 'Viman Nagar', 'Completed'),
(4, 3, 4, '2025-01-14 20:00', 'Baner', 'Aundh', 'Completed'),
(5, 4, 5, '2025-01-18 11:00', 'Hinjewadi', 'Wakad', 'Cancelled'),
(6, 5, 2, '2025-01-20 14:00', 'Aundh', 'Baner', 'Completed'),
(7, 5, 1, '2025-01-21 10:00', 'Baner', 'Viman Nagar', 'Completed');


INSERT INTO TripDetails VALUES
(1, 1, '2025-01-10 09:05', '2025-01-10 09:35', 12.5, 250, 4.5, 5),
(2, 3, '2025-01-12 08:05', '2025-01-12 08:55', 18.0, 400, 4.0, 5),
(3, 4, '2025-01-14 20:10', '2025-01-14 20:25', 5.2, 120, 3.2, 10),
(4, 6, '2025-01-20 14:05', '2025-01-20 14:25', 4.0, 95, 4.9, 5),
(5, 7, '2025-01-21 10:10', '2025-01-21 10:55', 16.0, 380, 5.0, 10);

INSERT INTO Feedback VALUES
(1, 2, 1, 'Driver not arriving', 'Cancelled due to delay'),
(2, 5, 4, 'Change of plans', 'No longer needed'),
(3, 4, 3, NULL, 'Smooth ride');

--  Identify customers who have completed the most bookings. What insights can you draw about their behavior?

SELECT c.customer_name,COUNT(*) AS completed_bookings
FROM Bookings b JOIN Customers c 
    ON b.customer_id = c.customer_id
WHERE b.status = 'Completed'
GROUP BY c.customer_id, c.customer_name;
 



-- 2.	Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations?
-- 3.	Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days?

SELECT c.customer_name,
       SUM(b.status='Cancelled') * 100 / COUNT(*) AS cancel_percentage
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING cancel_percentage > 30;


SELECT DAYNAME(booking_datetime) AS day_name,
       COUNT(*) AS total_bookings
FROM Bookings
GROUP BY day_name
ORDER BY total_bookings DESC;


-- 1.	Find the top 5 drivers who have completed the longest trips in terms of distance. What does this say about their working patterns?
-- 2.	Identify drivers with a high percentage of canceled trips. Could this indicate driver unreliability?

SELECT d.driver_name, MAX(t.distance_km) AS longest_trip
FROM TripDetails t
JOIN Bookings b ON t.booking_id = b.booking_id
JOIN Cabs c ON b.cab_id = c.cab_id
JOIN Drivers d ON c.driver_id = d.driver_id
GROUP BY d.driver_id
ORDER BY longest_trip DESC
LIMIT 1;


SELECT d.driver_name,
       SUM(b.status='Cancelled') * 100 / COUNT(*) AS cancel_rate
FROM Bookings b
JOIN Cabs c ON b.cab_id = c.cab_id
JOIN Drivers d ON c.driver_id = d.driver_id
GROUP BY d.driver_id
HAVING cancel_rate > 20;



-- Revenue & Business Metrics
-- 1 .	Identify the top 3 most frequently traveled routes based on PickupLocation and DropoffLocation. Should the company allocate more cabs to these routes?
-- 2.	Determine if higher-rated drivers tend to complete more trips and earn higher fares. Is there a direct correlation between driver ratings and earnings?

SELECT pickup_location, drop_location, COUNT(*) AS total_trips
FROM Bookings
WHERE status='Completed'
GROUP BY pickup_location, drop_location
ORDER BY total_trips DESC
LIMIT 3;

SELECT d.driver_name,
       AVG(t.driver_rating) AS avg_rating,SUM(t.fare) AS total_earnings,COUNT(*) AS trips
FROM TripDetails t
JOIN Bookings b ON t.booking_id = b.booking_id
JOIN Cabs c ON b.cab_id = c.cab_id
JOIN Drivers d ON d.driver_id = c.driver_id
GROUP BY d.driver_id
ORDER BY avg_rating DESC;






-- 1. Create Railway Booking Table
CREATE TABLE RailwayBooking (
    BookingID INT PRIMARY KEY,
    PassengerName VARCHAR(50),
    TrainNumber INT,
    SourceStation VARCHAR(50),
    DestinationStation VARCHAR(50),
    TravelDate DATE,
    SeatNumber INT,
    Class VARCHAR(20),
    Fare DECIMAL(10,2)
);

-- 2. Insert Sample Records (Note: Populate with at least 5,000 records for testing)
INSERT INTO RailwayBooking
(BookingID, PassengerName, TrainNumber, SourceStation, DestinationStation, TravelDate, SeatNumber, Class, Fare)
VALUES
(1, 'Aman', 12001, 'Delhi', 'Lucknow', '2026-11-01', 1, 'AC', 1500),
(2, 'Riya', 12002, 'Kanpur', 'Delhi', '2026-11-02', 2, 'Sleeper', 800),
(3, 'Rahul', 12003, 'Lucknow', 'Kanpur', '2026-11-03', 3, 'AC', 1000);

SELECT COUNT(*) AS TotalBookings FROM RailwayBooking;
SELECT * FROM RailwayBooking LIMIT 10;

-- 3. Query & EXPLAIN Before Indexing
SELECT *
FROM RailwayBooking
WHERE PassengerName = 'Aman';

EXPLAIN
SELECT *
FROM RailwayBooking
WHERE PassengerName = 'Aman';

-- 4. Single-Column Index Creation & Analysis
CREATE INDEX idx_passenger_name
ON RailwayBooking (PassengerName);

SHOW INDEX FROM RailwayBooking;

SELECT *
FROM RailwayBooking
WHERE PassengerName = 'Aman';

EXPLAIN
SELECT *
FROM RailwayBooking
WHERE PassengerName = 'Aman';

-- 5. Composite Index Creation & Analysis
CREATE INDEX idx_route
ON RailwayBooking (SourceStation, DestinationStation);

SELECT *
FROM RailwayBooking
WHERE SourceStation = 'Delhi'
  AND DestinationStation = 'Lucknow';

EXPLAIN
SELECT *
FROM RailwayBooking
WHERE SourceStation = 'Delhi'
  AND DestinationStation = 'Lucknow';

-- 6. Cleanup (Drop Indexes)
DROP INDEX idx_passenger_name ON RailwayBooking;
DROP INDEX idx_route ON RailwayBooking;
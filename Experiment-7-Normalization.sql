
-- EXPERIMENT 7
-- Normalization of Sales Table from UNF to 3NF and BCNF
-- MySQL 8.0+
-- Database: dbms_exp7

CREATE DATABASE IF NOT EXISTS dbms_exp7;
USE dbms_exp7;

-- Reset tables so the script can be run more than once.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Salespersons;
DROP TABLE IF EXISTS Sales_1NF;
DROP TABLE IF EXISTS Sales_UNF;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Create the denormalized sales table (UNF)
CREATE TABLE Sales_UNF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(50),
    ProductID INT,
    ProductName VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    SalespersonID INT,
    SalespersonName VARCHAR(50)
);

-- 2. Insert sample data
INSERT INTO Sales_UNF
    (OrderID, OrderDate, CustomerID, CustomerName, ProductID,
     ProductName, Quantity, UnitPrice, SalespersonID, SalespersonName)
VALUES
    (1, '2026-01-10', 101, 'Aman', 201, 'Laptop', 1, 50000.00, 301, 'Rahul'),
    (1, '2026-01-10', 101, 'Aman', 202, 'Mouse', 2, 500.00, 301, 'Rahul'),
    (2, '2026-01-11', 102, 'Priya', 203, 'Keyboard', 1, 1500.00, 302, 'Neha'),
    (3, '2026-01-12', 103, 'Rohan', 201, 'Laptop', 1, 50000.00, 301, 'Rahul'),
    (4, '2026-01-13', 101, 'Aman', 202, 'Mouse', 2, 500.00, 303, 'Amit'),
    (5, '2026-01-14', 104, 'Sneha', 204, 'Monitor', 1, 20000.00, 302, 'Neha');

-- Display the original table
SELECT * FROM Sales_UNF;

-- Functional Dependencies:
-- OrderID -> OrderDate, CustomerID, SalespersonID
-- CustomerID -> CustomerName
-- ProductID -> ProductName, UnitPrice
-- SalespersonID -> SalespersonName
-- (OrderID, ProductID) -> Quantity

-- 3. Convert to 1NF
CREATE TABLE Sales_1NF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(50),
    ProductID INT,
    ProductName VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    SalespersonID INT,
    SalespersonName VARCHAR(50),
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF
SELECT * FROM Sales_UNF;

SELECT * FROM Sales_1NF;

-- 4. Convert to 2NF
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(50),
    SalespersonID INT,
    SalespersonName VARCHAR(50)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Orders
    (OrderID, OrderDate, CustomerID, CustomerName, SalespersonID, SalespersonName)
SELECT DISTINCT
    OrderID, OrderDate, CustomerID, CustomerName, SalespersonID, SalespersonName
FROM Sales_1NF;

INSERT INTO Products (ProductID, ProductName, UnitPrice)
SELECT DISTINCT ProductID, ProductName, UnitPrice
FROM Sales_1NF;

INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
SELECT OrderID, ProductID, Quantity
FROM Sales_1NF;

SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM OrderDetails;

-- 5. Convert to 3NF / BCNF
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50) NOT NULL
);

CREATE TABLE Salespersons (
    SalespersonID INT PRIMARY KEY,
    SalespersonName VARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    SalespersonID INT NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_orders_salesperson
        FOREIGN KEY (SalespersonID) REFERENCES Salespersons(SalespersonID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);

CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT fk_details_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT fk_details_product
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert normalized data
INSERT INTO Customers (CustomerID, CustomerName)
SELECT DISTINCT CustomerID, CustomerName
FROM Sales_1NF;

INSERT INTO Salespersons (SalespersonID, SalespersonName)
SELECT DISTINCT SalespersonID, SalespersonName
FROM Sales_1NF;

INSERT INTO Orders (OrderID, OrderDate, CustomerID, SalespersonID)
SELECT DISTINCT OrderID, OrderDate, CustomerID, SalespersonID
FROM Sales_1NF;

INSERT INTO Products (ProductID, ProductName, UnitPrice)
SELECT DISTINCT ProductID, ProductName, UnitPrice
FROM Sales_1NF;

INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
SELECT OrderID, ProductID, Quantity
FROM Sales_1NF;

-- 6. Verify normalized tables
SELECT * FROM Customers;
SELECT * FROM Salespersons;
SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM OrderDetails;

-- 7. Verify lossless join
SELECT
    O.OrderID,
    O.OrderDate,
    C.CustomerID,
    C.CustomerName,
    P.ProductID,
    P.ProductName,
    OD.Quantity,
    P.UnitPrice,
    S.SalespersonID,
    S.SalespersonName
FROM Orders AS O
JOIN Customers AS C ON O.CustomerID = C.CustomerID
JOIN Salespersons AS S ON O.SalespersonID = S.SalespersonID
JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID
JOIN Products AS P ON OD.ProductID = P.ProductID
ORDER BY O.OrderID, P.ProductID;

-- 8. Check dependency consistency
SELECT CustomerID
FROM Customers
GROUP BY CustomerID
HAVING COUNT(DISTINCT CustomerName) > 1;

SELECT ProductID
FROM Products
GROUP BY ProductID
HAVING COUNT(DISTINCT ProductName) > 1;

SELECT SalespersonID
FROM Salespersons
GROUP BY SalespersonID
HAVING COUNT(DISTINCT SalespersonName) > 1;

-- 9. Inspect primary and foreign keys
SHOW KEYS FROM Customers;
SHOW KEYS FROM Salespersons;
SHOW KEYS FROM Orders;
SHOW KEYS FROM Products;
SHOW KEYS FROM OrderDetails;

-- Expected Result:
-- Sales data is divided into five normalized tables.
-- The final JOIN reconstructs the original six order-line records.

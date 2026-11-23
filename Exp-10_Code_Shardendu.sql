-- 1. Create Database & Table
CREATE DATABASE QueryOptimizationDB;
USE QueryOptimizationDB;

CREATE TABLE EmployeeSales (
    SaleID INT PRIMARY KEY,
    EmployeeID INT,
    EmployeeName VARCHAR(50),
    Department VARCHAR(30),
    City VARCHAR(30),
    Product VARCHAR(50),
    SaleAmount DECIMAL(10,2),
    SaleDate DATE
);

-- 2. Generate Dataset with 10,000 Rows Using Recursive CTE
INSERT INTO EmployeeSales
(SaleID, EmployeeID, EmployeeName, Department, City, Product, SaleAmount, SaleDate)
WITH RECURSIVE Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 10000
)
SELECT
    n AS SaleID,
    ((n - 1) % 100) + 1 AS EmployeeID,
    CONCAT('Employee_', ((n - 1) % 100) + 1) AS EmployeeName,
    CASE
        WHEN n % 5 = 0 THEN 'IT'
        WHEN n % 5 = 1 THEN 'HR'
        WHEN n % 5 = 2 THEN 'Sales'
        WHEN n % 5 = 3 THEN 'Finance'
        ELSE 'Marketing'
    END AS Department,
    CASE
        WHEN n % 5 = 0 THEN 'Delhi'
        WHEN n % 5 = 1 THEN 'Lucknow'
        WHEN n % 5 = 2 THEN 'Kanpur'
        WHEN n % 5 = 3 THEN 'Mumbai'
        ELSE 'Pune'
    END AS City,
    CASE
        WHEN n % 4 = 0 THEN 'Laptop'
        WHEN n % 4 = 1 THEN 'Mobile'
        WHEN n % 4 = 2 THEN 'Tablet'
        ELSE 'Monitor'
    END AS Product,
    (500 + (n % 5000)) AS SaleAmount,
    DATE_ADD('2025-01-01', INTERVAL (n % 365) DAY) AS SaleDate
FROM Numbers;

SELECT COUNT(*) AS TotalRecords FROM EmployeeSales;
SELECT * FROM EmployeeSales LIMIT 10;

-- 3. Case 1: Searching by Employee Name (Single Index)
-- Before Optimization
SELECT * FROM EmployeeSales WHERE EmployeeName = 'Employee_25';
EXPLAIN SELECT * FROM EmployeeSales WHERE EmployeeName = 'Employee_25';

-- Optimization
CREATE INDEX idx_employee_name ON EmployeeSales (EmployeeName);

-- After Optimization
SELECT * FROM EmployeeSales WHERE EmployeeName = 'Employee_25';
EXPLAIN SELECT * FROM EmployeeSales WHERE EmployeeName = 'Employee_25';

-- 4. Case 2: Searching by Department & City (Composite Index)
-- Before Optimization
SELECT * FROM EmployeeSales WHERE Department = 'IT' AND City = 'Delhi';
EXPLAIN SELECT * FROM EmployeeSales WHERE Department = 'IT' AND City = 'Delhi';

-- Optimization
CREATE INDEX idx_department_city ON EmployeeSales (Department, City);

-- After Optimization
SELECT * FROM EmployeeSales WHERE Department = 'IT' AND City = 'Delhi';
EXPLAIN SELECT * FROM EmployeeSales WHERE Department = 'IT' AND City = 'Delhi';

-- 5. Case 3: Query Rewriting (Removing Column Function)
-- Before Optimization
SELECT * FROM EmployeeSales WHERE YEAR(SaleDate) = 2025;
EXPLAIN SELECT * FROM EmployeeSales WHERE YEAR(SaleDate) = 2025;

-- Optimization (Date Range Rewrite + Index)
CREATE INDEX idx_sale_date ON EmployeeSales (SaleDate);

SELECT * FROM EmployeeSales
WHERE SaleDate >= '2025-01-01' AND SaleDate < '2026-01-01';

EXPLAIN SELECT * FROM EmployeeSales
WHERE SaleDate >= '2025-01-01' AND SaleDate < '2026-01-01';

-- 6. Case 4: Query Rewriting (Leading Wildcard Removal)
-- Before Optimization
SELECT * FROM EmployeeSales WHERE EmployeeName LIKE '%25%';
EXPLAIN SELECT * FROM EmployeeSales WHERE EmployeeName LIKE '%25%';

-- After Optimization (Prefix Match)
SELECT * FROM EmployeeSales WHERE EmployeeName LIKE 'Employee_25%';
EXPLAIN SELECT * FROM EmployeeSales WHERE EmployeeName LIKE 'Employee_25%';

-- 7. Case 5: Aggregation & Filtering
-- Before Optimization
SELECT Department, SUM(SaleAmount) AS TotalSales
FROM EmployeeSales
WHERE City = 'Delhi'
GROUP BY Department;

EXPLAIN SELECT Department, SUM(SaleAmount) AS TotalSales
FROM EmployeeSales
WHERE City = 'Delhi'
GROUP BY Department;

-- Optimization
CREATE INDEX idx_city_department ON EmployeeSales (City, Department);

-- After Optimization
SELECT Department, SUM(SaleAmount) AS TotalSales
FROM EmployeeSales
WHERE City = 'Delhi'
GROUP BY Department;

EXPLAIN SELECT Department, SUM(SaleAmount) AS TotalSales
FROM EmployeeSales
WHERE City = 'Delhi'
GROUP BY Department;

-- 8. Check All Indexes
SHOW INDEX FROM EmployeeSales;

-- 9. Execution Time Profiling (MySQL 8.0.18+)
EXPLAIN ANALYZE SELECT * FROM EmployeeSales WHERE EmployeeName = 'Employee_25';
EXPLAIN ANALYZE SELECT * FROM EmployeeSales WHERE YEAR(SaleDate) = 2025;
EXPLAIN ANALYZE SELECT * FROM EmployeeSales WHERE SaleDate >= '2025-01-01' AND SaleDate < '2026-01-01';

-- 10. Cleanup (Drop Indexes)
DROP INDEX idx_employee_name ON EmployeeSales;
DROP INDEX idx_department_city ON EmployeeSales;
DROP INDEX idx_sale_date ON EmployeeSales;
DROP INDEX idx_city_department ON EmployeeSales;
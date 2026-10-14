-- Experiment 3: Employee-Department-Project Schema
-- Aim: To create an Employee-Department-Project database and
-- execute SQL queries using selection, projection, aggregate
-- functions, GROUP BY, HAVING, CASE and ORDER BY.

-- Create Database
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- Create Department Table
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

-- Create Employee Table
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
);

-- Create Project Table
CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
);

-- Create Employee_Project Table
CREATE TABLE Employee_Project (
    emp_id INT,
    project_id INT,
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id)
        REFERENCES Employee(emp_id),
    FOREIGN KEY (project_id)
        REFERENCES Project(project_id)
);

-- Insert 5 Departments
INSERT INTO Department VALUES
(1, 'IT', 'Delhi'),
(2, 'HR', 'Mumbai'),
(3, 'Finance', 'Pune'),
(4, 'Marketing', 'Bangalore'),
(5, 'Operations', 'Hyderabad');

-- Insert 30 Employees
INSERT INTO Employee VALUES
(1,'Aarav',60000,'2022-01-10',1),
(2,'Vivaan',55000,'2022-02-15',1),
(3,'Aditya',70000,'2021-03-20',1),
(4,'Arjun',48000,'2023-01-12',1),
(5,'Kabir',65000,'2021-07-11',1),
(6,'Rohan',52000,'2023-04-05',1),
(7,'Ananya',45000,'2022-05-15',2),
(8,'Diya',50000,'2021-08-21',2),
(9,'Isha',47000,'2023-02-10',2),
(10,'Meera',55000,'2020-11-01',2),
(11,'Sara',49000,'2022-12-12',2),
(12,'Riya',53000,'2023-03-17',2),
(13,'Karan',75000,'2020-01-10',3),
(14,'Rahul',68000,'2021-04-15',3),
(15,'Nikhil',72000,'2022-06-20',3),
(16,'Varun',65000,'2023-01-05',3),
(17,'Mohit',59000,'2021-09-09',3),
(18,'Ankit',62000,'2022-10-10',3),
(19,'Neha',58000,'2021-01-20',4),
(20,'Pooja',62000,'2022-03-25',4),
(21,'Tanya',54000,'2023-05-12',4),
(22,'Simran',60000,'2020-07-18',4),
(23,'Kriti',57000,'2021-11-14',4),
(24,'Naina',52000,'2023-06-19',4),
(25,'Manish',61000,'2020-02-02',5),
(26,'Sahil',56000,'2022-04-04',5),
(27,'Yash',59000,'2021-05-05',5),
(28,'Dev',63000,'2023-02-02',5),
(29,'Harsh',58000,'2022-09-09',5),
(30,'Raj',55000,'2023-01-01',5);

-- Insert 8 Projects
INSERT INTO Project VALUES
(101,'AI Platform',500000,1),
(102,'Cloud Migration',400000,1),
(103,'Recruitment System',200000,2),
(104,'Payroll System',300000,3),
(105,'Marketing Campaign',250000,4),
(106,'Sales Analytics',350000,4),
(107,'Inventory System',450000,5),
(108,'Operations Dashboard',300000,5);

-- 1. Selection
-- Find employees earning more than 60000
SELECT emp_id, emp_name, salary
FROM Employee
WHERE salary > 60000;

-- 2. Projection
-- Display employee names and salaries
SELECT emp_name, salary
FROM Employee;

-- 3. Aggregate Functions
SELECT
    COUNT(*) AS total_employees,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary,
    SUM(salary) AS total_salary
FROM Employee;

-- 4. GROUP BY
SELECT
    dept_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM Employee
GROUP BY dept_id;

-- 5. HAVING
SELECT
    dept_id,
    AVG(salary) AS average_salary
FROM Employee
GROUP BY dept_id
HAVING AVG(salary) > 60000;

-- 6. CASE Expression
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 70000 THEN 'High'
        WHEN salary >= 55000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM Employee;

-- 7. ORDER BY
SELECT emp_name, salary
FROM Employee
ORDER BY salary DESC;

-- Result:
-- The Employee-Department-Project schema was created
-- and SQL queries were executed successfully.
```

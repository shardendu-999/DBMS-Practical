-- Experiment 5: Views and Recursive CTE
-- Aim: To create SQL views for department salary summary
-- and employee hierarchy, test view updatability and
-- implement a recursive CTE to display reporting chains.

USE company_db;

-- Part A: Department Salary Summary View
CREATE OR REPLACE VIEW Department_Salary_Summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS highest_salary,
    MIN(e.salary) AS lowest_salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Display the View
SELECT * FROM Department_Salary_Summary;

-- Part B: Employee Hierarchy
-- Add a manager column to Employee.
-- Run these ALTER statements only once.
ALTER TABLE Employee
ADD COLUMN manager_id INT NULL;

ALTER TABLE Employee
ADD CONSTRAINT fk_manager
FOREIGN KEY (manager_id)
REFERENCES Employee(emp_id);

-- Insert Manager Relationships
UPDATE Employee
SET manager_id = NULL
WHERE emp_id = 1;

UPDATE Employee
SET manager_id = 1
WHERE emp_id IN (2, 3, 4, 5, 6);

UPDATE Employee
SET manager_id = 3
WHERE emp_id IN (7, 8, 9);

UPDATE Employee
SET manager_id = 5
WHERE emp_id IN (10, 11, 12);

UPDATE Employee
SET manager_id = 13
WHERE emp_id IN (14, 15, 16);

UPDATE Employee
SET manager_id = 14
WHERE emp_id IN (17, 18);

-- Recursive CTE: Display Employee Hierarchy
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level
    FROM Employee
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        eh.level + 1
    FROM Employee e
    INNER JOIN EmployeeHierarchy eh
        ON e.manager_id = eh.emp_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level
FROM EmployeeHierarchy
ORDER BY level, emp_id;

-- View Updatability Test
CREATE OR REPLACE VIEW Employee_View AS
SELECT
    emp_id,
    emp_name,
    salary,
    dept_id
FROM Employee;

-- Update employee salary through the simple view
UPDATE Employee_View
SET salary = 61000
WHERE emp_id = 1;

-- Check the updated employee
SELECT *
FROM Employee
WHERE emp_id = 1;

-- Result:
-- Views and recursive CTEs were implemented.
-- The department salary summary and employee
-- reporting hierarchy can be displayed.

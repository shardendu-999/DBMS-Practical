-- Experiment 4: Advanced SQL Queries
-- Aim: To perform advanced SQL operations using INNER JOIN,
-- LEFT JOIN, SELF JOIN, 3-way JOIN, correlated subqueries,
-- EXISTS, simulated INTERSECT, EXCEPT and EXPLAIN.

USE company_db;

-- 1. INNER JOIN
-- Display employees along with their departments
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

-- 2. LEFT JOIN
-- Display all departments and their employees
SELECT
    d.dept_name,
    e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;

-- 3. SELF JOIN
-- Display employees working in the same department
SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee e1
JOIN Employee e2
    ON e1.dept_id = e2.dept_id
   AND e1.emp_id < e2.emp_id;

-- 4. THREE-WAY JOIN
-- Display employee, department and project information
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
JOIN Project p
    ON d.dept_id = p.dept_id;

-- 5. CORRELATED SUBQUERY
-- Employees earning more than their department average
SELECT
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- 6. EXISTS
-- Departments having an employee earning above 70000
SELECT d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 70000
);

-- 7. SIMULATED INTERSECT
-- Find employees in departments located in Delhi
SELECT e.emp_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id
WHERE d.location = 'Delhi';

-- 8. SIMULATED EXCEPT
-- Departments without employees earning above 70000
SELECT d.dept_name
FROM Department d
WHERE d.dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM Employee
    WHERE salary > 70000
);

-- 9. EXPLAIN
-- View the query execution plan
EXPLAIN
SELECT
    e.emp_name,
    d.dept_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
WHERE e.salary > 60000;

-- Result:
-- Advanced SQL operations using joins, subqueries,
-- EXISTS, set-operation simulation and EXPLAIN
-- were successfully demonstrated.
```

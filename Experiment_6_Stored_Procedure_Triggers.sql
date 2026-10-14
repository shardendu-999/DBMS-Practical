-- Experiment 6: Stored Procedure and Triggers
-- Aim: To create a stored procedure transfer_employee()
-- with validation and error handling, and implement
-- triggers for salary validation and audit logging.

USE company_db;

-- Part A: Create Salary Audit Table
CREATE TABLE IF NOT EXISTS Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(50)
);

-- Remove old triggers and procedure if they exist
DROP TRIGGER IF EXISTS before_employee_insert;
DROP TRIGGER IF EXISTS before_employee_salary_update;
DROP TRIGGER IF EXISTS employee_salary_audit;
DROP PROCEDURE IF EXISTS transfer_employee;

-- Part B: BEFORE INSERT Trigger
-- Prevent insertion of employees with invalid salaries

DELIMITER //

CREATE TRIGGER before_employee_insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END //

-- Part C: BEFORE UPDATE Trigger
-- Prevent salary updates to zero or negative values

CREATE TRIGGER before_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END //

-- Part D: AFTER UPDATE Trigger
-- Record salary changes in the audit table

CREATE TRIGGER employee_salary_audit
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NOT (OLD.salary <=> NEW.salary) THEN
        INSERT INTO Salary_Audit
            (emp_id, old_salary, new_salary, action)
        VALUES
            (OLD.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATED');
    END IF;
END //

-- Part E: Stored Procedure
-- Transfer an employee to another department

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE employee_exists INT DEFAULT 0;
    DECLARE department_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*) INTO employee_exists
    FROM Employee
    WHERE emp_id = p_emp_id;

    SELECT COUNT(*) INTO department_exists
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF employee_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee does not exist';

    ELSEIF department_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist';

    ELSE
        START TRANSACTION;

        UPDATE Employee
        SET dept_id = p_new_dept_id
        WHERE emp_id = p_emp_id;

        COMMIT;
    END IF;
END //

DELIMITER ;

-- Test Salary Update Trigger
UPDATE Employee
SET salary = 65000
WHERE emp_id = 1;

-- Check Salary Audit Records
SELECT * FROM Salary_Audit;

-- Execute Stored Procedure
CALL transfer_employee(1, 2);

-- Verify Employee Department
SELECT emp_id, emp_name, dept_id
FROM Employee
WHERE emp_id = 1;

-- Test Invalid Employee (optional)
-- CALL transfer_employee(999, 2);

-- Test Invalid Department (optional)
-- CALL transfer_employee(1, 999);

-- Result:
-- Stored procedure, salary validation triggers,
-- and salary audit logging were implemented.

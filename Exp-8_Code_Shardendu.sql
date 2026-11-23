-- 1. Create Bank Account Table & Insert Sample Records
CREATE TABLE BankAccount (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(50),
    Balance DECIMAL(10,2)
);

INSERT INTO BankAccount VALUES
(101, 'Aman', 10000),
(102, 'Riya', 8000),
(103, 'Rahul', 12000);

SELECT * FROM BankAccount;

-- 2. Implement Transaction Using COMMIT
BEGIN;

UPDATE BankAccount
SET Balance = Balance - 1000
WHERE AccountID = 101;

UPDATE BankAccount
SET Balance = Balance + 1000
WHERE AccountID = 102;

COMMIT;

SELECT * FROM BankAccount;

-- 3. Implement ROLLBACK
BEGIN;

UPDATE BankAccount
SET Balance = Balance - 2000
WHERE AccountID = 101;

UPDATE BankAccount
SET Balance = Balance + 2000
WHERE AccountID = 102;

ROLLBACK;

SELECT * FROM BankAccount;

-- 4. Implement SAVEPOINT
BEGIN;

UPDATE BankAccount
SET Balance = Balance - 500
WHERE AccountID = 101;

SAVEPOINT sp1;

UPDATE BankAccount
SET Balance = Balance + 500
WHERE AccountID = 102;

ROLLBACK TO SAVEPOINT sp1;

COMMIT;

-- 5. Simulate Partial Transaction Failure
BEGIN;

UPDATE BankAccount
SET Balance = Balance - 1000
WHERE AccountID = 101;

-- Simulate failure
ROLLBACK;

-- 6. Set Transaction Isolation Levels
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 7. Demonstrate Concurrency / Dirty Read (Two Sessions)
-- [Session 1]
BEGIN;
UPDATE BankAccount
SET Balance = 5000
WHERE AccountID = 101;

-- [Session 2]
SELECT Balance
FROM BankAccount
WHERE AccountID = 101;

-- [Session 1]
ROLLBACK;

-- 8. Demonstrate Non-Repeatable Read (Two Sessions)
-- [Session 1]
BEGIN;
SELECT Balance
FROM BankAccount
WHERE AccountID = 101;

-- [Session 2]
UPDATE BankAccount
SET Balance = Balance + 1000
WHERE AccountID = 101;
COMMIT;

-- [Session 1]
SELECT Balance
FROM BankAccount
WHERE AccountID = 101;

-- 9. Demonstrate Phantom Read (Two Sessions)
-- [Session 1]
BEGIN;
SELECT *
FROM BankAccount
WHERE Balance > 5000;

-- [Session 2]
INSERT INTO BankAccount
VALUES (104, 'Neha', 7000);
COMMIT;

-- [Session 1]
SELECT *
FROM BankAccount
WHERE Balance > 5000;
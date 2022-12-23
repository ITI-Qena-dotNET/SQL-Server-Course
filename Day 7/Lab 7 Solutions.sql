-- ************************** SQL Server Lab 4 **************************
-- ALTER AUTHORIZATION ON DATABASE::Company_SD TO sa

-- 1. Create a stored procedure to show the number of students per department. [Use ITI DB]
CREATE OR ALTER PROC GetNoStudentsPerDepartment
AS
SELECT d.Dept_Name, COUNT(s.St_Id) AS NumberOfStudents
FROM Department d LEFT OUTER JOIN Student s ON s.Dept_Id = d.Dept_Id
GROUP BY d.Dept_Name

EXECUTE GetNoStudentsPerDepartment

-- 2. Create a stored procedure that will check for the # of employees in the project p1
-- if they are more than 3 print a message to the user “'The number of employees in the project p1 is 3 or more'”
-- if they are less display a message to the user “'The following employees work for the project p1'” in addition to the first name and last name of each one.
-- [Use Company DB]
CREATE OR ALTER PROC CheckP1EmployeesNumber
AS
	DECLARE @countResult int

	SELECT @countResult = COUNT(w.ESSn)
	FROM Works_for w INNER JOIN Employee e ON w.ESSn = e.SSN
	WHERE w.Pno = 100
	GROUP BY w.Pno

	IF @countResult > 3
		PRINT 'The number of employees in the project p1 is 3 or more'
	ELSE
		PRINT 'The following employees work for the project p1'
		SELECT e.Fname, e.Lname
		FROM Employee e INNER JOIN Works_for w ON w.ESSn = e.SSN
		INNER JOIN Project p ON w.Pno = p.Pnumber
		WHERE p.Pnumber = 100

EXECUTE CheckP1EmployeesNumber

-- 3. Create a stored procedure that will be used in case there is an old employee has left the project and a new one become instead of him.
-- The procedure should take 3 parameters (old Emp. number, new Emp. number and the project number) and it will be used to update works_for table. [Company DB]
CREATE OR ALTER PROC ChangeEmployeeOnProject @oldEmpNumber int, @newEmpNumber int, @projectNumber int
AS
	IF EXISTS (SELECT * FROM Works_for WHERE Pno = @projectNumber AND ESSn = @oldEmpNumber)
		UPDATE Works_for
		SET ESSn = @newEmpNumber
		WHERE Pno = @projectNumber AND ESSn = @oldEmpNumber
	ELSE
		PRINT 'Does Not Exist'

SELECT * FROM ChangeEmployeeOnProject 1, 2, 1

-- 4. Create an Audit table with the following structure (ProjectNo | UserName | ModifiedDate | Hours_Old | Hours_New).
-- This table will be used to audit the update trials on the Hours column (works_for table, Company DB)
-- Example:
-- If a user updated the Hours column then the project number, the user name that made that update, 
-- the date of the modification and the value of the old and the new Hours will be inserted into the Audit table.
-- Note: This process will take place only if the user updated the Hours column
CREATE TABLE AuditWorksFor
(
	ProjectNo int,
	UserName varchar(50),
	ModifiedDate date,
	Hours_Old int,
	Hours_New int
)

CREATE OR ALTER TRIGGER AuditWorksForCompany
ON Works_for
AFTER UPDATE
AS
	DECLARE @oldValue int, @newValue int, @projectNumber int
	
	IF UPDATE(Hours)
		SELECT @newValue = i.Hours  FROM inserted i
		SELECT @oldValue = d.Hours  FROM deleted d
		SELECT @projectNumber = d.Pno  FROM deleted d

	INSERT INTO AuditWorksFor
	VALUES (@projectNumber, SUSER_NAME(), GETDATE(), @oldValue, @newValue)

UPDATE Works_for
SET Hours += 5
WHERE ESSn = 112233

-- 5. Create a trigger to prevent anyone from inserting a new record in the Department table [ITI DB]
-- Print a message for the user to tell him that he ‘can’t insert a new record in that table’
CREATE TRIGGER PreventInsertDepartmentTable
ON Department
INSTEAD OF INSERT
AS
	PRINT 'You can’t insert a new record in that table'

INSERT INTO Department(Dept_Id) VALUES(100)

-- 6. Create a trigger that prevents the insertion Process for the Employee table in September and test it  [Company DB].
CREATE OR ALTER TRIGGER PreventInsertInSeptember
ON Employee
FOR INSERT
AS
	if MONTH(GETDATE()) = 9
		PRINT 'CANNOT INSERT IN SEPTEMBER'
		DELETE FROM Employee
		WHERE SSN = (SELECT SSN FROM inserted)
		ROLLBACK TRANSACTION

INSERT INTO Employee(SSN)
VALUES(40000)

-- 7. Create a trigger that prevents users from altering any table in Company DB.
CREATE TRIGGER PreventAltersInAnyTableInCompanyDb
ON DATABASE
FOR ALTER_TABLE
AS
	PRINT 'You should ask your DBA for permission to Alter tables in Company DB'
	ROLLBACK TRANSACTION

ALTER TABLE Departments ADD CountEmp int

-- 8. Create a trigger on student table after insert to add Row in a Student Audit table (Server User Name | Date | Note)
-- where the note will be “[username] Insert New Row with Key=[Key Value] in table [table name]” [Use ITI_new]
CREATE TABLE StudentAudit
(
	ServerUserName varchar(50),
	AuditDate Date,
	Note varchar(100)
)

CREATE TRIGGER AuditInsertStudent
ON Student
AFTER INSERT
AS
	DECLARE @keyInserted int
	SELECT @keyInserted = St_Id FROM inserted

	INSERT INTO StudentAudit
	VALUES (SUSER_NAME(), GETDATE(), CONCAT(SUSER_NAME(), ' Insert New Row with Key=', @keyInserted, ' in table Student'))

INSERT INTO Student(St_Id)
VALUES (400)

-- 9. Create a trigger on student table instead of delete to add Row in Student Audit table (ServerUserName | Date | Note)
-- where the note will be “ try to delete Row with Key=[Key Value]”
CREATE TRIGGER AuditDeleteStudent
ON Student
INSTEAD OF DELETE
AS
	DECLARE @keyDeleted int
	SELECT @keyDeleted = St_Id FROM deleted

	INSERT INTO StudentAudit
	VALUES (SUSER_NAME(), GETDATE(), CONCAT(SUSER_NAME(), ' tried to delete Row with Key=', @keyDeleted))

DELETE FROM Student
WHERE St_Id = 300

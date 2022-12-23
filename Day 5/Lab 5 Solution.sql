-- ************************************ PART 1 Problems ************************************
-- 1. Create a view that displays the student’s full name, course name if the student has a grade of more than 50.
CREATE VIEW StudentsNamesWhoGotMoreThan50
AS
SELECT (s.St_Fname + ' ' + s.St_Lname) as FullName, c.Crs_Name
FROM Student s LEFT OUTER JOIN Stud_Course sc ON s.St_Id = sc.St_Id
LEFT OUTER JOIN Course c ON sc.Crs_Id = c.Crs_Id
WHERE sc.Grade > 50

--SELECT * FROM StudentsNamesWhoGotMoreThan50

-- TODO
-- 2. Create an Encrypted view that displays manager (Instructor) names and the topics they teach.
CREATE VIEW InstructorsWithTopicsTheyTeach
WITH ENCRYPTION
AS
SELECT i.Ins_Name, t.Top_Name
FROM Department d INNER JOIN Instructor i ON d.Dept_Manager = i.Ins_Id
INNER JOIN Ins_Course ic ON i.Ins_Id = ic.Ins_Id
INNER JOIN Course c ON ic.Crs_Id = c.Crs_Id
INNER JOIN Topic t ON c.Top_Id = t.Top_Id

--SELECT * FROM InstructorsWithTopicsTheyTeach

-- 3. Create a view that will display Instructor Name, Department Name for the ‘SD’ or ‘Java’ Department.
CREATE VIEW InstructorsInJavaOrSdDepartment
AS
SELECT i.Ins_Name, d.Dept_Name
FROM Instructor i LEFT OUTER JOIN Department d ON i.Dept_Id = d.Dept_Id
WHERE d.Dept_Name IN ('SD', 'Java')

-- 4. Create a view “V1” that displays student data for the students who lives in Alex or Cairo.
--Note: Prevent the users to run the following query (UPDATE V1 SET st_address = 'tanta'  WHERE st_address = 'alex');
CREATE VIEW V1
AS
SELECT St_Id, St_Fname, St_Lname, St_Age, St_super
FROM Student
WHERE St_Address IN ('Alex', 'Cairo')
WITH CHECK OPTION

-- SELECT * FROM V1
 Update V1 set St_Fname = 'Mohamed'  Where St_Id = 3

-- 5. Create a temporary table [Session based] on Company DB to save employee name and his today task.
CREATE TABLE #EmployeeTasks
(
	EmployeeName varchar(50),
	Task varchar(200)
)

-- ************************************ PART 2 Problems ************************************
--ALTER AUTHORIZATION ON DATABASE::Company_SD TO sa

-- 1. Create a view that will display the project name and the number of employees works on it.
CREATE VIEW ProjectNameWithEmployeesCount
AS
SELECT p.Pname, COUNT(w.ESSn) as EmployeeCount
FROM Project p LEFT OUTER JOIN Works_for w ON p.Pnumber = w.Pno
GROUP BY p.Pname

-- SELECT * FROM ProjectNameWithEmployeesCount

-- 2. Create a view named “v_D30” that will display employee number, project number, hours of the projects in department 30.
CREATE VIEW v_D30
AS
SELECT e.SSN, w.Pno, w.Hours
FROM Employee e LEFT OUTER JOIN Works_for w ON e.SSN = w.ESSn
WHERE e.Dno = 30

-- SELECT * FROM v_D30

-- 3. Create a view named  “v_count“ that will display the project name and the number of hours for each one.
CREATE VIEW v_count
AS
SELECT p.Pname, SUM(w.Hours) AS NumberOfHours
FROM Project p LEFT OUTER JOIN Works_for w ON p.Pnumber = w.Pno
GROUP BY p.Pname

-- SELECT * FROM v_count

-- 4. Create a view named ”v_project_500” that will display the emp no. for the project 500. (Use the previously created view “v_D30”)
CREATE VIEW v_project_500
AS
SELECT SSN, Pno
FROM v_D30
WHERE Pno = 500

-- SELECT * FROM v_project_500

-- 6. Modify the view named “v_without_budget” to display all DATA in project 300 and 400
CREATE VIEW v_without_budget
AS
SELECT *
FROM Project
WHERE Pnumber IN (300, 400)

-- 7. Delete the views  “v_D30” and “v_count”
DROP VIEW v_D30
DROP VIEW v_count

-- ************************************ PART 2 Problems ************************************
-- 1. Make a rule that makes sure the value is less than 1000 then bind it on the Salary in Employee table.
CREATE RULE LessThan1000 as @s < 1000
sp_bindrule LessThan1000, 'Employee.Salary'

-- 2. Create a new user data type named 'loc' with the following Criteria:
-- • nchar(2)
-- • default: NY 
-- • create a rule for this Datatype :values in (NY,DS,KW)) and associate it to the location column
CREATE TYPE loc FROM nchar(2)
CREATE DEFAULT NY_DEF as 'NY'
sp_bindefault NY_DEF, loc
CREATE RULE DefinedLocations as @l in ('NY', 'DS', 'KW')
sp_bindrule DefinedLocations, loc

-- 3. Create a New table Named NewStudent, and use the new UDD on it you just have made and ID column and don’t make it identity.
CREATE TABLE NewStudent
(
	ID int,
	Location loc
)

-- 4. Create a new sequence for the ID values of the previous table.
CREATE SEQUENCE NewStudentId
START WITH 1
INCREMENT BY 1

-- a. Insert 3 records in the table using the sequence.
INSERT INTO NewStudent
VALUES ((NEXT VALUE FOR NewStudentId), 'NY'),
((NEXT VALUE FOR NewStudentId), 'DS'),
((NEXT VALUE FOR NewStudentId), 'KW')

-- b. Delete the second row of the table.
DELETE FROM NewStudent
WHERE ID = (SELECT ID FROM NewStudent ORDER BY ID OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)

-- c. Insert 2 other records using the sequence.
INSERT INTO NewStudent
VALUES ((NEXT VALUE FOR NewStudentId), 'NY'),
((NEXT VALUE FOR NewStudentId), 'DS')

-- d. Can you insert another record without using the sequence? Try it!
-- Can you do the same if it was an identity column?
INSERT INTO NewStudent
VALUES ((NEXT VALUE FOR NewStudentId), 'NY'),
(10000, 'DS')

-- e. Can you edit the value of the ID column in any of the inserted records? Try it!
-- Can you do the same if it was an identity column?
UPDATE NewStudent
SET ID = 30
WHERE ID = 1

-- f. Can you use the same sequence to insert in another table?
INSERT INTO Employee (SSN)
VALUES (NEXT VALUE FOR NewStudentId)

-- g. If yes, do you think that the sequence will start from its initial value in the new table and insert the same IDs that were inserted in the old table?
-- ******* Answer: The Sequence will start from the next value it genereated in the old table

-- h. How to skip some values from the sequence not to be inserted in the table? Try it.
-- Can you do the same with the Identity column?

-- i. What are the differences between the Identity column and Sequence?

-- Difference 1
-- The IDENTITY property is tied to a particular table and cannot be shared among multiple tables since it is a table column property.
-- The SEQUENCE object is defined by the user and can be shared by multiple tables since is it is not tied to any table. 

-- Difference 2
-- To generate the next IDENTITY value, a new row has to be inserted into the table.
-- The next VALUE for a SEQUENCE object can simply be generated using the NEXT VALUE FOR clause with the sequence object.

-- Difference 3
-- The value for the IDENTITY property cannot be reset to its initial value.
-- The value for the SEQUENCE object can be reset.

-- Difference 4
-- A maximum value cannot be set for the IDENTITY property.
-- The maximum value for a SEQUENCE object can be defined.

-- Reference with examples: https://www.sqlshack.com/difference-between-identity-sequence-in-sql-server/
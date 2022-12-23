-- *************************** PART 1 Problems (ITI_new) *********************************
-- 1. Create a scalar function that takes a date and returns the Month name of that date. Test with ‘1/12/2009’
CREATE OR ALTER FUNCTION GetMonthFromDate(@inDate date)
RETURNS varchar(15)
BEGIN
	DECLARE @monthName varchar(10)
	SELECT @monthName = DATENAME(MONTH, @inDate)
	RETURN @monthName
END

SELECT dbo.GetMonthFromDate('1/12/2009'); --------------------- DONE

-- 2. Create a multi-statements table-valued function that takes 2 integers and returns the values between them.
CREATE OR ALTER FUNCTION GetTableFromTwoInts(@firstVal int, @secondVal int)
RETURNS TABLE
AS
RETURN
(
	SELECT St_Id, St_Fname, St_Lname
	FROM Student
	WHERE St_Id BETWEEN @firstVal AND @secondVal
)

SELECT * FROM GetTableFromTwoInts(1, 6); -------------------- DONE

-- 3. Create a tabled valued function that takes Student No and returns Department Name with Student full name.
CREATE OR ALTER FUNCTION GetStudentFullNameAndDeptNameFromId(@stNo int)
RETURNS TABLE
AS
RETURN
(
	SELECT d.Dept_Name, CONCAT(s.St_Fname, ' ', s.St_Lname) AS FullName
	FROM Student s INNER JOIN Department d ON s.Dept_Id = d.Dept_Id
	WHERE s.St_Id = @stNo
)

SELECT * FROM GetStudentFullNameAndDeptNameFromId(3); -------------------- DONE

-- 4. Create a scalar function that takes Student ID and returns a message to the user (use Case statement)
-- a. If the first name and Last name are null then display 'First name & last name are null'
-- b. If the First name is null then display 'first name is null'
-- c. If the Last name is null then display 'last name is null'
-- d. Else display 'First name & last name are not null'
CREATE OR ALTER FUNCTION SendMessageToStudent(@stId int)
RETURNS varchar(50)
BEGIN
	DECLARE @firstName varchar(50), @lastName varchar(50), @result varchar(50)
	
	SELECT @firstName = St_Fname, @lastName = St_Lname 
	FROM Student 
	WHERE St_Id = @stId

	SELECT @result = CASE
		WHEN @firstName IS NULL AND @lastName IS NULL THEN 'First name & last name are null'
		WHEN @firstName IS NULL AND @lastName IS NOT NULL THEN 'First name is null'
		WHEN @firstName IS NOT NULL AND @lastName IS NULL THEN 'Last name is null'
		ELSE 'First name & last name are not null'
	END

	RETURN @result
END

SELECT dbo.SendMessageToStudent(15); -------------------- DONE

-- 5. Create a function that takes an integer that represents the format of the Manager hiring date
-- and displays department name, Manager Name, and hiring date with this format. 
CREATE OR ALTER FUNCTION DisplayDepartmentInfo(@dateFormat int)
RETURNS TABLE
AS
RETURN
(
	SELECT d.Dept_Name, i.Ins_Name, CONVERT(date, d.Manager_hiredate, @dateFormat) AS HiringDate
	FROM Department d INNER JOIN Instructor i ON d.Dept_Manager = i.Ins_Id
)

SELECT * FROM DisplayDepartmentInfo(108); -------------------- DONE

-- 6. Create multi-statements table-valued function that takes a string. Note: Use the “ISNULL” function
-- If string ='first name' returns student first name
-- If string ='last name' returns student last name 
-- If string ='full name' returns Full Name from student table 
CREATE OR ALTER FUNCTION GetStudentInfo(@inputText varchar(20))
RETURNS @res TABLE (Result varchar(30))
AS
BEGIN
	IF @inputText = 'first name'
		INSERT INTO @res
		SELECT ISNULL(St_Fname, 'First Name is Null') FROM Student
	ELSE IF @inputText = 'last name'
		INSERT INTO @res
		SELECT ISNULL(St_Lname, 'Last Name is Null') FROM Student
	ELSE IF @inputText = 'full name'
		INSERT INTO @res
		SELECT CONCAT(St_Fname, ' ', St_Lname) FROM Student

	RETURN
END

SELECT * FROM GetStudentInfo('first name'); -------------------- DONE
SELECT * FROM GetStudentInfo('last name');
SELECT * FROM GetStudentInfo('full name');

-- 7. Write a query that returns the Student No and Student first name without the last char
SELECT St_Id, LEFT(St_Fname, LEN(St_Fname) - 1)
FROM Student

-- *************************** PART 2 Problems *********************************
-- ALTER AUTHORIZATION ON DATABASE::Company_SD TO sa
-- 1. Create a function that takes project number and display all employees in this project
CREATE OR ALTER FUNCTION GetAllEmployeesInProject(@projectNumber int)
RETURNS TABLE
AS
RETURN
(
	SELECT e.*
	FROM Employee e LEFT OUTER JOIN Works_for w ON w.ESSn = e.SSN
	INNER JOIN Project p ON p.Pnumber = w.Pno
	WHERE p.Pnumber = @projectNumber
)

SELECT * FROM GetAllEmployeesInProject(100); -------------------- DONE

-- ** BONUS **
-- 2. Write a Query that computes the increment in salary that arises if the salary of employees increased by any value.
CREATE OR ALTER FUNCTION ComputeIncrementInSalary(@empId int, @salaryAmountIncrease int)
RETURNS @res TABLE (SalaryBefore int, SalaryAfter int, PercentIncrease float)
AS
BEGIN
	DECLARE @salBefore int, @salAfter int, @percentageIncrease float
	
	SELECT @salBefore = Salary FROM Employee WHERE SSN = @empId
	SELECT @salAfter = Salary + @salaryAmountIncrease FROM Employee WHERE SSN = @empId
	SELECT @percentageIncrease = (@salaryAmountIncrease / @salBefore) * 100

	INSERT INTO @res
	VALUES(@salBefore, @salAfter, @percentageIncrease)

	RETURN
END

SELECT * FROM ComputeIncrementInSalary(112233, (SELECT FLOOR(RAND() * (3000 - 1000 + 1)) + 1000));

-- How to Generate Random Numbers between x and y, Where x = 1000, y = 3000
--SELECT FLOOR(RAND() * (3000 - 1000 + 1)) + 1000;


-- ********************************** LAB 5 **********************************
-- 1. Display all the data from the Employee table (HumanResources Schema) as an XML document “Use XML Raw”. “Use Adventure works DB”
-- A) Elements
SELECT * FROM HumanResources.Employee
FOR XML RAW('Employee'), ELEMENTS, ROOT('Employees')

-- B) Attributes
SELECT * FROM HumanResources.Employee
FOR XML AUTO, ROOT('Employees')

-- 2. Display Each Department Name with its instructors. “Use ITI DB”
-- A) Use XML Raw:
SELECT d.Dept_Name, i.Ins_Name
FROM Instructor i RIGHT OUTER JOIN Department d ON i.Dept_Id = d.Dept_Id
--WHERE i.Ins_Name IS NOT NULL
FOR XML RAW('manager'), ELEMENTS, ROOT('instructors_managers')

-- B) Use XML Path
SELECT d.Dept_Id "@id", d.Dept_Name "name", i.Ins_Name "manager_name"
FROM Instructor i RIGHT OUTER JOIN Department d ON i.Dept_Id = d.Dept_Id
--WHERE i.Ins_Name IS NOT NULL
FOR XML PATH('department'), ROOT('instructors_managers')

-- 3. Use the following variable to create a new table “customers” inside the company DB. Use OpenXML
DECLARE @docs XML =
'<customers>
	<customer FirstName="Bob" Zipcode="91126">
		<order ID="12221">Laptop</order>
	</customer>
	<customer FirstName="Judy" Zipcode="23235">
		<order ID="12221">Workstation</order>
	</customer>
	<customer FirstName="Howard" Zipcode="20009">
		<order ID="3331122">Laptop</order>
	</customer>
	<customer FirstName="Mary" Zipcode="12345">
		<order ID="555555">Server</order>
	</customer>
</customers>'

DECLARE @hdocs INT
EXEC sp_xml_preparedocument @hdocs output, @docs

--CREATE TABLE Customers AS
--(
	SELECT * 
	FROM OPENXML (@hdocs, '//customer')
	WITH (
		  FirstName varchar(10) '@FirstName',
		  Zipcode varchar(10) '@Zipcode',
		  [ID] int 'order/@ID',
		  [orders] varchar(20) 'order'
	)
--)

EXEC sp_xml_removedocument @hdocs

-- Using "ITI_new" database:
-- 4. Create an index on column (Hiredate) that allows you to cluster the data in the table Department. What will happen?
CREATE CLUSTERED INDEX HiredateCI ON Department(Manager_hiredate)

-- 5. Create an index that allows you to enter unique ages in the student table. What will happen?
CREATE UNIQUE INDEX ST_AGE ON Student(St_Age)

-- 6. create a non-clustered index on column(Manager_hiredate) that allows you to enter a unique instructor id in the table Department.
CREATE NONCLUSTERED INDEX Manager_hiredateNCI ON Department(Manager_hiredate)
--CREATE UNIQUE INDEX Manager_hiredate ON Department(Dept_Manager)

INSERT INTO Department
VALUES (100, 'LO', 'No Desc', 'Cairo', 8, '2022-03-03')

-- 7. cur the count of times that Khalid appear after Ahmed in st_Fname column (using the cursor)
DECLARE firstNameCursor CURSOR 
FOR
	SELECT St_Fname
	FROM Student 
FOR READ ONLY

DECLARE @currentFirstName varchar(20), @resultCounter int = 0

OPEN firstNameCursor
FETCH firstNameCursor INTO @currentFirstName

WHILE @@FETCH_STATUS = 0
BEGIN 
	WHILE @currentFirstName = 'Ahmed'
		BEGIN
			FETCH firstNameCursor INTO @currentFirstName
			IF @currentFirstName = 'Khalid'
				SET @resultCounter = @resultCounter + 1
	    end
	FETCH firstNameCursor INTO @currentFirstName
END

PRINT CONCAT('Number of Occurrences of Khaled after Ahmed is ', @resultCounter)

CLOSE firstNameCursor 
DEALLOCATE firstNameCursor

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
declare @docs xml =
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

CREATE TABLE Customers AS
(
SELECT * 
FROM OPENXML (@hdocs, '//Customer')  --levels  XPATH Code
WITH (StudentID int '@order/ID',
	  [Address] varchar(10) 'Address', 
	  StudentFirst varchar(10) 'StudentName/First',
	  StudentSECOND varchar(10) 'StudentName/Second'
	  )
)

EXEC sp_xml_removedocument @hdocs

-- Using "AdventureWorks2012" database:
-- 4. Create an index on column (Hiredate) that allows you to cluster the data in the table Department. What will happen?
CREATE CLUSTERED INDEX HiredateCI ON Department(Manager_hiredate)

-- 5. Create an index that allows you to enter unique ages in the student table. What will happen?
CREATE UNIQUE INDEX ST_AGE ON Student(St_Age)

-- 6. create a non-clustered index on column(Manager_hiredate) that allows you to enter a unique instructor id in the table Department.
CREATE NONCLUSTERED INDEX Manager_hiredateNCI ON Department(Manager_hiredate)

-- 7. find the count of times that Ahmed appear Khalid after Khalid in st_Fname column (using the cursor)












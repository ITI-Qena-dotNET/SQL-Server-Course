-- ***************** PROBLEM 1 ******************

-- 1. Display all the employees Data
SELECT * FROM Employee

-- 2. Display the employee First name, last name, Salary and Department number.
SELECT Fname, Lname, Salary, Dno FROM Employee

-- 3. Display all the projects names, locations and the department which is responsible about it.
SELECT p.Pname, p.Plocation, d.Dname
FROM Project p LEFT OUTER JOIN Departments d on p.Dnum = d.Dnum

-- 4. If you know that the company policy is to pay an annual commission for each employee with specific percent equals 10%
-- of his/her annual salary .Display each employee full name and his annual commission in an ANNUAL COMM column (alias).
SELECT (Fname + ' ' + Lname) as FullName, (Salary + Salary * 0.1) as ANNUAL_COMM
FROM Employee

-- 5. Display the employees Id, name who earns more than 1000 LE monthly.
SELECT SSN, Fname, Salary
FROM Employee
WHERE Salary > 1000

-- 6. Display the employees Id, name who earns more than 10000 LE annually.
SELECT SSN, Fname, Salary
FROM Employee
WHERE Salary > (10000 / 12)

-- 7. Display the names and salaries of the female employees.
SELECT Fname, Salary
FROM Employee
WHERE Sex = 'F'

-- 8. Display each department id, name which managed by a manager with id equals 968574
SELECT Dnum, Dname
FROM Departments 
WHERE MGRSSN = 968574

-- 9. Display the ids, names and locations of the projects which controlled with department 10.
SELECT Pnumber, Pname, Plocation
FROM Project
WHERE Dnum = 10

-- ***************** PROBLEM 2 ******************

-- 10. Display the Department id, name and id and the name of its manager.
SELECT d.Dnum, d.Dname, e.Fname
FROM Departments d LEFT OUTER JOIN Employee e ON d.MGRSSN = e.SSN

-- 11. Display the name of the departments and the name of the projects under its control.
SELECT d.Dname, p.Pname
FROM Departments d LEFT OUTER JOIN Project p on d.Dnum = p.Dnum

-- 12. Display the full data about all the dependence associated with the name of the employee they depend on him/her.
SELECT e.Fname, d.* 
FROM Employee e RIGHT OUTER JOIN Dependent d ON e.SSN = d.ESSN

-- 13.	Display the Id, name and location of the projects in Cairo or Alex city.
SELECT Pnumber, Pname, Plocation
FROM Project
WHERE City in ('Cairo', 'Alex')

-- 14. Display the Projects full data of the projects with a name starts with "a" letter.
SELECT *
FROM Project
WHERE Pname LIKE 'a%'

-- 15. Display all the employees in department 30 whose salary from 1000 to 2000 LE monthly
SELECT e.*
FROM Employee e
WHERE Dno = 30 AND e.Salary BETWEEN 1000 AND 2000

-- 16. Retrieve the names of all employees in department 10 who works more than or equal 10 hours per week on "AL Rabwah" project.
SELECT e.Fname, e.Dno
FROM Employee e LEFT OUTER JOIN Works_for w ON e.SSN = w.ESSn
LEFT OUTER JOIN Project p ON w.Pno = p.Pnumber
WHERE w.Hours >= 10 AND p.Pname = 'AL Rabwah'

-- TODO: Ask for elaboration
-- 17. Find the names of the employees who are directly supervised with Kamel Mohamed.
SELECT emp.Fname, emp.Lname
FROM Employee emp, Employee sup
WHERE emp.Superssn = sup.SSN AND sup.Fname = 'Kamel' AND sup.Lname = 'Mohamed'

-- 18. Retrieve the names of all employees and the names of the projects they are working on, sorted by the project name.
SELECT e.Fname, p.Pname
FROM Employee e LEFT OUTER JOIN Works_for w ON e.SSN = w.ESSn
LEFT OUTER JOIN Project p ON w.Pno = p.Pnumber
WHERE p.Pname IS NOT NULL
ORDER BY p.Pname

-- 19. For each project located in Cairo City, find the project number, the controlling department name ,the department manager last name ,address and birthdate.
SELECT p.Pnumber, d.Dname, e.SSN, e.Lname, e.Address, e.Bdate
FROM Project p LEFT OUTER JOIN  Departments d ON p.Dnum = d.Dnum
LEFT OUTER JOIN Employee e ON d.Dnum = e.Dno
WHERE p.City = 'Cairo'

-- 20. Display All Data of the managers
SELECT *
FROM Employee
WHERE Superssn IS NULL

SELECT e.*
FROM Employee e, Employee man
WHERE man.SSN = e.Superssn

-- 21. Display All Employees data and the data of their dependents even if they have no dependents
SELECT e.*, d.*
FROM Employee e LEFT OUTER JOIN Dependent d ON e.SSN = d.ESSN

-- ***************** DML PROBLEMS ******************

-- 1. Insert your personal data to the employee table as a new employee in department number 30, SSN=102672, Superssn=112233, salary=3000
INSERT INTO Employee
VALUES('Youssef', 'Wael', 102672, '1999-08-16', 'Nasr City, Cairo', 'M', 3000, 112233, 30)

-- 2. Insert another employee with  your friend's personal data as new employee in department number 30, SSN=102660,
-- but don�t enter any value for salary or manager number to him.
INSERT INTO Employee(Fname, Lname, SSN, Bdate, Address, Sex, Dno)
VALUES('Mohamed', 'Khaled', 102660, '1999-08-16', 'Abbas St., Cairo', 'M', 30)

-- 3. Upgrade your salary by 20 % of its last value. (Relates to Number 1)
UPDATE Employee
SET Salary = (Salary + Salary * 0.2)
WHERE SSN = (SELECT SSN FROM Employee WHERE Fname = 'Youssef')
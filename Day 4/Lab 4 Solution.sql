-- *********************** DQL Problems ********************

-- 1. For each project, list the project name and the total hours per week (for all employees) spent on that project.
SELECT p.Pname, SUM(w.Hours)
FROM Project p LEFT OUTER JOIN Works_for w ON p.Pnumber = w.Pno
GROUP BY p.Pname

-- 2. Display the data of the department which has the smallest employee ID over all employees' ID.
SELECT TOP(1) d.*
FROM Departments d LEFT OUTER JOIN Employee e ON d.Dnum = e.Dno AND e.Dno IS NOT NULL
ORDER BY e.SSN

-- 3. For each department, retrieve the department name and the maximum, minimum and average salary of its employees.
SELECT d.Dname, MAX(e.Salary) AS MaximumSalary, Min(e.Salary) AS MinimumSalary, AVG(e.Salary) AS AvergaeSalary
FROM Departments d LEFT OUTER JOIN Employee e ON d.Dnum = e.Dno
GROUP BY d.Dname

-- 4. List the last name of all managers who have no dependents.
SELECT e.Lname
FROM Employee e
WHERE e.SSN NOT IN (SELECT DISTINCT e.SSN FROM Employee e RIGHT OUTER JOIN Dependent d ON e.SSN = d.ESSN)

-- 5. For each department, if its average salary is less than the average salary of all employees,
-- display its number, name and number of its employees.
SELECT d.Dnum, d.Dname, COUNT(e.SSN) as NumberOfEmployees
FROM Employee e RIGHT OUTER JOIN Departments d ON e.Dno = d.Dnum
GROUP BY d.Dnum, d.Dname
HAVING AVG(e.Salary) < (SELECT AVG(Salary) FROM Employee)

-- 6. Retrieve a list of employees and the projects they are working on ordered by department and within each department,
-- ordered alphabetically by last name, first name.
SELECT e.Fname, e.Lname, p.Pname
FROM Employee e RIGHT OUTER JOIN Works_for w  ON w.ESSn = e.SSN
LEFT OUTER JOIN Project p ON w.Pno = p.Pnumber
ORDER BY e.Lname, e.Fname

-- 7. Try to update all salaries of employees who work in Project ‘Al Rabwah’ by 30%
UPDATE Employee
SET Salary = (Salary + Salary * 0.3)
WHERE SSN = 
(
SELECT e.SSN
FROM Employee e RIGHT OUTER JOIN Works_for w  ON w.ESSn = e.SSN
LEFT OUTER JOIN Project p ON w.Pno = p.Pnumber
WHERE P.Pname = 'Al Rabwah'
)

-- 8. Display the employee number and name if at least one of them have dependents (Use exists keyword) (SELF-STUDY)
SELECT e.SSN, e.Fname, e.Lname
FROM Employee e
WHERE EXISTS (SELECT d.ESSN FROM Dependent d)
--(SELECT emp.SSN FROM Dependent d LEFT OUTER JOIN Employee emp ON d.ESSN = emp.SSN)
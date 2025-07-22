
-- EMPLOYEE DATABASE MANAGEMENT QUERIES

set search_path to projects;

-- Load the mock_data into postgresql database

-- Preview the loaded data

select * from mock_data;

-- Display view columns from the data

select employee_id, salary, rank
from mock_data;

-- QUESTION 1 - Write a query that displays an employee with the highest salary

select employee_id, first_name, last_name, salary
from mock_data
order by salary desc
limit 1;

-- QUESTION 2 - Find employees with the second highest salary

select employee_id, first_name, last_name, salary
from mock_data
where salary<100 and salary>=95
order by salary desc
limit 5;

-- QUESTION 3 - Find the average salary, the minimum and maximum salary by department, and the number of employees in each department

select department, AVG(salary) as Average_salary, MIN(salary) as Minimum_salary, MAX(salary) as Maximum_salary, COUNT(*) as Number_of_employees
from mock_data
group by department;

-- QUESTION 4 - List employees whose salary is more than 2 standard deviations above their department's average.

-- We'll use a PostgreSQL query with a window function to compute the average and standard deviation of 
-- salaries within each department, and then filter employees whose salary exceeds that threshold.

SELECT 
    employee_id,
    first_name,
    last_name,
    department,
    salary
FROM(
    SELECT 
        employee_id,
        first_name,
        last_name,
        department,
        salary,
        AVG(salary) OVER (PARTITION BY department) AS department_average_salary,
        STDDEV(salary) OVER (PARTITION BY department) AS department_standard_deviation_salary
    FROM mock_data
) sub
WHERE salary > department_average_salary + 1 * department_standard_deviation_salary;

select department, salary,
	AVG(salary) over (partition by department) as Average_salary,
	STDDEV(salary) over (partition by department) as stddev_salary
from mock_data
order by department, salary desc;

select department, count(*) as number_employees, stddev(salary) as stddev_salary
from mock_data
group by department;

SELECT 
    employee_id,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) AS avg_salary,
    STDDEV(salary) OVER (PARTITION BY department) AS stddev_salary,
    AVG(salary) OVER (PARTITION BY department) + 2 * STDDEV(salary) OVER (PARTITION BY department) AS threshold
FROM mock_data
ORDER BY department, salary DESC;


-- QUESTION 5 - Rank employees by salary, and break ties using rank (seniority), in descending order.

-- To rank employees by salary (highest first), and break ties using rank (seniority) (also descending, so more senior ranks come first), 
-- we can use PostgreSQL's ROW_NUMBER() or RANK() with ORDER BY.

select employee_id, first_name, last_name, department, salary, rank,
row_number() over (order by salary desc, rank desc)
from mock_data;

-- QUESTION 6 - Classify employees into quartiles based on salary.

select employee_id, department, salary,
NTILE(4) over (order by salary desc) as salary_quartile
from mock_data;

select employee_id, department, salary,
case 
	when NTILE(4) over (order by salary) = 1 then 'Q1 - Lowest'
	when NTILE(4) over (order by salary) = 2 then 'Q2'
	when NTILE(4) over (order by salary) = 3 then 'Q3'
	when NTILE(4) over (order by salary) = 4 then 'Q4 - Highest'
end as salary_quartiles
from mock_data;

-- QUESTION 7 - Simulate Lagging Salary Increase:- show how each employee's salary compares to the previous ranked employee (globally).

select employee_id, first_name, last_name, salary,
LAG(salary) over (order by salary desc) as previous_salary,
salary - LAG(salary) over (order by salary desc) as salary_difference
from mock_data;

select employee_id, first_name, last_name, salary,
ROW_NUMBER() over (order by salary desc) as salary_rank,
LAG(salary) over (order by salary desc) as previous_salary,
salary - LAG(salary) over (order by salary desc) as salary_difference
from mock_data;
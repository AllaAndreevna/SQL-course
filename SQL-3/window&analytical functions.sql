-- 1. Определить, во сколько раз зарплата каждого сотрудника меньше максимальной зарплаты по компании.

WITH max_salary AS (
    SELECT MAX(salary) AS max_sal
    FROM employees
),
employee_salaries AS (
    SELECT employee_id, salary
    FROM employees
)
SELECT 
    e.employee_id,
    e.salary,
    m.max_sal,
    ROUND(m.max_sal / e.salary, 2) AS times_less
FROM 
    employee_salaries e,
    max_salary m;

-- 2. Определить, во сколько раз зарплата сотрудника отличается от средней зарплаты по департаменту.

WITH avg_dept_salaries AS (
    SELECT department_id, AVG(salary) AS avg_sal
    FROM employees
    GROUP BY department_id
),
employee_salaries AS (
    SELECT employee_id, department_id, salary
    FROM employees
)
SELECT 
    e.employee_id,
    e.department_id,
    e.salary,
    a.avg_sal,
    ROUND(e.salary / a.avg_sal, 2) AS times_diff
FROM 
    employee_salaries e
JOIN 
    avg_dept_salaries a ON e.department_id = a.department_id;
    
-- 3. Вывести список всех сотрудников. Для каждого сотрудника вывести среднюю зарплату по департаменту 
-- и среднюю зарплату по должности. Определить, во сколько раз средняя зарплата по департаменту 
-- отличается от средней зарплаты по должности.

-- вариант решения №1
WITH avg_dept_salaries AS (
    SELECT department_id, AVG(salary) AS avg_dep_sal
    FROM employees
    GROUP BY department_id
),
avg_pos_salaries AS (
    SELECT job_id, AVG(salary) AS avg_job_sal
    FROM employees
    GROUP BY job_id
),
employee_salaries AS (
    SELECT employee_id, department_id, job_id, salary
    FROM employees
)

SELECT 
    e.employee_id, 
    d.avg_dep_sal, 
    p.avg_job_sal, 
    ROUND(d.avg_dep_sal / p.avg_job_sal, 2) AS avg_salary_diff
FROM employee_salaries e
JOIN avg_dept_salaries d ON e.department_id = d.department_id
JOIN avg_pos_salaries p ON e.job_id = p.job_id;


-- вариант решения №2
WITH avg_salaries AS (
    SELECT 
        department_id,
        job_id,
        AVG(salary) AS avg_salary,
        AVG(AVG(salary)) OVER (PARTITION BY department_id) AS avg_dept_salary,
        AVG(AVG(salary)) OVER (PARTITION BY job_id) AS avg_job_salary
    FROM 
        employees
    GROUP BY 
        department_id, job_id
)
SELECT 
    department_id,
    job_id,
    avg_salary,
    avg_dept_salary,
    avg_job_salary,
    CASE 
        WHEN avg_job_salary = 0 THEN NULL
        ELSE avg_dept_salary / avg_job_salary 
    END AS salary_ratio
FROM 
    avg_salaries;

-- 4. Вывести список сотрудников, получающих минимальную зарплату по департаменту. 
-- Если в каком-либо департаменте несколько сотрудников получают минимальную зарплату, 
-- вывести того, чья фамилия идет раньше по алфавиту.

WITH min_salaries AS (
    SELECT 
        department_id,
        MIN(salary) AS min_salary
    FROM 
        employees
    GROUP BY 
        department_id
)
SELECT 
    e.first_name, 
    e.last_name, 
    e.department_id
FROM 
    employees e
JOIN 
    min_salaries ms ON e.department_id = ms.department_id AND e.salary = ms.min_salary
ORDER BY 
    e.department_id, e.last_name;

-- 5. На основе таблицы employees создать таблицу scores c результатами соревнований 
-- со следующим маппингом: employee_id -> man_id, department_id -> division, salary -> score. 
-- Вывести список людей, занявших первые 3 места в каждом дивизионе 
-- (т.е. занявших три позиции с максимальным количеством очков).

create table scores as
select employee_id as man_id,
	   department_id as division,
       salary as score
from employees;

with ranked_scores as ( 
	select man_id, 
		   division, 
		   score, 
		   ROW_NUMBER() over (partition by division order by score DESC) as rank
	from scores 
)
select man_id,
	   division,
	   score
from ranked_scores
where rank <= 3
order by division, rank;

-- 6. Отсортировать список сотрудников по фамилиям и разбить на 5 по возможности равных групп. 
-- Для каждого сотрудника вывести разницу между его зарплатой и средней зарплатой по группе.

WITH sorted_employees AS (
    SELECT 
        employee_id,
        last_name,
        salary,
        ROW_NUMBER() OVER (ORDER BY last_name) AS row_num
    FROM 
        employees
),
grouped_employees AS (
    SELECT 
        employee_id,
        last_name,
        salary,
        row_num,
        NTILE(5) OVER (ORDER BY row_num) AS group_num
    FROM 
        sorted_employees
),
average_salaries AS (
    SELECT 
        group_num,
        AVG(salary) AS avg_salary
    FROM 
        grouped_employees
    GROUP BY 
        group_num
)
SELECT 
    ge.last_name,
    ge.group_num,
    ge.salary,
    av_s.avg_salary,
    (ge.salary - av_s.avg_salary) AS salary_difference
FROM 
    grouped_employees ge
JOIN 
    average_salaries av_s ON ge.group_num = av_s.group_num
ORDER BY 
    ge.group_num, ge.last_name;
    
   

-- 7. Для каждого сотрудника посчитать количество сотрудников, 
-- принятых на работу в период ± 1 год от даты его принятия на работу, 
-- а также количество сотрудников, принятых позже данного сотрудника, 
-- но в этом же году. Если два сотрудника приняты в один день, 
-- считать принятым позже сотрудника с большим employee_id.

WITH employment_dates AS (
    SELECT 
        employee_id,
        hire_date
    FROM 
        employees
),
count_within_year AS (
    SELECT 
        e1.employee_id,
        COUNT(e2.employee_id) AS count_within_one_year
    FROM 
        employment_dates e1
    LEFT JOIN 
        employment_dates e2 ON e2.hire_date BETWEEN e1.hire_date - INTERVAL '1 year' AND e1.hire_date + INTERVAL '1 year'
    GROUP BY 
        e1.employee_id
),
count_later_same_year AS (
    SELECT 
        e1.employee_id,
        COUNT(e2.employee_id) AS count_later_same_year
    FROM 
        employment_dates e1
    LEFT JOIN 
        employment_dates e2 ON 
            EXTRACT(YEAR FROM e2.hire_date) = EXTRACT(YEAR FROM e1.hire_date) AND
            e2.hire_date > e1.hire_date
    GROUP BY 
        e1.employee_id
)
SELECT 
    e.employee_id,
    cw.count_within_one_year,
    cl.count_later_same_year
FROM 
    employment_dates e
LEFT JOIN 
    count_within_year cw ON e.employee_id = cw.employee_id
LEFT JOIN 
    count_later_same_year cl ON e.employee_id = cl.employee_id
ORDER BY 
    e.employee_id;

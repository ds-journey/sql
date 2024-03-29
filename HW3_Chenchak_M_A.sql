-- создание таблиц

create table customer (
	customer_id int4 primary key,
	first_name varchar(50),
	last_name varchar(50),
	gender varchar(30),
	dob date,
	job_title varchar(50),
	job_industry_category varchar(50),
	wealth_segment varchar(50),
	deceased_indicator varchar (50),
	owns_car varchar (30),
	address varchar(50),
	postcode varchar (30), 
	state varchar (30),
	country varchar (30),
	property_valuation int4
	
);

CREATE TABLE TRANSACTION (
	transaction_id int4 PRIMARY KEY,
	product_id	int4,
	customer_id int4,
	transaction_date date,
	online_order boolean,
	order_status varchar (30),
	brand varchar (30),
	product_line varchar (30),
	product_class varchar (30),
	product_size varchar (30),
	list_price float4,
	standard_cost float4
);

-- Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества.
select c.job_industry_category, count(c.customer_id) as customers_count from customer c 
group by c.job_industry_category 
order by customers_count desc;

-- Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности.
with combined_cte as (
	select date_trunc('month', t.transaction_date) as year_and_month, t.list_price, c.job_industry_category
	from "transaction" t 
	join customer c on t.customer_id = c.customer_id 
)
select cte.year_and_month, cte.job_industry_category, sum(cte.list_price) from combined_cte cte
group by cte.year_and_month, job_industry_category
order by cte.year_and_month, job_industry_category;

-- Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT
SELECT count(t.online_order), t.brand , c.job_industry_category
FROM "transaction"  AS t
JOIN customer AS c ON t.customer_id = c.customer_id
WHERE t.order_status='Approved' AND c.job_industry_category = 'IT' and online_order is true 
GROUP BY t.brand ,c.job_industry_category;


-- Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, 
-- отсортировав результат по убыванию суммы транзакций и количества клиентов. 
-- Выполните двумя способами: используя только group by и используя только оконные функции. Сравните результат.
-- 1 способ:
SELECT  c.customer_id, count(t.transaction_id) AS transaction_count ,sum(list_price) as sum, max(list_price), min(list_price)
FROM "transaction"  AS t
JOIN customer AS c ON t.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY sum desc;

-- 2 способ - через оконные функции: 
with tbl as (
	select c.customer_id, t.list_price
	from "transaction" t 
	join customer c on t.customer_id = c.customer_id 
)
select tbl.customer_id
		,sum(tbl.list_price) over(partition by tbl.customer_id) as sum_transaction
		,min(tbl.list_price) over(partition by tbl.customer_id) as min_transaction
		,max(tbl.list_price) over(partition by tbl.customer_id) as max_transaction
		,count(tbl.list_price) over(partition by tbl.customer_id) as count_transaction
from tbl
ORDER BY sum_transaction desc;

-- Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период (сумма транзакций не может быть null). 
-- Напишите отдельные запросы для минимальной и максимальной суммы.
-- для начала создадим вью
create view temp_tbl as (
	SELECT  c.customer_id, c.first_name, c.last_name, count(t.transaction_id) AS transaction_count ,sum(list_price) as sum
	FROM "transaction"  AS t
	JOIN customer AS c ON t.customer_id = c.customer_id
	GROUP BY c.customer_id
);

-- Поиск клиентов с максимальной суммой транзакций
select first_name, last_name, sum
from temp_tbl t
WHERE sum = (SELECT MAX(sum) FROM temp_tbl);


-- Поиск клиентов с минимальной суммой транзакций
select first_name, last_name, sum
from temp_tbl t
WHERE sum = (SELECT MIN(sum) FROM temp_tbl);

-- Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций.
-- Использую ранжирование для корректного выводв Id транзакции для самой ранней даты
WITH ranked_transactions AS (
    SELECT 
        customer_id,
        transaction_id, 
        transaction_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date) AS transaction_rank
    FROM transaction
)
SELECT 
    customer_id, 
    transaction_id, 
    transaction_date
FROM ranked_transactions
WHERE transaction_rank = 1;


-- Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал вычисляется в днях)
-- максимальная разница между самой первой и самой последней транзакцией
WITH transaction_gaps AS (
    SELECT 
    	c.customer_id,
        c.first_name,
        c.last_name,
        c.job_title,
        first_value(t.transaction_date) over(partition by t.customer_id order by t.transaction_date) as first_transaction_date,
        last_value(t.transaction_date) over(partition by t.customer_id order by t.transaction_date range between current row and unbounded following) as last_transaction_date
    FROM customer c
    JOIN transaction t ON c.customer_id = t.customer_id
)
SELECT distinct 
	first_name,
    last_name,
    job_title,
    transaction_gaps.last_transaction_date - transaction_gaps.first_transaction_date as gap
FROM transaction_gaps
where (transaction_gaps.last_transaction_date - transaction_gaps.first_transaction_date) = 
(select MAX(transaction_gaps.last_transaction_date - transaction_gaps.first_transaction_date) FROM transaction_gaps);


-- максимальная разница между соседними транзакциями
WITH transaction_tab AS (
    SELECT 
     c.customer_id,
        c.first_name,
        c.last_name,
        c.job_title,
       lag(t.transaction_date) OVER (PARTITION BY t.customer_id order by t.transaction_date) AS lag_transaction,
       lead(t.transaction_date) OVER (PARTITION BY c.customer_id ORDER BY t.transaction_date) AS lead_transaction 
    FROM customer c
    JOIN transaction t ON c.customer_id = t.customer_id
)
SELECT distinct 
    first_name,
    last_name,
    job_title,
    transaction_tab.lead_transaction - transaction_tab.lag_transaction as max_interval
FROM transaction_tab
where (transaction_tab.lead_transaction - transaction_tab.lag_transaction) = 
(select MAX(transaction_tab.lead_transaction - transaction_tab.lag_transaction) FROM transaction_tab);

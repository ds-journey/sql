-- создание таблиц

create table customer (
	customer_id int primary key,
	first_name varchar(255),
	last_name varchar(255),
	gender varchar(10),
	DOB date,
	job_title varchar(255),
	job_industry_category varchar(255),
	wealth_segment varchar(255),
	deceased_indicator varchar (1),
	owns_car varchar (4),
	address varchar(255),
	postcode varchar (4), 
	state varchar (255),
	country varchar (100),
	property_valuation int
	
);

CREATE TABLE TRANSACTION (
	transaction_id int PRIMARY KEY,
	product_id	int,
	customer_id int,
	transaction_date date,
	online_order boolean,
	order_status varchar (255),
	brand varchar (255),
	product_line varchar (255),
	product_class varchar (255),
	product_size varchar (255),
	list_price float,
	standard_cost float
);

-- Вывести все уникальные бренды, у которых стандартная стоимость выше 1500 долларов.
select distinct(t.brand) from "transaction" t 
where standard_cost > 1500;

--Вывести все подтвержденные транзакции за период '2017-04-01' по '2017-04-09' включительно.
select t.* from "transaction" t
where t.order_status = 'Approved' and t.transaction_date between '2017-04-01'::date and '2017-04-09'::date;


-- Вывести все профессии у клиентов из сферы IT или Financial Services, которые начинаются с фразы 'Senior'.
select c.job_title from customer c 
where c.job_title like 'Senior%' and (c.job_industry_category = 'IT' or c.job_industry_category = 'Financial Services');

-- Вывести все бренды, которые закупают клиенты, работающие в сфере Financial Services
select distinct(t.brand) from "transaction" t 
where t.customer_id in (select c.customer_id  from customer c 
where c.job_industry_category = 'Financial Services');

-- Вывести 10 клиентов, которые оформили онлайн-заказ продукции из брендов 'Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'.
select c.first_name, c.last_name from customer c
where c.customer_id in (select t.customer_id from "transaction" t where t.brand in ('Giant Bicycles', 'Norco Bicycles', 'Trek Bicycles'));

-- Вывести всех клиентов, у которых нет транзакций.
select c.first_name, c.last_name from customer c
where c.customer_id not in (select t.customer_id from "transaction" t);

-- Вывести всех клиентов из IT, у которых транзакции с максимальной стандартной стоимостью.
select c.customer_id, c.first_name, c.last_name, c.job_industry_category, t.standard_cost  from customer c  
join "transaction" t on c.customer_id = t.customer_id
where c.job_industry_category = 'IT' and t.standard_cost notnull and t.standard_cost = (select max(t.standard_cost) from "transaction" t);

-- Вывести всех клиентов из сферы IT и Health, у которых есть подтвержденные транзакции за период '2017-07-07' по '2017-07-17'.
select c.customer_id, c.first_name, c.last_name, c.job_industry_category, t.transaction_date,  t.order_status  from customer c  
join "transaction" t on c.customer_id = t.customer_id
where c.job_industry_category in ('IT', 'Health') and t.order_status = 'Approved' and t.transaction_date between '2017-07-07'::date and '2017-07-17'::date;

-- creating database
create database if not exists salesDataWalmart;

-- creating table
Create table if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10, 2)not null,
    quantity int not null,
    VAT float(6, 4)not null,
    total decimal(12, 4) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15)not null,
    cogs decimal(10, 2) not null,
    gross_margin_pct float(11, 9),
    gross_income decimal(12, 4) not null,
    rating float(2, 1)
);
-- ---------------------------------------------------------------------------------------------------------------------
-- ----------------feature  engineering---------------------------------------------------------------------------------

-- time_of_day

select
	time,
    (CASE 
		when time between '00:00:00' and '12:00:00' then "Morning"
        when time between '12:01:00' and '16:00:00' then "Afternoon"
        ELSE "Evening"
    END 
    )AS time_of_date
FROM sales;

alter table sales add column time_of_day varchar(20);

update sales 
set time_of_day = (
	CASE 
		when time between '00:00:00' and '12:00:00' then "Morning"
        when time between '12:01:00' and '16:00:00' then "Afternoon"
        ELSE "Evening"
    END 
);

-- day_name----------------------------------------------------------

select 
	date,
    dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);


-- month_name--------------------------------------------------------------

select date, monthname(date)
from sales;

alter table sales add column month_name varchar(10);

update sales 
set month_name = monthname(date);

-- -------------------------------------------------------------------------------------------------------------------

-- EDA
-- Business questions to answer

-- generic questions

-- 1. how many unique cities does the data have?

select distinct(city) from sales;

-- 2. in which city is each branch?
select distinct(city), branch from sales;

-- product questions-----------------------------------------

-- 1. how many unique product lines does the data have?
select count(distinct(product_line)) from sales;

-- 2. most common payment method?
select payment_method, count(payment_method) as cnt from sales 
group by payment_method
order by cnt;

-- 3. what is the most selling product line;
select product_line, count(product_line) as pl from sales
group by product_line
order by pl;

-- 4. What is the total revenue by month?
select month_name as month, 
sum(total) as total_revenue 
from sales
group by month_name 
order by total_revenue desc;

-- 5. which month had the largest cogs(cost of goods sold)?
select month_name as month, 
sum(cogs) as total_cogs 
from sales
group by month_name 
order by total_cogs desc;

-- 6. which product line had the largect revenue?
select product_line, 
sum(total) as total_rev 
from sales
group by product_line 
order by total_rev desc;

-- 7. What is the city with the largest revenue?
select city, branch, 
sum(total) as total_rev 
from sales
group by city, branch 
order by total_rev desc;

-- 8. what product line had the largest VAT?
select product_line,
avg(VAT) as avg_vat 
from sales
group by product_line 
order by avg_vat desc;

-- 9. which branch sold more products than average product sold?
select branch,
sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- 10. most common product line by gender?
select gender,
product_line,
count(gender) as cnt
from sales
group by gender, product_line
order by cnt;

-- 11. what is the avg rating of each product line?
select product_line,
round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc;

-- 12. -- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;
-- -----------------------------------------------------------------

-- sales questions
-- 1. no. of sales made in each time of the day per weekday?
select time_of_day, count(*) as total_sales
from sales
where day_name = "Sunday"
group by time_of_day
order by total_sales desc;

-- 2. which of the customer type brings the moat revenue?
select customer_type, sum(total) as total_rev
from sales
group by customer_type
order by total_rev desc;

-- 3. which city has the largest tax percent/VAT?
select city, sum(VAT) as total_VAT
from sales
group by city
order by total_VAT desc;

-- 4. which customer has the largest tax percent/VAT?
select customer_type, sum(VAT) as total_VAT
from sales
group by customer_type
order by total_VAT desc;
-- ------------------------------------------------------------------------

-- customer questions
-- 1. how many unique customer types does the data have?
select distinct(customer_type) from sales;

-- 2. how many unique payment methods does the data have?
select distinct(payment_method) from sales;

-- 3. most common customer type?
select customer_type, count(customer_type) as cnt
from sales
group by customer_type
order by cnt desc;

-- 4. customer type that buys the most?
select customer_type, count(*) as cnt_qty
from sales
group by customer_type
order by cnt_qty desc;

-- 5. what is the gender of most of the customers?
select gender, count(*) as cnt_qty
from sales
group by gender
order by cnt_qty desc;

-- 6. what is the gender distribution per branch?
select branch, gender, count(*) as cnt_qty
from sales
group by branch, gender;

-- 7. what tme of the day customers give the most ratings?
select time_of_day, avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating desc;

-- 8. what tme of the day customers give the most ratings per branch?
select time_of_day, branch, avg(rating) as avg_rating
from sales
group by time_of_day, branch;

-- 9. which day of the week has the best rating?
select day_name, avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- 9. which day of the week has the best rating per branch?
select day_name, branch, avg(rating) as avg_rating
from sales
group by day_name, branch
order by avg_rating desc;
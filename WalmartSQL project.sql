CREATE database Walmatsalesdata ;
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    tax_pct FLOAT NOT NULL CHECK (tax_pct >= 0 AND tax_pct <= 100),
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct DECIMAL(5, 2),  -- Changed to DECIMAL
    gross_income DECIMAL(12, 4),
    rating DECIMAL(2, 1)  -- Changed to DECIMAL
);


-- feature engineering

-- time of day
select 
	time,
    (Case
		when 'time' between "00:00:00" and "12:00:00" then "Morning"
        when 'time' between "12:01:00" and "16:00:00" then "Afternoon"
        else "Evenimg"
    end) as time_of_day
from sales;

update sales
set time_of_day = (
	Case
		when 'time' between "00:00:00" and "12:00:00" then "Morning"
		when 'time' between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evenimg"
	end
	);
    
    
-- day_name
Select
	date,
    dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);

-- month_name

select
	date,
    monthname(date)as month_name
from sales;

alter table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);


-- how many unique cities does the data have?
select
	distinct city
from sales;

-- In which city is each branch?
select
	distinct city,
    branch
from sales;

-- How many unique product lines does the data have?
select
	count(distinct product_line)
from sales;

-- What is the most common payment method?
select
	 payment,
	 count(payment) as count
from sales
group by payment
order by count desc;

-- most sold product
select
	product_line,
	 count(product_line) as count
from sales
group by product_line
order by count desc;

-- total revenue per month
select
	 month_name as month_name,
     sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- Month with the largest cost of goods sold

select
	 month_name as month_name,
     sum(cogs) as total_cogs
from sales
group by month_name
order by  total_cogs desc;

-- product line with largest revenue
select
	 product_line,
     sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- What city had the largest revenue
select
	 branch,
	 city,
     sum(total) as total_revenue
from sales
group by city, branch
order by total_revenue desc;

-- product line with the most VAT
select
	product_line,
    avg(tax_pct) as vat
from sales
group by product_line
order by vat desc;

-- branch with the more products than average sold
select
	branch,
    sum(quantity) as qty
    
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- most common product line by gender?
select 
	gender,
    product_line,
    count(gender) as total
from sales
group by gender, product_line
order by total desc;

-- average rating of each product line?
select
	round(avg(rating), 2) as avg_rating,
    product_line
from sales
group by product_line
order by avg_rating desc;

-- Sales analysis
--  number of sales made at each time of the day
 Select 
	time_of_day,
    count(*) as total_sales
from sales
where day_name = "Monday"
group by time_of_day
order by total_sales desc;

-- which of the customer types generate the most revenue?
select
	customer_type,
    sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc;

-- which city has the largest tax percent/vat?
select
	city,
    avg(vat) as tax_percent
from sales
group by city
order by tax_percent desc;


-- wcustomer type that pays the most vat?
select
	customer_type,
	avg(vat) as VAT
from sales
group by customer_type
order by VAT desc;

-- Customer analysis
-- how many customer types does the data have?
select
	distinct(customer_type),
     count(customer_type) as total
from sales
group by customer_type
order by total;

-- how many payment methods does the data have?
select
	distinct(payment)
from sales;

-- customer gender
select
	gender,
    count(gender) as total
from sales
group by gender
order by total desc;

-- gender distribution per branch
select
	gender,
    count(gender) as total
from sales
where branch = 'A'
group by gender
order by total desc;

-- what time of the day dow customers give the most rating
select
	time_of_day,
    avg(rating) as avg_rating
from sales
where branch = "A"         
group by time_of_day
order by avg_rating desc;

-- day of the week with the most rating
select
	day_name,
    avg(rating) as avg_rating
from sales
where branch = "A"
group by day_name
order by avg_rating desc;



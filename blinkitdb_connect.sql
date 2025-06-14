-- Business Requirement
-- Analyze Blinkit’s sales, customer satisfaction, and inventory using KPIs and Power BI visualizations to find optimization opportunities.

-- Key KPIs
-- Total Sales: Overall revenue

-- Average Sales: Revenue per sale

-- Number of Items: Total items sold

-- Average Rating: Customer feedback score

-- Granular Requirements
-- Sales by Fat Content – Impact of fat on sales

-- Sales by Item Type – Performance by item category

-- Fat Content by Outlet – Outlet-wise fat-based sales

-- Sales by Establishment Type – Influence of outlet age/type

-- Chart Requirements
-- % Sales by Outlet Size – Size vs. sales share

-- Sales by Location – Geographic sales view

-- All KPIs by Outlet Type – Full metric breakdown by type





CREATE DATABASE blinkit_data;
USE blinkit_data;
CREATE TABLE blinkit_products (
    Item_Fat_Content VARCHAR(50),
    Item_Identifier VARCHAR(20),
    Item_Type VARCHAR(100),
    Outlet_Establishment_Year INT,
    Outlet_Identifier VARCHAR(20),
    Outlet_Location_Type VARCHAR(50),
    Outlet_Size VARCHAR(20),
    Outlet_Type VARCHAR(50),
    Item_Visibility DECIMAL(10,8),
    Item_Weight DECIMAL(10,4),
    Sales DECIMAL(10,5),
    Rating DECIMAL(10,2)
);
RENAME TABLE blinkit_products TO blinkit_data;
ALTER TABLE blinkit_data
MODIFY COLUMN Item_Weight DECIMAL(10,4) NULL;
SHOW VARIABLES LIKE 'secure_file_priv';

ALTER TABLE blinkit_data
MODIFY COLUMN Item_Visibility DECIMAL(13,12);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\blinkit_products.csv'
INTO TABLE blinkit_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Item_Fat_Content, Item_Identifier, Item_Type, Outlet_Establishment_Year, 
 Outlet_Identifier, Outlet_Location_Type, Outlet_Size, Outlet_Type, 
 Item_Visibility, @Item_Weight, Sales, Rating)
SET Item_Weight = NULLIF(@Item_Weight, '');

show warnings;
select * from blinkit_data;
SELECT COUNT(*) FROM blinkit_data;
TRUNCATE TABLE blinkit_data;

Select distinct(Item_Fat_Content) from blinkit_data;




update blinkit_data
set item_fat_content=
case
when Item_Fat_Content in ('LF','low fat') then 'Low Fat'
when Item_Fat_Content ='reg' Then 'Regular'
else Item_Fat_Content
end;



select sum(Sales) as total_sales from blinkit_data;
select concat(cast(sum(Sales)/1000000 as decimal(10,2)) ,' million') as total_sales_as_million from blinkit_data;

select avg(sales) from blinkit_data;
select cast(avg(sales) as decimal(10,1)) as avg_sales from blinkit_data;

select count(*) as num_of_items from blinkit_data;

select concat(cast(sum(Sales)/1000000 as decimal(10,2)) ,' million') as total_sales_as_million from blinkit_data
where Item_Fat_Content='Low Fat';

select avg(rating) from blinkit_data;
select item_fat_content, cast(sum(sales)/100000 as decimal(10,3)) as total_sales from blinkit_data group by Item_Fat_Content order by total_sales desc;

select item_fat_content, 
cast(sum(sales)/100000 as decimal(10,3)) as total_sales ,
cast(avg(sales) as decimal(10,1)) as avg_sales,
count(*) as num_of_items,
cast(avg(Rating) as decimal(10,2)) as avg_rating
from blinkit_data 
where Outlet_Establishment_Year=2022
group by Item_Fat_Content 
order by total_sales desc;

#TOP 5
select Item_Type, 
cast(sum(sales)/100000 as decimal(10,3)) as total_sales ,
cast(avg(sales) as decimal(10,1)) as avg_sales,
count(*) as num_of_items,
cast(avg(Rating) as decimal(10,2)) as avg_rating
from blinkit_data 
where Outlet_Establishment_Year=2022
group by Item_Type
order by total_sales desc
LIMIT 5;

#one way is to present like this (not so good)
select Outlet_Location_Type,Item_Fat_Content ,
cast(sum(sales)/100000 as decimal(10,3)) as total_sales 
from blinkit_data 
group by Outlet_Location_Type,Item_Fat_Content 
order by total_sales desc;

#better way
SELECT 
  Outlet_Location_Type,
  #It sums sales for each location only when Item_Fat_Content is 'Low Fat', else adds 0.
  CAST(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Sales ELSE 0 END)/100000 AS DECIMAL(10,3)) AS `Low Fat`,
  CAST(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Sales ELSE 0 END)/100000 AS DECIMAL(10,3)) AS `Regular`
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

select Outlet_Establishment_Year,
cast(sum(sales)/100000 as decimal(10,3)) as total_sales ,
cast(avg(sales) as decimal(10,1)) as avg_sales,
count(*) as num_of_items,
cast(avg(Rating) as decimal(10,2)) as avg_rating
from blinkit_data  
group by Outlet_Establishment_Year
order by total_sales desc;


SELECT
Outlet_Size,
cast(sum(sales) as decimal(10,2)) AS Total_Sales,
cast((sum(sales)*100.0/sum(sum(sales)) over()) as decimal(10,2)) as sales_percentage
#SUM(SUM(Sales)) OVER() It adds up all the SUM(Sales) values, across all groups. So, this gives the grand total sales.
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

select Outlet_Location_Type,
cast(sum(sales)/100000 as decimal(10,3)) as total_sales ,
cast((sum(sales)*100.0/sum(sum(sales)) over()) as decimal(10,2)) as sales_percentage,
cast(avg(sales) as decimal(10,1)) as avg_sales,
count(*) as num_of_items,
cast(avg(Rating) as decimal(10,2)) as avg_rating
from blinkit_data  
#can use where also here
group by Outlet_Location_Type
order by total_sales desc;


select Outlet_Type,
cast(sum(sales)/100000 as decimal(10,3)) as total_sales ,
cast((sum(sales)*100.0/sum(sum(sales)) over()) as decimal(10,2)) as sales_percentage,
cast(avg(sales) as decimal(10,1)) as avg_sales,
count(*) as num_of_items,
cast(avg(Rating) as decimal(10,2)) as avg_rating
from blinkit_data  
#can use where also here
group by Outlet_Type
order by total_sales desc;
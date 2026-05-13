use ChocolateDB
go 

------------------------------------------------
select * from sales 
select * from stores
select * from calendar
select * from Customers
select * from products
------------------------------------------------


-- Convert discount_old column from TIME to DECIMAL percentage format in new column as (discountDecimal)
alter table sales 
add discount decimal(5,2)

update sales
set discountDecimal = datepart(minute, discount) / 100.0

/*  
	alter table sales 
	drop column discount_old
*/
------------------------------------------------

-- Checked for duplicate records using COUNT and COUNT DISTINCT
select count(distinct(customer_id))
from customers

select count(*)
from customers 
------------------------------------------------

-- View for Analysis

-----------------Total Revenue-----------------


go

create view Total_Revenue as 

select sum(revenue) TotalRevenue
from sales 

go

select * from Total_Revenue ;

-----------------Total Profit-----------------
go 

create view Total_Profit as

select SUM(Profit) TotalProfit

from sales

go

select * from Total_Profit

-----------------Total Orders-----------------
go

create view Total_Orders as 

select count(distinct(order_id)) TotalOrders 

from sales

go

select * from Total_Orders

-----------------Total Customers-----------------
go

create view Total_Customers as

select count(customer_id) TotalCustomers

from customers

go

select * from Total_Customers

---------------Profit Margin--------------------
go

create view	Profit_Margin as 

select sum(Profit) Total_Profit, 
	
	sum(revenue)Total_Revenue,
	
	concat(round((sum(profit)/sum(revenue)*100),3),'%') as ProfirMargin

from sales 

go

select * from Profit_Margin

---------------------Sales by Country---------------------
go

create view Total_Sales_By_Country as 

select country ,

round(sum(revenue),2) as TotalSalesForCountry

from stores

join sales 

on sales.store_id = stores.store_id

group by country

go

select * from Total_Sales_By_Country 

-----------------Sales by Category-----------------
go 

create view Total_Sales_By_Category as

select category , 

round(sum(revenue),2) TotalSalesForCategory

from products

join sales

on sales.product_id = products.product_id

group by category

go

select * from Total_Sales_By_Category

-----------------Top Products By Brand-----------------
go 

create view Top_Products_By_Brand as 

with A_brand as (
	
	select brand , product_name , category ,

	sum(revenue) TotalRevenue ,

	sum(profit) TotalProfit , 

	sum(quantity) TotalQuantity

	from products

	join sales 

	on products.product_id = sales.product_id

	group by brand , product_name , category 
)

select * ,	
	
	rank() over(partition by brand order by TotalRevenue desc) as ProductRank

from A_brand

go

select * from Top_Products_By_Brand

-----------------Top Customers-----------------
go 

create view Top_Customers as 

select top 10 sales.customer_id , 

round(sum(revenue),2) as TotalForCustomer

from sales 

join customers

on customers.customer_id = sales.customer_id

group by sales.customer_id

order by TotalForCustomer desc

go 

select * from Top_Customers


-----------------Monthly Trend-----------------
go 

create view Monthly_Revenue_Growth as 

with CTE_Revenue as (

select year(order_date) Years,

	month(order_date) Months , 

	round(sum(revenue),2) as TotalRevenue

from sales

group by year(order_date) , month(order_date) 

)

select 
	DATEFROMPARTS(years , months , 1) Date,
	* ,
	
	isnull(lag(TotalRevenue) over(order by years , months),0)PreviousMonth ,

	isnull(TotalRevenue - lag(TotalRevenue) over(order by years, months),0) RevenueDifference ,

	isnull(round(((TotalRevenue - lag(TotalRevenue) over(order by years, months)) / 
	
	lag(TotalRevenue) over(order by years, months)) * 100,2),0) GrowthPercentage

from CTE_Revenue

go 

select * from Monthly_Revenue_Growth


-----------------Top Products Analysis-----------------
go 

create view Top_Products_Analysis as 

select product_name , 

		brand ,
		
		category , 

		sum(revenue) as TotalRevenue ,

		sum(profit) as TotalProfit ,

		sum(quantity) as TotalQuantity

from products

join sales

on sales.product_id = products.product_id

group by product_name , category , brand

go 

select * from Top_Products_Analysis

-----------------Top Company Analysis-----------------
go 

create view Brand_Performance_Analysis as 

select brand , 

	sum(revenue) as TotalRevenue ,

	sum(profit) as TotalProfit

from products

join sales

on sales.product_id = products.product_id

group by brand

go 

select * from Brand_Performance_Analysis

-----------------Gender Analysis-----------------
go 

create view Top_Gender as 

select gender , loyalty_member , 

	sum(revenue) as TotalRevenue ,

	sum(profit) as TotalProfit ,

	count(distinct(order_id)) as TotalOrders

from customers

join sales

on sales.customer_id = customers.customer_id

group by gender , loyalty_member 

go 

select * from Top_Gender

------------------- Store Performance Analysis-----------------
go 

create view Store_Performance_Analysis as

with CTE_stores as (

select stores.store_id , country , store_type ,
	
	sum(revenue) TotalRevenue ,

	sum(profit) TotalProfit

from stores

join sales

on sales.store_id = stores.store_id

group by stores.store_id , country , store_type 

)

select * ,
	
	rank() over(partition by country order by TotalRevenue desc) as RankStores

from CTE_stores

go

select * from Store_Performance_Analysis

-------------------------------------------------------


# Maven Toys Analysis
Sales and Inventory analysis of the Maven Toys Chain Stores in Mexico.

# Overview
We have been provided with sales & inventory data for a fictitious chain of toy stores in Mexico called Maven Toys, 
including information about products, stores, daily sales transactions, and current inventory levels at each location. 

The data spans from January 1st 2017 to September 30th 2018, containing over 820,000 transactions for all stores owned by Maven Toys. 

The objective is to prepare the data, analyze and visualize it, and subsequently outline findings which allow the toy store chain to 
enhance its decision making capabilities and boost profits. 

The major questions that we will attempt to answer are:
1) Which product categories drive the biggest profits? Is this the same across store locations?
2) Are there any seasonal trends or patterns in the sales data?
3) Are sales being lost with out-of-stock products at certain locations?
4) How much money is tied up in inventory at the toy stores? How long will it last?

# Data Colletion
The data used within this project is provided from the following link:  
[Maven Toys Sales | Kaggle](https://www.kaggle.com/datasets/mysarahmadbhat/toy-sales)

We are provided with four tables which contain the following fields:

### Products (35 unique products)
1) Product_ID - Unique ID given to each product offered  
2) Product_Name - Unique name given to each product offered  
3) Product_Category - Category group assigned to each product based on its characteristics/utility  
4) Product_Cost - Expense incurred for making/attaining the product, in US dollars  
5) Product_Price - Price at which the product is sold to customers, in US dollars   

### Stores (50 different stores)
1) Store_ID - Unique store ID given to each toy store  
2) Store_Name - Unique store name given to each toy store  
3) Store_City - City in Mexico where the store is located  
4) Store_Location - Classification of location in the city where the store is located (Downtown,   
  Commercial, Residential, Airport)  
5) Store_Open_Date - Date when the store was opened  

### Sales
1) Sale_ID - Unique Sale_ID for each transaction conducted in a store  
2) Date - Date on which the transaction occurred  
3) Store_ID - Unique store ID given to each toy store  
4) Product_ID - Unique ID given to each product offered  
5) Units - No of units of the product sold  
 
### Inventory:
1) Store_ID - Unique store ID given to each toy store  
2) Product_ID - Unique ID given to each product offered  
3) Stock_On_Hand - Stock quantity of the product in the store  
 
# Data Preparation:
Given the nature of the information provided, it is beneficial to place it into a MySQL database. 
The data has been separated into multiple tables that can be linked to each other based on identical fields. 
Queries provide for quick and easy manipulation of data and access to useful database insights. 
The usage of a database also guarantees a level of data integrity based on the enforced data types within our tables. 
Establishing constraints such as primary and foreign keys also allows us to avoid incorrect values and duplicated data which 
gives us confidence that the data we are using is accurate.   

### Data Model
![MavenToys Database Schema](https://user-images.githubusercontent.com/45236211/205615304-81c3d805-5bdc-4004-81a5-be2990bf2d0f.PNG)

### SQL Database Schema Creation
[MavenToys Database Creation](https://github.com/acyrus/Maven-Toys-Analysis/blob/main/Database%20Schema%20Creation.sql)

### Importing Data Into CSV Files
[CSV File Import](https://github.com/acyrus/Maven-Toys-Analysis/blob/main/Data%20Import%20from%20CSV%20Files.sql)

The data provided is fairly simple and easy to understand. After double checking imports and comparing it to source data, we are confident 
that the data has been imported successfully and accurately. 



# Data Analysis
Exploratory Data Analysis techniques in MySQL will be used to analyze the prepared dataset. This will allow us to produce descriptive statistics
which helps to understand patterns, detect outliers and find interesting relations among the variables. We will utilize various SQL elements such
as Aggregate Functions, Joins, Temporary Tables, CTEs, Views, Stored Procedures and Window Functions. 


[Complete Data Analysis Repository In MySQL](https://github.com/acyrus/Maven-Toys-Analysis/blob/main/SQL%20Data%20Analysis.sql)


1. How many of our 35 products are offered in each of our 50 stores?

```
CREATE VIEW v_productsperstore AS
    SELECT DISTINCT
        st.store_id,
        st.store_name,
        COUNT(DISTINCT p.product_id) AS products_offered
    FROM
        stores st
            JOIN
        sales s ON s.store_id = st.store_id
            JOIN
        products p ON p.product_id = s.product_id
    GROUP BY st.store_id
    ORDER BY store_id;

SELECT * FROM v_productsperstore;
```

2.  Which units are not being sold by each of our 50 stores?
```
-- Creation of the temporary table that will store the units sold for each product of each store
CREATE TEMPORARY TABLE prodstoresales
(
	store_id INT,
    product_id INT,
    product_name VARCHAR(100),
    units_sold INT
);

-- Procedure which returns the sum of units sold for each product within each store, including products not sold by certain stores

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS p_prodstoresales()
BEGIN
	 DECLARE v_store_id INT;
     SET v_store_id=1;
 
 WHILE (v_store_id < 51) DO
	
    INSERT INTO prodstoresales
	
    WITH storesales AS
	(
    SELECT v_store_id AS store_id,p.product_id,p.product_name, COALESCE(sum(s.units),0) AS units_sold
	FROM products p
	LEFT JOIN sales s ON
	s.product_id=p.product_id
	AND s.store_id=v_store_id
	GROUP BY p.product_id
	ORDER BY p.product_id
    )
    
	SELECT * FROM storesales;
	SET v_store_id=v_store_id+1;

 END WHILE;
END$$

DELIMITER ;

CALL p_prodstoresales;

SELECT * FROM prodstoresales
WHERE units_sold=0;
```



3. What is the sales and profit calculation of each transaction within our stores?
```
ALTER TABLE products
ADD COLUMN profit DOUBLE;

UPDATE products
SET profit=ROUND(product_price-product_cost);

CREATE TEMPORARY TABLE SaleProfitCalc
SELECT 
	s.sale_id, s.sale_date, s.store_id, s.product_id, s.units, 
    p.product_cost, p.product_price,
    (p.product_cost)*s.units AS cost_price,
    (p.product_price)*s.units AS sales,
    ROUND(((p.product_price)*s.units)-((p.product_cost)*s.units))AS profit

FROM 
sales s
JOIN products p 
ON s.product_id=p.product_id;

SELECT * FROM SaleProfitCalc;
```
4. What is the daily running sales and profit for each store and each product?
```
SELECT 
	spc.sale_id, spc.sale_date, spc.store_id, spc.product_id, spc.units, 
    spc.product_cost, spc.product_price, spc.cost_price, spc.sales,
	SUM(spc.sales) OVER (PARTITION BY spc.store_id ORDER BY spc.store_id, spc.sale_date) AS running_total_sales,
    SUM(spc.profit) OVER (PARTITION BY spc.store_id ORDER BY spc.store_id, spc.sale_date) AS running_total_profit
FROM 
SaleProfitCalc spc;
```
5. What is the total running sales for each month across all stores?
```
WITH monthlysales AS
(SELECT
	spc.sale_date,
    MONTH(spc.sale_date) AS month,
    YEAR(spc.sale_date) AS year,
    SUM(spc.sales) AS total_sales
    FROM 
	SaleProfitCalc spc
    GROUP BY MONTH(spc.sale_date),YEAR(spc.sale_date)
)
SELECT	
	monthlysales.*,
    SUM(monthlysales.total_sales) OVER (ORDER BY monthlysales.year, monthlysales.month) AS rolling_monthly_sales 
FROM
	monthlysales;
```

6. What are the three best selling products within each of our stores?
```
SELECT st.store_name, p.product_name, aa.row_num
FROM 
(SELECT a.* FROM
(SELECT
	spc.store_id,
    spc.product_id,
    SUM(spc.sales) AS total_sales,
	ROW_NUMBER() OVER (PARTITION BY spc.store_id ORDER BY SUM(spc.sales) DESC) AS row_num
FROM 
SaleProfitCalc spc
GROUP BY spc.store_id,spc.product_id) a
WHERE a.row_num<=3) aa
JOIN stores st ON st.store_id=aa.store_id
JOIN products p ON p.product_id=aa.product_id;
```

7. What are the number of units of each product sold within each story daily?
```
CREATE TEMPORARY TABLE UnitsSoldDaily
  SELECT
  s.sale_date,
  p.product_id,
  st.store_id,
  SUM(s.units) AS units_sold
  FROM
  sales s
  JOIN stores st
  ON st.store_id=s.store_Id
  JOIN products p ON
  p.product_id=s.product_id
  GROUP BY p.product_id,st.store_id,s.sale_date;
 ```
 
8. What are the units of each product sold each month?
```
CREATE TEMPORARY TABLE UnitsSoldMonthlyYearly
 SELECT 
	YEAR(usd.sale_date) AS Year, 
	CASE 
		WHEN MONTH(usd.sale_date)=1 THEN 'January'
		WHEN MONTH(usd.sale_date)=2 THEN 'February'
		WHEN MONTH(usd.sale_date)=3 THEN 'March'
		WHEN MONTH(usd.sale_date)=4 THEN 'April'
		WHEN MONTH(usd.sale_date)=5 THEN 'May'
		WHEN MONTH(usd.sale_date)=6 THEN 'June'
		WHEN MONTH(usd.sale_date)=7 THEN 'July'
		WHEN MONTH(usd.sale_date)=8 THEN 'August'
		WHEN MONTH(usd.sale_date)=9 THEN 'September'
		WHEN MONTH(usd.sale_date)=10 THEN 'October'
		WHEN MONTH(usd.sale_date)=11 THEN 'November'
		ELSE 'December'
    END AS 'Month',
	p.product_id,
	st.store_id,
    SUM(usd.units_sold) AS total_units_sold
 FROM UnitsSoldDaily usd
 JOIN products p ON p.product_id=usd.product_id
 JOIN stores st ON st.store_id=usd.store_id
 GROUP BY YEAR(usd.sale_date), MONTH(usd.sale_date),p.product_id, st.store_id;
 ```
9. What is the total revenue and profit of our remaining stock from all stores?
```
WITH inventory_sales AS
(SELECT 
    i.*,
    p.product_cost,
    p.product_price,
    ROUND((i.stock_on_hand * p.product_cost),2) AS stock_cost,
    ROUND((i.stock_on_hand * p.product_price),2) AS stock_revenue
FROM
    inventory i
        JOIN
products p ON i.product_id = p.product_id
)
SELECT 
	invs.*,
    ROUND((invs.stock_revenue-invs.stock_cost),2) AS stock_profit
FROM
	inventory_sales invs;
 ```
# Data Visualization
After completing our initial analysis in MySQL, selected queries were exorted to Power BI, a visualization tool. Data visualization is essential, 
as the grahical representation of data sets provides context to our data and allows us to visualze trends and patterns much more easily. 

[Maven Toys Dashboards (PDF)](https://github.com/acyrus/Maven-Toys-Analysis/blob/main/Maven%20Toys%20Dashboards.pdf)

### Sales and Profit Dashbaord
This dashboard provides graphical illustrations of Maven Toys' sales and profit statistics with the ability to filter the result by multiple categories 
such as Date, Store Location, and Product Category. Such information enables Maven Toys to identify elements of its business which drive sales and profits
most significantly. 

![Maven Toys Sales and Profit Dashboard](https://user-images.githubusercontent.com/45236211/205647077-75ecaf7a-d976-44c9-8bb0-a6a35ecca434.jpg)


### Units and Inventory Dashboard
This dashboard visualizes the number of units sold and examines the status of the current stock on hand. Equipped with similar filter capabilities as the previous dashboard, this dashboard provides insight into the number of units sold across time, which assists Maven Toys in planning for future demand. 

![Maven Toys Units and Inventory Dashboard](https://user-images.githubusercontent.com/45236211/205646328-dfd74f59-a591-4746-a8dc-796c04851d2b.jpg)

# Discussion

### 1. Which product categories drive the biggest profits? Is this the same across store locations?

From a review of the dashboard, it was observed that ‘Toys’ was the leading product category in profits 1.1mil, followed by Electronics at 1.0mil. 
However, it was noted that Electronics had a profit margin of 44.6% making it the most profitable Product Category. 
Comparing across store locations however reveals that Toys were the most profitable in Downtown and Residential areas only.. Electronics was most profitable at Airports and Commercial, 

### 2. Are there any seasonal trends or patterns in the sales data?
It was noticed that there was a decrease in sales June to August, 2017 followed by a steady increase from September to December. The spike in December of 2017 
is most likely due to increased demand of toys for Christmas. From 2018 onwards, sales decrease somewhat but maintains a constant level until July until it drops again, similar to what happened the year before. If history repeats itself, the business should expect an increase in sales once again at the end of the year. 

### 3. Are sales being lost with out-of-stock products at certain locations?
An initial observation displays that not every store offers all 35 products. One may assume that stores that offer all 35 products will generally have more sales, 
but this is not necessarily the case. The top selling store, Ciudad de Mexico 2 with 554k USD in sales only offers 30 products. Additionally, of the top 5 selling stores, 3 of them offer only 30 products. It is assumed that these stores all do not offer the same 5 products.
Given this context, these 5 remaining products likely do not affect much sales.

### 4. How much money is tied up in inventory at the toy stores? 
According to the dashboard, Maven Toys should expect 410k in sales and 110k in profit based on the remaining inventory across all its stores. This is assuming
that all product costs and prices remain the same.

### 5. How long will it last?
Currently, there are 29,742 units of toys across all stores. A high level overview suggests that this figure is inadequate to meet the monthly demand of customers, 
as the monthly average of units sold thus far has amounted to 52,000 units. It should be noted however, that this figure will vary from store to store. 
Despite an increase in the number of units sold within the past 3 months, the average amount of units being sold has trended upwards. Judging from prior quarters, it is likely that demand in the next three months will exceed the monthly average of units sold. If the trend continues, Maven Toys will need to acquire more than 52,000 units monthly in order to meet the end of year demand. 

 


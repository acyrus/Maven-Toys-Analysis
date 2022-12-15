USE maventoys;
       
-- View to return the unique amount of products offered at each store
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


-- Creation of temporary table that will store the amount of units sold for each product of each store
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


-- Execution of the procedure previously created
CALL p_prodstoresales;


-- Filtering to return products not sold by each store 
SELECT 
    st.store_name,
    ps.product_name,
    ps.units_sold
FROM
	prodstoresales ps
JOIN 
	stores st ON
ps.store_id=st.store_id
WHERE units_sold=0;


-- Return the product name and number of stores which do not offer it
SELECT p.product_name, COUNT(p.product_name) AS no_of_times
FROM prodstoresales ps
JOIN products p ON ps.product_id=p.product_id
WHERE units_sold=0
GROUP BY p.product_name
ORDER BY COUNT(p.product_name) DESC;


-- Calculating the total sales and profit for each transaction of each store
DROP TEMPORARY TABLE SaleProfitCalc;
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

-- Calculating the sales and profit for each store
SELECT 
    st.store_name,
    ROUND(SUM(spc.sales),2) AS sales,
    ROUND(SUM(spc.profit),2) AS profit
FROM
    SaleProfitCalc spc
        JOIN
    stores st ON st.store_id = spc.store_id
GROUP BY st.store_name;

-- Finding the number of units sold, total sales and profit for each product
SELECT 
    p.product_name,
    SUM(spc.units) AS units_sold,
    ROUND(SUM(spc.sales), 2) AS sales,
    ROUND(SUM(spc.profit), 2) AS profit
FROM
    SaleProfitCalc spc
        JOIN
    products p ON p.product_id = spc.product_id
GROUP BY p.product_name;


-- Finding the total sales and profit for each city whose sales is greater than $1 million 
SELECT 
    st.store_city,
    ROUND(SUM(spc.sales), 2) AS sales,
    ROUND(SUM(spc.profit), 2) AS profit
FROM
    SaleProfitCalc spc
        JOIN
    stores st ON st.store_id = spc.product_id
GROUP BY st.store_city
HAVING ROUND(SUM(spc.sales), 2) > 1000000;


-- Finding the daily total running sales and profit for each store
SELECT 
    spc.sale_date, spc.store_id, spc.sales,
    SUM(spc.sales) OVER (PARTITION BY spc.store_id ORDER BY spc.store_id, spc.sale_date) AS running_total_sales,
    SUM(spc.profit) OVER (PARTITION BY spc.store_id ORDER BY spc.store_id, spc.sale_date) AS running_total_profit
FROM 
SaleProfitCalc spc;

-- Finding the monthly total running sales across all stores
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

  
-- Finding the best selling products within each store
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
JOIN products p ON p.product_id=aa.product_id
ORDER BY st.store_id, aa.row_num;
SHOW WARNINGS;


-- Calculating the number of units sold of each product with each store daily
DROP TEMPORARY TABLE UnitsSoldDaily;
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
  
  
 -- Displaying the total number of units sold for each product and for each store in each month of each year
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
 

-- Calculating the total costs, revenue and profit in the stock on hand of all stores
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
	
-- Table creation to compare statistics across aggeegate date values in PowerBI
CREATE TABLE daymonthyear (
    sale_date DATE,
    sale_day_of_month VARCHAR(15),
    sale_day_of_week VARCHAR(15),
    sale_month VARCHAR(15),
    sale_year VARCHAR(15)
);

-- Inserting scope of date information into the previously created table
INSERT INTO daymonthyear
SELECT 
	DISTINCT sale_date,
	DAYOFMONTH(sale_date) AS sale_day_of_month,
  CASE 
		WHEN DAYOFWEEK(sale_date)=1 THEN 'Sunday'
		WHEN DAYOFWEEK(sale_date)=2 THEN 'Monday'
		WHEN DAYOFWEEK(sale_date)=3 THEN 'Tuesday'
		WHEN DAYOFWEEK(sale_date)=4 THEN 'Wednesday'
		WHEN DAYOFWEEK(sale_date)=5 THEN 'Thursday'
		WHEN DAYOFWEEK(sale_date)=6 THEN 'Friday'
		ELSE 'Saturday'
	END AS sale_day_of_week,
	  CASE 
		WHEN MONTH(sale_date)=1 THEN 'January'
		WHEN MONTH(sale_date)=2 THEN 'February'
		WHEN MONTH(sale_date)=3 THEN 'March'
		WHEN MONTH(sale_date)=4 THEN 'April'
		WHEN MONTH(sale_date)=5 THEN 'May'
		WHEN MONTH(sale_date)=6 THEN 'June'
		WHEN MONTH(sale_date)=7 THEN 'July'
		WHEN MONTH(sale_date)=8 THEN 'August'
		WHEN MONTH(sale_date)=9 THEN 'September'
		WHEN MONTH(sale_date)=10 THEN 'October'
		WHEN MONTH(sale_date)=11 THEN 'November'
		ELSE 'December'	
	  END AS sale_month,
      YEAR(sale_date) AS sale_year
FROM
	SaleProfitCalc;







 

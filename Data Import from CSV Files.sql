#IMPORTING DATA VIA CSV FILES

# Set the parameter which will allow the csv file to read into SQL
SET GLOBAL local_infile = true;

LOAD DATA LOCAL INFILE 'C:\\Users\\cyrus\\OneDrive\\Desktop\\SQL Datasets\\Maven Toys\\stores.csv' 
INTO TABLE stores FIELDS TERMINATED BY ',' ENCLOSED BY '"' IGNORE 1 ROWS
(
	store_id,
	store_name,
        store_city,
	store_location,
        @v_date
)

SET store_open_date=STR_TO_DATE(@v_date,'%Y-%m-%d');


LOAD DATA LOCAL INFILE 'C:\\Users\\cyrus\\OneDrive\\Desktop\\SQL Datasets\\Maven Toys\\products.csv' 
INTO TABLE products FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(
	product_id,
	product_name,
        product_category,
	product_cost,
        product_price
);

/*
Procedure which removes the dollar sign from the product_cost and product_price columns of the product table
and changes their datatypes to DOUBLE

*/
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS prepareproducts()
BEGIN
	UPDATE products
	SET product_cost=REPLACE(product_cost,'$','');
    
        UPDATE products
	SET product_price=REPLACE(product_price,'$','');

	UPDATE products
	SET product_cost=TRIM(product_cost);

	UPDATE products
	SET product_price=TRIM(product_price);

	ALTER TABLE products
	CHANGE COLUMN product_cost product_cost DOUBLE;
 
	ALTER TABLE products
	CHANGE COLUMN product_price product_price DOUBLE;
	
END$$

DELIMITER ;

CALL prepareproducts;


LOAD DATA LOCAL INFILE 'C:\\Users\\cyrus\\OneDrive\\Desktop\\SQL Datasets\\Maven Toys\\sales.csv' 
INTO TABLE sales FIELDS TERMINATED BY ',' ENCLOSED BY '"' IGNORE 1 ROWS
(
	sale_id,
        @v_sale_date,
        store_id,
        product_id,
        units
)

SET sale_date=STR_TO_DATE(@v_sale_date,'%Y-%m-%d');


LOAD DATA LOCAL INFILE 'C:\\Users\\cyrus\\OneDrive\\Desktop\\SQL Datasets\\Maven Toys\\inventory.csv' 
INTO TABLE inventory FIELDS TERMINATED BY ',' ENCLOSED BY '"' IGNORE 1 ROWS
(
	store_id,
	product_id,
        stock_on_hand
);

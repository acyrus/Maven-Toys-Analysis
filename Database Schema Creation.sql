DROP DATABASE IF EXISTS maventoys;
CREATE DATABASE IF NOT EXISTS maventoys;
USE maventoys;

CREATE TABLE stores (
    store_id INT,
    store_name VARCHAR(100),
    store_city VARCHAR(100),
    store_location VARCHAR(50),
    store_open_date DATE,
    PRIMARY KEY (store_id)
);

CREATE TABLE inventory (
    store_id INT,
    product_id INT,
    stock_on_hand INT
);

CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    product_category VARCHAR(100),
    product_cost VARCHAR(10),
    product_price VARCHAR(10),
    PRIMARY KEY (product_id)
);


CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    store_id INT,
    product_id INT,
    units INT,
    PRIMARY KEY (sale_id)
);


#CREATION OF CONSTRAINTS
ALTER TABLE sales
ADD CONSTRAINT fk_store_id_s
FOREIGN KEY(store_id) REFERENCES stores(store_id);

ALTER TABLE sales
ADD CONSTRAINT fk_product_id_s
FOREIGN KEY(product_id) REFERENCES products(product_id);

ALTER TABLE inventory
ADD CONSTRAINT fk_store_id_i
FOREIGN KEY(store_id) REFERENCES stores(store_id);

ALTER TABLE inventory
ADD CONSTRAINT fk_product_id_i
FOREIGN KEY(product_id) REFERENCES products(product_id);
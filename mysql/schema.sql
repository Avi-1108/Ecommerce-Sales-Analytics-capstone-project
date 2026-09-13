CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(50),
gender VARCHAR(10),
age INT,
city VARCHAR(20),
state VARCHAR(20),
customer_segment VARCHAR(20),
signup_date DATE
);

CREATE TABLE products(
product_id INT PRIMARY KEY,
product_name VARCHAR(50),
category VARCHAR(50),
sub_category VARCHAR(50),
brand VARCHAR(20),
cost_price DECIMAL(12,2),
selling_price DECIMAL(12,2)
);

CREATE TABLE stores(
store_id INT PRIMARY KEY,
store_name VARCHAR(20),
city VARCHAR(50),
state VARCHAR(50),
region VARCHAR(20)
);

CREATE TABLE orders(
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT,
store_id INT,
payment_method VARCHAR(20),
order_status VARCHAR(30),
FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
FOREIGN KEY(store_id) REFERENCES stores(store_id)
);

CREATE TABLE order_items(
order_item_id INT PRIMARY KEY,
order_id INT,
product_id INT,
quantity INT,
unit_price DECIMAL(10,2),
discount_pct DECIMAL(10,2),
shipping_cost DECIMAL(10,2),
FOREIGN KEY(order_id) REFERENCES orders(order_id),
FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE returns(
return_id INT PRIMARY KEY,
order_id INT,
return_date DATE,
return_reason VARCHAR(100),
returned_quantity INT,
FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
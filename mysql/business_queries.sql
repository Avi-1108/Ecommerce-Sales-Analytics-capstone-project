-- Q1: Find all completed orders made through UPI.
-- order_id, order_date, customer_id, payment_method, order_status
SELECT order_id, order_date, customer_id, payment_method, order_status FROM orders
WHERE payment_method = "UPI" AND order_status = "Delivered";

-- Q2 Display every order along with:
-- order_id, order_date, customer name, customer city, store name, store region, order status
SELECT order_id, order_date, customer_name, c.city, store_name, region, order_status FROM orders o
JOIN customers c USING (customer_id)
JOIN stores s USING (store_id);

-- Q3 Find the top 10 products by quantity sold.
-- product_id, product_name, category, total_quantity
SELECT product_id, product_name, category, SUM(quantity) AS quantity FROM products
JOIN order_items USING(product_id)
GROUP BY product_id, product_name
ORDER BY quantity DESC LIMIT 10;

-- Q4 Calculate total net revenue for each product category.
-- category, total_revenue
SELECT category, SUM(quantity*unit_price) AS total_revenue FROM products
JOIN order_items USING(product_id)
GROUP BY category;

-- Q5 Find the top 10 customers by total revenue generated.
-- customer_id, customer_name, customer_segment, total_revenue
SELECT customer_id, customer_name, customer_segment, SUM(quantity*unit_price) AS total_revenue FROM customers
JOIN orders USING(customer_id)
JOIN order_items USING(order_id)
GROUP BY customer_id, customer_name
ORDER BY total_revenue DESC LIMIT 10;

-- Q6 Find customer segments where:
-- a) number of customers is greater than 100
-- customer_segment, customer_count, total_revenue
SELECT customer_segment, COUNT( DISTINCT customer_id) AS customer_count, SUM(quantity*unit_price) AS total_revenue FROM customers
JOIN orders USING(customer_id)
JOIN order_items USING(order_id)
GROUP BY customer_segment
HAVING customer_count > 100;

-- b) total revenue is greater than ₹10,00,000
-- customer_segment, customer_count, total_revenue
SELECT customer_segment, COUNT(DISTINCT customer_id) AS customer_count, SUM(quantity*unit_price) AS total_revenue FROM customers
JOIN orders USING(customer_id)
JOIN order_items USING(order_id)
GROUP BY customer_segment
HAVING total_revenue > 1000000;

-- Q7 Find all customers who have never placed an order.
SELECT customer_id, customer_name FROM customers
LEFT JOIN orders USING(customer_id)
WHERE order_id IS NULL;

-- Q8 Calculate the following for every store:
-- store_id, store_name, region, number of orders, total revenue, average order value (Sort by total revenue descending.)
SELECT store_id, store_name, region, COUNT(DISTINCT order_id) AS "number of orders", SUM(quantity*unit_price) AS total_revenue, SUM(quantity*unit_price)/COUNT(DISTINCT order_id) AS "average order value" FROM stores
LEFT JOIN orders USING(store_id)
LEFT JOIN order_items USING(order_id)
GROUP BY store_id, store_name
ORDER BY total_revenue DESC;

-- Q9 Calculate monthly revenue.
-- year, month, total_orders, total_revenue
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, COUNT(DISTINCT order_id) AS total_orders, SUM(quantity*unit_price) AS total_revenue FROM orders
JOIN order_items USING(order_id)
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year asc,month asc;

-- Q10 Find the top 3 products by revenue within each category.(WINDOWS FUNCTION)
-- category, product_name, total_revenue, rank
SELECT * FROM(SELECT category, product_name, SUM(quantity*unit_price) AS total_revenue, 
DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(quantity*unit_price) DESC) AS ranks FROM products
JOIN order_items USING(product_id)
GROUP BY category, product_name) AS x
WHERE ranks <=3;


-- Q11 Rank customers within each customer segment based on their total revenue.
-- customer_name, customer_segment, total_revenue, customer_rank
SELECT * FROM (SELECT customer_name, customer_segment, SUM(quantity*unit_price) AS total_revenue, 
DENSE_RANK() OVER(PARTITION BY customer_segment ORDER BY SUM(quantity*unit_price) DESC) AS customer_rank FROM customers
JOIN orders USING(customer_id)
JOIN order_items USING(order_id) GROUP BY customer_name,customer_segment) AS x
WHERE customer_rank <=3;

-- Q12 Calculate month-over-month revenue growth.
-- year, month, current_month_revenue, previous_month_revenue, revenue_difference, percentage_change
WITH revenue AS(
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(quantity*unit_price) AS current_month_revenue,
LAG(SUM(quantity*unit_price)) OVER(ORDER BY YEAR(order_date), MONTH(order_date)) AS previous_month_revenue
FROM orders JOIN order_items USING(order_id)
GROUP BY year,month
)
SELECT year, month, current_month_revenue, previous_month_revenue,
current_month_revenue - previous_month_revenue AS revenue_difference,
((current_month_revenue - previous_month_revenue)/previous_month_revenue)*100 AS percentage_change
FROM revenue;

-- Q13 Find the top 10 orders by returned quantity.
-- order_id, customer_name, order_date, returned_quantity, return_reason
SELECT order_id, customer_name, order_date, returned_quantity, return_reason FROM customers
JOIN orders USING(customer_id)
JOIN returns USING(order_id)
ORDER BY returned_quantity DESC LIMIT 10;

-- Q14 Find customers whose total spending is greater than the average spending of all customers who have placed an order.
-- customer_id, customer_name, total_spending
WITH total_spending AS(
SELECT customer_id, customer_name, SUM(quantity*unit_price) AS total_spending FROM customers
JOIN orders USING(customer_id)
JOIN order_items USING(order_id)
GROUP BY customer_id, customer_name
), 
avg_spending AS(
SELECT AVG(total_spending) AS average_spending FROM total_spending
)
SELECT customer_id, customer_name, total_spending FROM total_spending
JOIN avg_spending
WHERE total_spending > average_spending;


-- Q15 Create a customer classification based on total spending:
-- ₹2,00,000+ -> VIP, ₹1,00,000 to < ₹2,00,000 -> High Value, ₹50,000 to < ₹1,00,000 -> Medium Value, < ₹50,000 -> Low Value
-- customer_id, customer_name, customer_segment, total_spending, customer_category
SELECT customer_id, customer_name, customer_segment, SUM(quantity*unit_price) AS total_spending,
CASE
WHEN SUM(quantity*unit_price) >= 200000 THEN "VIP"
WHEN SUM(quantity*unit_price) >= 100000 THEN "High Value"
WHEN SUM(quantity*unit_price) >= 50000 THEN "Medium Value"
ELSE "Low Value"
END AS customer_category FROM customers
JOIN orders USING(customer_id)
JOIN order_items USING(order_id)
GROUP BY customer_id, customer_name;
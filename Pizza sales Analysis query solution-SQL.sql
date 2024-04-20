---------------------------------Basic--------------------------------------------
--Q1.Retrieve the total number of orders placed.--
SELECT COUNT(*) AS total_orders
FROM `pizzadata.orders`
--Q2.Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(od.quantity * p.price)) AS total_revenue
FROM `pizzadata.order_details`as od
JOIN `pizzadata.pizzas` as p ON od.pizza_id = p.pizza_id;

--Q3.Identify the highest-priced pizza.--
SELECT 
    pt.name AS pizza_name, p.price AS pizza_price
FROM
    `pizzadata.pizzas` AS p
        JOIN
    `pizzadata.pizza_types` AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

--Q4.Identify the most common pizza size ordered.--
SELECT 
    p.size AS pizza_size, COUNT(*) AS size_count
FROM
    `pizzadata.pizzas` AS p
        JOIN
    `pizzadata.order_details` AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY size_count DESC

--Q5.List the top 5 most ordered pizza types along with their quantities.
SELECT
    pt.name AS pizza_name,
    SUM(od.quantity) AS total_quantity
FROM
    `pizzadata.pizza_types` AS pt
JOIN
    `pizzadata.pizzas` AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN
    `pizzadata.order_details` AS od ON p.pizza_id = od.pizza_id
GROUP BY
    pt.name
ORDER BY
    total_quantity DESC
LIMIT 5;
-----------------------------------------Intermediate----------------------
--Q1.Join the necessary tables to find the total quantity of each pizza category ordered.--------
SELECT 
    pt.category AS pizza_category,
    SUM(od.quantity) AS total_quantity
FROM
    `pizzadata.pizza_types` AS pt
        JOIN
    `pizzadata.pizzas` AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    `pizzadata.order_details` AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;
--Q2.Determine the distribution of orders by hour of the day.
SELECT 
    EXTRACT(HOUR FROM time) AS order_hour,
    COUNT(*) AS order_count
FROM
    `pizzadata.orders`
GROUP BY order_hour
ORDER BY order_hour;
--Q3.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS count_ca
FROM
    `pizzadata.pizza_types`
GROUP BY category
ORDER BY count_ca DESC
LIMIT 4
--Q4.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(total_pizzas) AS avg_pizzas_per_day
FROM (
    SELECT DATE(o.date) AS order_date, SUM(od.quantity) AS total_pizzas
    FROM `pizzadata.orders` o
    JOIN `pizzadata.order_details` od ON o.order_id = od.order_id
    GROUP BY DATE(o.date)
) AS daily_pizzas;
--Q5.Determine the top 3 most ordered pizza types based on revenue.--
SELECT 
    pt.name AS pizza_name, SUM(od.quantity * p.price) AS revenue
FROM
    `pizzadata.order_details` od
        JOIN
    `pizzadata.pizzas` AS p ON od.pizza_id = p.pizza_id
        JOIN
    `pizzadata.pizza_types` AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;
-----------------------------------Advanced-------------------------------------------:
--Q1.Calculate the percentage contribution of each pizza type to total revenue.--
SELECT
    pt.category,
    SUM(od.quantity * p.price) AS revenue
FROM
    `pizzadata.pizza_types` AS pt
JOIN
    `pizzadata.pizzas` AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN
    `pizzadata.order_details` AS od ON od.pizza_id = p.pizza_id
GROUP BY
    pt.category
ORDER BY
    revenue DESC;

--Q2.Analyze the cumulative revenue generated over time.
SELECT 
    DATE(o.date) AS order_date,
    SUM(od.quantity * p.price) AS cumulative_revenue
FROM
    `pizzadata.orders` o
        JOIN
    `pizzadata.order_details` AS od ON o.order_id = od.order_id
        JOIN
    `pizzadata.pizzas` AS p ON od.pizza_id = p.pizza_id
GROUP BY DATE(o.date)
ORDER BY order_date
--Q3.Determine the top 3 most ordered pizza types based on revenue for each pizza category.--
WITH PizzaRevenueRanked AS (
    SELECT pt.category AS pizza_category,
           pt.name AS pizza_name,
           SUM(od.quantity * p.price) AS revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS revenue_rank
    FROM `pizzadata.order_details` as od
    JOIN `pizzadata.pizzas` as p ON od.pizza_id = p.pizza_id
    JOIN `pizzadata.pizza_types` as pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)
SELECT pizza_category, pizza_name, revenue, revenue_rank
FROM PizzaRevenueRanked
WHERE revenue_rank <= 3;


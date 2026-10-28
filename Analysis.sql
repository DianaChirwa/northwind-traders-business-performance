-- KPI 1: Total Orders

SELECT COUNT(*) AS total_orders
FROM orders;


-- KPI 2: Total Revenue

SELECT
     SUM(order_details.quantity
        * products.unit_price
        * (1 - order_details.discount)) 
		AS total_revenue
FROM order_details
JOIN products
    ON order_details.product_id = products.product_id;


-- KPI 3: Average Revenue

SELECT
    SUM(order_details.quantity
        * products.unit_price
        * (1 - order_details.discount))
    /
    COUNT(DISTINCT order_details.order_id)
    AS average_order_value
FROM order_details
JOIN products
    ON order_details.product_id = products.product_id;


--- KPI 4: SHIPPING EFFICIENCY: Average Order-to-Ship Time

SELECT
    AVG(orders.shipped_date - orders.order_date) AS average_shipping_time
FROM orders;



-- Are there any noticeable sales trends over time?
SELECT
    EXTRACT(YEAR FROM orders.order_date) AS order_year,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(
        order_details.quantity
        * products.unit_price
        * (1 - order_details.discount)
    ) AS total_revenue
FROM orders
JOIN order_details
    ON orders.order_id = order_details.order_id
JOIN products
    ON order_details.product_id = products.product_id
GROUP BY EXTRACT(YEAR FROM orders.order_date)
ORDER BY order_year;


-- Which are the best and worst selling products?
--- Best products:
SELECT
    products.product_name,
    SUM(order_details.quantity) AS units_sold
FROM products
JOIN order_details
    ON products.product_id = order_details.product_id
GROUP BY products.product_name
ORDER BY units_sold DESC;

--- Add total revenue
SELECT
    products.product_name,
    SUM(order_details.quantity) AS units_sold,
    SUM(
        order_details.quantity
        * products.unit_price
        * (1 - order_details.discount)
    ) AS total_revenue
FROM products
JOIN order_details
    ON products.product_id = order_details.product_id
GROUP BY products.product_name
ORDER BY total_revenue DESC;


-- Can you identify any key customers?
--- Customer ranking by revenue & order volume
SELECT
    customers.company_name,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(
        order_details.quantity
        * products.unit_price
        * (1 - order_details.discount)
    ) AS total_revenue
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_details
    ON orders.order_id = order_details.order_id
JOIN products
    ON order_details.product_id = products.product_id
GROUP BY customers.company_name
ORDER BY total_revenue DESC;


-- Are shipping costs consistent across providers?

SELECT
    shippers.company_name,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    AVG(orders.shipped_date - orders.order_date) AS avg_shipping_time,
    AVG(orders.freight) AS avg_freight
FROM shippers
JOIN orders
    ON shippers.shipper_id = orders.shipper_id
GROUP BY shippers.company_name
ORDER BY avg_shipping_time;


-- How fast is their delivery service, how many orders are delivered on time or late

SELECT
    CASE
        WHEN shipped_date <= required_date THEN 'Shipped by Required Date'
        ELSE 'Shipped After Required Date'
    END AS shipping_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    CASE
        WHEN shipped_date <= required_date THEN 'Shipped by Required Date'
        ELSE 'Shipped After Required Date'
    END;

-- Employee Analysis

SELECT
    employees.employee_name,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(
        order_details.quantity
        * products.unit_price
        * (1 - order_details.discount)
    ) AS total_revenue
FROM employees
JOIN orders
    ON employees.employee_id = orders.employee_id
JOIN order_details
    ON orders.order_id = order_details.order_id
JOIN products
    ON order_details.product_id = products.product_id
GROUP BY employees.employee_name
ORDER BY total_revenue DESC;

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100),
    description TEXT
);


CREATE TABLE shippers (
    shipper_id INTEGER PRIMARY KEY,
    company_name VARCHAR(100)
);


CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name VARCHAR(100),
    title VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100),
    reports_to INTEGER
);


CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(100),
    contact_name VARCHAR(100),
    contact_title VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100)
);


CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    quantity_per_unit VARCHAR(100),
    unit_price TEXT,
    discontinued INTEGER,
    category_id INTEGER,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

---Convert unit_price to a numeric data type
ALTER TABLE products
ALTER COLUMN unit_price TYPE NUMERIC(10,2)
USING REPLACE(unit_price, ',', '.')::NUMERIC(10,2);


CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id VARCHAR(10),
    employee_id INTEGER,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    shipper_id INTEGER,
    freight TEXT,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (shipper_id) REFERENCES shippers(shipper_id)
);
---Convert freight to a numeric data type
ALTER TABLE orders
ALTER COLUMN freight TYPE NUMERIC(10,2)
USING REPLACE(freight, ',', '.')::NUMERIC(10,2);


CREATE TABLE order_details (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    discount TEXT,

    PRIMARY KEY (order_id, product_id),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
--- Convert discount to a numeric data type
ALTER TABLE order_details
ALTER COLUMN discount TYPE NUMERIC(4,2)
USING REPLACE(discount, ',', '.')::NUMERIC(4,2);


-- Check the imported dataset
SELECT 'categories' AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'shippers', COUNT(*) FROM shippers
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details;

--- Validate prices, quantities and discounts
SELECT
    (SELECT COUNT(*) FROM products WHERE unit_price IS NULL) AS null_unit_prices,
    (SELECT COUNT(*) FROM orders WHERE freight IS NULL) AS null_freight,
    (SELECT COUNT(*) FROM order_details WHERE discount IS NULL) AS null_discounts;

--- Validate order dates
SELECT *
FROM orders
WHERE order_date IS NULL
   OR required_date IS NULL
   OR shipped_date IS NULL
   OR required_date < order_date
   OR shipped_date < order_date;
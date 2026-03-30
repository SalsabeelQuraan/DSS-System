-- Create a DB
CREATE DATABASE dss_system;
-- \c dss_system;

-- Employee Table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    position VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);

-- Products Table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    cost_price DECIMAL(10,2),
    selling_price DECIMAL(10,2)
);

-- Inventory Table
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT,
    quantity INT,
    last_updated DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Costs Table
CREATE TABLE costs (
    cost_id SERIAL PRIMARY KEY,
    product_id INT,
    amount DECIMAL(10,2),
    cost_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Sales Table
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT,
    quantity INT,
    sale_date DATE,
    total_price DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Calculate total price for sales
UPDATE sales s
SET total_price = s.quantity * p.selling_price
FROM products p
WHERE s.product_id = p.product_id;

-- Total Sales
SELECT SUM(total_price) AS total_sales
FROM sales;

-- Profit 
SELECT 
    (SELECT SUM(total_price) FROM sales) -
    (SELECT SUM(amount) FROM costs) AS profit;

-- Best Selling Product
SELECT 
    p.name,
    SUM(s.quantity) AS total_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.name
ORDER BY total_sold DESC
LIMIT 10;

-- Least best selling product
SELECT 
    p.name,
    SUM(s.quantity) AS total_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.name
ORDER BY total_sold ASC
LIMIT 10;

-- Inventory Status
SELECT 
    p.name,
    i.quantity,
    CASE 
        WHEN i.quantity < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS status
FROM inventory i
JOIN products p ON i.product_id = p.product_id;

-- Sales by product
SELECT 
    p.name,
    SUM(s.total_price) AS revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.name
ORDER BY revenue DESC;

-- Sales by date
SELECT 
    sale_date,
    SUM(total_price) AS daily_sales
FROM sales
GROUP BY sale_date
ORDER BY sale_date;

-- Decision support (best product in terms of profitability)
SELECT 
    p.name,
    (p.selling_price - p.cost_price) * SUM(s.quantity) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.name
ORDER BY total_profit DESC;

-- Cost Analysis
SELECT 
    p.name,
    SUM(c.amount) AS total_cost
FROM costs c
JOIN products p ON c.product_id = p.product_id
GROUP BY p.name
ORDER BY total_cost DESC;

-- Comprehensive Report (DSS Report)
SELECT 
    p.name,
    SUM(s.quantity) AS total_sold,
    SUM(s.total_price) AS revenue,
    (p.selling_price - p.cost_price) * SUM(s.quantity) AS profit
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.name, p.selling_price, p.cost_price
ORDER BY profit DESC;

-- Add View ready for analysis
CREATE VIEW dss_summary AS
SELECT 
    p.product_id,
    p.name,
    SUM(s.quantity) AS total_sold,
    SUM(s.total_price) AS revenue,
    (p.selling_price - p.cost_price) * SUM(s.quantity) AS profit
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.name, p.selling_price, p.cost_price;

-- to use it
SELECT * FROM dss_summary;
-- ============================================================
-- DATABASE CREATION
-- ============================================================
CREATE DATABASE Retail_Analytics;
USE Retail_Analytics;


-- ============================================================
-- TABLE CREATION
-- ============================================================

-- Sales Table
CREATE TABLE sales (
    order_id VARCHAR(20),
    order_date DATE,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    store_id VARCHAR(20),
    sales_channel VARCHAR(20),
    quantity INT,
    unit_price FLOAT,
    discount_pct FLOAT,
    total_amount FLOAT,
    cost_price FLOAT,
    profit FLOAT,
    order_year FLOAT,
    order_month VARCHAR(20)
);

-- Customer Table
CREATE TABLE customer (
    customer_id VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(20),
    age FLOAT,
    signup_date DATE,
    region VARCHAR(50),
    age_group VARCHAR(20)
);

-- Products Table
CREATE TABLE products (
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    cost_price FLOAT,
    unit_price FLOAT,
    margin_pct FLOAT
);

-- Stores Table
CREATE TABLE stores (
    store_id VARCHAR(20),
    store_name VARCHAR(100),
    store_type VARCHAR(50),
    region VARCHAR(50),
    city VARCHAR(50),
    operating_cost FLOAT
);

-- Returns Table
CREATE TABLE returns_data (
    return_id VARCHAR(20),
    order_id VARCHAR(20),
    return_date DATE,
    return_reason VARCHAR(100)
);


-- ============================================================
-- LOADING CLEANED DATA INTO TABLES
-- ============================================================

BULK INSERT sales
FROM 'C:\Users\USER\Desktop\Retail_Sales_Capstone\data\cleaned\cleaned_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

BULK INSERT customer
FROM 'C:\Users\USER\Desktop\Retail_Sales_Capstone\data\cleaned\cleaned_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

BULK INSERT products
FROM 'C:\Users\USER\Desktop\Retail_Sales_Capstone\data\cleaned\cleaned_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

BULK INSERT stores
FROM 'C:\Users\USER\Desktop\Retail_Sales_Capstone\data\cleaned\cleaned_stores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

BULK INSERT returns_data
FROM 'C:\Users\USER\Desktop\Retail_Sales_Capstone\data\cleaned\cleaned_returns.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

SELECT * FROM sales;

SELECT * FROM customer;

SELECT * FROM products;

SELECT * FROM stores;

SELECT * FROM returns_data;


-- ============================================================
-- CONVERT NULLABLE COLUMNS TO NOT NULL
-- ============================================================

ALTER TABLE customer
ALTER COLUMN customer_id VARCHAR(20) NOT NULL;

ALTER TABLE products
ALTER COLUMN product_id VARCHAR(20) NOT NULL;

ALTER TABLE stores
ALTER COLUMN store_id VARCHAR(20) NOT NULL;

ALTER TABLE returns_data
ALTER COLUMN return_id VARCHAR(20) NOT NULL;

ALTER TABLE sales
ALTER COLUMN order_id VARCHAR(20) NOT NULL;


-- ============================================================
-- CHECK FOR DUPLICATE PRIMARY KEY VALUES IN ALL TABLES
-- ============================================================

-- Check duplicate order_id
SELECT order_id, COUNT(*) AS Total
FROM sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check duplicate customer_id
SELECT customer_id, COUNT(*) AS Total
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check duplicate product_id
SELECT product_id, COUNT(*) AS Total
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check duplicate store_id
SELECT store_id, COUNT(*) AS Total
FROM stores
GROUP BY store_id
HAVING COUNT(*) > 1;

-- Check duplicate return_id
SELECT return_id, COUNT(*) AS Total
FROM returns_data
GROUP BY return_id
HAVING COUNT(*) > 1;


-- ============================================================
-- REMOVE DUPLICATE RECORD FROM SALES TABLE
-- ============================================================

DELETE FROM sales
WHERE order_id = 'O02025'
  AND order_date = '2024-11-03'
  AND customer_id = 'C0712'
  AND product_id = 'P0778';


-- ============================================================
-- CREATE PRIMARY KEYS
-- ============================================================

ALTER TABLE customer
ADD CONSTRAINT PK_customer PRIMARY KEY (customer_id);

ALTER TABLE products
ADD CONSTRAINT PK_products PRIMARY KEY (product_id);

ALTER TABLE stores
ADD CONSTRAINT PK_stores PRIMARY KEY (store_id);

ALTER TABLE returns_data
ADD CONSTRAINT PK_returns PRIMARY KEY (return_id);

ALTER TABLE sales
ADD CONSTRAINT PK_sales PRIMARY KEY (order_id);


-- ============================================================
-- CREATE RELATIONSHIPS
-- ============================================================

-- Sales → Customer
ALTER TABLE sales
ADD CONSTRAINT FK_sales_customer
FOREIGN KEY (customer_id)
REFERENCES customer(customer_id);

-- Sales → Products
ALTER TABLE sales
ADD CONSTRAINT FK_sales_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- Returns → Sales
ALTER TABLE returns_data
ADD CONSTRAINT FK_returns_sales
FOREIGN KEY (order_id)
REFERENCES sales(order_id);

-- ============================================================
-- CREATE INDEXES
-- ============================================================

EXEC sp_helpindex 'sales';
EXEC sp_helpindex 'customer';
EXEC sp_helpindex 'products';
EXEC sp_helpindex 'returns_data';

-- ============================================================
-- CALCULATE DERIVED METRICS
-- ============================================================

SELECT
    order_id,
    discount_pct * 100 AS discount_percent,
    total_amount - (quantity * cost_price) AS profit
FROM sales;


-- ============================================================
-- BUSINESS QUESTIONS
-- ============================================================

-- 1. Total Revenue
SELECT SUM(total_amount) AS total_revenue
FROM sales;

-- 2. Top 5 Products by Quantity
SELECT TOP 5 product_id,
       SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_id
ORDER BY total_quantity DESC;

-- 3. Customers by Region
SELECT region,
       COUNT(*) AS total_customers
FROM customer
GROUP BY region;

-- 4. Profit by Store
SELECT store_id,
       SUM(profit) AS total_profit
FROM sales
GROUP BY store_id;

-- 5. Returns by Reason
SELECT return_reason,
       COUNT(*) AS total_returns
FROM returns_data
GROUP BY return_reason;

-- 6. Average Revenue per Customer
SELECT AVG(total_amount) AS avg_revenue
FROM sales;

-- 7. Profit by Sales Channel
SELECT sales_channel,
       AVG(profit) AS avg_profit
FROM sales
GROUP BY sales_channel;

-- 8. Monthly Profit
SELECT order_month,
       SUM(profit) AS total_profit
FROM sales
GROUP BY order_month;

-- 9. Sales by Category
SELECT p.category,
       SUM(s.total_amount) AS total_sales
FROM sales s
JOIN products p
ON s.product_id = p.product_id
GROUP BY p.category;

-- 10. Top 5 Customers by Profit
SELECT TOP 5 customer_id,
       SUM(profit) AS total_profit
FROM sales
GROUP BY customer_id
ORDER BY total_profit DESC;


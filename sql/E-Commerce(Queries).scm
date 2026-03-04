create database e_comm;
use e_comm;
show tables;
desc sales_data;
CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(50),
    segment VARCHAR(50),
    region VARCHAR(50)
);
CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50),
    category VARCHAR(100),
    sub_category VARCHAR(100)
);
CREATE TABLE dim_date (
    date_key INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE,
    year INT,
    month INT,
    day INT
);
CREATE TABLE fact_orders (
    order_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    customer_key INT,
    product_key INT,
    date_key INT,
    sales DECIMAL(10,2),
    profit DECIMAL(10,2),
    discount DECIMAL(5,2),

    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);
INSERT INTO dim_customer (customer_id, segment, region)
SELECT DISTINCT Customer_ID, Segment, Region
FROM sales_data;

INSERT INTO dim_product (product_id, category, sub_category)
SELECT DISTINCT Product_ID, Category, Sub_Category
FROM sales_data;

INSERT INTO dim_date (order_date, year, month, day)
SELECT DISTINCT 
    Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    DAY(Order_Date)
FROM sales_data;

INSERT INTO fact_orders 
(order_id, customer_key, product_key, date_key, sales, profit, discount)
SELECT
    s.Order_ID,
    c.customer_key,
    p.product_key,
    d.date_key,
    s.Sales,
    s.Profit,
    s.Discount
FROM sales_data s
JOIN dim_customer c
    ON s.Customer_ID = c.customer_id
JOIN dim_product p
    ON s.Product_ID = p.product_id
JOIN dim_date d
    ON s.Order_Date = d.order_date;
SELECT 
    c.customer_id,
    DATEDIFF(CURDATE(), MAX(d.order_date)) AS Recency,
    COUNT(f.order_id) AS Frequency,
    SUM(f.sales) AS Monetary
FROM fact_orders f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY c.customer_id;

SELECT 
    c.region,
    SUM(f.sales) AS total_sales
FROM fact_orders f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.region;

SELECT 
    d.year,
    d.month,
    SUM(f.sales) AS total_sales
FROM fact_orders f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
desc sales_data;
desc rfm_table;








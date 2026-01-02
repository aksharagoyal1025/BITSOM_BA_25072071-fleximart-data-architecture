USE fleximart_dw;
CREATE DATABASE IF NOT EXISTS fleximart_dw;
USE fleximart_dw;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_of_week VARCHAR(10),
    day_of_month INT,
    month INT,
    month_name VARCHAR(10),
    quarter VARCHAR(2),
    year INT,
    is_weekend BOOLEAN
);

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    customer_segment VARCHAR(20)
);

CREATE TABLE fact_sales (
    sale_key INT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    quantity_sold INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key)
);
 -- dim_date: 30 dates (2024-01-01 to 2024-01-30)
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240101, '2024-01-01', 'Monday',    1, 1, 'January', 'Q1', 2024, FALSE),
(20240102, '2024-01-02', 'Tuesday',   2, 1, 'January', 'Q1', 2024, FALSE),
(20240103, '2024-01-03', 'Wednesday', 3, 1, 'January', 'Q1', 2024, FALSE),
(20240104, '2024-01-04', 'Thursday',  4, 1, 'January', 'Q1', 2024, FALSE),
(20240105, '2024-01-05', 'Friday',    5, 1, 'January', 'Q1', 2024, FALSE),
(20240106, '2024-01-06', 'Saturday',  6, 1, 'January', 'Q1', 2024, TRUE),
(20240107, '2024-01-07', 'Sunday',    7, 1, 'January', 'Q1', 2024, TRUE),
(20240108, '2024-01-08', 'Monday',    8, 1, 'January', 'Q1', 2024, FALSE),
(20240109, '2024-01-09', 'Tuesday',   9, 1, 'January', 'Q1', 2024, FALSE),
(20240110, '2024-01-10', 'Wednesday',10, 1, 'January', 'Q1', 2024, FALSE),
(20240111, '2024-01-11', 'Thursday', 11, 1, 'January', 'Q1', 2024, FALSE),
(20240112, '2024-01-12', 'Friday',   12, 1, 'January', 'Q1', 2024, FALSE),
(20240113, '2024-01-13', 'Saturday', 13, 1, 'January', 'Q1', 2024, TRUE),
(20240114, '2024-01-14', 'Sunday',   14, 1, 'January', 'Q1', 2024, TRUE),
(20240115, '2024-01-15', 'Monday',   15, 1, 'January', 'Q1', 2024, FALSE),
(20240116, '2024-01-16', 'Tuesday',  16, 1, 'January', 'Q1', 2024, FALSE),
(20240117, '2024-01-17', 'Wednesday',17, 1, 'January', 'Q1', 2024, FALSE),
(20240118, '2024-01-18', 'Thursday', 18, 1, 'January', 'Q1', 2024, FALSE),
(20240119, '2024-01-19', 'Friday',   19, 1, 'January', 'Q1', 2024, FALSE),
(20240120, '2024-01-20', 'Saturday', 20, 1, 'January', 'Q1', 2024, TRUE),
(20240121, '2024-01-21', 'Sunday',   21, 1, 'January', 'Q1', 2024, TRUE),
(20240122, '2024-01-22', 'Monday',   22, 1, 'January', 'Q1', 2024, FALSE),
(20240123, '2024-01-23', 'Tuesday',  23, 1, 'January', 'Q1', 2024, FALSE),
(20240124, '2024-01-24', 'Wednesday',24, 1, 'January', 'Q1', 2024, FALSE),
(20240125, '2024-01-25', 'Thursday', 25, 1, 'January', 'Q1', 2024, FALSE),
(20240126, '2024-01-26', 'Friday',   26, 1, 'January', 'Q1', 2024, FALSE),
(20240127, '2024-01-27', 'Saturday', 27, 1, 'January', 'Q1', 2024, TRUE),
(20240128, '2024-01-28', 'Sunday',   28, 1, 'January', 'Q1', 2024, TRUE),
(20240129, '2024-01-29', 'Monday',   29, 1, 'January', 'Q1', 2024, FALSE),
(20240130, '2024-01-30', 'Tuesday',  30, 1, 'January', 'Q1', 2024, FALSE);

-- dim_product: 15 products across 3 categories
INSERT INTO dim_product (product_id, product_name, category, subcategory, unit_price) VALUES
('ELEC001', 'Galaxy S21',          'Electronics', 'Smartphone',   45000.00),
('ELEC002', 'MacBook Pro 14',      'Electronics', 'Laptop',      150000.00),
('ELEC003', 'Sony WH-1000XM5',     'Electronics', 'Headphones',   28000.00),
('ELEC004', 'Dell 27\" 4K Monitor','Electronics', 'Monitor',      32000.00),
('ELEC005', 'Samsung 55\" QLED TV','Electronics', 'Television',   65000.00),

('FASH001', 'Levi\'s Slim Jeans',  'Fashion',     'Clothing',      3500.00),
('FASH002', 'Nike Air Max 270',    'Fashion',     'Footwear',     12000.00),
('FASH003', 'Adidas T-Shirt',      'Fashion',     'Clothing',      1500.00),
('FASH004', 'Puma RS-X',           'Fashion',     'Footwear',      9000.00),
('FASH005', 'H&M Formal Shirt',    'Fashion',     'Clothing',      2000.00),

('HOME001', 'Prestige Cooker',     'Home',        'Kitchen',       2500.00),
('HOME002', 'Philips Mixer',       'Home',        'Kitchen',       4000.00),
('HOME003', 'Milton Bottle',       'Home',        'Accessories',    600.00),
('HOME004', 'Sleepwell Mattress',  'Home',        'Furniture',    18000.00),
('HOME005', 'Syska LED Bulb Pack', 'Home',        'Lighting',       800.00);

-- dim_customer: 12 customers across 4 cities
INSERT INTO dim_customer (customer_id, customer_name, city, state, customer_segment) VALUES
('C001', 'Rahul Sharma',     'Mumbai',    'Maharashtra', 'Retail'),
('C002', 'Priya Singh',      'Delhi',     'Delhi',       'Retail'),
('C003', 'Amit Verma',       'Bengaluru', 'Karnataka',   'Online'),
('C004', 'Neha Gupta',       'Kolkata',   'West Bengal', 'Retail'),
('C005', 'Sanjay Patel',     'Ahmedabad', 'Gujarat',     'Wholesale'),
('C006', 'Anjali Mehta',     'Pune',      'Maharashtra', 'Online'),
('C007', 'Rohit Kumar',      'Jaipur',    'Rajasthan',   'Retail'),
('C008', 'Sneha Rao',        'Hyderabad', 'Telangana',   'Online'),
('C009', 'Vikram Joshi',     'Chennai',   'Tamil Nadu',  'Retail'),
('C010','Karan Malhotra',    'Mumbai',    'Maharashtra', 'Wholesale'),
('C011','Shreya Das',        'Kolkata',   'West Bengal', 'Online'),
('C012','Nitin Yadav',       'Delhi',     'Delhi',       'Retail');

-- fact_sales: 40 sales transactions
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
-- Weekday smaller orders
(20240102,  1,  1, 1, 45000.00,  0.00, 45000.00),
(20240103,  2,  2, 1,150000.00,5000.00,145000.00),
(20240104,  3,  3, 2, 28000.00,1000.00,55000.00),
(20240105,  6,  4, 2,  3500.00, 500.00, 6500.00),
(20240108,  7,  5, 1, 12000.00,   0.00,12000.00),
(20240109,  8,  6, 3,  1500.00, 200.00, 4300.00),
(20240110, 11,  7, 1,  2500.00,   0.00, 2500.00),
(20240111, 12,  8, 1,  4000.00, 200.00, 3800.00),
(20240112, 13,  9, 4,   600.00, 100.00, 2300.00),
(20240115, 14, 10, 1, 18000.00,1000.00,17000.00),

-- Weekend higher sales
(20240106,  1,  3, 2, 45000.00,5000.00,85000.00),
(20240106,  7,  3, 1, 12000.00,   0.00,12000.00),
(20240107,  5,  2, 1, 65000.00,5000.00,60000.00),
(20240107,  9,  2, 2,  9000.00,1000.00,17000.00),
(20240113,  2,  1, 1,150000.00,7000.00,143000.00),
(20240113, 10,  1, 2,  2000.00, 200.00, 3800.00),
(20240114,  3,  4, 1, 28000.00,   0.00,28000.00),
(20240114,  6,  4, 1,  3500.00, 300.00, 3200.00),
(20240120,  5,  6, 1, 65000.00,3000.00,62000.00),
(20240121,  4,  6, 1, 32000.00,1000.00,31000.00),

-- Mix more dates
(20240116, 15, 11, 3,   800.00,  50.00, 2350.00),
(20240117,  8, 11, 2,  1500.00, 100.00, 2900.00),
(20240118,  9, 12, 1,  9000.00,   0.00, 9000.00),
(20240119, 11, 12, 2,  2500.00, 200.00, 4800.00),
(20240122, 12,  9, 1,  4000.00,   0.00, 4000.00),
(20240123, 13,  8, 2,   600.00,  50.00, 1150.00),
(20240124, 14,  7, 1, 18000.00,1500.00,16500.00),
(20240125,  1,  5, 1, 45000.00,2000.00,43000.00),
(20240126,  2,  6, 1,150000.00,8000.00,142000.00),
(20240127,  3,  3, 1, 28000.00, 500.00,27500.00),
(20240128,  4,  2, 2, 32000.00,2000.00,62000.00),

-- Extra weekend & spread across customers
(20240120,  6,  1, 3,  3500.00, 500.00,10000.00),
(20240121,  7,  2, 2, 12000.00, 500.00,23500.00),
(20240127,  8,  3, 1,  1500.00,   0.00, 1500.00),
(20240127,  9,  4, 1,  9000.00, 500.00, 8500.00),
(20240128, 10,  5, 1,  2000.00,   0.00, 2000.00),
(20240129, 11,  6, 1,  2500.00,   0.00, 2500.00),
(20240129, 12,  7, 2,  4000.00, 300.00, 7700.00),
(20240129, 13,  8, 3,   600.00, 100.00, 1700.00),
(20240130, 14,  9, 1, 18000.00,2000.00,16000.00),
(20240130, 15, 10, 4,   800.00, 200.00, 3000.00);


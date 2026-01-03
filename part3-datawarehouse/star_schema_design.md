## Section 1: Schema Overview
This star schema is made for FlexiMart sales data. The main table is fact_sales. Each row in this table is one product line from an order. It stores numbers like how many units were sold, what was the unit price, how much discount was given, and what was the total amount of that line.

Around this fact table, there are three dimension tables: dim_date, dim_product, and dim_customer. The dim_date table stores information about the date, like full date, day of week, month, quarter, year, and whether it is a weekend. The dim_product table stores details about each product, like product_id, name, category, subcategory, and unit price. The dim_customer table stores customer_id, customer_name, city, state, and customer_segment. The fact_sales table keeps only the foreign keys (date_key, product_key, customer_key) plus the measures. Because of this design, the tables form a clear “star” shape.

## Section 2: Design Decisions
The grain of fact_sales is one row per product per order line item. This means if one order has three different products, then fact_sales will have three rows. This level of detail is helpful because we can easily calculate totals by day, month, product, category, city, or customer segment. If we stored only one row per order, then it would be harder to see which products are selling well.

The dimension tables use surrogate keys (simple integer keys) instead of natural keys from the source system. Surrogate keys are stable and do not change when source system codes change. They also make joins faster. This star schema supports drill‑down and roll‑up. For example, we can start from total sales in a year, then go to quarter, then month, and even a single date using dim_date. In the same way, we can move from total category sales to a single product using dim_product. Because the facts and dimensions are clearly separated, queries stay simple and easy to write.

## Section 3: Sample Data Flow
Suppose in the source system there is an order: Order-#101, Customer “John Doe”, Product “Laptop”, quantity 2, unit price 50000, date “2024‑01‑15”. In the data warehouse, this information is stored across the star schema. First, the date “2024‑01‑15” is linked to a row in dim_date with a key like 20240115 and attributes like month = 1, month_name = “January”, quarter = “Q1”, and year = 2024.

Next, the Laptop product is stored in dim_product and given a product_key (for example 5). The customer “John Doe” is stored in dim_customer with a customer_key (for example 12). Finally, fact_sales gets one row: date_key = 20240115, product_key = 5, customer_key = 12, quantity_sold = 2, unit_price = 50000, discount_amount = 0, total_amount = 100000. Using these keys, reports can easily show sales by month, by product, or by customer segment.

## testing for commit

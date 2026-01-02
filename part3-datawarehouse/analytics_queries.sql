USE fleximart_dw;

-- Query 1: Monthly Sales Drill-Down
-- Business Scenario: The CEO wants to see sales performance broken down by time periods...
-- Added OLAP query to analyze monthly sales by product category and region.

SELECT
    d.year,
    d.quarter,
    d.month_name,
    SUM(f.total_amount)   AS total_sales,
    SUM(f.quantity_sold)  AS total_quantity
FROM fact_sales f
JOIN dim_date d
  ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY
    d.year,
    d.quarter,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.quarter,
    d.month;

-- Query 2: Top 10 Products by Revenue
-- Business Scenario: The product manager needs to identify top-performing products...

WITH product_sales AS (
    SELECT
        p.product_name,
        p.category,
        SUM(f.quantity_sold) AS units_sold,
        SUM(f.total_amount)  AS revenue
    FROM fact_sales f
    JOIN dim_product p
      ON f.product_key = p.product_key
    GROUP BY
        p.product_name,
        p.category
),
total AS (
    SELECT SUM(revenue) AS total_revenue
    FROM product_sales
)
SELECT
    ps.product_name,
    ps.category,
    ps.units_sold,
    ps.revenue,
    ROUND(ps.revenue / t.total_revenue * 100, 2) AS revenue_percentage
FROM product_sales ps
CROSS JOIN total t
ORDER BY ps.revenue DESC
LIMIT 10;

-- Query 3: Customer Segmentation
-- Business Scenario: Marketing wants to target high-value customers...

WITH customer_spend AS (
    SELECT
        c.customer_key,
        c.customer_name,
        SUM(f.total_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_customer c
      ON f.customer_key = c.customer_key
    GROUP BY
        c.customer_key,
        c.customer_name
),
segmented AS (
    SELECT
        CASE
            WHEN total_revenue > 50000 THEN 'High Value'
            WHEN total_revenue BETWEEN 20000 AND 50000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment,
        total_revenue
    FROM customer_spend
)
SELECT
    customer_segment,
    COUNT(*)              AS customer_count,
    SUM(total_revenue)    AS total_revenue,
    AVG(total_revenue)    AS avg_revenue_per_customer
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;

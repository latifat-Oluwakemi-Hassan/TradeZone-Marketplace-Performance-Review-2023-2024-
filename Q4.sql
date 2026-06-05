--Question 4: Quarterly Revenue Trends---
--Compare quarterly revenue across 2023 and 2024. 
--For each quarter, calculate total revenue, average order value and total number of orders. 
--Identify which single quarter showed the strongest revenue growth from 2023 to 2024.
WITH order_summary AS (
    SELECT
        o.order_id,
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(QUARTER FROM o.order_date) AS quarter,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_date >= '2023-01-01'
      AND o.order_date < '2025-01-01'
      AND o.order_status = 'Delivered'
    GROUP BY
        o.order_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(QUARTER FROM o.order_date)
)

SELECT
    year,
    quarter,
    ROUND(SUM(order_revenue),2) AS total_revenue,
    ROUND(AVG(order_revenue),2) AS avg_order_value,
    COUNT(order_id) AS total_orders
FROM order_summary
GROUP BY year, quarter
ORDER BY year, quarter;
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
      AND o.order_date <  '2025-01-01'
    GROUP BY o.order_id, year, quarter
),

quarterly_stats AS (
    SELECT
        year,
        quarter,
        SUM(order_revenue) AS total_revenue,
        AVG(order_revenue) AS avg_order_value,
        COUNT(order_id) AS total_orders
    FROM order_summary
    GROUP BY year, quarter
),

growth_calc AS (
    SELECT
        q2024.quarter,
        q2024.total_revenue AS revenue_2024,
        q2023.total_revenue AS revenue_2023,
        (q2024.total_revenue - q2023.total_revenue) AS revenue_growth
    FROM quarterly_stats q2024
    JOIN quarterly_stats q2023
        ON q2024.quarter = q2023.quarter
    WHERE q2024.year = 2024
      AND q2023.year = 2023
)

SELECT
    quarter,
    revenue_2023,
    revenue_2024,
    revenue_growth
FROM growth_calc
ORDER BY revenue_growth DESC
LIMIT 1;
---Question 5: Customer Spend Segmentation---
--Segment customers based on their total spend in 2024 into three groups:
  --High Spenders: ≥ ₦100,000
 -- Medium Spenders: ₦50,000 – ₦99,999
-- Low Spenders: < ₦50,000
--For each group, calculate the customer count, average spend per customer and total revenue contribution.
WITH customer_spend AS (
    SELECT
        o.customer_id,
        SUM(COALESCE(o.total_amount,0)) AS total_spend
    FROM orders o
    WHERE o.order_status = 'Delivered'
      AND o.order_date >= '2024-01-01'
      AND o.order_date < '2025-01-01'
    GROUP BY o.customer_id
),

segmented_customers AS (
    SELECT
        customer_id,
        total_spend,
        CASE
            WHEN total_spend >= 100000 THEN 'High Spender'
            WHEN total_spend BETWEEN 50000 AND 99999.99 THEN 'Medium Spender'
            ELSE 'Low Spender'
        END AS segment
    FROM customer_spend
)

SELECT
    segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(total_spend),2) AS avg_spend_per_customer,
    ROUND(SUM(total_spend),2) AS total_revenue
FROM segmented_customers
GROUP BY segment
ORDER BY
CASE segment
    WHEN 'High Spender' THEN 1
    WHEN 'Medium Spender' THEN 2
    WHEN 'Low Spender' THEN 3
END;
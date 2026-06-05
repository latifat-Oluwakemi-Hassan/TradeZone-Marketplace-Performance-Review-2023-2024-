---Question 1: Customer Acquisition & 30-Day Conversion--------
--Find the top 5 states by number of new customer sign-ups in 2024. 
--For each state, calculate what percentage of these new customers
--made at least one purchase within their first 30 days of signing up.


WITH new_customers AS (
SELECT 
        customer_id,
        state,
        signup_date
FROM customers
WHERE signup_date >= DATE '2024-01-01'
     AND signup_date <  DATE '2025-01-01'
),

converted_customers AS (
SELECT DISTINCT
        nc.customer_id,
        nc.state
FROM new_customers nc
JOIN orders o
       ON o.customer_id = nc.customer_id
       AND o.order_date >= nc.signup_date
       AND o.order_date <= nc.signup_date + INTERVAL '30 days'
),

state_summary AS (
SELECT
        nc.state,
        COUNT(nc.customer_id) AS new_signups,
        COUNT(cc.customer_id) AS converted
FROM new_customers nc
LEFT JOIN converted_customers cc
        ON nc.customer_id = cc.customer_id
GROUP BY nc.state
)

SELECT
    state,
    new_signups,
    converted,
    ROUND(100.0 * converted / NULLIF(new_signups, 0), 2) AS conversion_pct
FROM state_summary
ORDER BY new_signups DESC
LIMIT 5;

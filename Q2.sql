--Question 2: Product Performance---------
---Identify the top 10 products by total revenue in 2024. 
---Include product name, category, total revenue and total number of orders. Sort by revenue descending.

SELECT 
  p.product_name,
  p.category,
  SUM(oi.quantity * oi.unit_price) AS total_revenue,
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_date <  '2025-01-01'
  AND oi.unit_price IS NOT NULL
GROUP BY 
  p.product_id, 
  p.product_name, 
  p.category
ORDER BY total_revenue DESC
LIMIT 10;
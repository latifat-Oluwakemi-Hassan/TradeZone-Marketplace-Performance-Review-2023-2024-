---Question 7: Review Ratings and Sales Performance
--Group products based on their average review rating into three categories:
-- High Rated: 4.0 and above
 --Mid Rated: 3.0 – 3.99
-- Low Rated: Below 3.0
--For each category, calculate the product count, total revenue and average unit price.

WITH product_ratings AS (
  SELECT 
    product_id,
    AVG(rating) AS avg_rating
  FROM reviews
  GROUP BY product_id
),

rated_products AS (
  SELECT 
    product_id,
    CASE 
      WHEN avg_rating >= 4.0 THEN 'High Rated'
      WHEN avg_rating >= 3.0 THEN 'Mid Rated'
      ELSE 'Low Rated'
    END AS rating_bucket
  FROM product_ratings
)

SELECT 
  rp.rating_bucket,
  COUNT(DISTINCT rp.product_id) AS product_count,
  ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
  ROUND(AVG(oi.unit_price), 2) AS avg_unit_price
FROM rated_products rp
JOIN order_items oi 
  ON rp.product_id = oi.product_id
GROUP BY rp.rating_bucket
ORDER BY total_revenue DESC;
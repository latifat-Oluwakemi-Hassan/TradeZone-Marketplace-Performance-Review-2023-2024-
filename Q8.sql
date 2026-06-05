--Question 8:-- Top Seller Bonus Qualification--
--Identify the top 10 sellers in 2024 by total revenue who completed at least 10 orders
--and have an average customer rating of 4.0 or above.
--Include their total orders, average rating, and total revenue.

WITH seller_orders AS (
    SELECT
        o.seller_id,
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_date >= '2024-01-01'
      AND o.order_date <  '2025-01-01'
    GROUP BY o.seller_id, o.order_id
),

seller_revenue AS (
    SELECT
        seller_id,
        COUNT(order_id) AS total_orders,
        SUM(order_revenue) AS total_revenue
    FROM seller_orders
    GROUP BY seller_id
),

seller_ratings AS (
    SELECT
        o.seller_id,
        AVG(r.rating) AS avg_rating
    FROM orders o
    JOIN reviews r
        ON o.order_id = r.order_id
    GROUP BY o.seller_id
),

qualified_sellers AS (
    SELECT
        sr.seller_id,
        sr.total_orders,
        sr.total_revenue,
        rr.avg_rating
    FROM seller_revenue sr
    JOIN seller_ratings rr
        ON sr.seller_id = rr.seller_id
    WHERE sr.total_orders >= 10
      AND rr.avg_rating >= 4.0
)

SELECT
    qs.seller_id,
    qs.total_orders,
    ROUND(qs.avg_rating, 2) AS avg_rating,
    ROUND(qs.total_revenue, 2) AS total_revenue
FROM qualified_sellers qs
ORDER BY total_revenue DESC
LIMIT 10;
---Question 3: Seller Fulfilment Efficiency----
---Calculate the average time in hours between order placement and delivery for each seller. ---
---Return the top 20 sellers with the fastest average fulfilment times among sellers who have completed at least 20 orders. 
---Include their total completed orders and average customer rating.

WITH completed_orders AS (
    SELECT
        o.order_id,
        o.seller_id,
        (o.delivery_date - o.order_date) * 24.0 AS hours_to_deliver
    FROM orders o
    WHERE o.delivery_date IS NOT NULL
      AND o.order_date IS NOT NULL
),

seller_stats AS (
    SELECT
        seller_id,
        COUNT(*) AS completed_orders,
        AVG(hours_to_deliver) AS avg_fulfilment_hours
    FROM completed_orders
    GROUP BY seller_id
    HAVING COUNT(*) >= 20
),

seller_ratings AS (
    SELECT
        o.seller_id,
        AVG(r.rating) AS avg_rating
    FROM orders o
    JOIN reviews r
        ON o.order_id = r.order_id
    GROUP BY o.seller_id
)

SELECT
    ss.seller_id,
    ss.completed_orders,
    ROUND(ss.avg_fulfilment_hours, 2) AS avg_fulfilment_hours,
    ROUND(sr.avg_rating, 2) AS avg_customer_rating
FROM seller_stats ss
LEFT JOIN seller_ratings sr
    ON ss.seller_id = sr.seller_id
ORDER BY ss.avg_fulfilment_hours ASC
LIMIT 20;
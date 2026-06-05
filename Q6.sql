--Question 6: Payment Method Preferences by State
--Analyse payment method preferences across each state in the dataset.
--For each state, show the transaction count and total amount for each payment method
--(Cash on Delivery, Card, Mobile Money, Bank Transfer) and identify the most popular method per state.

WITH payment_summary AS (
    SELECT
        c.state,
        p.payment_method,
        COUNT(p.payment_id) AS transaction_count,
        SUM(p.amount) AS total_amount
    FROM payments p
    JOIN orders o 
        ON p.order_id = o.order_id
    JOIN customers c 
        ON o.customer_id = c.customer_id
    GROUP BY c.state, p.payment_method
),

ranked_methods AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY state 
            ORDER BY transaction_count DESC
        ) AS method_rank
    FROM payment_summary
)

SELECT
    state,
    payment_method,
    transaction_count,
    ROUND(total_amount, 2) AS total_amount,
    method_rank
FROM ranked_methods
ORDER BY state, method_rank;

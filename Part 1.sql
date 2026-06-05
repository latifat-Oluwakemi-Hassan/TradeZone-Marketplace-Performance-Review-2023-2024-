--DATA OVERVIEW---
--Quick row count for all tables in the tradeZone database --
--To confirm that the data are inserted correctly--

SELECT 'customers' AS table_name, COUNT(*) FROM customers
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;

--checking the data samples structures--
SELECT * FROM customers LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM payments LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM reviews LIMIT 10;
SELECT * FROM sellers LIMIT 10;

--------------------------------------------------------
--DATA CLEANING: CUSTOMERS TABLE--
---------------------------------------------------------
--Identify missing values in key customer fields
--16 customers email values were Null.
SELECT *
FROM customers
WHERE customer_id IS NULL
   OR email IS NULL
   OR state IS NULL
   OR signup_date IS NULL;

--Duplicates checked in customers table---
-- Checking customer_ids that appears more than once in the customers table
--No duplicate customer_id --
SELECT *
FROM (
    SELECT *,
           COUNT(*) OVER (PARTITION BY customer_id) AS dup_count
    FROM customers
) t
WHERE dup_count > 1;
--Checking duplicate emails in customers table--
--46 emails records were found 
SELECT *
FROM (
    SELECT *,
           COUNT(*) OVER (PARTITION BY email) AS email_count
    FROM customers
) t
WHERE email_count > 1
ORDER BY email; 

--Fixing inconsistencies in city name
--formatting problem
--standardization problem
SELECT DISTINCT city
FROM customers
ORDER BY city;

UPDATE customers
SET city = CASE
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%lagos%' THEN 'Lagos'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%abuja%' THEN 'Abuja'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%ibadan%' THEN 'Ibadan'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%kano%' THEN 'Kano'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%portharcourt%' THEN 'Port Harcourt'
    ELSE city
END;

-- Verifiying that signup_date column follows consistency format(YYYY/MM/DD)
SELECT signup_date
FROM customers
LIMIT 10;
----------------------------------------------------------
--DATA CLEANING: ORDER_ITEMS TABLE--
----------------------------------------------------------
-- 97 records in the order_items table have NULL unit_price values.
SELECT *
FROM order_items
WHERE quantity IS NULL
   OR unit_price IS NULL;
   
-- Inspect order_items with missing unit_price and include product detail
--four products were found which includes JAMB CBT practice questions, 
--Standing Fan 18 inch 5-speed, Kitchen knife set 7 piece,and Ribena blackcurrent 1L
SELECT 
    oi.order_id,
    oi.product_id,
    p.product_name,
    p.unit_price AS product_price,
    oi.unit_price AS order_item_price
FROM order_items oi
LEFT JOIN products p 
    ON oi.product_id = p.product_id
WHERE oi.unit_price IS NULL;


-- checking duplicate order_items
-- No duplicated found
SELECT *
FROM (
    SELECT *,
           COUNT(*) OVER (PARTITION BY order_id, product_id) AS dup_count
    FROM order_items
) t
WHERE dup_count > 1
ORDER BY order_id, product_id;
--------------------------------------------------
--DATA CLEANING ORDERS TABLE--
--------------------------------------------------
-- checking missing values in orders table
SELECT *
FROM orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL
   OR delivery_date IS NULL
   OR order_status IS NULL 
   OR total_amount IS NULL;
---checking distinct order_status   
SELECT DISTINCT order_status FROM orders;

--Checking null total_amount and delivery_date---
--79 records were missing both---
SELECT COUNT(*)
FROM orders
WHERE total_amount IS NULL
  AND delivery_date IS NULL;
--71 records were identified where delivery_date exists
--but total_amount is NULL, indicating incomplete transaction records.
SELECT
  SUM(CASE WHEN total_amount IS NULL AND delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_both,
  SUM(CASE WHEN total_amount IS NULL AND delivery_date IS NOT NULL THEN 1 ELSE 0 END) AS amount_only,
  SUM(CASE WHEN total_amount IS NOT NULL AND delivery_date IS NULL THEN 1 ELSE 0 END) AS date_only
FROM orders;

---checking the order date format---

SELECT order_date
FROM orders
LIMIT 10;

SELECT delivery_date
FROM orders
LIMIT 10;
------------------------------------------------------
---DATA CLEANING PAYMENTS
------------------------------------------------------
-- checking missing values in the payments table--
SELECT *,
       CASE 
           WHEN payment_id IS NULL THEN 'Missing payment_id'
           WHEN order_id IS NULL THEN 'Missing order_id'
           WHEN payment_method IS NULL THEN 'Missing payment_method'
           WHEN amount IS NULL THEN 'Missing amount'
           WHEN payment_date IS NULL THEN 'Missing payment_date'
       END AS issue_type
FROM payments
WHERE payment_id IS NULL
   OR order_id IS NULL
   OR payment_method IS NULL
   OR amount IS NULL
   OR payment_date IS NULL;
   
--count of payment records with missing amount
--155 payment records were with missing amount
SELECT COUNT(*)
FROM payments
WHERE amount IS NULL;
---checking the null amount with their payment method
SELECT payment_method, COUNT(*) 
FROM payments
WHERE amount IS NULL
GROUP BY payment_method;

----checking duplicate in payments
-- checking for duplicate(4 payment_id were found with duplicate order_id, amount , payment_method and payment_date)
SELECT *
FROM (
    SELECT *,
           COUNT(*) OVER (
               PARTITION BY order_id, payment_method, amount, payment_date
           ) AS dup_count
    FROM payments
) t
WHERE dup_count > 1;

--checking payment_date-
--Payment dates were in timestamp format
SELECT payment_date
FROM payments
LIMIT 10;

--Payment date was formatted to normal date type
-- To ensure all date columns follow a consistent format 
ALTER TABLE payments
ALTER COLUMN payment_date TYPE DATE
USING payment_date:: DATE;

--checking for duplicate payment_date
SELECT DATE(payment_date), COUNT(*)
FROM payments
GROUP BY DATE(payment_date)
HAVING COUNT(*) > 1;

------------------------------------
--DATA CLEANING PRODUCTS
------------------------------------
--Checking null values in products table.
SELECT *
FROM products
WHERE product_id IS NULL
   OR product_name IS NULL
   OR category IS NULL
   OR unit_price IS NULL
   OR seller_id IS NULL;
   
--Checking the category column for distinct
SELECT DISTINCT category FROM products;

--Normalize text format( chnging values to lowercase for uniform comparison)
UPDATE products
SET category = LOWER(TRIM(category));
--Standardized the category column by cleaning formatting inconsistencies 
--(case, spellings,) and mapping similar values to unified category labels to ensure accurate analysis and reporting.

UPDATE products
SET category = CASE
    WHEN category IN ('electronics', 'electronis') THEN 'Electronics'
    WHEN category IN ('fashion', 'fashon') THEN 'Fashion'
    WHEN category IN ('home & garden', 'home and garden') THEN 'Home & Garden'
    WHEN category IN ('beauty', 'beauty and personal care') THEN 'Beauty & Personal Care'
    WHEN category IN ('sports', 'sports and fitness') THEN 'Sports & Fitness'
    WHEN category IN ('food', 'food and beverages') THEN 'Food & Beverages'
    WHEN category IN ('books', 'books and stationery') THEN 'Books & Stationery'
    ELSE INITCAP(category)
END;
-------------------------------------------------
--DATA CLEANING:REVIEWS-- 
-------------------------------------------------
-- checking missing values in orders table
--No Missing value
SELECT *
FROM reviews
WHERE review_id IS NULL
   OR product_id IS NULL
   OR customer_id IS NULL
   OR order_id IS NULL
   OR rating IS NULL
   OR review_date IS NULL;

--Duplicate check in reviews table
--No duplicate found
SELECT *
FROM (
    SELECT *,
           COUNT(*) OVER (
               PARTITION BY product_id, customer_id, order_id, rating, review_date
           ) AS dup_count
    FROM reviews
) t
WHERE dup_count > 1;
-----------------------------------
--DATA CLEANING SELLERS TABLE
-----------------------------------
--checking null values in seller
--no missing values
SELECT *
FROM sellers
WHERE seller_id IS NULL
   OR seller_name IS NULL
   OR onboarding_date IS NULL
   OR product_category IS NULL
   OR city IS NULL
   OR state IS NULL
   OR account_status IS NULL;
--normalizing product_category
  UPDATE sellers
SET product_category = LOWER(TRIM(product_category)); 

--Standardized the category column by cleaning formatting inconsistencies 
--(case, spellings,) and mapping similar values to unified category labels to ensure accurate analysis and reporting.
UPDATE sellers
SET product_category = CASE
    WHEN product_category IN ('electronics', 'electronis') THEN 'Electronics'
    WHEN product_category IN ('fashion', 'fashon') THEN 'Fashion'
    WHEN product_category IN ('home & garden', 'home and garden') THEN 'Home & Garden'
    WHEN product_category IN ('beauty', 'beauty and personal care') THEN 'Beauty & Personal Care'
    WHEN product_category IN ('sports', 'sports and fitness') THEN 'Sports & Fitness'
    WHEN product_category IN ('food', 'food and beverages') THEN 'Food & Beverages'
    WHEN product_category IN ('books', 'books and stationery') THEN 'Books & Stationery'
    ELSE INITCAP(product_category)
END;

--Fixing inconsistencies in city name
--formatting problem
--standardization problem
SELECT DISTINCT city
FROM sellers;
  
UPDATE sellers
SET city = CASE
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%lagos%' THEN 'Lagos'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%abuja%' THEN 'Abuja'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%ibadan%' THEN 'Ibadan'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%kano%' THEN 'Kano'
    WHEN LOWER(REPLACE(REPLACE(REPLACE(city, ' ', ''), '-', ''), ',', '')) LIKE '%portharcourt%' THEN 'Port Harcourt'
    ELSE city
END;

-------------------------------------------------------
--DATA VALIDATION
-------------------------------------------------------
--Flag orders where total_amount differs from
-- sum of order_items.line_total by more than ₦10
SELECT * FROM order_items LIMIT 10;
---creating a view for validation
CREATE VIEW flagged_amount_mismatches AS
SELECT
  o.order_id,
  o.total_amount AS stated_total,
  SUM(oi.line_total) AS calculated_total,
  ABS(o.total_amount - SUM(oi.line_total)) AS difference
FROM orders o
JOIN order_items oi 
    ON oi.order_id = o.order_id
WHERE o.total_amount IS NOT NULL
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.line_total)) > 10;
---checking the orders flagged
--124 rows were flagged
SELECT *
FROM flagged_amount_mismatches
WHERE difference > 10;
--validating if line order was accurately calculated
SELECT 
    order_id,
    product_id,
    quantity,
    unit_price,
    line_total,
    (quantity * unit_price) AS expected_total,
    (line_total - (quantity * unit_price)) AS difference
FROM order_items
WHERE line_total IS NOT NULL
  AND ABS(line_total - (quantity * unit_price)) > 0.01;

  SELECT *
FROM order_items
WHERE line_total IS NULL;
--validating the total rows affected
SELECT 
    COUNT(*) AS total_rows,
    COUNT(CASE WHEN unit_price IS NULL THEN 1 END) AS missing_unit_price
FROM order_items;
---checking distribution of missing unit_price by category
SELECT *
FROM order_items
WHERE unit_price IS NULL;
--Missing unit_price are distributed among 3 catergory

SELECT 
    p.category,
    COUNT(*) AS missing_price_count
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
WHERE oi.unit_price IS NULL
GROUP BY p.category
ORDER BY missing_price_count DESC;

---validating Ratings range between 1 and 5(flag out-of-range ratings)
CREATE VIEW flagged_invalid_ratings AS
SELECT 
    review_id,
    product_id,
    customer_id,
    rating,
    CASE 
        WHEN rating < 1 THEN 'Below minimum'
        WHEN rating > 5 THEN 'Above maximum'
    END AS issue_type
FROM reviews
WHERE rating < 1 OR rating > 5;

---checking the flagged ratings
SELECT *
FROM flagged_invalid_ratings;

---checking negative product unit_price
CREATE VIEW flagged_negative_prices AS
SELECT 
    product_id,
    product_name,
    unit_price,
    'Negative Price' AS issue_type
FROM products
WHERE unit_price < 0;

-- No negative_price count 
SELECT COUNT(*) AS negative_price_count
FROM flagged_negative_prices;

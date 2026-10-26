-- Seed data for the glasses store (MySQL 8)
-- Generates a realistic volume of data so query optimisation (Portfolio 2) is meaningful.
-- Run AFTER schema.sql on an empty database.

SET SESSION cte_max_recursion_depth = 1000000;

-- Helper table of numbers 1..200000 (dropped at the end)
CREATE TABLE numbers (n INT PRIMARY KEY);
INSERT INTO numbers
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 200000
)
SELECT n FROM seq;

-- Categories
INSERT INTO categories(name) VALUES
    ('Anti-Blue Light Glasses'),
    ('Photochromic Glasses'),
    ('Prescription Glasses');

-- 10,000 customers
INSERT INTO customers(full_name, email, phone, address)
SELECT CONCAT('Customer ', n),
       CONCAT('customer', n, '@mail.com'),
       CONCAT('0803', LPAD(n, 7, '0')),
       CONCAT(n, ' Sample Street, Abuja')
FROM numbers WHERE n <= 10000;

-- 300 frame models
INSERT INTO products(category_id, name, description)
SELECT FLOOR(1 + RAND() * 3),
       CONCAT('Frame Model ', n),
       'Lightweight frame'
FROM numbers WHERE n <= 300;

-- 1,200 variants (4 per frame): colour, size, lens type, price, stock
INSERT INTO product_variants(product_id, sku, colour, size, lens_type,
                             prescription_supported, price, stock_quantity)
SELECT ((n - 1) MOD 300) + 1,
       CONCAT('SKU-', LPAD(n, 5, '0')),
       ELT(FLOOR(1 + RAND() * 5), 'Black', 'Tortoise', 'Clear', 'Blue', 'Gold'),
       ELT(FLOOR(1 + RAND() * 3), 'S', 'M', 'L'),
       ELT(FLOOR(1 + RAND() * 2), 'ANTI_BLUE_LIGHT', 'PHOTOCHROMIC'),
       (RAND() < 0.5),
       ROUND(15000 + RAND() * 30000, 2),
       FLOOR(RAND() * 200)
FROM numbers WHERE n <= 1200;

-- 200,000 orders spread over the last year
INSERT INTO orders(customer_id, order_date, status, total_amount)
SELECT FLOOR(1 + RAND() * 10000),
       NOW() - INTERVAL FLOOR(RAND() * 365) DAY,
       ELT(FLOOR(1 + RAND() * 5), 'PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED'),
       0
FROM numbers WHERE n <= 200000;

-- First line item for every order (random variant chosen once per order via temp table)
CREATE TEMPORARY TABLE tmp_items AS
SELECT order_id, FLOOR(1 + RAND() * 1200) AS vid, FLOOR(1 + RAND() * 3) AS q
FROM orders;

INSERT INTO order_items(order_id, variant_id, quantity, unit_price)
SELECT t.order_id, v.variant_id, t.q, v.price
FROM tmp_items t JOIN product_variants v ON v.variant_id = t.vid;

DROP TEMPORARY TABLE tmp_items;

-- Second line item for every order
CREATE TEMPORARY TABLE tmp_items AS
SELECT order_id, FLOOR(1 + RAND() * 1200) AS vid, FLOOR(1 + RAND() * 3) AS q
FROM orders;

INSERT INTO order_items(order_id, variant_id, quantity, unit_price)
SELECT t.order_id, v.variant_id, t.q, v.price
FROM tmp_items t JOIN product_variants v ON v.variant_id = t.vid;

DROP TEMPORARY TABLE tmp_items;

-- Order totals
UPDATE orders o
JOIN (SELECT order_id, SUM(quantity * unit_price) AS t
      FROM order_items GROUP BY order_id) x
  ON x.order_id = o.order_id
SET o.total_amount = x.t;

-- Payments for orders that were paid
INSERT INTO payments(order_id, amount, method, status, paid_at)
SELECT order_id, total_amount,
       ELT(FLOOR(1 + RAND() * 3), 'CARD', 'TRANSFER', 'PAY_ON_DELIVERY'),
       'SUCCESS', order_date
FROM orders
WHERE status IN ('PAID', 'SHIPPED', 'DELIVERED');

-- Deliveries for shipped / delivered orders
INSERT INTO deliveries(order_id, address, status, shipped_at, delivered_at)
SELECT o.order_id, c.address, o.status,
       o.order_date + INTERVAL 1 DAY,
       IF(o.status = 'DELIVERED', o.order_date + INTERVAL 4 DAY, NULL)
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status IN ('SHIPPED', 'DELIVERED');

-- 20,000 reviews
INSERT INTO reviews(product_id, customer_id, rating, comment)
SELECT FLOOR(1 + RAND() * 300),
       FLOOR(1 + RAND() * 10000),
       FLOOR(1 + RAND() * 5),
       'Sample review'
FROM numbers WHERE n <= 20000;

DROP TABLE numbers;

-- Quick sanity check
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'product_variants', COUNT(*) FROM product_variants
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'deliveries', COUNT(*) FROM deliveries
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;

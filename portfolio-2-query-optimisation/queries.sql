-- Portfolio 2: Business queries for the glasses store (MySQL 8)

-- Q1: Revenue and units sold by lens type (anti-blue light vs photochromic)
SELECT v.lens_type,
       SUM(oi.quantity)                 AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN product_variants v ON v.variant_id = oi.variant_id
JOIN orders o           ON o.order_id   = oi.order_id
WHERE o.status <> 'CANCELLED'
GROUP BY v.lens_type
ORDER BY revenue DESC;

-- Q2: Paid orders in the last 30 days
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE status = 'PAID'
  AND order_date >= NOW() - INTERVAL 30 DAY;

-- Q3: Top 10 customers by total spend
SELECT c.customer_id, c.full_name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status <> 'CANCELLED'
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 10;

-- Q4: Monthly revenue
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(total_amount)                AS revenue
FROM orders
WHERE status IN ('PAID', 'SHIPPED', 'DELIVERED')
GROUP BY month
ORDER BY month;

-- Q5: Payments by method
SELECT method, COUNT(*) AS payments, SUM(amount) AS total_amount
FROM payments
WHERE status = 'SUCCESS'
GROUP BY method;

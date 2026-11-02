-- Portfolio 3: COMMIT, ROLLBACK and constraint-protected transactions
-- Run with: mysql -f -t -vvv  (so statements, results and errors are all shown)

-- ---------- Setup: known starting state ----------
UPDATE product_variants SET stock_quantity = 10, price = 25000 WHERE variant_id = 1;
SELECT variant_id, stock_quantity FROM product_variants WHERE variant_id = 1;

-- ---------- 1. Successful order: COMMIT ----------
START TRANSACTION;
INSERT INTO orders(customer_id, status) VALUES (1, 'PENDING');
SET @oid = LAST_INSERT_ID();
INSERT INTO order_items(order_id, variant_id, quantity, unit_price) VALUES (@oid, 1, 2, 25000);
UPDATE product_variants SET stock_quantity = stock_quantity - 2 WHERE variant_id = 1;
UPDATE orders SET total_amount = 50000 WHERE order_id = @oid;
COMMIT;
SELECT stock_quantity AS stock_after_commit FROM product_variants WHERE variant_id = 1;
SELECT order_id, status, total_amount FROM orders WHERE order_id = @oid;

-- ---------- 2. Cancelled order: ROLLBACK ----------
START TRANSACTION;
UPDATE product_variants SET stock_quantity = stock_quantity - 3 WHERE variant_id = 1;
SELECT stock_quantity AS stock_inside_transaction FROM product_variants WHERE variant_id = 1;
ROLLBACK;
SELECT stock_quantity AS stock_after_rollback FROM product_variants WHERE variant_id = 1;

-- ---------- 3. Failed update: CHECK constraint blocks negative stock ----------
START TRANSACTION;
UPDATE product_variants SET stock_quantity = stock_quantity - 999 WHERE variant_id = 1;
ROLLBACK;
SELECT stock_quantity AS stock_after_failed_update FROM product_variants WHERE variant_id = 1;

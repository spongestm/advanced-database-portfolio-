-- Portfolio 3: atomic "place order" stored procedure with row locking

DROP PROCEDURE IF EXISTS place_order;

DELIMITER $$
CREATE PROCEDURE place_order(IN p_customer INT, IN p_variant INT, IN p_qty INT)
BEGIN
  DECLARE v_price DECIMAL(12,2);
  DECLARE v_stock INT;
  DECLARE v_order INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- Lock the stock row so no other session can change it until we finish
  SELECT price, stock_quantity INTO v_price, v_stock
    FROM product_variants WHERE variant_id = p_variant FOR UPDATE;

  IF v_stock < p_qty THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
  END IF;

  INSERT INTO orders(customer_id, status, total_amount)
    VALUES (p_customer, 'PENDING', v_price * p_qty);
  SET v_order = LAST_INSERT_ID();

  INSERT INTO order_items(order_id, variant_id, quantity, unit_price)
    VALUES (v_order, p_variant, p_qty, v_price);

  UPDATE product_variants SET stock_quantity = stock_quantity - p_qty
    WHERE variant_id = p_variant;

  COMMIT;
  SELECT v_order AS new_order_id;
END$$
DELIMITER ;

-- ---------- Tests ----------
SELECT stock_quantity AS stock_before FROM product_variants WHERE variant_id = 1;
CALL place_order(1, 1, 2);
SELECT stock_quantity AS stock_after_good_order FROM product_variants WHERE variant_id = 1;
CALL place_order(1, 1, 500);
SELECT stock_quantity AS stock_after_rejected_order FROM product_variants WHERE variant_id = 1;

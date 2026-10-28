-- Indexes chosen from the baseline execution plans
CREATE INDEX idx_orders_status_date ON orders(status, order_date, total_amount);
CREATE INDEX idx_orders_cust_status ON orders(customer_id, status, total_amount);
CREATE INDEX idx_payments_status_method ON payments(status, method, amount);
ANALYZE TABLE orders, payments;

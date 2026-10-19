-- Portfolio 1: Database schema (MySQL 8)
-- Case study: online store for anti-blue light and photochromic glasses

CREATE TABLE customers (
    customer_id  INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL UNIQUE,
    phone        VARCHAR(20),
    address      TEXT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id  INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- A frame model, e.g. "Classic Round"
CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_id  INT NOT NULL,
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB;

-- A specific colour / size / lens type of a frame, with its own price and stock
CREATE TABLE product_variants (
    variant_id             INT AUTO_INCREMENT PRIMARY KEY,
    product_id             INT NOT NULL,
    sku                    VARCHAR(40) NOT NULL UNIQUE,
    colour                 VARCHAR(30),
    size                   VARCHAR(20),
    lens_type              VARCHAR(30) NOT NULL
                           CHECK (lens_type IN ('ANTI_BLUE_LIGHT','PHOTOCHROMIC')),
    prescription_supported BOOLEAN NOT NULL DEFAULT FALSE,
    price                  DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity         INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    order_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status        VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                  CHECK (status IN ('PENDING','PAID','SHIPPED','DELIVERED','CANCELLED')),
    total_amount  DECIMAL(12,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id  INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT NOT NULL,
    variant_id     INT NOT NULL,
    quantity       INT NOT NULL CHECK (quantity > 0),
    unit_price     DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),  -- price at time of purchase
    FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id  INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT NOT NULL UNIQUE,
    amount      DECIMAL(12,2) NOT NULL,
    method      VARCHAR(30) NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    paid_at     TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

CREATE TABLE deliveries (
    delivery_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT NOT NULL UNIQUE,
    address       TEXT NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'PROCESSING',
    shipped_at    TIMESTAMP NULL,
    delivered_at  TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

CREATE TABLE reviews (
    review_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_id   INT NOT NULL,
    customer_id  INT NOT NULL,
    rating       INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id)  REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

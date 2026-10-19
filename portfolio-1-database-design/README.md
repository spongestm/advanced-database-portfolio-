# portfolio-1-database-design
Selected Case Study

Organisation: Techsuite, an online store selling anti-blue light and photochromic glasses (my own business).

Nature of the business/system: An e-commerce platform where customers browse glasses, choose a frame and lens type (anti-blue light or photochromic, with or without prescription), place orders, pay online, and track delivery.

Users of the database:

Customers (browse, order, review)
Business owner/admin (manage products, stock, orders and deliveries)

Major data to be stored:

Customers, phone numbers and delivery addresses
Product categories (e.g. anti-blue light glasses, photochromic glasses, accessories)
Products (frames) and their variants (colour, size, lens type, price, stock per variant)
Lens details (blue-light filter, photochromic tint, UV protection, prescription or non-prescription)
Orders and order items
Payments (card, bank transfer, pay on delivery)
Deliveries and delivery status
Product reviews and ratings

Key operations the database will support:

Add new glasses and update stock for each variant (colour, size, lens type)
Place orders and reduce stock automatically
Process payments and confirm orders
Track delivery from processing to delivered
Retrieve customer order history and reviews
Generate sales reports (e.g. best-selling lens type, monthly revenue)
Why this case study suits the portfolio
Relational design: orders, customers, payments and stock need strict consistency (ACID transactions).
Query optimisation: sales reports and product searches over thousands of orders benefit from indexing.
NoSQL: glasses have varied attributes (photochromic tint and transition speed, blue-light filter percentage, frame size), which fit flexible documents.
Distributed/cloud: an online store must stay available and handle traffic spikes (for example during promotions).
Tools
Relational database: MySQL 8
NoSQL database: MongoDB (Portfolio 4)
Version control: Git/GitHub
Readme
MD
Uploads
mit-8103-advanced-database-systems-ca-september-cohort-2026.pdf
Memory
Mit 8103 Portfolio, MIT 8103 Portfolio




## Entities and Relationships

| Entity | Purpose |
|---|---|
| customers | People who buy glasses |
| categories | Product groups (anti-blue light, photochromic, accessories) |
| products | A frame model (e.g. "Classic Round") |
| product_variants | A specific colour, size and lens type with its own price and stock |
| orders | A purchase made by a customer |
| order_items | The variants and quantities inside an order |
| payments | Payment for an order |
| deliveries | Delivery tracking for an order |
| reviews | Customer ratings of products |

**Key relationships**
- One customer places many orders
- One order contains many order items
- Each order item refers to one product variant
- One category has many products; one product has many variants
- One order has one payment and one delivery
- A customer can review many products

## ER Diagram
![ER Diagram](er-diagram.png)


## Keys and Constraints
- **Primary keys:** every table uses an auto-increment integer ID.
- **Foreign keys:** link orders to customers, order items to orders and
  product variants, variants to products, and so on. They prevent orphan records.
- **UNIQUE:** customer email and variant SKU cannot be duplicated;
  payments and deliveries are one-to-one with orders.
- **CHECK:** prevents negative prices or stock, restricts rating to 1-5,
  restricts order status and lens type to valid values.
- **unit_price in order_items:** copies the price at purchase time so later
  price changes do not alter past orders.

The full schema is in `schema.sql`.
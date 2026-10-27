# portfolio-2-query-optimisation


# Portfolio 2: Query Processing and Optimisation

## Test data
`seed.sql` generates a realistic dataset for the glasses store so that query
performance can be measured meaningfully:
- 10,000 customers, 300 frame models, 1,200 product variants
- 200,000 orders with about 400,000 order items over the last 12 months
- Payments, deliveries and 20,000 reviews

![Row counts](screenshots/01-row-counts.png)

## How to reproduce
1. `docker compose up -d`
2. Load `portfolio-1-database-design/schema.sql`, then
   `portfolio-2-query-optimisation/seed.sql`


   
## Business Queries
`queries.sql` contains five queries answering real business questions
(revenue by lens type, recent paid orders, top customers, monthly revenue,
payment methods).

## Baseline Performance (before indexing)
Measured with `EXPLAIN ANALYZE` on 200,000 orders. Second run recorded.

| Query | Purpose | Time (ms) | Access method |
|---|---|---|---|
| Q1 | Revenue by lens type | ___ | ___ |
| Q2 | Paid orders, last 30 days | ___ | Table scan on orders |
| Q3 | Top 10 customers | ___ | ___ |
| Q4 | Monthly revenue | ___ | Table scan on orders |
| Q5 | Payments by method | ___ | Table scan on payments |


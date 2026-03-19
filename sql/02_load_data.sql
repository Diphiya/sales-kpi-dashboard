-- ============================================================
-- 02_load_data.sql
-- Sales KPI Dashboard — Load & Stage Raw CSV Data
-- ============================================================
-- Run AFTER 01_create_schema.sql
-- Assumes sales_data.csv is accessible at the path below.
-- Adjust path for your environment.
-- ============================================================

-- ─────────────────────────────────────────
-- Step 1: Create staging table
-- ─────────────────────────────────────────
DROP TABLE IF EXISTS staging_sales;

CREATE TABLE staging_sales (
    order_id         VARCHAR(30),
    order_date       VARCHAR(20),   -- raw string, parsed below
    ship_date        VARCHAR(20),
    customer_id      VARCHAR(20),
    customer_name    VARCHAR(255),
    segment          VARCHAR(50),
    city             VARCHAR(100),
    state            VARCHAR(100),
    region_name      VARCHAR(100),
    product_id       VARCHAR(20),
    product_name     VARCHAR(255),
    category         VARCHAR(100),
    sub_category     VARCHAR(100),
    quantity         INT,
    unit_price       DECIMAL(10,2),
    discount         DECIMAL(5,4),
    cost             DECIMAL(12,2),
    unit_cost        DECIMAL(10,2)
);

-- ─────────────────────────────────────────
-- Step 2: Load CSV (PostgreSQL COPY)
-- ─────────────────────────────────────────
-- Option A — server-side file path (adjust path):
-- COPY staging_sales FROM '/absolute/path/to/data/sales_data.csv'
--     WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');

-- Option B — psql client-side (\copy works from local machine):
-- \copy staging_sales FROM 'data/sales_data.csv' WITH (FORMAT csv, HEADER true)

-- ─────────────────────────────────────────
-- Step 3: Insert into dim_product (upsert)
-- ─────────────────────────────────────────
INSERT INTO dim_product (product_id, product_name, category, sub_category, unit_cost)
SELECT DISTINCT
    product_id,
    product_name,
    category,
    sub_category,
    unit_cost
FROM staging_sales
ON CONFLICT (product_id) DO UPDATE
    SET product_name = EXCLUDED.product_name,
        category     = EXCLUDED.category,
        sub_category = EXCLUDED.sub_category,
        unit_cost    = EXCLUDED.unit_cost;

-- ─────────────────────────────────────────
-- Step 4: Insert into dim_customer (upsert)
-- ─────────────────────────────────────────
INSERT INTO dim_customer (customer_id, customer_name, segment, city, state, region_id)
SELECT DISTINCT
    s.customer_id,
    s.customer_name,
    s.segment,
    s.city,
    s.state,
    r.region_id
FROM staging_sales s
JOIN dim_region r ON r.region_name = s.region_name
ON CONFLICT (customer_id) DO NOTHING;

-- ─────────────────────────────────────────
-- Step 5: Insert into fact_sales
-- ─────────────────────────────────────────
INSERT INTO fact_sales (
    order_id, order_date, ship_date,
    customer_id, product_id, region_id,
    quantity, unit_price, discount, cost
)
SELECT
    s.order_id,
    TO_DATE(s.order_date, 'MM/DD/YYYY'),
    TO_DATE(s.ship_date,  'MM/DD/YYYY'),
    s.customer_id,
    s.product_id,
    r.region_id,
    s.quantity,
    s.unit_price,
    COALESCE(s.discount, 0),
    s.cost
FROM staging_sales s
JOIN dim_region r ON r.region_name = s.region_name
ON CONFLICT (order_id, product_id) DO NOTHING;

-- ─────────────────────────────────────────
-- Step 6: Validate row counts
-- ─────────────────────────────────────────
SELECT 'staging_sales'  AS table_name, COUNT(*) AS row_count FROM staging_sales
UNION ALL
SELECT 'fact_sales',    COUNT(*) FROM fact_sales
UNION ALL
SELECT 'dim_product',   COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_customer',  COUNT(*) FROM dim_customer;

-- Clean up staging
DROP TABLE IF EXISTS staging_sales;

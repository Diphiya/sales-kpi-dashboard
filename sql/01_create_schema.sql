-- ============================================================
-- 01_create_schema.sql
-- Sales KPI Dashboard — Database Schema
-- ============================================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_region;
DROP TABLE IF EXISTS dim_date;

-- ─────────────────────────────────────────
-- Dimension: Date
-- ─────────────────────────────────────────
CREATE TABLE dim_date (
    date_key        DATE        PRIMARY KEY,
    year            INT         NOT NULL,
    quarter         INT         NOT NULL,   -- 1-4
    month           INT         NOT NULL,   -- 1-12
    month_name      VARCHAR(20) NOT NULL,
    week            INT         NOT NULL,
    day_of_week     VARCHAR(15) NOT NULL,
    is_weekend      BOOLEAN     NOT NULL DEFAULT FALSE
);

-- ─────────────────────────────────────────
-- Dimension: Region
-- ─────────────────────────────────────────
CREATE TABLE dim_region (
    region_id       SERIAL      PRIMARY KEY,
    region_name     VARCHAR(100) NOT NULL,
    country         VARCHAR(100) NOT NULL DEFAULT 'United States',
    zone            VARCHAR(50)            -- e.g. East, West, Central, South
);

-- ─────────────────────────────────────────
-- Dimension: Product
-- ─────────────────────────────────────────
CREATE TABLE dim_product (
    product_id      VARCHAR(20) PRIMARY KEY,
    product_name    VARCHAR(255) NOT NULL,
    category        VARCHAR(100) NOT NULL,
    sub_category    VARCHAR(100),
    unit_cost       DECIMAL(10,2) NOT NULL
);

-- ─────────────────────────────────────────
-- Dimension: Customer
-- ─────────────────────────────────────────
CREATE TABLE dim_customer (
    customer_id     VARCHAR(20) PRIMARY KEY,
    customer_name   VARCHAR(255) NOT NULL,
    segment         VARCHAR(50)  NOT NULL,  -- Consumer, Corporate, Home Office
    city            VARCHAR(100),
    state           VARCHAR(100),
    region_id       INT REFERENCES dim_region(region_id)
);

-- ─────────────────────────────────────────
-- Fact: Sales
-- ─────────────────────────────────────────
CREATE TABLE fact_sales (
    order_id        VARCHAR(30)   NOT NULL,
    order_date      DATE          NOT NULL REFERENCES dim_date(date_key),
    ship_date       DATE,
    customer_id     VARCHAR(20)   NOT NULL REFERENCES dim_customer(customer_id),
    product_id      VARCHAR(20)   NOT NULL REFERENCES dim_product(product_id),
    region_id       INT           NOT NULL REFERENCES dim_region(region_id),
    quantity        INT           NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10,2) NOT NULL,
    discount        DECIMAL(5,4)  NOT NULL DEFAULT 0.00,
    total_revenue   DECIMAL(12,2) GENERATED ALWAYS AS
                        (quantity * unit_price * (1 - discount)) STORED,
    cost            DECIMAL(12,2) NOT NULL,
    profit          DECIMAL(12,2) GENERATED ALWAYS AS
                        (quantity * unit_price * (1 - discount) - cost) STORED,
    PRIMARY KEY (order_id, product_id)
);

-- ─────────────────────────────────────────
-- Indexes for performance
-- ─────────────────────────────────────────
CREATE INDEX idx_sales_order_date    ON fact_sales(order_date);
CREATE INDEX idx_sales_customer      ON fact_sales(customer_id);
CREATE INDEX idx_sales_product       ON fact_sales(product_id);
CREATE INDEX idx_sales_region        ON fact_sales(region_id);
CREATE INDEX idx_product_category    ON dim_product(category);
CREATE INDEX idx_customer_segment    ON dim_customer(segment);

-- ─────────────────────────────────────────
-- Populate dim_date (2021–2025)
-- ─────────────────────────────────────────
INSERT INTO dim_date (date_key, year, quarter, month, month_name, week, day_of_week, is_weekend)
SELECT
    d::DATE                                          AS date_key,
    EXTRACT(YEAR  FROM d)::INT                       AS year,
    EXTRACT(QUARTER FROM d)::INT                     AS quarter,
    EXTRACT(MONTH FROM d)::INT                       AS month,
    TO_CHAR(d, 'Month')                              AS month_name,
    EXTRACT(WEEK  FROM d)::INT                       AS week,
    TO_CHAR(d, 'Day')                                AS day_of_week,
    EXTRACT(DOW   FROM d) IN (0, 6)                  AS is_weekend
FROM generate_series('2021-01-01'::DATE, '2025-12-31'::DATE, '1 day') AS d;

-- ─────────────────────────────────────────
-- Seed: Regions
-- ─────────────────────────────────────────
INSERT INTO dim_region (region_name, country, zone) VALUES
    ('North-East',    'United States', 'East'),
    ('South-East',    'United States', 'East'),
    ('Midwest',       'United States', 'Central'),
    ('South-Central', 'United States', 'South'),
    ('West',          'United States', 'West'),
    ('North-West',    'United States', 'West');

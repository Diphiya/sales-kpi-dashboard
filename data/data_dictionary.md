# Data Dictionary — sales_data.csv

This document describes every column in the raw dataset used for the Sales KPI Dashboard.

---

## Table: `sales_data.csv` → loaded into `fact_sales`

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| `order_id` | VARCHAR | Unique identifier for each order | `ORD-000001` |
| `order_date` | DATE (MM/DD/YYYY) | Date the order was placed | `03/15/2023` |
| `ship_date` | DATE (MM/DD/YYYY) | Date the order was shipped | `03/19/2023` |
| `customer_id` | VARCHAR | Unique customer identifier | `CUST-0001` |
| `customer_name` | VARCHAR | Full name of the customer | `Alice Johnson` |
| `segment` | VARCHAR | Customer type / segment | `Consumer`, `Corporate`, `Home Office` |
| `city` | VARCHAR | Customer's city | `New York` |
| `state` | VARCHAR | Customer's state abbreviation | `NY` |
| `region_name` | VARCHAR | Sales region (maps to `dim_region`) | `North-East` |
| `product_id` | VARCHAR | Unique product identifier | `PROD-0001` |
| `product_name` | VARCHAR | Display name of the product | `Laptops Model 1` |
| `category` | VARCHAR | High-level product category | `Technology` |
| `sub_category` | VARCHAR | Product sub-category | `Laptops` |
| `quantity` | INT | Number of units ordered | `3` |
| `unit_price` | DECIMAL(10,2) | Price per unit (after markup, before discount) | `499.99` |
| `discount` | DECIMAL(5,4) | Fractional discount applied (0 = no discount) | `0.10` (= 10%) |
| `unit_cost` | DECIMAL(10,2) | Cost of goods per unit | `220.00` |
| `cost` | DECIMAL(12,2) | Total cost (`unit_cost × quantity`) | `660.00` |

---

## Derived / Calculated Columns (in `fact_sales`)

These columns are computed in the database and do **not** appear in the raw CSV:

| Column | Formula | Description |
|--------|---------|-------------|
| `total_revenue` | `quantity × unit_price × (1 − discount)` | Net revenue after discount |
| `profit` | `total_revenue − cost` | Gross profit |
| `profit_margin_pct` | `profit / total_revenue × 100` | Profit as % of revenue |

---

## Dimension Tables (populated from CSV)

### `dim_region`
| Column | Description |
|--------|-------------|
| `region_id` | Auto-generated primary key |
| `region_name` | Region name matching `sales_data.csv` |
| `country` | Always `United States` in this dataset |
| `zone` | Broad zone grouping (East, West, Central, South) |

### `dim_product`
| Column | Description |
|--------|-------------|
| `product_id` | Matches `product_id` in raw data |
| `product_name` | Full product display name |
| `category` | Product category |
| `sub_category` | Product sub-category |
| `unit_cost` | Standard cost per unit |

### `dim_customer`
| Column | Description |
|--------|-------------|
| `customer_id` | Matches `customer_id` in raw data |
| `customer_name` | Full customer name |
| `segment` | Consumer / Corporate / Home Office |
| `city` | Customer city |
| `state` | Customer state |
| `region_id` | FK → `dim_region` |

---

## Notes

- **Discount values** are stored as decimals (e.g., `0.20` = 20%). Multiply by 100 for display.
- **Dates** in the CSV use `MM/DD/YYYY` format. The SQL load script (`02_load_data.sql`) converts them to `DATE` using `TO_DATE(value, 'MM/DD/YYYY')`.
- **Orders with multiple products** share the same `order_id` but have separate rows — the composite key in `fact_sales` is `(order_id, product_id)`.
- **Sample data** covers **2022–2024** and contains **2,000 order lines** across **15 customers**, **45 products**, and **6 regions**.

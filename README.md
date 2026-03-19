# 📊 Sales Performance & KPI Dashboard

> End-to-end sales analytics project using SQL, Power BI, and Excel — tracking revenue, profit margins, regional performance, and customer segments.

---

## 🗂️ Project Overview

This project analyzes sales data to track key performance indicators (KPIs) and surface actionable business insights. It includes:

- **SQL queries** to aggregate and transform raw sales data
- **Power BI dashboard** (`.pbix`) to visualize monthly trends, top products, and customer segments
- **Excel workbooks** for data cleaning, pivot analysis, and KPI summaries
- **Sample dataset** (CSV) to reproduce results end-to-end

---

## 📁 Project Structure

```
sales-kpi-dashboard/
├── sql/
│   ├── 01_create_schema.sql         # Database schema & table definitions
│   ├── 02_load_data.sql             # Data loading / staging queries
│   ├── 03_kpi_revenue.sql           # Revenue & profit margin KPIs
│   ├── 04_regional_performance.sql  # Regional breakdown & rankings
│   ├── 05_product_analysis.sql      # Top-performing products
│   ├── 06_customer_segments.sql     # Customer segmentation queries
│   └── 07_seasonal_trends.sql       # Monthly & seasonal trend analysis
├── data/
│   ├── sales_data.csv               # Raw sample sales dataset
│   └── data_dictionary.md           # Column descriptions & definitions
├── dashboard/
│   ├── Sales_KPI_Dashboard.pbix     # Power BI dashboard file
│   └── Sales_KPI_Dashboard.xlsx     # Excel KPI workbook
├── docs/
│   ├── insights_report.md           # Key findings & business recommendations
│   └── dashboard_preview.png        # Screenshot of Power BI dashboard
└── README.md
```

---

## 🧰 Tools & Technologies

| Tool | Purpose |
|------|---------|
| **SQL** (PostgreSQL / SQL Server) | Data aggregation, transformation, KPI calculations |
| **Power BI** | Interactive dashboard & data visualization |
| **Microsoft Excel** | Data cleaning, pivot tables, KPI summaries |
| **CSV** | Raw sample dataset |

---

## 📌 Key KPIs Tracked

- **Total Revenue** — Monthly and YTD
- **Profit Margin (%)** — By product and region
- **Sales Growth Rate** — Month-over-month & year-over-year
- **Top 10 Products** — By revenue and units sold
- **Regional Performance** — Ranked by revenue, with underperformer flags
- **Customer Segments** — New vs. returning, segment revenue share
- **Seasonal Trends** — Peak and low periods across the year

---

## 🚀 Getting Started

### 1. Set Up the Database

```sql
-- Run scripts in order:
psql -U your_user -d your_db -f sql/01_create_schema.sql
psql -U your_user -d your_db -f sql/02_load_data.sql
```

> Alternatively, use SQL Server Management Studio (SSMS) or any SQL client and run the `.sql` files in sequence.

### 2. Run KPI Queries

```sql
-- Example: Get regional performance summary
psql -U your_user -d your_db -f sql/04_regional_performance.sql
```

### 3. Open the Excel Workbook

- Open `dashboard/Sales_KPI_Dashboard.xlsx`
- The workbook contains:
  - **Raw Data** sheet (paste your exported SQL results here)
  - **KPI Summary** sheet with auto-calculated metrics
  - **Pivot Tables** for product and regional breakdowns
  - **Charts** for trend visualization

### 4. Open Power BI Dashboard

- Open `dashboard/Sales_KPI_Dashboard.pbix` in Power BI Desktop
- Update the data source connection to your database or CSV file
- Refresh data — all visuals update automatically

---

## 📊 Dashboard Features

### Power BI Dashboard Pages

| Page | Description |
|------|-------------|
| **Executive Summary** | High-level KPI cards: Revenue, Profit, Growth Rate |
| **Sales Trends** | Monthly revenue line chart with YoY comparison |
| **Regional Performance** | Map + bar chart of sales by region, with underperformer highlights |
| **Product Analysis** | Top 10 products by revenue and margin |
| **Customer Segments** | Donut chart + table of segment breakdown |
| **Seasonal Insights** | Heatmap of sales by month and quarter |

---

## 💡 Key Findings

See [`docs/insights_report.md`](docs/insights_report.md) for the full analysis. Highlights:

- **Q4 consistently drives 38% of annual revenue** — driven by holiday demand
- **The North-East region underperforms** by ~22% vs. the company average
- **Electronics and Office Supplies** are the highest-margin product categories
- **Returning customers** account for 67% of revenue despite being only 41% of customers
- **July–August dip** represents a recurring seasonal low requiring promotional intervention

---

## 📂 Data Dictionary

See [`data/data_dictionary.md`](data/data_dictionary.md) for full column descriptions.

Key columns in `sales_data.csv`:

| Column | Type | Description |
|--------|------|-------------|
| `order_id` | VARCHAR | Unique order identifier |
| `order_date` | DATE | Date of purchase |
| `region` | VARCHAR | Geographic sales region |
| `product_name` | VARCHAR | Name of the product sold |
| `category` | VARCHAR | Product category |
| `customer_segment` | VARCHAR | Customer type (Consumer, Corporate, Home Office) |
| `quantity` | INT | Units sold |
| `unit_price` | DECIMAL | Price per unit |
| `total_revenue` | DECIMAL | Gross revenue (qty × price) |
| `cost` | DECIMAL | Cost of goods sold |
| `profit` | DECIMAL | Revenue minus cost |


[MIT](LICENSE)

---

*Built with SQL · Power BI · Excel*

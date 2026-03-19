# Power BI Dashboard — Setup & Configuration Guide

> This guide walks you through connecting, configuring, and publishing the Sales KPI Dashboard in Power BI Desktop.

---

## Prerequisites

- **Power BI Desktop** (free) — [Download here](https://powerbi.microsoft.com/desktop)
- Access to your SQL database **OR** the `sales_data.csv` file
- The `.pbix` file in this folder *(once published from Power BI Desktop)*

---

## Option A — Connect to CSV (Quickest Start)

1. Open **Power BI Desktop**
2. Click **Home → Get Data → Text/CSV**
3. Browse to `data/sales_data.csv` in this project folder
4. Click **Transform Data** and verify column types:
   - `order_date`, `ship_date` → **Date**
   - `quantity` → **Whole Number**
   - `unit_price`, `cost`, `discount` → **Decimal Number**
5. Click **Close & Apply**

---

## Option B — Connect to SQL Database

1. Click **Home → Get Data → More → Database**
2. Select your database type (PostgreSQL, SQL Server, etc.)
3. Enter your server/host and database name
4. Import these tables:
   - `fact_sales`
   - `dim_product`
   - `dim_customer`
   - `dim_region`
   - `dim_date`
5. Verify relationships in **Model View** (see below)

---

## Data Model (Star Schema)

```
           dim_date
               │ order_date
               │
dim_region ───┤ region_id      ├─── fact_sales ───┤ product_id ─── dim_product
               │                       │
dim_customer ──┘ customer_id           │
                               (grain: order_id + product_id)
```

**Relationships to configure in Model View:**

| From (fact_sales) | To (dimension) | Cardinality |
|-------------------|----------------|-------------|
| `order_date` | `dim_date.date_key` | Many → One |
| `customer_id` | `dim_customer.customer_id` | Many → One |
| `product_id` | `dim_product.product_id` | Many → One |
| `region_id` | `dim_region.region_id` | Many → One |

---

## DAX Measures

Create these measures in Power BI (**Home → New Measure**):

```dax
-- Total Revenue
Total Revenue = SUM(fact_sales[total_revenue])

-- Total Profit
Total Profit = SUM(fact_sales[profit])

-- Profit Margin %
Profit Margin % = DIVIDE([Total Profit], [Total Revenue])

-- Total Orders
Total Orders = DISTINCTCOUNT(fact_sales[order_id])

-- MoM Revenue Growth
MoM Growth % =
VAR CurrentMonth = [Total Revenue]
VAR PrevMonth = CALCULATE([Total Revenue], DATEADD(dim_date[date_key], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PrevMonth, PrevMonth)

-- YoY Revenue Growth
YoY Growth % =
VAR CurrentYear = [Total Revenue]
VAR PrevYear = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(dim_date[date_key]))
RETURN DIVIDE(CurrentYear - PrevYear, PrevYear)

-- Average Order Value
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])

-- Revenue vs. Average Region (for underperformer flag)
Pct vs Avg Region =
VAR AvgRegion = AVERAGEX(VALUES(dim_region[region_name]), [Total Revenue])
RETURN DIVIDE([Total Revenue] - AvgRegion, AvgRegion)
```

---

## Dashboard Pages & Visuals

### Page 1 — Executive Summary
| Visual | Type | Fields |
|--------|------|--------|
| Total Revenue | KPI Card | `[Total Revenue]` |
| Total Profit | KPI Card | `[Total Profit]` |
| Profit Margin % | KPI Card | `[Profit Margin %]` |
| Total Orders | KPI Card | `[Total Orders]` |
| Revenue by Year | Column Chart | `dim_date[year]`, `[Total Revenue]` |
| Revenue vs. Profit | Line + Column | Month axis, both measures |

### Page 2 — Sales Trends
| Visual | Type | Fields |
|--------|------|--------|
| Monthly Revenue | Line Chart | `dim_date[month_name]`, `[Total Revenue]`, year as legend |
| MoM Growth | KPI Card | `[MoM Growth %]` |
| YoY Comparison | Bar Chart | `dim_date[year]`, `[Total Revenue]` |
| Revenue Heatmap | Matrix | Rows=Year, Cols=Month, Values=`[Total Revenue]` |

### Page 3 — Regional Performance
| Visual | Type | Fields |
|--------|------|--------|
| Revenue Map | Filled Map | `dim_region[region_name]`, `[Total Revenue]` |
| Region Bar Chart | Bar Chart | `dim_region[region_name]`, `[Total Revenue]` |
| Underperformers Table | Table | Region, Revenue, `[Pct vs Avg Region]` |
| Region × Category Matrix | Matrix | Rows=Region, Cols=Category, `[Total Revenue]` |

### Page 4 — Product Analysis
| Visual | Type | Fields |
|--------|------|--------|
| Top Products | Bar Chart | `dim_product[product_name]` (Top N filter), `[Total Revenue]` |
| Category Donut | Donut Chart | `dim_product[category]`, `[Total Revenue]` |
| Margin Scatter | Scatter | X=`[Total Revenue]`, Y=`[Profit Margin %]`, Details=Product |
| Sub-Category Table | Table | Category, Sub-Category, Revenue, Profit, Margin% |

### Page 5 — Customer Segments
| Visual | Type | Fields |
|--------|------|--------|
| Segment Donut | Donut Chart | `dim_customer[segment]`, `[Total Revenue]` |
| Segment KPIs | Multi-row Card | Revenue, Profit, Orders per segment |
| Top Customers | Table | Customer, Segment, Revenue, Orders |
| New vs. Returning | Stacked Bar | Year axis, customer type legend |

### Page 6 — Seasonal Insights
| Visual | Type | Fields |
|--------|------|--------|
| Monthly Heatmap | Matrix | Rows=Year, Cols=Month, Values=`[Total Revenue]` (conditional formatting) |
| Quarterly Index | Bar Chart | Quarter, `[Total Revenue]` |
| Peak/Low Periods | Line Chart | All months, highlight top/bottom 3 |

---

## Slicers (Add to All Pages)

- **Year** — `dim_date[year]`
- **Region** — `dim_region[region_name]`
- **Segment** — `dim_customer[segment]`
- **Category** — `dim_product[category]`

Use **Sync Slicers** (View → Sync Slicers) to sync across all pages.

---

## Publishing

1. **Save** your `.pbix` file to `dashboard/Sales_KPI_Dashboard.pbix`
2. Click **Home → Publish**
3. Sign in to your Power BI account
4. Select your workspace
5. Share the published report link with stakeholders

---

## Refreshing Data

- For CSV: **Home → Refresh** to reload the file
- For SQL: Set up **Scheduled Refresh** in Power BI Service (requires gateway for on-premises databases)

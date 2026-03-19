-- ============================================================
-- 03_kpi_revenue.sql
-- Sales KPI Dashboard — Revenue & Profit Margin KPIs
-- ============================================================

-- ─────────────────────────────────────────
-- 1. Overall KPI Summary (all-time)
-- ─────────────────────────────────────────
SELECT
    COUNT(DISTINCT order_id)                              AS total_orders,
    SUM(quantity)                                         AS total_units_sold,
    ROUND(SUM(total_revenue), 2)                          AS total_revenue,
    ROUND(SUM(cost), 2)                                   AS total_cost,
    ROUND(SUM(profit), 2)                                 AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(total_revenue), 0) * 100, 2)
                                                          AS profit_margin_pct
FROM fact_sales;

-- ─────────────────────────────────────────
-- 2. Monthly Revenue & Profit (full history)
-- ─────────────────────────────────────────
SELECT
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(fs.total_revenue), 2)                       AS monthly_revenue,
    ROUND(SUM(fs.profit), 2)                              AS monthly_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                          AS profit_margin_pct,
    COUNT(DISTINCT fs.order_id)                           AS order_count
FROM fact_sales fs
JOIN dim_date d ON d.date_key = fs.order_date
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- ─────────────────────────────────────────
-- 3. Month-over-Month (MoM) Revenue Growth
-- ─────────────────────────────────────────
WITH monthly AS (
    SELECT
        d.year,
        d.month,
        SUM(fs.total_revenue) AS revenue
    FROM fact_sales fs
    JOIN dim_date d ON d.date_key = fs.order_date
    GROUP BY d.year, d.month
)
SELECT
    year,
    month,
    ROUND(revenue, 2)                                     AS revenue,
    ROUND(
        LAG(revenue) OVER (ORDER BY year, month), 2
    )                                                     AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year, month))
        / NULLIF(LAG(revenue) OVER (ORDER BY year, month), 0) * 100, 2
    )                                                     AS mom_growth_pct
FROM monthly
ORDER BY year, month;

-- ─────────────────────────────────────────
-- 4. Year-over-Year (YoY) Revenue Growth
-- ─────────────────────────────────────────
WITH yearly AS (
    SELECT
        d.year,
        SUM(fs.total_revenue)  AS revenue,
        SUM(fs.profit)         AS profit
    FROM fact_sales fs
    JOIN dim_date d ON d.date_key = fs.order_date
    GROUP BY d.year
)
SELECT
    year,
    ROUND(revenue, 2)                                     AS total_revenue,
    ROUND(profit, 2)                                      AS total_profit,
    ROUND(profit / NULLIF(revenue, 0) * 100, 2)           AS profit_margin_pct,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year))
        / NULLIF(LAG(revenue) OVER (ORDER BY year), 0) * 100, 2
    )                                                     AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- ─────────────────────────────────────────
-- 5. Quarterly Revenue Breakdown
-- ─────────────────────────────────────────
SELECT
    d.year,
    d.quarter,
    CONCAT('Q', d.quarter, ' ', d.year)                  AS period_label,
    ROUND(SUM(fs.total_revenue), 2)                       AS quarterly_revenue,
    ROUND(SUM(fs.profit), 2)                              AS quarterly_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                          AS profit_margin_pct
FROM fact_sales fs
JOIN dim_date d ON d.date_key = fs.order_date
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

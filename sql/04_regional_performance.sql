-- ============================================================
-- 04_regional_performance.sql
-- Sales KPI Dashboard — Regional Breakdown & Rankings
-- ============================================================

-- ─────────────────────────────────────────
-- 1. Revenue by Region (all-time)
-- ─────────────────────────────────────────
SELECT
    r.region_name,
    r.zone,
    ROUND(SUM(fs.total_revenue), 2)                            AS total_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS total_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS profit_margin_pct,
    COUNT(DISTINCT fs.order_id)                                AS total_orders,
    COUNT(DISTINCT fs.customer_id)                             AS unique_customers,
    RANK() OVER (ORDER BY SUM(fs.total_revenue) DESC)          AS revenue_rank
FROM fact_sales fs
JOIN dim_region r ON r.region_id = fs.region_id
GROUP BY r.region_id, r.region_name, r.zone
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────
-- 2. Underperforming Regions
--    (revenue < 80% of average regional revenue)
-- ─────────────────────────────────────────
WITH regional_revenue AS (
    SELECT
        r.region_name,
        SUM(fs.total_revenue) AS revenue
    FROM fact_sales fs
    JOIN dim_region r ON r.region_id = fs.region_id
    GROUP BY r.region_name
),
avg_revenue AS (
    SELECT AVG(revenue) AS avg_regional_revenue FROM regional_revenue
)
SELECT
    rr.region_name,
    ROUND(rr.revenue, 2)                                       AS region_revenue,
    ROUND(a.avg_regional_revenue, 2)                           AS avg_revenue,
    ROUND((rr.revenue - a.avg_regional_revenue)
          / NULLIF(a.avg_regional_revenue, 0) * 100, 2)        AS pct_vs_avg,
    CASE
        WHEN rr.revenue < 0.80 * a.avg_regional_revenue THEN '⚠️ Underperforming'
        WHEN rr.revenue > 1.20 * a.avg_regional_revenue THEN '✅ Outperforming'
        ELSE '➖ On Target'
    END                                                        AS performance_flag
FROM regional_revenue rr
CROSS JOIN avg_revenue a
ORDER BY rr.revenue DESC;

-- ─────────────────────────────────────────
-- 3. Monthly Revenue Trend by Region
-- ─────────────────────────────────────────
SELECT
    r.region_name,
    d.year,
    d.month,
    d.month_name,
    ROUND(SUM(fs.total_revenue), 2)                            AS monthly_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS monthly_profit
FROM fact_sales fs
JOIN dim_region r ON r.region_id = fs.region_id
JOIN dim_date   d ON d.date_key  = fs.order_date
GROUP BY r.region_name, d.year, d.month, d.month_name
ORDER BY r.region_name, d.year, d.month;

-- ─────────────────────────────────────────
-- 4. Region × Category Revenue Matrix
-- ─────────────────────────────────────────
SELECT
    r.region_name,
    p.category,
    ROUND(SUM(fs.total_revenue), 2)                            AS revenue,
    ROUND(SUM(fs.profit), 2)                                   AS profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS margin_pct
FROM fact_sales fs
JOIN dim_region  r ON r.region_id  = fs.region_id
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY r.region_name, p.category
ORDER BY r.region_name, revenue DESC;

-- ─────────────────────────────────────────
-- 5. YoY Regional Growth Comparison
-- ─────────────────────────────────────────
WITH yearly_regional AS (
    SELECT
        r.region_name,
        d.year,
        SUM(fs.total_revenue) AS revenue
    FROM fact_sales fs
    JOIN dim_region r ON r.region_id = fs.region_id
    JOIN dim_date   d ON d.date_key  = fs.order_date
    GROUP BY r.region_name, d.year
)
SELECT
    region_name,
    year,
    ROUND(revenue, 2)                                          AS revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY region_name ORDER BY year))
        / NULLIF(LAG(revenue) OVER (PARTITION BY region_name ORDER BY year), 0) * 100, 2
    )                                                          AS yoy_growth_pct
FROM yearly_regional
ORDER BY region_name, year;

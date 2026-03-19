-- ============================================================
-- 07_seasonal_trends.sql
-- Sales KPI Dashboard — Monthly & Seasonal Trend Analysis
-- ============================================================

-- ─────────────────────────────────────────
-- 1. Revenue by Month (aggregated across all years)
--    Identifies seasonal patterns
-- ─────────────────────────────────────────
SELECT
    d.month,
    d.month_name,
    ROUND(AVG(monthly_rev.revenue), 2)                          AS avg_monthly_revenue,
    ROUND(SUM(monthly_rev.revenue), 2)                          AS total_revenue_all_years,
    COUNT(DISTINCT d.year)                                       AS years_in_sample
FROM dim_date d
JOIN (
    SELECT
        order_date,
        SUM(total_revenue) AS revenue
    FROM fact_sales
    GROUP BY order_date
) daily ON daily.order_date = d.date_key
JOIN (
    SELECT
        EXTRACT(YEAR FROM order_date)  AS yr,
        EXTRACT(MONTH FROM order_date) AS mo,
        SUM(total_revenue)             AS revenue
    FROM fact_sales
    GROUP BY yr, mo
) monthly_rev ON monthly_rev.yr = d.year AND monthly_rev.mo = d.month
GROUP BY d.month, d.month_name
ORDER BY d.month;

-- ─────────────────────────────────────────
-- 2. Revenue Heatmap: Year × Month
-- ─────────────────────────────────────────
SELECT
    d.year,
    d.month_name,
    d.month,
    ROUND(SUM(fs.total_revenue), 2)                             AS revenue,
    ROUND(SUM(fs.profit), 2)                                    AS profit,
    COUNT(DISTINCT fs.order_id)                                 AS orders
FROM fact_sales fs
JOIN dim_date d ON d.date_key = fs.order_date
GROUP BY d.year, d.month_name, d.month
ORDER BY d.year, d.month;

-- ─────────────────────────────────────────
-- 3. Quarterly Seasonality Index
--    (quarter revenue / avg quarter revenue × 100)
-- ─────────────────────────────────────────
WITH quarterly AS (
    SELECT
        d.year,
        d.quarter,
        SUM(fs.total_revenue) AS q_revenue
    FROM fact_sales fs
    JOIN dim_date d ON d.date_key = fs.order_date
    GROUP BY d.year, d.quarter
),
avg_quarter AS (
    SELECT quarter, AVG(q_revenue) AS avg_q_revenue
    FROM quarterly
    GROUP BY quarter
),
overall_avg AS (
    SELECT AVG(q_revenue) AS overall_avg FROM quarterly
)
SELECT
    aq.quarter,
    ROUND(aq.avg_q_revenue, 2)                                  AS avg_quarterly_revenue,
    ROUND(oa.overall_avg, 2)                                    AS overall_avg_quarterly,
    ROUND(aq.avg_q_revenue / NULLIF(oa.overall_avg, 0) * 100, 2)
                                                                AS seasonality_index
FROM avg_quarter aq
CROSS JOIN overall_avg oa
ORDER BY aq.quarter;

-- ─────────────────────────────────────────
-- 4. Weekend vs. Weekday Sales
-- ─────────────────────────────────────────
SELECT
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END    AS day_type,
    COUNT(DISTINCT fs.order_id)                                  AS orders,
    ROUND(SUM(fs.total_revenue), 2)                              AS total_revenue,
    ROUND(AVG(fs.total_revenue), 2)                              AS avg_revenue_per_line,
    ROUND(SUM(fs.profit), 2)                                     AS total_profit
FROM fact_sales fs
JOIN dim_date d ON d.date_key = fs.order_date
GROUP BY d.is_weekend
ORDER BY day_type;

-- ─────────────────────────────────────────
-- 5. Peak & Low Sales Months (last 2 years)
-- ─────────────────────────────────────────
WITH monthly_totals AS (
    SELECT
        d.year,
        d.month,
        d.month_name,
        SUM(fs.total_revenue) AS revenue
    FROM fact_sales fs
    JOIN dim_date d ON d.date_key = fs.order_date
    WHERE d.year >= EXTRACT(YEAR FROM CURRENT_DATE) - 2
    GROUP BY d.year, d.month, d.month_name
)
SELECT
    year,
    month,
    month_name,
    ROUND(revenue, 2)                                            AS revenue,
    RANK() OVER (PARTITION BY year ORDER BY revenue DESC)        AS revenue_rank_in_year,
    CASE
        WHEN RANK() OVER (PARTITION BY year ORDER BY revenue DESC) <= 3
            THEN '🔥 Peak Month'
        WHEN RANK() OVER (PARTITION BY year ORDER BY revenue ASC) <= 3
            THEN '❄️ Low Month'
        ELSE '—'
    END                                                          AS season_flag
FROM monthly_totals
ORDER BY year, month;

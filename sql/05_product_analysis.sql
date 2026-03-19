-- ============================================================
-- 05_product_analysis.sql
-- Sales KPI Dashboard — Top-Performing Products
-- ============================================================

-- ─────────────────────────────────────────
-- 1. Top 10 Products by Revenue
-- ─────────────────────────────────────────
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    SUM(fs.quantity)                                           AS units_sold,
    ROUND(SUM(fs.total_revenue), 2)                            AS total_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS total_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS profit_margin_pct,
    RANK() OVER (ORDER BY SUM(fs.total_revenue) DESC)          AS revenue_rank
FROM fact_sales  fs
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
ORDER BY total_revenue DESC
LIMIT 10;

-- ─────────────────────────────────────────
-- 2. Top 10 Products by Profit Margin
-- ─────────────────────────────────────────
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(fs.total_revenue), 2)                            AS total_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS total_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS profit_margin_pct
FROM fact_sales  fs
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(fs.total_revenue) > 1000          -- filter low-volume noise
ORDER BY profit_margin_pct DESC
LIMIT 10;

-- ─────────────────────────────────────────
-- 3. Category-Level Performance
-- ─────────────────────────────────────────
SELECT
    p.category,
    COUNT(DISTINCT p.product_id)                               AS product_count,
    SUM(fs.quantity)                                           AS units_sold,
    ROUND(SUM(fs.total_revenue), 2)                            AS total_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS total_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS profit_margin_pct,
    ROUND(SUM(fs.total_revenue) / NULLIF(SUM(SUM(fs.total_revenue)) OVER (), 0) * 100, 2)
                                                               AS revenue_share_pct
FROM fact_sales  fs
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────
-- 4. Sub-Category Drilldown
-- ─────────────────────────────────────────
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(fs.total_revenue), 2)                            AS revenue,
    ROUND(SUM(fs.profit), 2)                                   AS profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS margin_pct,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(fs.total_revenue) DESC)
                                                               AS rank_in_category
FROM fact_sales  fs
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY p.category, p.sub_category
ORDER BY p.category, revenue DESC;

-- ─────────────────────────────────────────
-- 5. Loss-Making Products (profit < 0)
-- ─────────────────────────────────────────
SELECT
    p.product_name,
    p.category,
    ROUND(SUM(fs.total_revenue), 2)                            AS total_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS total_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS profit_margin_pct,
    COUNT(DISTINCT fs.order_id)                                AS order_count
FROM fact_sales  fs
JOIN dim_product p ON p.product_id = fs.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(fs.profit) < 0
ORDER BY total_profit ASC;

-- ─────────────────────────────────────────
-- 6. Discount Impact on Profitability
-- ─────────────────────────────────────────
SELECT
    CASE
        WHEN fs.discount = 0            THEN 'No Discount'
        WHEN fs.discount <= 0.10        THEN '1-10%'
        WHEN fs.discount <= 0.20        THEN '11-20%'
        WHEN fs.discount <= 0.30        THEN '21-30%'
        ELSE '30%+'
    END                                                        AS discount_bucket,
    COUNT(*)                                                   AS order_lines,
    ROUND(AVG(fs.total_revenue), 2)                            AS avg_order_revenue,
    ROUND(SUM(fs.profit), 2)                                   AS total_profit,
    ROUND(AVG(fs.profit), 2)                                   AS avg_profit_per_line,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                               AS profit_margin_pct
FROM fact_sales fs
GROUP BY discount_bucket
ORDER BY MIN(fs.discount);

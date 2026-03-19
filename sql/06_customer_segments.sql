-- ============================================================
-- 06_customer_segments.sql
-- Sales KPI Dashboard — Customer Segmentation Analysis
-- ============================================================

-- ─────────────────────────────────────────
-- 1. Revenue by Customer Segment
-- ─────────────────────────────────────────
SELECT
    c.segment,
    COUNT(DISTINCT fs.customer_id)                              AS customer_count,
    COUNT(DISTINCT fs.order_id)                                 AS total_orders,
    ROUND(AVG(order_totals.order_value), 2)                     AS avg_order_value,
    ROUND(SUM(fs.total_revenue), 2)                             AS total_revenue,
    ROUND(SUM(fs.profit), 2)                                    AS total_profit,
    ROUND(SUM(fs.profit) / NULLIF(SUM(fs.total_revenue), 0) * 100, 2)
                                                                AS profit_margin_pct,
    ROUND(SUM(fs.total_revenue)
          / NULLIF(SUM(SUM(fs.total_revenue)) OVER (), 0) * 100, 2)
                                                                AS revenue_share_pct
FROM fact_sales fs
JOIN dim_customer c ON c.customer_id = fs.customer_id
JOIN (
    SELECT order_id, SUM(total_revenue) AS order_value
    FROM fact_sales
    GROUP BY order_id
) order_totals ON order_totals.order_id = fs.order_id
GROUP BY c.segment
ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────
-- 2. New vs. Returning Customers
--    (first-order year = "new", subsequent = "returning")
-- ─────────────────────────────────────────
WITH customer_first_order AS (
    SELECT
        customer_id,
        MIN(order_date)                     AS first_order_date,
        EXTRACT(YEAR FROM MIN(order_date))  AS first_year
    FROM fact_sales
    GROUP BY customer_id
),
tagged_sales AS (
    SELECT
        fs.*,
        d.year,
        CASE
            WHEN d.year = cfo.first_year THEN 'New Customer'
            ELSE 'Returning Customer'
        END AS customer_type
    FROM fact_sales fs
    JOIN dim_date d             ON d.date_key    = fs.order_date
    JOIN customer_first_order cfo ON cfo.customer_id = fs.customer_id
)
SELECT
    year,
    customer_type,
    COUNT(DISTINCT customer_id)                                 AS customers,
    COUNT(DISTINCT order_id)                                    AS orders,
    ROUND(SUM(total_revenue), 2)                                AS revenue,
    ROUND(SUM(profit), 2)                                       AS profit
FROM tagged_sales
GROUP BY year, customer_type
ORDER BY year, customer_type;

-- ─────────────────────────────────────────
-- 3. Top 20 Customers by Lifetime Value (LTV)
-- ─────────────────────────────────────────
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    c.state,
    COUNT(DISTINCT fs.order_id)                                 AS total_orders,
    ROUND(SUM(fs.total_revenue), 2)                             AS lifetime_revenue,
    ROUND(SUM(fs.profit), 2)                                    AS lifetime_profit,
    ROUND(AVG(order_totals.order_value), 2)                     AS avg_order_value,
    MIN(fs.order_date)                                          AS first_purchase,
    MAX(fs.order_date)                                          AS last_purchase,
    MAX(fs.order_date) - MIN(fs.order_date)                     AS customer_tenure_days
FROM fact_sales fs
JOIN dim_customer c ON c.customer_id = fs.customer_id
JOIN (
    SELECT order_id, SUM(total_revenue) AS order_value
    FROM fact_sales
    GROUP BY order_id
) order_totals ON order_totals.order_id = fs.order_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.state
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- ─────────────────────────────────────────
-- 4. RFM Scoring (Recency, Frequency, Monetary)
--    Reference date: most recent order date in dataset
-- ─────────────────────────────────────────
WITH ref_date AS (
    SELECT MAX(order_date) AS max_date FROM fact_sales
),
customer_rfm AS (
    SELECT
        fs.customer_id,
        c.customer_name,
        c.segment,
        (SELECT max_date FROM ref_date) - MAX(fs.order_date)   AS recency_days,
        COUNT(DISTINCT fs.order_id)                             AS frequency,
        ROUND(SUM(fs.total_revenue), 2)                         AS monetary
    FROM fact_sales fs
    JOIN dim_customer c ON c.customer_id = fs.customer_id
    GROUP BY fs.customer_id, c.customer_name, c.segment
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC)               AS r_score,  -- lower = better
        NTILE(5) OVER (ORDER BY frequency DESC)                 AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)                  AS m_score
    FROM customer_rfm
)
SELECT
    customer_id,
    customer_name,
    segment,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)                               AS rfm_total,
    CASE
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Champions'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Loyal Customers'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Potential Loyalists'
        WHEN r_score >= 4 AND (f_score + m_score) <= 4 THEN 'New Customers'
        WHEN r_score <= 2 AND (f_score + m_score) >= 8 THEN 'At Risk'
        ELSE 'Need Attention'
    END                                                         AS rfm_segment
FROM rfm_scores
ORDER BY rfm_total DESC;

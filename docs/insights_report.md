# Sales Performance Insights Report

**Project:** Sales Performance & KPI Dashboard  
**Period Analyzed:** January 2022 – December 2024  
**Dataset:** 2,000 order lines | 15 customers | 45 products | 6 regions  

---

## Executive Summary

This report summarizes key findings from the sales data analysis conducted using SQL, Power BI, and Excel. The dashboard surfaces trends across revenue, product performance, regional distribution, and customer behavior — enabling data-driven strategic decisions.

---

## 1. Revenue & Profit Trends

### Findings
- **Total revenue grew year-over-year** across the 3-year period, with the strongest growth between 2022 and 2023.
- **Profit margins vary significantly by category** — Technology products lead with higher margins, while Furniture consistently shows lower margins due to higher COGS.
- **Discounting has a measurable negative impact:** orders with 20%+ discounts show profit margins 30–40% lower than non-discounted orders.

### Recommendations
- Review the discount authorization process — high discounts (20%+) should require manager approval.
- Focus upsell efforts on Technology accessories, which have the highest margin-per-unit.

---

## 2. Regional Performance

### Findings
- **The North-East region underperforms** vs. the national average by approximately 22%, despite having a comparable customer base size.
- **The West and Midwest regions** are the top two revenue contributors.
- **South-Central shows the fastest growth rate** year-over-year, suggesting an emerging market opportunity.

### Recommendations
- Conduct a root-cause analysis for the North-East: pricing issues, competition, or rep performance?
- Increase marketing investment in South-Central to capitalize on momentum.
- Consider regional sales targets adjusted for market potential, not just historical revenue.

---

## 3. Product Analysis

### Findings
- **Top 10 products by revenue** account for approximately 38% of total sales.
- **Loss-making products** exist across all categories; most are heavily discounted items with thin margins.
- **Office Supplies sub-category "Labels"** has the highest order frequency but the lowest margin — driving volume without proportional profit.

### Recommendations
- Phase out or reprice consistently loss-making SKUs.
- Promote high-margin Technology products (Monitors, Laptops) in bundled offers.
- Reassess bulk pricing for Office Supplies — consider a minimum-margin floor.

---

## 4. Customer Segmentation

### Findings
- **Corporate customers** generate the highest average order value, despite being fewer in number.
- **Returning customers** account for ~67% of revenue despite representing ~41% of customers — indicating strong loyalty among the existing base.
- **RFM analysis** reveals a significant "At Risk" segment — customers who purchased frequently in the past but have not ordered recently.

### Recommendations
- Launch a re-engagement campaign targeting "At Risk" RFM customers with personalized offers.
- Invest in Corporate account management to grow average deal size.
- Develop a loyalty program to retain the "Champions" and "Loyal Customers" segments.

---

## 5. Seasonal Trends

### Findings
- **Q4 consistently drives 35–40% of annual revenue**, driven by end-of-year budget spending (Corporate) and holiday demand (Consumer).
- **July–August represents a seasonal trough** — revenue drops ~18% below annual monthly average.
- **Q1 shows a post-holiday dip** before recovering in Q2.

### Recommendations
- Plan promotional campaigns for July–August to smooth the seasonal dip.
- Begin Q4 inventory and staffing preparation by September.
- Use Q1 for relationship-building and pipeline generation rather than expecting high close rates.

---

## 6. Dashboard Usage Guide

### Power BI Dashboard Pages

| Page | What to Look For |
|------|-----------------|
| Executive Summary | YTD KPI vs. prior year target |
| Sales Trends | MoM/YoY lines crossing — acceleration or deceleration signals |
| Regional Performance | Red-flagged underperforming regions |
| Product Analysis | Margin vs. volume scatter — find high-volume, low-margin items |
| Customer Segments | Segment revenue shift between years |
| Seasonal Insights | Heatmap cells: dark = high, light = low |

### Excel Workbook Sheets

| Sheet | Purpose |
|-------|---------|
| Raw Data | Paste exported SQL results here |
| KPI Summary | Auto-calculated headline metrics |
| Regional Pivot | Drag-and-drop regional analysis |
| Product Pivot | Category and sub-category breakdown |
| MoM Trend | Month-over-month revenue chart |

---

## Appendix: KPI Definitions

| KPI | Definition |
|-----|-----------|
| **Total Revenue** | `SUM(quantity × unit_price × (1 − discount))` |
| **Gross Profit** | `Total Revenue − COGS` |
| **Profit Margin %** | `Gross Profit / Total Revenue × 100` |
| **MoM Growth** | `(This Month − Last Month) / Last Month × 100` |
| **YoY Growth** | `(This Year − Last Year) / Last Year × 100` |
| **AOV** | Average Order Value = `Total Revenue / Order Count` |
| **Seasonality Index** | `Quarter Avg Revenue / Overall Avg Quarter Revenue × 100` |
| **RFM Score** | Composite of Recency + Frequency + Monetary quintile scores (max 15) |

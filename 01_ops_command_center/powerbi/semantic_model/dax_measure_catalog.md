# DAX Measure Catalog — Project 1 (Ops Command Center)

## Purpose

This catalog documents the intended Power BI measure layer for Project 1.

It is designed to:

- govern business-facing measures
- tie report metrics back to SQL mart logic
- separate base aggregations from derived KPIs and diagnostics
- keep the semantic model thin and explainable

## Status Key

- **SQL validated** = logic already exists in mart / QA / reconciliation SQL
- **Planned in semantic model** = intended for Power BI, not yet implemented in a PBIX
- **Diagnostic** = intended for reconciliation / trust reporting rather than executive KPI cards

## Measure Design Principles

- Prefer `mart.fact_sales_daily` as the canonical sales surface
- Use mart KPI views where business logic is already curated in SQL
- Keep base measures simple and reusable
- Build derived KPIs from validated base measures where appropriate
- Treat reconciliation measures as governed diagnostics

## Base Measures

| Measure Name | Business Definition | SQL Reference | Intended Page | Status | Notes |
|---|---|---|---|---|---|
| Gross Sales | Sum of gross sales across modeled sales facts | `mart.fact_sales_daily` | Executive Overview, Sales & Margin | SQL validated | Canonical gross sales measure should be based on total modeled sales, not distributor-only sales. |
| Net Sales | Sum of net sales across modeled sales facts | `mart.fact_sales_daily` | Executive Overview, Sales & Margin | SQL validated | Primary top-line sales measure. |
| COGS | Sum of cost of goods sold across modeled sales facts | `mart.fact_sales_daily` | Executive Overview, Sales & Margin | SQL validated | Base finance measure used in gross-margin calculations. |
| Discount Amount | Gross sales minus net sales | `mart.fact_sales_daily` | Sales & Margin | SQL validated | Useful for discount and pricing analysis. |
| Units Sold | Sum of units sold | `mart.fact_sales_daily` | Executive Overview, Sales & Margin | Planned in semantic model | Derived from sales fact quantity. |
| Orders | Sum of order count | `mart.fact_sales_daily` | Executive Overview, Sales & Margin | Planned in semantic model | Useful for AOV-style reporting. |
| Customers | Sum of customer count | `mart.fact_sales_daily` | Sales & Margin | Planned in semantic model | Useful for basket and penetration analysis. |
| Labor Hours | Sum of labor hours worked | `mart.fact_labor_daily` | People & Productivity | SQL validated | Core workforce input. |
| Labor Cost | Sum of labor cost | `mart.fact_actuals_monthly` or labor mart logic | People & Productivity, Finance / Strategy | Planned in semantic model | Monthly labor-cost reporting should stay aligned to modeled finance logic where used. |
| On Hand Units | Sum of on-hand inventory units | `mart.fact_inventory_snapshot_daily` | Ops & Inventory | Planned in semantic model | Base operations measure. |
| Units Shipped | Sum of shipped units | `mart.fact_shipments_daily` | Ops & Inventory | Planned in semantic model | Base shipment measure. |

## Derived KPI Measures

| Measure Name | Business Definition | SQL Reference | Intended Page | Status | Notes |
|---|---|---|---|---|---|
| Gross Margin $ | Net sales minus COGS | `mart.kpi_gross_margin_daily` | Executive Overview, Sales & Margin | SQL validated | Finance-style KPI surface already exists in SQL. |
| Gross Margin % | Gross margin divided by net sales | `mart.kpi_gross_margin_daily` | Executive Overview, Sales & Margin | Planned in semantic model | Use safe divide in DAX. |
| Net Sales per Labor Hour | Net sales divided by labor hours | `mart.kpi_sales_per_labor_hour_daily` | Executive Overview, People & Productivity | SQL validated | Core cross-functional productivity KPI. |
| Gross Sales per Labor Hour | Gross sales divided by labor hours | `mart.kpi_sales_per_labor_hour_daily` | People & Productivity | SQL validated | Useful companion productivity KPI. |
| In-Stock Rate | In-stock SKUs divided by total SKU universe in scope | `mart.kpi_instock_rate_daily` | Ops & Inventory | SQL validated | Primary inventory health KPI. |
| Days of Supply | Estimated days of inventory coverage | `mart.kpi_days_of_supply` | Ops & Inventory | SQL validated | Should be summarized carefully to avoid misleading row-level averaging. |
| ROI | Gross margin relative to labor cost | `mart.roi_monthly` | Finance / Strategy | SQL validated | Monthly finance-style KPI. |
| Breakeven Net Sales | Net sales required to cover labor cost | `mart.breakeven_monthly` | Finance / Strategy | SQL validated | Monthly approximation for performance framing. |
| Average Order Value | Net sales divided by orders | `mart.fact_sales_daily` | Sales & Margin | Planned in semantic model | Derived report KPI built from validated base measures. |
| Units per Order | Units sold divided by orders | `mart.fact_sales_daily` | Sales & Margin | Planned in semantic model | Useful for mix and basket analysis. |

## Comparison / Time-Based Measures

| Measure Name | Business Definition | SQL Reference | Intended Page | Status | Notes |
|---|---|---|---|---|---|
| Net Sales vs Prior Period $ | Change in net sales vs prior period | semantic model only | Executive Overview, Sales & Margin | Planned in semantic model | DAX time-intelligence measure. |
| Net Sales vs Prior Period % | Percent change in net sales vs prior period | semantic model only | Executive Overview, Sales & Margin | Planned in semantic model | Use date dimension and safe divide. |
| Gross Margin bps Change | Change in gross margin % expressed in basis points | semantic model only | Sales & Margin | Planned in semantic model | Good executive-style margin trend measure. |
| Labor Productivity vs Prior Period % | Percent change in sales per labor hour vs prior period | semantic model only | People & Productivity | Planned in semantic model | Useful for workforce efficiency trends. |

## Reconciliation / Diagnostic Measures

| Measure Name | Business Definition | SQL Reference | Intended Page | Status | Notes |
|---|---|---|---|---|---|
| Sales vs GL Delta $ | Dollar difference between modeled sales metrics and finance actuals | `mart.recon_sales_to_gl_monthly` | Reconciliation / Data Health | SQL validated | Diagnostic measure, not core KPI. |
| Sales vs GL Delta % | Percent difference between modeled sales metrics and finance actuals | `mart.recon_sales_to_gl_monthly` | Reconciliation / Data Health | SQL validated | Used with tolerance-aware trust messaging. |
| Reconciliation Status | Pass / fail / warning status for selected reconciliation metric | `mart.recon_sales_to_gl_monthly`, `mart.mart_reconciliation_controls` | Reconciliation / Data Health | SQL validated | Best surfaced as a controlled badge or table status. |
| Distributor vs POS Delta $ | Dollar variance between distributor and POS sales surfaces | `mart.recon_sales_distributor_vs_pos` | Reconciliation / Data Health | SQL validated | Operational comparison, not exact-tie expectation. |
| Distributor vs POS Delta % | Percent variance between distributor and POS sales surfaces | `mart.recon_sales_distributor_vs_pos` | Reconciliation / Data Health | SQL validated | Best used for monitoring and drill-through. |
| Missing Dimension Join Count | Count of fact rows missing expected conformed dimension matches | `mart.controls_missing_dim_joins` | Reconciliation / Data Health | SQL validated | Data-trust measure. |
| Data Freshness Status | Whether latest mart data is current relative to source expectations | `mart.controls_freshness` | Reconciliation / Data Health | SQL validated | Simulated data may intentionally produce warnings. |

## Suggested Measure Layer Structure

### Base measures
- Gross Sales
- Net Sales
- COGS
- Discount Amount
- Units Sold
- Orders
- Customers
- Labor Hours
- On Hand Units
- Units Shipped

### Derived KPIs
- Gross Margin $
- Gross Margin %
- Net Sales per Labor Hour
- Gross Sales per Labor Hour
- In-Stock Rate
- Days of Supply
- ROI
- Breakeven Net Sales
- Average Order Value
- Units per Order

### Comparison measures
- Net Sales vs Prior Period $
- Net Sales vs Prior Period %
- Gross Margin bps Change
- Labor Productivity vs Prior Period %

### Diagnostic measures
- Sales vs GL Delta $
- Sales vs GL Delta %
- Reconciliation Status
- Distributor vs POS Delta %
- Missing Dimension Join Count
- Data Freshness Status

## Notes

- Most business logic is intentionally pushed into SQL marts and KPI views.
- The semantic model should remain thin and primarily expose governed, validated measures.
- Reconciliation and control measures should live on a dedicated diagnostics page, not be mixed indiscriminately into executive KPI layouts.
- Where possible, Power BI outputs should be checked against SQL reference queries and mart-layer control views.
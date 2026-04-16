# Build Sequence — Project 1 Semantic Model

## Purpose

This document defines the recommended order for building the Power BI semantic model once authoring begins.

The goal is to reduce rework, keep the model governed, and ensure that report pages are built only after the underlying relationships and measure layer are stable.

---

## Build Philosophy

Build the semantic model in layers:

1. connect trusted mart objects
2. shape the semantic model structure
3. define governed measures
4. validate against SQL
5. build report pages
6. validate again before publish

Do not start by dragging visuals onto a blank canvas.

---

## Phase 1 — Connect to Reporting Objects

### Goal
Connect only to the mart-layer objects intended for reporting and diagnostics.

### Primary objects
- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_labor_daily`
- `mart.fact_actuals_monthly`
- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`

### Supporting objects
- `mart.fact_sales_distributor_daily`
- `mart.fact_sales_pos_daily`
- `mart.fact_shipments_daily`
- `mart.fact_labor_daily_employee`
- `mart.kpi_gross_margin_daily`
- `mart.kpi_sales_per_labor_hour_daily`
- `mart.kpi_instock_rate_daily`
- `mart.kpi_days_of_supply`
- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_missing_dim_joins`
- `mart.mart_reconciliation_controls`

### Rule
Do not connect raw, staging, or intermediate objects directly into the semantic model.

---

## Phase 2 — Clean Table and Field Presentation

### Goal
Make the semantic model readable before relationships and measures multiply.

### Actions
- rename table display names for business readability
- rename field display names to `Title Case`
- hide technical / metadata columns not needed in visuals
- confirm key columns remain visible for relationship setup
- organize objects logically

### Example
- `mart.fact_sales_daily` display name = `Sales`
- `mart.dim_store` display name = `Store`

---

## Phase 3 — Define Relationships

### Goal
Create the conformed-dimension structure of the model.

### Core relationships
- `dim_date.date` -> sales / labor / inventory date fields
- `dim_store.store_code` -> sales / labor / inventory store_code
- `dim_sku.sku` -> sales / inventory sku fields

### Supporting relationships
- `dim_employee.employee_id` -> employee-level labor fact, if included
- monthly `period_month` join for `fact_actuals_monthly` using month-start date

### Rules
- prefer one-to-many from dimension to fact
- keep filtering single-direction where practical
- avoid unnecessary many-to-many relationships
- validate grain before activating relationships

---

## Phase 4 — Create Base Measures

### Goal
Create the additive, reusable measures first.

### Examples
- Gross Sales
- Net Sales
- COGS
- Discount Amount
- Units Sold
- Orders
- Customers
- Labor Hours
- Labor Cost
- On Hand Units
- Units Shipped

### Rule
Do not build complex KPI logic until the base layer is stable.

---

## Phase 5 — Create Derived KPI Measures

### Goal
Build business-facing KPIs from validated base measures or KPI marts.

### Examples
- Gross Margin $
- Gross Margin %
- Average Order Value
- Units per Order
- Net Sales per Labor Hour
- Gross Sales per Labor Hour
- In-Stock Rate
- Days of Supply
- ROI
- Breakeven Net Sales

### Rule
Prefer SQL-curated KPI marts when they already encode the intended business logic.

---

## Phase 6 — Create Comparison Measures

### Goal
Support period-over-period storytelling and trend interpretation.

### Examples
- Net Sales vs Prior Period $
- Net Sales vs Prior Period %
- Gross Margin bps Change
- Labor Productivity vs Prior Period %

### Rule
Only add comparison measures after the date dimension and base measures are validated.

---

## Phase 7 — Create Diagnostic / Trust Measures

### Goal
Expose reconciliation and trust signals intentionally.

### Examples
- Sales vs GL Delta $
- Sales vs GL Delta %
- Reconciliation Status
- Distributor vs POS Delta %
- Missing Dimension Join Count
- Data Freshness Status

### Rule
Keep these measures grouped separately from the executive KPI layer.

---

## Phase 8 — Organize Display Folders

### Goal
Make the model navigable.

### Folders
- Base Measures
- Sales KPIs
- Labor KPIs
- Inventory KPIs
- Finance KPIs
- Time Intelligence
- Reconciliation
- Diagnostics / Trust
- Narrative Measures

### Rule
Organize the model before building pages so measure sprawl does not start early.

---

## Phase 9 — Validate Against SQL

### Goal
Confirm the semantic model matches the governed SQL truth.

### Validation checks
- KPI card totals tie to SQL reference queries
- relationship filters behave correctly
- reconciliation outputs match mart control views
- no unexpected row multiplication occurs
- selected page-level test cases match expected results

### Reference documents
- `semantic_model_validation.md`
- `dax_measure_catalog.md`
- `page_to_measure_map.md`

---

## Phase 10 — Build Report Pages

### Goal
Build visuals only after the semantic model is stable.

### Recommended page order
1. Executive Overview
2. Reconciliation & Data Health
3. Sales & Margin
4. Ops & Inventory
5. People & Productivity
6. Detail Drillthrough

### Rule
Start with the pages that show the strongest portfolio value first.

---

## Phase 11 — Add Narrative Measures and Tooltips

### Goal
Translate KPI outputs into business-readable interpretation.

### Examples
- Narrative - Net Sales
- Narrative - Gross Margin
- Narrative - Net Sales per Labor Hour
- Narrative - In-Stock Rate
- Narrative - Sales vs GL Status

### Rule
Narratives should support decision-making, not restate raw values.

---

## Phase 12 — Publish Readiness Review

### Goal
Confirm the model is safe to present.

### Publish checks
- SQL QA suite passed
- key report outputs tie to SQL
- reconciliation page reflects control state
- naming and display folders are consistent
- page layouts are readable
- known warnings are documented

---

## Current Recommendation

For Project 1, the first practical build sequence should be:

1. connect the canonical facts and dimensions
2. define relationships
3. build base measures
4. build executive KPI measures
5. validate against SQL
6. build the Executive Overview page
7. add reconciliation / trust visuals
8. expand to deeper pages only after the first page is stable

This sequence keeps the first version focused, governed, and portfolio-ready.
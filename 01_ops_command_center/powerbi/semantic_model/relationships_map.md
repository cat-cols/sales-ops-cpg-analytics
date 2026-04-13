# Relationships Map — Project 1 (Ops Command Center)

## Goal

Document the intended one-to-many relationships from conformed dimensions to reporting facts, KPI marts, and control-oriented objects.

The primary design goal is to keep the Power BI semantic model simple, stable, and aligned to the mart layer.

## Relationship Design Principles

- Prefer one-to-many relationships from dimensions into facts
- Keep filtering single-direction where possible
- Use conformed dimensions across Sales, Ops, and People
- Treat reconciliation/control views as diagnostics objects, not core facts
- Avoid many-to-many joins unless a bridge is explicitly designed
- Use the canonical mart facts where possible instead of source-specific marts unless a source comparison is needed

## Primary Conformed Dimensions

### `mart.dim_date`
- Grain: 1 row per calendar date
- Primary time dimension for daily reporting

### `mart.dim_store`
- Grain: 1 row per store_code
- Shared across Sales, Labor, and Operations

### `mart.dim_sku`
- Grain: 1 row per sku
- Shared across Sales and Inventory

### `mart.dim_employee`
- Grain: 1 row per employee entity
- Used for employee-level labor analysis where needed

## Primary Reporting Facts

### Canonical Sales Fact
`mart.fact_sales_daily`
- Grain: `sale_date + store_code + sku + channel + sales_source`
- Use as the primary sales reporting fact for the semantic model

### Supporting Source-Specific Sales Facts
`mart.fact_sales_distributor_daily`
- Grain: `sale_date + store_code + sku + channel`

`mart.fact_sales_pos_daily`
- Grain: `sale_date + store_code + sku`

These are useful for source-specific analysis and reconciliation, but should not be the main executive reporting surface if `mart.fact_sales_daily` is available.

### Labor Facts
`mart.fact_labor_daily`
- Grain: `work_date + store_code`

`mart.fact_labor_daily_employee`
- Grain: `work_date + store_code + employee_id`

### Operations Facts
`mart.fact_inventory_snapshot_daily`
- Grain: `snapshot_date + store_code + sku`

`mart.fact_shipments_daily`
- Grain: `ship_date + store_code + sku`

### Finance Fact
`mart.fact_actuals_monthly`
- Grain: `period_month + kpi_category`

This is a monthly finance-style fact and should be used carefully in the semantic model because its grain differs from the daily operational facts.

## Primary Relationships

## Date Relationships

### Daily operational relationships
- `mart.dim_date.date` -> `mart.fact_sales_daily.sale_date`
- `mart.dim_date.date` -> `mart.fact_sales_distributor_daily.sale_date`
- `mart.dim_date.date` -> `mart.fact_sales_pos_daily.sale_date`
- `mart.dim_date.date` -> `mart.fact_labor_daily.work_date`
- `mart.dim_date.date` -> `mart.fact_labor_daily_employee.work_date`
- `mart.dim_date.date` -> `mart.fact_inventory_snapshot_daily.snapshot_date`
- `mart.dim_date.date` -> `mart.fact_shipments_daily.ship_date`
- `mart.dim_date.date` -> `mart.kpi_gross_margin_daily.sale_date`
- `mart.dim_date.date` -> `mart.kpi_sales_per_labor_hour_daily.kpi_date`
- `mart.dim_date.date` -> `mart.kpi_instock_rate_daily.snapshot_date`
- `mart.dim_date.date` -> `mart.kpi_days_of_supply.snapshot_date`

### Monthly finance relationship
- `mart.dim_date.date` -> `mart.fact_actuals_monthly.period_month`

This relationship is intended to join on the first day of month. In Power BI, this can work as long as `period_month` is consistently the month-start date. If the model later expands, a dedicated month-level reporting table may be cleaner.

## Store Relationships

- `mart.dim_store.store_code` -> `mart.fact_sales_daily.store_code`
- `mart.dim_store.store_code` -> `mart.fact_sales_distributor_daily.store_code`
- `mart.dim_store.store_code` -> `mart.fact_sales_pos_daily.store_code`
- `mart.dim_store.store_code` -> `mart.fact_labor_daily.store_code`
- `mart.dim_store.store_code` -> `mart.fact_labor_daily_employee.store_code`
- `mart.dim_store.store_code` -> `mart.fact_inventory_snapshot_daily.store_code`
- `mart.dim_store.store_code` -> `mart.fact_shipments_daily.store_code`
- `mart.dim_store.store_code` -> `mart.kpi_gross_margin_daily.store_code`
- `mart.dim_store.store_code` -> `mart.kpi_sales_per_labor_hour_daily.store_code`
- `mart.dim_store.store_code` -> `mart.kpi_instock_rate_daily.store_code`
- `mart.dim_store.store_code` -> `mart.kpi_days_of_supply.store_code`

## SKU Relationships

- `mart.dim_sku.sku` -> `mart.fact_sales_daily.sku`
- `mart.dim_sku.sku` -> `mart.fact_sales_distributor_daily.sku`
- `mart.dim_sku.sku` -> `mart.fact_sales_pos_daily.sku`
- `mart.dim_sku.sku` -> `mart.fact_inventory_snapshot_daily.sku`
- `mart.dim_sku.sku` -> `mart.fact_shipments_daily.sku`
- `mart.dim_sku.sku` -> `mart.kpi_days_of_supply.sku`

## Employee Relationships

If employee-level workforce analysis is included in the semantic model:

- `mart.dim_employee.employee_id` -> `mart.fact_labor_daily_employee.employee_id`

## Relationship Status Guidance

## Recommended active relationships
These should be the default active relationships for the main reporting model:

- `dim_date` -> daily facts / KPI marts
- `dim_store` -> operational facts / KPI marts
- `dim_sku` -> sales and inventory facts
- `dim_employee` -> employee-level labor fact

## Use with care
These objects have useful reporting value but should not be treated like standard conformed facts:

- `mart.fact_actuals_monthly`
- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_missing_dim_joins`
- `mart.controls_rowcounts_daily`
- `mart.mart_reconciliation_controls`

These are best placed on a reconciliation / data-health page rather than blended directly into core KPI visuals.

## Notes on KPI Mart Views

The KPI marts are intentionally treated as report-ready facts:

- `mart.kpi_gross_margin_daily`
- `mart.kpi_sales_per_labor_hour_daily`
- `mart.kpi_instock_rate_daily`
- `mart.kpi_days_of_supply`

These reduce BI-layer complexity by pushing business logic into SQL rather than recreating every KPI from raw facts in DAX.

## Validation Rules

Relationships should only be used where grain remains stable and row multiplication risk is understood.

Expected uniqueness patterns:

- `mart.fact_sales_daily`: `sale_date + store_code + sku + channel + sales_source`
- `mart.fact_sales_distributor_daily`: `sale_date + store_code + sku + channel`
- `mart.fact_sales_pos_daily`: `sale_date + store_code + sku`
- `mart.fact_labor_daily`: `work_date + store_code`
- `mart.fact_labor_daily_employee`: `work_date + store_code + employee_id`
- `mart.fact_inventory_snapshot_daily`: `snapshot_date + store_code + sku`
- `mart.fact_shipments_daily`: `ship_date + store_code + sku`
- `mart.fact_actuals_monthly`: `period_month + kpi_category`

## Current Semantic Model Recommendation

For the first Power BI version, keep the model centered on:

- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_labor_daily`
- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`

Then expose reconciliation and trust objects on a dedicated diagnostics page rather than mixing them into the core star schema.
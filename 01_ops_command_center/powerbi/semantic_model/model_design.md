# Model Design — Project 1 (Ops Command Center)

## Purpose

This semantic model is designed to support business-facing reporting across Sales, Operations, People, and Finance-style controls for the Ops Command Center.

The model is intended to answer questions such as:

- What are net sales, gross sales, COGS, and gross margin over time?
- Which stores and SKUs are driving performance?
- How productive are stores based on revenue per labor hour?
- How healthy is inventory based on in-stock rate and days of supply?
- Where do reconciliation issues or data-trust warnings exist?

## Design Approach

The semantic layer is built on mart-layer views that already enforce stable grains, shared dimensions, and QA expectations.

The design principle is to keep the BI layer thin:

- business logic is pushed into SQL where practical
- grains are explicit
- conformed dimensions are reused across domains
- measures are governed and documented rather than created ad hoc in visuals
- reconciliation outputs are treated as reporting objects, not hidden backend artifacts

## Core Dimensions

### `mart.dim_date`
- Grain: 1 row per calendar date
- Primary reporting date dimension used across sales, labor, and inventory

### `mart.dim_store`
- Grain: 1 row per store_code
- Shared store/location dimension used across sales, labor, and operations

### `mart.dim_sku`
- Grain: 1 row per sku
- Shared product dimension used across sales and inventory

### `mart.dim_employee`
- Grain: 1 row per employee_id or modeled employee entity
- Used where employee-level labor analysis is needed

## Core Fact Tables

### `mart.fact_sales_daily`
- Grain: sale_date + store_code + sku + channel + sales_source
- Canonical sales fact for semantic-model reporting
- Includes both distributor and POS sales records through a unified reporting surface

### `mart.fact_sales_distributor_daily`
- Grain: sale_date + store_code + sku + channel
- Distributor-focused sales fact used for channel-specific reporting and reconciliation support

### `mart.fact_sales_pos_daily`
- Grain: sale_date + store_code + sku
- POS-focused sales fact used for operational comparison and reconciliation support

### `mart.fact_labor_daily`
- Grain: work_date + store_code
- Daily labor fact used for productivity KPIs

### `mart.fact_labor_daily_employee`
- Grain: work_date + store_code + employee_id
- Employee-level labor fact for more detailed workforce analysis

### `mart.fact_inventory_snapshot_daily`
- Grain: snapshot_date + store_code + sku
- Daily inventory snapshot fact

### `mart.fact_shipments_daily`
- Grain: ship_date + store_code + sku
- Daily shipment fact for operational flow analysis

### `mart.fact_actuals_monthly`
- Grain: period_month + kpi_category
- Monthly finance-style actuals used for reconciliation and executive reporting controls

## KPI / Analytical Mart Views

### `mart.kpi_gross_margin_daily`
- Grain: sale_date + store_code
- Derived daily gross-margin KPI surface

### `mart.kpi_sales_per_labor_hour_daily`
- Grain: kpi_date + store_code
- Cross-functional KPI combining sales and labor

### `mart.kpi_instock_rate_daily`
- Grain: snapshot_date + store_code
- Daily inventory health KPI

### `mart.kpi_days_of_supply`
- Grain: snapshot_date + store_code + sku
- SKU-level inventory coverage KPI

## Reconciliation / Control Views

### `mart.recon_sales_to_gl_monthly`
- Grain: period_month + metric
- Monthly reconciliation of modeled sales metrics to finance actuals
- Used as a reporting-ready trust/control object

### `mart.recon_sales_distributor_vs_pos`
- Grain: sale_date + store_code
- Operational comparison between distributor and POS sales surfaces
- Intended for monitoring, not exact-tie validation

### `mart.controls_rowcounts_daily`
- Rowcount-oriented control surface for daily model monitoring

### `mart.controls_missing_dim_joins`
- Highlights fact rows missing expected conformed dimension matches

### `mart.controls_dim_join_coverage`
- Surfaces dimension join coverage patterns for trust monitoring

### `mart.mart_reconciliation_controls`
- Rollup-style control view for reconciliation status monitoring

## Semantic Model Structure

The semantic model should be organized around a conformed star-schema pattern where possible:

- dimensions filter facts
- facts hold additive business measures
- KPI views support curated business calculations
- reconciliation/control views support a dedicated data-health page

### Recommended primary reporting table groups

**Sales**
- `mart.fact_sales_daily`
- `mart.fact_sales_distributor_daily`
- `mart.fact_sales_pos_daily`

**Operations**
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_shipments_daily`

**People**
- `mart.fact_labor_daily`
- `mart.fact_labor_daily_employee`

**Finance / Controls**
- `mart.fact_actuals_monthly`
- `mart.recon_sales_to_gl_monthly`
- `mart.mart_reconciliation_controls`

## Modeling Principles

- Prefer mart-layer facts and KPI marts over raw, staging, or intermediate objects
- Keep grains explicit and stable
- Reuse conformed dimensions across domains
- Separate base facts from derived KPIs
- Use reconciliation outputs as first-class trust objects
- Validate semantic-model outputs against SQL reference logic

## Canonical Fact Guidance

For executive and cross-functional reporting, `mart.fact_sales_daily` should be treated as the primary sales fact.

Use source-specific sales facts only when:
- comparing distributor vs POS behavior
- troubleshooting channel-specific logic
- validating source-specific rollups

## Known Constraints

- The semantic-model documentation is currently ahead of the full Power BI implementation
- The project is being developed on Mac, so the reporting layer is being designed in documentation first and intended for later Power BI buildout
- Some reporting concepts, such as a dedicated channel dimension, may remain logical/documented until they are formalized as physical mart-layer objects

## Current State

The SQL foundation for the semantic model is now materially complete:

- end-to-end pipeline runs successfully
- mart-layer QA passes
- dimension contracts pass
- monthly finance reconciliation passes within defined tolerances

This means the next major deliverable is not more warehouse logic, but the reporting layer built on top of the current mart design.
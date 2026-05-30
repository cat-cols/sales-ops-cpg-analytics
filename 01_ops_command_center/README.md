# Project 1 — Althea Ops Command Center

An end-to-end analytics engineering case study that simulates messy cross-functional source extracts, standardizes them in PostgreSQL, reconciles them to finance, and prepares a reporting-ready mart layer for Power BI.

## What this project proves

This project is designed to show that I can:

- ingest messy source data from multiple business functions
- standardize and model that data into clean, typed, reliable tables
- reconcile modeled outputs back to finance-facing totals
- build QA controls that hard-fail when key contracts are broken
- prepare a semantic-model-ready foundation for executive reporting

This is the flagship project in the repo and the closest match to a Business Analyst / Analytics Engineering workflow in a fast-moving consumer business.

## Business scenario

Leadership needs one trusted operating view across Sales, Operations, People, and Finance.

The challenge is not just dashboarding. It is making separate extracts agree on shared keys, consistent grains, and defensible KPI logic before anything reaches BI.

This project simulates that workflow with realistic source drops, layered SQL modeling, reconciliation checks, and reporting-oriented marts.

## Source intake scenario

The simulated intake mirrors recurring operational extracts:

- `sales_distributor_extract.csv`
- `pos_transactions.csv`
- `inventory_erp_snapshot.csv`
- `wms_shipments.csv`
- `labor_hours_payroll_export.xlsx`
- `timeclock_punches.csv`
- `finance_actuals_summary.xlsx`
- `gl_detail.csv`
- `account_status.csv`
- `dispensary_master.csv`
- `sku_distribution_status.csv`

These extracts intentionally include realistic issues such as:

- duplicate rows
- missing keys
- channel casing drift
- trailing whitespace
- mixed date formats
- inconsistent identifiers
- negative inventory exceptions
- payroll edge cases
- finance label variance

## Architecture

The project follows a layered warehouse pattern:

`Raw -> STG -> INT -> MART -> QA -> Power BI semantic/report layer`

### Raw
Landing tables store standardized raw loads from simulated source extracts.

### STG
Staging views clean types, normalize text, parse dates, and surface source-specific cleanup logic.

### INT
Intermediate views perform truth selection, deduplication, and conformance across shared business dimensions.

### MART
Mart views expose reporting-ready facts, dimensions, KPIs, and reconciliation controls.

### QA
SQL checks validate grain, null keys, uniqueness, reconciliation status, and mart dimension contracts.

## Current project status

### Complete
- messy source simulator
- Postgres raw loads
- STG layer
- INT / conformance layer
- MART facts and dimensions
- KPI views
- reconciliation controls
- hard-fail QA suite
- repeatable end-to-end pipeline command

### Current result
Project 1 now runs end to end with the SQL QA suite passing.

### Next layer
The next major step is the Power BI semantic model and report-page architecture built on top of the current mart layer.

## Repository structure

```text
01_ops_command_center/
  docs/
  sql/
    stg/
    int/
    mart/
    _qa/
    validation/
  data/
    source_extracts/
````

### Key SQL folders

* `sql/stg/` — source standardization
* `sql/int/` — conformance and truth-selection logic
* `sql/mart/` — facts, dimensions, KPIs, controls, recon
* `sql/_qa/` — hard-fail QA scripts

## Core modeled entities

### Facts

* `mart.fact_sales_distributor_daily`
* `mart.fact_sales_pos_daily`
* `mart.fact_sales_daily`
* `mart.fact_inventory_snapshot_daily`
* `mart.fact_shipments_daily`
* `mart.fact_labor_daily`
* `mart.fact_labor_daily_employee`
* `mart.fact_actuals_monthly`

### Dimensions

* `mart.dim_date`
* `mart.dim_store`
* `mart.dim_sku`
* `mart.dim_employee`

### KPI / control / recon views

* `mart.kpi_sales_per_labor_hour_daily`
* `mart.kpi_instock_rate_daily`
* `mart.kpi_days_of_supply`
* `mart.kpi_gross_margin_daily`
* `mart.roi_monthly`
* `mart.breakeven_monthly`
* `mart.controls_rowcounts_daily`
* `mart.controls_missing_dim_joins`
* `mart.controls_dim_join_coverage`
* `mart.recon_sales_distributor_vs_pos`
* `mart.recon_sales_to_gl_monthly`
* `mart.mart_reconciliation_controls`

## Shared modeling approach

This project uses conformed dimensions so Sales, Inventory, and Labor can align to the same business entities where possible.

### Stable grains

Examples of stable grains used in the mart layer:

* daily store / SKU / channel sales
* daily inventory snapshot by store / SKU
* daily labor by store
* daily labor by store / employee
* monthly finance actuals by KPI category

### Conformed dimensions

* Date
* Store / location
* SKU / product

## Example KPIs

The mart layer is designed to support KPIs such as:

* Gross Sales
* Net Sales
* COGS
* Gross Margin $
* Gross Margin %
* Units Sold
* Orders
* Customers
* Revenue per Labor Hour
* In-Stock Rate
* Days of Supply
* ROI
* Breakeven performance

## Reconciliation and controls

A major goal of the project is proving that modeled numbers are trustworthy.

### Finance reconciliation

`mart.recon_sales_to_gl_monthly` compares modeled monthly sales metrics to finance actuals.

Base metrics use strict tolerance rules, while derived gross margin is handled with its own tolerance logic because it is more sensitive to compounded variance.

### Control patterns included

* rowcount monitoring
* missing dimension join checks
* mart dimension contract checks
* grain / uniqueness checks
* freshness monitoring
* reconciliation status rollups

### QA philosophy

The QA layer is designed to hard-fail on meaningful model contract issues rather than silently allowing drift.

## How to run

From the repo root:

```bash
python3 scripts/generate_project1_data.py --pg-dsn "$P1_PG_OPS" --pg-load-mode truncate_then_append && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/stg/_build_stg.sql && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/int/_build_int.sql && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/mart/_build_mart.sql && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/_qa/_run_qa.sql
```

## What the pipeline does

1. generates synthetic but realistic source drops
2. loads standardized raw tables into PostgreSQL
3. builds staging views
4. builds intermediate conformance views
5. builds marts, KPIs, and reconciliation controls
6. runs QA checks across INT, MART, dimensions, and recon outputs

## Documentation

The `docs/` folder is intended to hold project-facing documentation such as:

* source register
* reconciliation log
* reporting calendar
* stakeholder notes
* executive walkthrough
* semantic model planning docs

## Power BI plan

The SQL foundation is complete enough to support a Power BI semantic model as the next project layer.

Planned deliverables for the reporting layer:

* semantic model design
* relationship map
* DAX measure catalog
* report page architecture
* narrative tooltip logic
* executive overview and reconciliation pages

## Why this project matters

This project is meant to show more than SQL syntax or dashboard aesthetics.

It shows the discipline behind trustworthy analytics:

* source intake awareness
* layered modeling
* cross-functional conformance
* reconciliation mindset
* QA controls
* reporting readiness

That combination is what turns raw extracts into decision-support data.

## Tech stack

* PostgreSQL
* SQL
* Python
* pandas
* NumPy
* openpyxl
* psycopg
* Excel / CSV source simulation
* Power BI planning artifacts

## Portfolio note

All data in this project is synthetic and intended to simulate realistic business workflows without using proprietary company data.
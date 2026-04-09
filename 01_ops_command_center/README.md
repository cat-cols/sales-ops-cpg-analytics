# Project 1 — Wyld Ops Command Center

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
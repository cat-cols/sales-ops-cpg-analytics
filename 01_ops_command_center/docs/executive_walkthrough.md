# Executive Walkthrough — Althea Ops Command Center

## 1. Business Problem

Leadership needs one trusted view across Sales, Operations, People, and Finance-style controls.

In practice, those domains arrive from separate systems with different grains, naming conventions, refresh cadences, and data quality problems. The challenge is not just reporting. It is turning messy source extracts into a decision-ready model that executives can trust.

This project simulates that problem and builds the data foundation for a cross-functional command center.

---

## 2. What This Project Does

Project 1:

- simulates messy multi-source business extracts
- loads and standardizes them in PostgreSQL
- aligns them to shared business keys
- builds reporting-ready facts, dimensions, and KPI marts
- validates outputs with QA and reconciliation controls
- prepares a governed foundation for Power BI

This is designed to show more than dashboarding. It is meant to show trusted analytics engineering and BI readiness.

---

## 3. Source Intake Scenario

Simulated source inputs include:

- distributor sales extracts
- POS transaction extracts
- ERP inventory snapshots
- WMS shipment extracts
- timeclock punch exports
- payroll labor summaries
- finance actuals summaries
- GL-style detail extracts
- store and assortment reference data

These sources intentionally include realistic problems such as:

- duplicate rows
- missing keys
- date format drift
- identifier inconsistencies
- channel naming drift
- negative inventory exceptions
- payroll and finance label variation

---

## 4. Data Architecture

The project follows a layered model:

**Raw → STG → INT → MART → QA → Power BI**

### Raw
Preserves landed source structure for traceability.

### STG
Standardizes types, names, dates, and source irregularities.

### INT
Conforms keys, selects truth, and aligns business logic across domains.

### MART
Exposes stable facts, dimensions, KPI marts, and reconciliation objects for reporting.

### QA
Hard-fails on broken contracts, grain issues, and reconciliation problems before report refresh.

---

## 5. Core Reporting Foundation

### Canonical facts
- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_labor_daily`
- `mart.fact_actuals_monthly`

### Supporting facts
- `mart.fact_sales_distributor_daily`
- `mart.fact_sales_pos_daily`
- `mart.fact_shipments_daily`
- `mart.fact_labor_daily_employee`

### Dimensions
- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`
- `mart.dim_employee`

### KPI / trust objects
- `mart.kpi_gross_margin_daily`
- `mart.kpi_sales_per_labor_hour_daily`
- `mart.kpi_instock_rate_daily`
- `mart.kpi_days_of_supply`
- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_missing_dim_joins`

---

## 6. QA and Reconciliation

A major goal of the project is to prove that modeled outputs are trustworthy.

The current project now includes:

- INT-to-MART validation
- mart grain and null-key checks
- mart dimension contract checks
- monthly finance reconciliation
- missing-dimension join monitoring
- freshness and control monitoring
- passing end-to-end SQL QA flow

Finance reconciliation uses explicit tolerance logic:

- base metrics use strict tolerances
- gross margin uses a separate tolerance because it is a derived metric

This turns trust into a visible reporting feature rather than an assumption.

---

## 7. Planned Power BI Experience

The report is designed as a command-center experience with these pages:

1. **Executive Overview**
   Sales, margin, labor productivity, inventory health, trust status

2. **Sales & Margin**
   trend, mix, discounts, gross margin movement

3. **Ops & Inventory**
   in-stock rate, days of supply, shipment and coverage risk

4. **People & Productivity**
   labor hours, labor cost, sales per labor hour

5. **Reconciliation & Data Health**
   variances, warnings, control status, freshness

6. **Detail Drillthrough**
   investigative support by store, SKU, date, or metric

The semantic model is intentionally designed to stay thin, with most business logic already governed in SQL.

---

## 8. Why This Matters

This project proves that I can:

- integrate messy cross-functional data
- model it into stable reporting facts and dimensions
- build KPI-ready mart outputs
- surface reconciliation and trust controls
- prepare a semantic-model-ready foundation for BI
- translate backend modeling into executive-facing reporting design

The SQL foundation is now complete enough that the next major deliverable is the presentation layer: Power BI pages, governed measures, screenshots, and walkthrough assets.
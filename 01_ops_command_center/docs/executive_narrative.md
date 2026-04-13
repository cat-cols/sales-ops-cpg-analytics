# Executive Walkthrough — Wyld Ops Command Center (Project 1)

## Table of Contents
- [Executive Walkthrough — Wyld Ops Command Center (Project 1)](#executive-walkthrough--wyld-ops-command-center-project-1)
  - [Table of Contents](#table-of-contents)
  - [1. Business Problem](#1-business-problem)
  - [2. Objective](#2-objective)
  - [3. Current Project State](#3-current-project-state)
  - [4. Simulated Source Systems](#4-simulated-source-systems)
    - [Sales sources](#sales-sources)
    - [Operations / inventory sources](#operations--inventory-sources)
    - [People / labor sources](#people--labor-sources)
    - [Finance sources](#finance-sources)
    - [Reference sources](#reference-sources)
  - [5. Data Flow: Raw → Stg → Int → Mart → QA](#5-data-flow-raw--stg--int--mart--qa)
    - [Raw](#raw)
    - [Stg](#stg)
    - [Int](#int)
    - [Mart](#mart)
    - [QA](#qa)
  - [6. Core Reporting Objects](#6-core-reporting-objects)
    - [Canonical facts](#canonical-facts)
    - [Supporting sales facts](#supporting-sales-facts)
    - [Dimensions](#dimensions)
    - [KPI marts](#kpi-marts)
    - [Reconciliation / control objects](#reconciliation--control-objects)
  - [7. QA, Reconciliation, and Trust Controls](#7-qa-reconciliation-and-trust-controls)
    - [Current trust state](#current-trust-state)
    - [Finance reconciliation logic](#finance-reconciliation-logic)
  - [8. Semantic Model Foundation](#8-semantic-model-foundation)
    - [Core reporting facts](#core-reporting-facts)
    - [Shared dimensions](#shared-dimensions)
    - [Supporting objects](#supporting-objects)
  - [9. Power BI Page Architecture](#9-power-bi-page-architecture)
    - [Planned page structure](#planned-page-structure)
  - [10. Decisions Supported](#10-decisions-supported)
  - [11. KPI Snapshot](#11-kpi-snapshot)
    - [Sales](#sales)
    - [Profitability](#profitability)
    - [Labor / productivity](#labor--productivity)
    - [Inventory health](#inventory-health)
    - [Trust / controls](#trust--controls)
  - [12. Sales \& Margin Story](#12-sales--margin-story)
  - [13. Ops \& Inventory Story](#13-ops--inventory-story)
  - [14. People \& Productivity Story](#14-people--productivity-story)
  - [15. Reconciliation \& Data Health Story](#15-reconciliation--data-health-story)
  - [16. Why This Project Matters](#16-why-this-project-matters)
  - [17. Recommended Next Steps](#17-recommended-next-steps)
  - [18. Caveats](#18-caveats)

---

## 1. Business Problem

Operational reporting breaks down when sales, inventory, labor, and finance data originate from different systems, different grains, different naming conventions, and different refresh cadences.

In practice, the hardest part of reporting is not building visuals. It is making the numbers trustworthy before they ever reach a dashboard.

This project simulates that real-world mess and transforms it into a reporting-ready command center designed to support executive and operational decision-making. The goal is to create a cross-functional analytics layer that is:

- trustworthy,
- business-readable,
- reconciliation-aware,
- and ready for a governed BI semantic model.

The intended use case is a business-facing operations command center where leaders can evaluate sales performance, gross margin, staffing productivity, inventory health, and trust signals from one reporting surface.

## 2. Objective

Build an executive-facing Ops Command Center that integrates **sales, inventory, labor, and finance-style actuals** into one reporting foundation.

This project is meant to prove more than table creation. It is designed to show that the repo can:

- absorb messy cross-functional extracts,
- standardize them into typed staging models,
- align them to shared business keys,
- produce stable mart-layer facts and dimensions,
- surface QA and reconciliation outputs,
- and support a Power BI reporting layer from trusted objects.

## 3. Current Project State

The SQL and data-modeling foundation for Project 1 is now materially complete.

Current progress includes:

- synthetic multi-source drop generation
- Postgres raw loads
- staging, intermediate, and mart layers
- KPI marts and reconciliation views
- hard-fail QA suite
- passing end-to-end SQL build and QA flow
- semantic-model documentation
- report-page architecture planning
- narrative tooltip planning

This means the project has moved beyond “can the model run?” and into “how should the reporting layer present a trustworthy business story?”

## 4. Simulated Source Systems

Project 1 simulates multi-source operational reporting by generating source-style drops across business domains.

### Sales sources
- distributor sales summary extracts
- POS transaction extracts

### Operations / inventory sources
- ERP inventory snapshot extracts
- WMS shipment extracts
- SKU distribution status extracts

### People / labor sources
- timeclock punch exports
- payroll-style labor summaries

### Finance sources
- monthly actuals summary extracts
- GL-style detail exports

### Reference sources
- account status extracts
- dispensary master extracts

These sources are intentionally uneven. They arrive on different cadences, use different field conventions, and do not start in a clean analytics-ready form. That is deliberate. The project is meant to demonstrate cleanup, conformance, and trust-building, not just final reporting.

## 5. Data Flow: Raw → Stg → Int → Mart → QA

The project follows a layered modeling pattern designed to separate ingestion, cleanup, conformance, reporting, and validation.

### Raw
The raw layer represents landed source extracts as received from simulated upstream systems.

Purpose:
- preserve source realism
- retain landed grain
- support traceability back to incoming files

### Stg
The staging layer standardizes source columns into typed, predictable structures.

Purpose:
- clean column names
- cast fields to usable types
- normalize dates, identifiers, and flags
- isolate source-specific cleanup logic

### Int
The intermediate layer performs cross-source alignment and truth selection.

Purpose:
- align shared business keys
- deduplicate and standardize across sources
- bridge source-specific quirks into reusable modeled logic
- create conformed business surfaces for marts

### Mart
The mart layer is the BI consumption layer.

Purpose:
- expose stable facts and dimensions
- define KPI-ready grains
- support semantic-model relationships
- surface control and reconciliation outputs alongside business facts

### QA
The QA layer validates whether the modeled layer is safe to trust.

Purpose:
- hard-fail on broken model contracts
- validate grain and uniqueness
- validate dimension contracts
- validate reconciliation outputs
- separate warnings from blocking issues

This layered pattern is the backbone of the project. It allows raw system mess to be transformed into something Power BI can consume without dragging source-system chaos into every visual.

## 6. Core Reporting Objects

The current project exposes a reporting-ready set of facts, dimensions, KPI marts, and trust surfaces.

### Canonical facts
- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_shipments_daily`
- `mart.fact_labor_daily`
- `mart.fact_labor_daily_employee`
- `mart.fact_actuals_monthly`

### Supporting sales facts
- `mart.fact_sales_distributor_daily`
- `mart.fact_sales_pos_daily`

### Dimensions
- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`
- `mart.dim_employee`

### KPI marts
- `mart.kpi_gross_margin_daily`
- `mart.kpi_sales_per_labor_hour_daily`
- `mart.kpi_instock_rate_daily`
- `mart.kpi_days_of_supply`
- `mart.roi_monthly`
- `mart.breakeven_monthly`

### Reconciliation / control objects
- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_rowcounts_daily`
- `mart.controls_missing_dim_joins`
- `mart.controls_dim_join_coverage`
- `mart.mart_reconciliation_controls`

These objects allow the project to support both business-facing reporting and trust-facing diagnostics.

## 7. QA, Reconciliation, and Trust Controls

A major goal of the project is to show that reporting outputs are not simply produced, but evaluated.

Key control patterns now in place include:

- INT-to-MART reconciliation checks
- mart grain and null-key checks
- dimension contract validation
- monthly sales-to-finance reconciliation
- missing dimension join monitoring
- rowcount and freshness monitoring
- end-to-end QA orchestration

Important trust objects include:

- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_missing_dim_joins`
- `mart.controls_rowcounts_daily`
- `mart.mart_reconciliation_controls`

### Current trust state
The current SQL foundation now passes the QA suite end to end.

That means:

- INT checks pass
- MART checks pass
- MART dimension checks pass
- reconciliation checks pass

### Finance reconciliation logic
Finance reconciliation uses explicit tolerance rules.

- Base finance metrics such as gross sales, net sales, and COGS use strict tolerances.
- Gross margin uses a separate tolerance because it is a derived metric and more sensitive to compounded variance.

This is a stronger and more realistic control design than forcing every metric to behave identically.

## 8. Semantic Model Foundation

The Power BI semantic layer is designed to sit on top of mart-layer objects rather than raw or staging tables.

The intended model emphasizes:

- facts at stable grains
- shared dimensions across sales, inventory, and labor
- reusable governed measures
- explicit naming conventions
- reconciliation and trust objects as first-class reporting surfaces

### Core reporting facts
- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_labor_daily`
- `mart.fact_actuals_monthly`

### Shared dimensions
- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`

### Supporting objects
- KPI marts for curated business logic
- reconciliation views for trust diagnostics
- control views for reporting health

The intended semantic model is intentionally thin. Business logic is pushed into SQL where practical so that the BI layer stays explainable and easier to govern.

## 9. Power BI Page Architecture

The first version of the report is intended to follow a command-center layout rather than a loose collection of visuals.

### Planned page structure

1. **Executive Overview**
   High-level KPI summary across sales, margin, labor productivity, inventory health, and trust signals.

2. **Sales & Margin**
   Trend, mix, discount impact, and gross margin movement.

3. **Ops & Inventory**
   In-stock performance, days of supply, shipment flow, and inventory coverage risk.

4. **People & Productivity**
   Labor hours, labor cost, and sales-per-labor-hour analysis.

5. **Reconciliation & Data Health**
   Pass/fail counts, major variances, freshness, and known simulation-related warnings.

6. **Detail Drillthrough**
   Investigative detail by date, store, SKU, metric, or control issue.

The point of this structure is to let users move from headline KPIs to operational explanation without needing to understand the underlying SQL.

## 10. Decisions Supported

The reporting layer is meant to support practical operating questions rather than abstract metric tourism.

Examples include:

- Which stores, SKUs, or channels are driving the strongest net sales?
- Where are discounts reducing realized revenue?
- Where is inventory at risk of being too thin to support demand?
- Which stores appear under- or over-staffed relative to sales volume?
- Are labor hours rising faster than revenue?
- Are inventory and shipment patterns consistent with what sales performance suggests?
- Are the reported metrics trustworthy enough to use for decision-making today?

The value of the project is not just that it models data. The value is that it creates a reporting layer that can inform action.

## 11. KPI Snapshot

Primary KPI families for the first report release:

### Sales
- Gross Sales
- Net Sales
- Units Sold
- Orders
- Customers
- Average Order Value
- Units per Order

### Profitability
- COGS
- Gross Margin $
- Gross Margin %

### Labor / productivity
- Labor Hours
- Labor Cost
- Net Sales per Labor Hour
- Gross Sales per Labor Hour

### Inventory health
- In-Stock Rate
- Days of Supply
- On Hand Units
- Units Shipped

### Trust / controls
- Sales vs GL Delta $
- Sales vs GL Delta %
- Reconciliation Status
- Missing Dimension Join Count
- Data Freshness Status

Detailed KPI definitions are documented separately in the semantic-model measure catalog.

## 12. Sales & Margin Story

The sales layer is anchored on:

- `mart.fact_sales_daily`
- `mart.fact_sales_distributor_daily`
- `mart.fact_sales_pos_daily`
- `mart.kpi_gross_margin_daily`

What this section should answer:

- Where are net sales strongest by day, store, SKU, channel, and source?
- How much of gross sales is being lost to discounts?
- What does gross margin look like over time?
- Where do source-specific sales views disagree?
- Which stores or products are driving change versus prior period?

This section is intended to combine top-line performance with explainability. It should not just show revenue movement. It should help explain why revenue or margin changed.

## 13. Ops & Inventory Story

The inventory / operations layer is anchored on:

- `mart.fact_inventory_snapshot_daily`
- `mart.fact_shipments_daily`
- `mart.fact_sku_distribution_status_daily`
- `mart.kpi_instock_rate_daily`
- `mart.kpi_days_of_supply`

What this section should answer:

- Are stores in stock on the right SKUs?
- Where is inventory thin or at risk?
- Which stores or SKUs show distribution coverage gaps?
- Are shipments and inventory snapshots telling a coherent story?

This section is intended to connect availability, movement, and coverage. It should help distinguish normal variation from operational risk.

## 14. People & Productivity Story

The people / labor layer is anchored on:

- `mart.fact_labor_daily`
- `mart.fact_labor_daily_employee`
- `mart.dim_employee`
- `mart.kpi_sales_per_labor_hour_daily`

What this section should answer:

- How many labor hours are being used per day and store?
- What is the labor-cost / productivity trend over time?
- Which stores appear over- or under-staffed relative to sales?
- Are staffing patterns helping explain KPI movement?

This section is meant to show whether labor deployment appears efficient relative to operational output, not just whether labor cost is increasing or decreasing.

## 15. Reconciliation & Data Health Story

This page is what separates a dashboard from a disciplined analytics project.

Control / trust objects to surface include:

- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_missing_dim_joins`
- `mart.controls_rowcounts_daily`
- `mart.controls_freshness`
- `mart.mart_reconciliation_controls`

What to show:

- latest pass / warning / fail signals
- largest variances
- freshness state by object
- missing join counts
- known acceptable warnings for simulated static data

This page should make it easy to understand whether a data issue is:

- a modeling problem,
- a source discrepancy,
- a simulation limitation,
- or a documented non-blocking warning.

## 16. Why This Project Matters

This project is not just a dashboard concept.

It demonstrates:

- cross-functional data integration
- layered SQL modeling
- stable reporting facts and conformed dimensions
- KPI governance
- reconciliation discipline
- hard-fail QA
- semantic-model planning
- executive-facing report architecture

In other words, it shows the work that has to happen before BI can be trusted.

## 17. Recommended Next Steps

Near-term next steps for Project 1:

1. finalize the executive-facing documentation set
2. build the first Power BI Executive Overview page or wireframe
3. create report screenshots / walkthrough assets
4. package the project as a flagship portfolio case study
5. continue the semantic-model measure layer and validation notes

The next phase of the project is presentation, not rescue.

## 18. Caveats

- The project uses simulated source drops rather than live production systems, so freshness warnings may appear even when the pipeline is functioning correctly.
- The semantic-model and reporting documentation are currently further along than the full Power BI implementation because development is being done on Mac.
- This is a portfolio case study, so the design is intended to demonstrate realistic analytics engineering, QA, and BI patterns rather than replicate any company’s internal schema exactly.
# Project 4 — GHG Scope Reporting + Audit-Ready Documentation (Sustainability analytics)

## Overview

This project simulates an audit-ready greenhouse gas reporting workflow for Scope 1, Scope 2, and selected Scope 3 emissions activity.

The goal is to demonstrate how messy sustainability source extracts can be standardized, joined to versioned emission factors, calculated into emissions outputs, and validated through repeatable QA controls.

This project is not intended to show climate-science expertise. It is designed to show audit-friendly analytics discipline:

- source-to-metric traceability
- versioned emission factor logic
- controlled source intake
- reportable versus non-reportable row handling
- QA checks and exception reporting
- documentation suitable for assurance review

All data and emission factors are synthetic and used for portfolio demonstration only.

---

## Business Problem

> Sustainability and finance teams need emissions reporting that is not only calculated, but also traceable and reviewable.

A dashboard alone is not enough. For emissions reporting, stakeholders need to know:

- which source files support each metric
- which emission factor version was used
- which rows were excluded from reportable totals
- whether all valid rows joined to approved factors
- whether source defects were surfaced for remediation
- whether the process can be rerun consistently

This project builds a simplified but realistic reporting pipeline to support those needs.

---

## Stakeholders & Decisions Supported

| Stakeholder | Questions Supported |
|---|---|
| Sustainability / ESG | What are emissions by scope, facility, month, and activity type? |
| Finance / FP&A | Which emissions categories may affect reporting, cost, or operational planning? |
| Operations | Which facilities or source systems are driving emissions and data quality issues? |
| Procurement / Logistics | Which packaging and freight activities contribute to Scope 3 emissions? |
| Audit / Assurance Reviewers | Can reported emissions be traced to source files, factors, and QA controls? |

---

## Reporting Scope

| Scope | Included Activity | Source Extract |
|---|---|---|
| Scope 1 | Natural gas, diesel, gasoline | `fuel_usage_facility.csv` |
| Scope 2 | Purchased electricity | `electricity_bills_monthly.xlsx` |
| Scope 3 | Freight shipping | `shipping_miles_logistics.csv` |
| Scope 3 | Packaging materials | `packaging_materials_procurement.csv` |

Reference files:

| Reference File | Purpose |
|---|---|
| `facility_master.csv` | Facility, region, country, and grid-region mapping |
| `product_line_master.csv` | Product-line and product-family mapping |
| `emission_factors_reference.csv` | Versioned emission factor table |

---

## Source Extracts

The project generates synthetic source extracts under:

```text
data/source_extracts/
```

Current generated sources include:

| Source                                |  Rows | Purpose                              |
| ------------------------------------- | ----: | ------------------------------------ |
| `facility_master.csv`                 |     5 | Facility reference                   |
| `product_line_master.csv`             |     4 | Product-line reference               |
| `electricity_bills_monthly.xlsx`      |    78 | Scope 2 electricity activity         |
| `fuel_usage_facility.csv`             |   109 | Scope 1 fuel activity                |
| `shipping_miles_logistics.csv`        | 1,719 | Scope 3 freight activity             |
| `packaging_materials_procurement.csv` |   562 | Scope 3 packaging activity           |
| `emission_factors_reference.csv`      |    16 | Versioned synthetic factor reference |

The source simulator intentionally creates realistic source issues, including:

* duplicate source records
* missing facility IDs
* missing product line IDs
* mixed date formats
* negative activity values
* unit drift
* casing and whitespace inconsistencies
* natural gas records reported in gallons instead of therms

The point is not to hide messy source data. The point is to show how the model controls it.

---

## Pipeline Architecture

The project uses a layered SQL workflow:

```text
source extracts
→ raw
→ stg
→ int
→ mart
→ qa
```

| Layer  | Purpose                                                          |
| ------ | ---------------------------------------------------------------- |
| `raw`  | Preserve source extracts with minimal assumptions                |
| `stg`  | Standardize source fields, types, units, dates, and QA flags     |
| `int`  | Conform all activity sources into one emissions activity ledger  |
| `mart` | Publish Power BI-ready facts, KPIs, and control views            |
| `qa`   | Validate row counts, uniqueness, reportability, and factor joins |

---

## Key SQL Objects

### Raw Tables

| Table                                     | Purpose                                 |
| ----------------------------------------- | --------------------------------------- |
| `raw.ghg_facility_master`                 | Facility reference landing table        |
| `raw.ghg_product_line_master`             | Product-line reference landing table    |
| `raw.ghg_emission_factors_reference`      | Emission factor reference landing table |
| `raw.ghg_electricity_bills_monthly`       | Electricity bill activity               |
| `raw.ghg_fuel_usage_facility`             | Fuel usage activity                     |
| `raw.ghg_shipping_miles_logistics`        | Freight activity                        |
| `raw.ghg_packaging_materials_procurement` | Packaging activity                      |

### Staging Views

| View                              | Purpose                                 |
| --------------------------------- | --------------------------------------- |
| `stg.stg_ghg_facility_master`     | Standardized facility reference         |
| `stg.stg_ghg_product_line_master` | Standardized product-line reference     |
| `stg.stg_ghg_emission_factors`    | Typed and standardized factor table     |
| `stg.stg_ghg_electricity_bills`   | Standardized Scope 2 activity           |
| `stg.stg_ghg_fuel_usage`          | Standardized Scope 1 activity           |
| `stg.stg_ghg_shipping_miles`      | Standardized Scope 3 freight activity   |
| `stg.stg_ghg_packaging_materials` | Standardized Scope 3 packaging activity |

### Conformance Views

| View                                | Purpose                                                           |
| ----------------------------------- | ----------------------------------------------------------------- |
| `int.int_ghg_activity_all`          | Unifies all activity sources into one common activity structure   |
| `int.int_ghg_activity_with_factors` | Joins activity to facilities, product lines, and emission factors |

### Mart Views

| View                                   | Purpose                                        |
| -------------------------------------- | ---------------------------------------------- |
| `mart.fact_emissions`                  | Main emissions fact table for reporting        |
| `mart.kpi_emissions_intensity_monthly` | Monthly emissions and intensity KPI output     |
| `mart.controls_missing_factor_joins`   | Surfaces missing factor joins                  |
| `mart.controls_negative_activity`      | Surfaces negative activity values              |
| `mart.controls_missing_dim_joins`      | Surfaces failed facility or product-line joins |
| `mart.controls_unknown_activity_type`  | Surfaces invalid activity/unit combinations    |

---

## Emissions Calculation

The model calculates emissions as:

```text
activity_amount × factor_value_kg_co2e_per_unit = kg_co2e
kg_co2e ÷ 1000 = metric_tons_co2e
```

Each emissions row preserves the factor metadata used in calculation:

* `factor_id`
* `factor_version`
* `source_authority`
* `factor_value_kg_co2e_per_unit`

This allows emissions outputs to be traced back to the factor version used.

---

## Factor Matching Logic

Activity rows are matched to emission factors using:

| Join Key         | Purpose                                                  |
| ---------------- | -------------------------------------------------------- |
| `factor_type`    | Maps the activity to the correct factor category         |
| `activity_unit`  | Ensures the activity unit matches the factor unit        |
| `activity_month` | Ensures the factor is effective for the reporting period |
| `region`         | Applies regional electricity factors where applicable    |

Scope 2 electricity uses the facility grid region.

Scope 1 and Scope 3 activity use `US` as the synthetic factor region.

---

## Reportable Row Logic

Rows are retained even when they are not reportable. This preserves the audit trail.

A row is excluded from reportable emissions totals when it has:

* negative activity amount
* missing facility ID
* invalid activity month
* unknown activity type
* missing facility join
* missing emission factor join

The final mart includes:

```text
is_reportable_emissions_row
qa_status_label
```

Examples of QA status labels:

```text
✅ Reportable
⚠️ Negative activity
⚠️ Unknown activity type
❌ Missing factor join
```

---

## QA Results

The QA suite currently validates:

| QA Check                                            | Result   |
| --------------------------------------------------- | -------- |
| Raw rowcounts                                       | Pass     |
| `mart.fact_emissions` activity ID uniqueness        | Pass     |
| Reportable emissions rows have calculated emissions | Pass     |
| Clean rows have factor joins                        | Pass     |
| QA summary by source system                         | Produced |

Current QA summary:

| Source System       | Scope   | Total Rows | Reportable Rows | Reportable Metric Tons CO2e |
| ------------------- | ------- | ---------: | --------------: | --------------------------: |
| electricity_bills   | Scope 2 |         78 |              74 |                      641.24 |
| fuel_usage          | Scope 1 |        109 |              99 |                      689.35 |
| packaging_materials | Scope 3 |        562 |             534 |                      667.19 |
| shipping_miles      | Scope 3 |      1,719 |           1,633 |                      109.21 |

Known exceptions are retained and surfaced through mart control views.

---

## Example Control Finding

The synthetic fuel usage extract includes natural gas records reported in `gallon`.

The approved natural gas factor expects:

```text
factor_type = natural_gas_therm
activity_unit = therm
```

The model does not force these rows into a calculation. Instead, it classifies them as unknown activity type exceptions and surfaces them in:

```text
mart.controls_unknown_activity_type
```

This protects reportable emissions totals while preserving the source defect for review.

---

## How to Run

From the repository root:

### 1. Generate synthetic source extracts

```bash
python 04_ghg_scope_reporting/scripts/generate_project4_ghg_inputs.py
```

### 2. Build schemas, raw tables, staging views, conformance views, and mart views

```bash
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 04_ghg_scope_reporting/sql/00_run_project4_pipeline.sql
```

### 3. Load source files into raw tables

```bash
python 04_ghg_scope_reporting/scripts/load_project4_raw_tables.py
```

### 4. Run QA checks

```bash
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 04_ghg_scope_reporting/sql/qa/_run_qa.sql
```

Important: the SQL pipeline recreates raw landing tables, so load the source files after running the SQL build.

---

## Documentation

| Document                              | Purpose                                                           |
| ------------------------------------- | ----------------------------------------------------------------- |
| `docs/Methodology.md`                 | Reporting methodology, calculation logic, and reportability rules |
| `docs/source_lineage.md`              | Source-to-metric lineage from extracts to mart outputs            |
| `docs/assumptions_log.md`             | Key modeling assumptions, limitations, and future improvements    |
| `docs/assurance_request_checklist.md` | Evidence checklist for assurance-style review                     |
| `docs/control_catalog.md`             | QA/control definitions, risks addressed, and remediation guidance |
| `docs/ghg_source_drop_manifest.csv`   | Generated source file manifest with row counts and load metadata  |

---

## Project Structure

```text
04_ghg_scope_reporting/
├── data/
│   └── source_extracts/
├── docs/
│   ├── Methodology.md
│   ├── source_lineage.md
│   ├── assumptions_log.md
│   ├── assurance_request_checklist.md
│   ├── control_catalog.md
│   └── ghg_source_drop_manifest.csv
├── scripts/
│   ├── generate_project4_ghg_inputs.py
│   └── load_project4_raw_tables.py
├── sql/
│   ├── 00_create_schemas.sql
│   ├── 00_run_project4_pipeline.sql
│   ├── raw/
│   ├── stg/
│   ├── int/
│   ├── mart/
│   └── qa/
├── powerbi/
└── README.md
```

---

## What This Project Demonstrates

This project demonstrates:

* SQL-first analytics engineering workflow
* messy source intake and standardization
* Scope 1 / Scope 2 / Scope 3 emissions modeling
* versioned emission factor matching
* source-to-metric traceability
* reportable versus non-reportable row logic
* mart-layer controls and QA checks
* documentation suitable for audit or assurance review
* Power BI-ready semantic model design

---

## What I Would Add Next

With internal production data, the next enhancements would be:

* replace synthetic emission factors with approved official factor sources
* add source file checksums
* persist QA results by run ID
* add exception owner and resolution workflow
* add source owner certification
* build a Power BI Sustainability Scorecard
* add DAX measures for emissions by scope, facility, product line, and YoY change
* add Power BI data quality indicators using mart control views
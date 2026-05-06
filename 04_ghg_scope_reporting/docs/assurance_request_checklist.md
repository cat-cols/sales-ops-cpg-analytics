# External Assurance Request Checklist — GHG Scope Reporting

## Purpose

This checklist outlines the evidence, documentation, and control outputs that would support an external review or assurance request for the Project 4 GHG Scope Reporting workflow.

The purpose is to demonstrate that reported emissions outputs are traceable, repeatable, and supported by documented methodology, source lineage, factor versioning, and QA controls.

---

## 1. Reporting Methodology

| Evidence Item | Location | Status | Notes |
|---|---|---|---|
| GHG reporting methodology | `docs/Methodology.md` | Available | Explains scope boundary, source flow, calculation logic, factor matching, and reportability rules |
| Reporting assumptions log | `docs/assumptions_log.md` | Available | Documents synthetic factor assumptions, reporting boundary, region logic, and known limitations |
| Source lineage documentation | `docs/source_lineage.md` | Available | Maps each source extract to raw, staging, conformance, mart, and QA outputs |

---

## 2. Source Evidence

| Source Extract | Location | Purpose | Expected Evidence |
|---|---|---|---|
| `electricity_bills_monthly.xlsx` | `data/source_extracts/electricity_bills/current/` | Scope 2 purchased electricity | Utility bill extract, meter number, invoice number, usage amount |
| `fuel_usage_facility.csv` | `data/source_extracts/fuel_usage/current/` | Scope 1 fuel usage | Fuel type, invoice number, activity amount, unit |
| `shipping_miles_logistics.csv` | `data/source_extracts/shipping_miles/current/` | Scope 3 freight | Shipment ID, shipping mode, distance, weight, ton-miles |
| `packaging_materials_procurement.csv` | `data/source_extracts/packaging_materials/current/` | Scope 3 packaging | Supplier, invoice number, material type, material weight |
| `facility_master.csv` | `data/source_extracts/facility_master/current/` | Facility reference | Facility ID, region, active status |
| `product_line_master.csv` | `data/source_extracts/product_line_master/current/` | Product reference | Product line ID, product family |
| `emission_factors_reference.csv` | `data/source_extracts/emission_factors/current/` | Factor reference | Factor ID, scope, factor type, unit, region, effective dates, version |

---

## 3. Source Load Evidence

| Evidence Item | Location | Purpose |
|---|---|---|
| Source drop manifest | `docs/ghg_source_drop_manifest.csv` | Confirms generated source files, row counts, load ID, and current/incoming file paths |
| Raw table rowcount QA | `sql/qa/01_check_raw_rowcounts.sql` | Confirms all expected raw tables contain loaded rows |
| Raw loader script | `scripts/load_project4_raw_tables.py` | Documents repeatable raw loading process |
| Source generator script | `scripts/generate_project4_ghg_inputs.py` | Documents synthetic source generation logic |

---

## 4. Transformation Evidence

| Layer | Evidence | Location |
|---|---|---|
| Raw layer | Raw table DDL | `sql/raw/01_create_raw_tables.sql` |
| Staging layer | Source standardization views | `sql/stg/` |
| Conformance layer | Unified activity and factor join views | `sql/int/` |
| Mart layer | Reporting facts, KPIs, and controls | `sql/mart/` |
| Pipeline runner | End-to-end SQL build script | `sql/00_run_project4_pipeline.sql` |

---

## 5. Emission Factor Evidence

| Evidence Item | Location | Review Purpose |
|---|---|---|
| Versioned factor table | `emission_factors_reference.csv` | Confirms factor IDs, versions, units, regions, and effective dates |
| Staged factor view | `stg.stg_ghg_emission_factors` | Confirms factor values are typed and standardized |
| Factor join logic | `int.int_ghg_activity_with_factors` | Confirms activity rows match factors by factor type, unit, region, and effective date |
| Missing factor control | `mart.controls_missing_factor_joins` | Identifies activity rows without matched factors |

---

## 6. QA and Control Evidence

| Control / QA Check | Location | Purpose |
|---|---|---|
| Raw rowcount check | `sql/qa/01_check_raw_rowcounts.sql` | Confirms source data loaded |
| Activity ID uniqueness | `sql/qa/02_check_fact_emissions_unique_activity_id.sql` | Confirms stable fact grain |
| Reportable emissions not null | `sql/qa/03_check_reportable_emissions_not_null.sql` | Confirms reportable rows have calculated emissions |
| Clean rows have factor joins | `sql/qa/04_check_clean_rows_have_factor.sql` | Confirms valid rows match emission factors |
| QA summary | `sql/qa/05_qa_summary.sql` | Summarizes source-level exceptions and reportable emissions |
| Missing factor joins | `mart.controls_missing_factor_joins` | Surfaces unmatched factor records |
| Negative activity | `mart.controls_negative_activity` | Surfaces invalid negative usage/activity |
| Missing dimension joins | `mart.controls_missing_dim_joins` | Surfaces missing facility/product joins |
| Unknown activity type | `mart.controls_unknown_activity_type` | Surfaces invalid activity type/unit combinations |

---

## 7. Reportable Emissions Evidence

| Evidence Item | Location | Purpose |
|---|---|---|
| Emissions fact view | `mart.fact_emissions` | Main reportable emissions dataset |
| Reportable row flag | `mart.fact_emissions.is_reportable_emissions_row` | Separates valid reportable rows from exceptions |
| QA status label | `mart.fact_emissions.qa_status_label` | Human-readable QA status for review and BI |
| Emissions KPI view | `mart.kpi_emissions_intensity_monthly` | Monthly emissions and intensity reporting output |

---

## 8. Known Exceptions for Review

Known synthetic exceptions intentionally included for QA demonstration:

| Exception Type | Example | Review Treatment |
|---|---|---|
| Natural gas unit mismatch | Natural gas reported in `gallon` instead of `therm` | Excluded from reportable emissions and surfaced in `mart.controls_unknown_activity_type` |
| Negative activity | Negative usage or ton-mile values | Excluded from reportable emissions and surfaced in `mart.controls_negative_activity` |
| Missing facility ID | Activity row missing facility key | Excluded or flagged through missing facility controls |
| Missing product line ID | Scope 3 activity missing product line | Flagged through missing dimension controls |
| Duplicate source rows | Duplicate generated source records | Preserved for visibility; future deduplication logic recommended |

---

## 9. Reviewer Questions This Pack Should Answer

| Reviewer Question | Where to Answer |
|---|---|
| What source data supports the reported emissions? | `docs/source_lineage.md`, source extracts, source manifest |
| What calculation method was used? | `docs/Methodology.md` |
| Which emission factors were used? | `emission_factors_reference.csv`, `stg.stg_ghg_emission_factors` |
| Were factors versioned? | `emission_factors_reference.csv`, `factor_version` in `mart.fact_emissions` |
| Which rows were excluded from reporting? | `mart.fact_emissions`, control views |
| Did all clean rows match factors? | `sql/qa/04_check_clean_rows_have_factor.sql` |
| Are fact rows unique? | `sql/qa/02_check_fact_emissions_unique_activity_id.sql` |
| Can the process be rerun? | `sql/00_run_project4_pipeline.sql`, `scripts/load_project4_raw_tables.py` |

---

## 10. Future Assurance Enhancements

Recommended future improvements:

- add source file checksums
- persist QA results by run ID
- add exception owner and resolution status
- add source owner certification workflow
- archive exact source files used for each reporting period
- replace synthetic factors with official cited factor sources
- add Power BI export package for reviewer-facing summaries
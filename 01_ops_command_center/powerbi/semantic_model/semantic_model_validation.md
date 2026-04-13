# Semantic Model Validation — Project 1 (Ops Command Center)

## Purpose

This document defines how the reporting layer should be validated against SQL source-of-truth logic for Project 1.

The goal is to ensure that semantic-model outputs are not trusted just because relationships or visuals look correct. Report-layer values should be checked against validated SQL references, reconciliation outputs, and mart-layer control views before report signoff.

## Validation Principles

The semantic model should be validated against:

- stable mart-layer totals
- SQL reference queries
- reconciliation outputs
- dimension contract checks
- grain uniqueness expectations
- missing dimension join controls
- freshness and trust diagnostics

The BI layer is intended to stay thin, with most business logic already validated in SQL.

## Validation Assets

### 1. Semantic-model reference queries

Primary file:

- `01_ops_command_center/sql/validation/semantic_model_test_queries.sql`

This query pack is intended to provide SQL reference outputs for report-layer comparison.

Current coverage includes:

- monthly sales reference totals
- monthly gross margin reference totals
- monthly labor reference totals
- monthly sales-per-labor-hour reference totals
- daily in-stock-rate reference outputs
- days-of-supply summary outputs
- monthly sales-to-finance reference outputs
- distributor-vs-POS comparison outputs
- fact grain uniqueness sanity checks
- missing dimension join reference outputs

### 2. Reconciliation and control surfaces

Supporting files / views include:

- `01_ops_command_center/sql/validation/reconciliation_checks.sql`
- `mart.recon_sales_to_gl_monthly`
- `mart.recon_sales_distributor_vs_pos`
- `mart.controls_missing_dim_joins`
- `mart.controls_rowcounts_daily`
- `mart.controls_freshness`
- `mart.mart_reconciliation_controls`

These provide machine-readable trust checks that should inform the reporting layer.

### 3. QA suite

Primary file:

- `01_ops_command_center/sql/_qa/_run_qa.sql`

This is the highest-level validation entry point for the modeled layer and should be treated as the project’s core publish-readiness gate.

## Current Validation Status

### Validated and working

The current Project 1 SQL foundation now validates successfully end to end.

Confirmed areas include:

- INT layer checks pass
- mart-layer checks pass
- mart dimension contract checks pass
- reconciliation checks pass
- monthly finance reconciliation passes within defined tolerances
- semantic-model reference query coverage exists for core reporting areas
- dimension and grain assumptions are now explicit and testable

### Current warnings

These are documented warnings, not current blockers:

- freshness controls may surface warnings because the project uses simulated static source drops rather than continuously refreshed production data
- KPI rows with sales but missing labor may still appear as operational/modeling notices depending on source coverage and grain alignment
- diagnostics objects should be surfaced on a trust page rather than blended into executive KPI visuals

## Validation Categories

## 1. Base metric validation

Base report metrics should tie back to validated SQL references.

Examples:

- Gross Sales
- Net Sales
- COGS
- Labor Hours
- On Hand Inventory

Expected behavior:
- Power BI totals should match the corresponding SQL reference totals for the same filter context and grain assumptions

## 2. Derived KPI validation

Derived measures should be validated against either:

- curated KPI mart views, or
- base SQL reference logic

Examples:

- Gross Margin $
- Gross Margin %
- Net Sales per Labor Hour
- In-Stock Rate
- Days of Supply
- ROI
- Breakeven Net Sales

Expected behavior:
- KPI outputs should match SQL-backed reference logic within the intended model grain and tolerance rules

## 3. Reconciliation / trust validation

Trust-oriented visuals should be validated directly against reconciliation and control views.

Examples:

- Sales vs GL Delta $
- Sales vs GL Delta %
- Reconciliation Status
- Distributor vs POS Delta %
- Missing Dimension Join Count
- Data Freshness Status

Expected behavior:
- diagnostic pages should reflect the current SQL control state exactly, not reinterpret it loosely in visuals

## 4. Relationship and grain validation

The semantic model should be checked to confirm that:

- dimensions filter facts as intended
- no unexpected row multiplication occurs
- daily facts and monthly finance objects are not mixed without explicit logic
- KPI marts are used at their intended grain
- source-specific facts are not substituted for canonical facts without reason

## Recommended Validation Workflow

Before report publication or screenshot export:

1. Run the SQL pipeline and QA suite
2. Confirm `_run_qa.sql` passes
3. Run semantic-model reference queries
4. Compare Power BI KPI cards and trend visuals to SQL totals
5. Check reconciliation / trust visuals against mart control views
6. Validate filters and slices on at least a few representative test cases
7. Confirm known warnings are documented where relevant

## Suggested Validation Test Cases

The reporting layer should eventually track test cases such as:

| Test Case | Expected Result | Validation Source | Status |
|---|---|---|---|
| Monthly Net Sales total matches SQL | Power BI total ties to SQL reference | `semantic_model_test_queries.sql` | Planned |
| Monthly Gross Margin total matches SQL | Power BI total ties to KPI mart / SQL reference | `mart.kpi_gross_margin_daily` | Planned |
| Revenue per Labor Hour matches SQL | KPI card equals SQL reference output | `mart.kpi_sales_per_labor_hour_daily` | Planned |
| In-Stock Rate matches SQL | Daily KPI equals SQL reference output | `mart.kpi_instock_rate_daily` | Planned |
| Sales vs GL Delta matches SQL | Diagnostic card/table matches recon view | `mart.recon_sales_to_gl_monthly` | Planned |
| Missing dimension join count matches SQL | Trust page shows current control result | `mart.controls_missing_dim_joins` | Planned |

## Validation Philosophy

The reporting layer should be explainable.

That means:

- every major KPI should have a reference source
- every trust indicator should tie to a control object
- every important relationship should reflect a known fact grain
- every executive-facing output should be defensible back to SQL

A semantic model is not complete when the visuals render. It is complete when the outputs are governed, testable, and explainable.

## Next Validation Improvements

The next best upgrades are:

- add explicit SQL-to-Power-BI test case results to this document
- document page-level validation by report page
- add measure-level validation notes once the DAX catalog is finalized
- surface trust checks on a dedicated Reconciliation / Data Health page
- create a lightweight publish-readiness checklist tied to the QA suite
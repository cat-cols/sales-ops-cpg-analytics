# Naming Conventions — Project 1

## Purpose

This document defines naming rules for the Project 1 semantic model so that tables, fields, and measures are consistent, readable, and easy to govern.

The goal is simple:

- SQL objects stay structured and engineering-friendly
- Power BI display names stay business-friendly
- measures remain easy to scan, reuse, and validate

---

## Guiding Principles

- Prefer clear names over clever names
- Keep SQL object names stable and explicit
- Keep report-facing names readable for business users
- Use consistent prefixes for table purpose
- Separate base measures from derived KPIs and diagnostics
- Avoid abbreviations unless they are widely understood

---

## SQL Object Naming

SQL model objects should remain in `snake_case`.

### Table / view prefixes

Use prefixes to signal object role:

- `dim_` = conformed dimension
- `fact_` = fact table or reporting fact view
- `kpi_` = curated KPI output view
- `recon_` = reconciliation output
- `controls_` = control / monitoring output
- `int_` = intermediate / conformance layer
- `stg_` = staging / source-standardization layer

### Examples

- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`
- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.kpi_sales_per_labor_hour_daily`
- `mart.recon_sales_to_gl_monthly`
- `mart.controls_missing_dim_joins`

---

## Column Naming

### SQL columns

Use `snake_case` for SQL column names.

### Rules

- use full words where practical
- avoid unnecessary abbreviations
- keep date columns explicit
- name keys consistently across facts and dimensions
- prefer semantic clarity over source-system naming

### Good examples

- `sale_date`
- `work_date`
- `snapshot_date`
- `period_month`
- `store_code`
- `employee_id`
- `gross_sales`
- `net_sales`
- `discount_amount`
- `labor_hours`
- `days_of_supply`

### Avoid

- `dt`
- `val`
- `amt1`
- `sales$`
- `str_cd`
- `inv_d`

---

## Key Naming Rules

Use the same key names across objects whenever the business entity is the same.

### Preferred shared keys

- `date_key`
- `date`
- `store_code`
- `sku`
- `employee_id`
- `channel`
- `sales_source`
- `kpi_category`

### Principle

If two objects join on the same business concept, the key name should match unless there is a strong reason it cannot.

---

## Date Naming Rules

Date fields should communicate grain clearly.

### Daily grain
- `sale_date`
- `work_date`
- `snapshot_date`
- `ship_date`
- `kpi_date`

### Monthly grain
- `period_month`

### Dimension date fields
- `date_key`
- `date`

### Rule

Do not use ambiguous date names like:

- `date_value`
- `event_date` when the event type is known
- `month` when the field is actually a month-start date

---

## Power BI Table Display Names

In Power BI, SQL object names can be shown with more readable display names if helpful.

### Recommended display approach

Keep the physical object name in SQL, but use business-friendly labels in the semantic model.

### Examples

| SQL Object | Suggested Display Name |
|---|---|
| `mart.fact_sales_daily` | Sales |
| `mart.fact_inventory_snapshot_daily` | Inventory Snapshot |
| `mart.fact_labor_daily` | Labor |
| `mart.fact_actuals_monthly` | Finance Actuals |
| `mart.dim_date` | Date |
| `mart.dim_store` | Store |
| `mart.dim_sku` | SKU |
| `mart.recon_sales_to_gl_monthly` | Sales to GL Reconciliation |
| `mart.controls_missing_dim_joins` | Missing Dimension Joins |

### Rule

Business users should not have to interpret technical prefixes like `fact_` or `recon_` in the report UI unless that context is intentionally useful.

---

## Power BI Column Display Names

Column display names in Power BI should use `Title Case`.

### Examples

| SQL Column | Suggested Display Name |
|---|---|
| `gross_sales` | Gross Sales |
| `net_sales` | Net Sales |
| `discount_amount` | Discount Amount |
| `labor_hours` | Labor Hours |
| `days_of_supply` | Days of Supply |
| `store_code` | Store Code |
| `period_month` | Period Month |

### Rule

Preserve business wording used in KPI definitions and report labels.

---

## Measure Naming

Measures should use `Title Case` and should not include table prefixes in the measure name.

### Good examples

- `Gross Sales`
- `Net Sales`
- `COGS`
- `Gross Margin $`
- `Gross Margin %`
- `Labor Hours`
- `Net Sales per Labor Hour`
- `In-Stock Rate`
- `Days of Supply`
- `Sales vs GL Delta $`
- `Sales vs GL Delta %`
- `Reconciliation Status`

### Avoid

- `m_GrossSales`
- `fact_sales_daily_net_sales`
- `Net_Sales`
- `gross sales`
- `GM%` unless the audience already expects it

---

## Measure Categories

Measures should follow a consistent naming structure by type.

### Base measures
Simple additive measures from facts.

Examples:
- `Gross Sales`
- `Net Sales`
- `COGS`
- `Units Sold`
- `Orders`
- `Labor Hours`

### Derived KPI measures
Calculated business metrics.

Examples:
- `Gross Margin $`
- `Gross Margin %`
- `Average Order Value`
- `Net Sales per Labor Hour`
- `In-Stock Rate`

### Comparison measures
Period-over-period or benchmark comparisons.

Examples:
- `Net Sales vs Prior Period $`
- `Net Sales vs Prior Period %`
- `Gross Margin bps Change`

### Diagnostic measures
Trust, QA, and reconciliation outputs.

Examples:
- `Sales vs GL Delta $`
- `Sales vs GL Delta %`
- `Distributor vs POS Delta %`
- `Missing Dimension Join Count`
- `Data Freshness Status`

---

## Symbols in Measure Names

Symbols are acceptable in report-facing measure names when they improve readability.

### Allowed
- `%`
- `$`

### Examples
- `Gross Margin %`
- `Gross Margin $`
- `Sales vs GL Delta %`

### Avoid excessive punctuation
Do not overuse:
- parentheses
- slashes
- hyphen chains
- technical suffix clutter

### Avoid examples like
- `Gross Margin % (Calc)`
- `Net Sales / Labor Hours / Daily`
- `Sales_vs_GL_Delta_%`

---

## Acronyms and Abbreviations

Only use abbreviations that are commonly understood by the intended audience.

### Acceptable
- `COGS`
- `GL`
- `KPI`
- `SKU`
- `POS`
- `ROI`

### Use with care
- `AOV`
- `bps`
- `DIO`

If used, define them in the KPI catalog or report glossary.

---

## KPI View Naming

KPI SQL views should indicate both metric purpose and grain.

### Preferred pattern

`kpi_<metric_name>_<grain>`

### Examples

- `kpi_gross_margin_daily`
- `kpi_sales_per_labor_hour_daily`
- `kpi_instock_rate_daily`

### Rule

The name should communicate:
- what the metric is
- what its reporting grain is

---

## Reconciliation and Control Naming

These objects should sound operational and explicit.

### Preferred patterns

- `recon_<object_a>_to_<object_b>_<grain>`
- `controls_<topic>`

### Examples

- `recon_sales_to_gl_monthly`
- `recon_sales_distributor_vs_pos`
- `controls_missing_dim_joins`
- `controls_rowcounts_daily`

### Rule

These names should read like QA artifacts, not business KPIs.

---

## Relationship / Key Consistency Rules

Where possible:

- dimensions should expose the same key name used by facts
- facts should not rename a join key unnecessarily
- Power BI relationship columns should be easy to identify visually

### Example

Preferred:
- `dim_store.store_code`
- `fact_sales_daily.store_code`
- `fact_labor_daily.store_code`

Avoid:
- `dim_store.store_id`
- `fact_sales_daily.location_code`
- `fact_labor_daily.site`
when all three mean the same business key

---

## Null / Unknown Member Naming

If an unknown or fallback member is introduced later in the semantic model, label it consistently.

### Preferred labels

- `Unknown`
- `Unmapped`
- `Missing`
- `Not Available`

Do not create multiple versions of the same fallback concept unless they are intentionally distinct.

Avoid mixes like:
- `Unknown`
- `UNK`
- `N/A`
- `No Value`
for the same business situation

---

## Page Naming

Report pages should use short, executive-friendly names.

### Recommended examples

- `Executive Overview`
- `Sales & Margin`
- `Ops & Inventory`
- `People & Productivity`
- `Reconciliation & Data Health`
- `Detail Drillthrough`

---

## File Naming for Semantic Model Docs

Use `snake_case` for documentation file names.

### Examples

- `model_design.md`
- `relationships_map.md`
- `dax_measure_catalog.md`
- `semantic_model_validation.md`
- `naming_conventions.md`

---

## Current Project 1 Recommendation

For Project 1 specifically:

- keep SQL object names exactly as modeled
- use business-friendly display names in Power BI
- treat `mart.fact_sales_daily` as the canonical sales fact
- keep reconciliation and control objects clearly labeled as diagnostics
- keep measures short, readable, and governed

---

## Quick Reference

### SQL
- `snake_case`
- explicit prefixes
- explicit grain in KPI/recon views

### Power BI tables
- business-friendly display names

### Power BI columns
- `Title Case`

### Measures
- `Title Case`
- no table prefixes
- use `%` and `$` where helpful
- separate base, KPI, comparison, and diagnostic measures

### Keys
- same business key = same name whenever possible
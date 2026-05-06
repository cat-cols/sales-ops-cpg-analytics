# Control Catalog — GHG Scope Reporting

## Purpose

This control catalog documents the QA checks, mart control views, and exception-monitoring logic used in Project 4: GHG Scope Reporting + Audit-Ready Documentation.

The purpose is to make the reporting controls understandable to business stakeholders, data reviewers, and assurance reviewers.

Each control is designed to protect the reliability of the emissions reporting output by checking source completeness, model grain, factor matching, dimensional joins, and reportable-row logic.

---

## Control Summary

| Control ID | Control Name | Type | Severity | SQL Location | Status |
|---|---|---|---|---|---|
| GHG-QA-001 | Raw rowcount check | QA check | High | `sql/qa/01_check_raw_rowcounts.sql` | Active |
| GHG-QA-002 | Fact emissions activity ID uniqueness | QA check | Critical | `sql/qa/02_check_fact_emissions_unique_activity_id.sql` | Active |
| GHG-QA-003 | Reportable emissions not null | QA check | Critical | `sql/qa/03_check_reportable_emissions_not_null.sql` | Active |
| GHG-QA-004 | Clean rows have factor joins | QA check | Critical | `sql/qa/04_check_clean_rows_have_factor.sql` | Active |
| GHG-QA-005 | QA summary | QA summary | Medium | `sql/qa/05_qa_summary.sql` | Active |
| GHG-CTRL-001 | Missing factor joins | Mart control view | High | `mart.controls_missing_factor_joins` | Active |
| GHG-CTRL-002 | Negative activity amounts | Mart control view | High | `mart.controls_negative_activity` | Active |
| GHG-CTRL-003 | Missing dimension joins | Mart control view | High | `mart.controls_missing_dim_joins` | Active |
| GHG-CTRL-004 | Unknown activity type | Mart control view | High | `mart.controls_unknown_activity_type` | Active |

---

## Control Severity Definitions

| Severity | Meaning | Expected Action |
|---|---|---|
| Critical | The reporting output may be structurally invalid or materially unreliable | Stop/reporting hold until resolved |
| High | Source defects or mapping issues may affect reportability | Review and remediate before publication |
| Medium | Useful for monitoring completeness or exception trends | Review during reporting cycle |
| Low | Informational or documentation-only control | Track as needed |

---

## GHG-QA-001 — Raw Rowcount Check

**Type:** QA check  
**Severity:** High  
**SQL location:** `sql/qa/01_check_raw_rowcounts.sql`

### Purpose

Confirms that all expected raw source tables contain loaded rows.

### Risk Addressed

A missing or empty source file could cause downstream emissions totals to be incomplete.

### Tables Checked

- `raw.ghg_facility_master`
- `raw.ghg_product_line_master`
- `raw.ghg_emission_factors_reference`
- `raw.ghg_electricity_bills_monthly`
- `raw.ghg_fuel_usage_facility`
- `raw.ghg_shipping_miles_logistics`
- `raw.ghg_packaging_materials_procurement`

### Pass Condition

All expected raw tables return non-zero row counts.

### Remediation

If a source table is empty:

1. Confirm the source extract exists in `data/source_extracts/.../current/`.
2. Rerun `scripts/load_project4_raw_tables.py`.
3. Confirm the raw table DDL matches the source file columns.
4. Review the source drop manifest for expected row counts.

---

## GHG-QA-002 — Fact Emissions Activity ID Uniqueness

**Type:** QA check  
**Severity:** Critical  
**SQL location:** `sql/qa/02_check_fact_emissions_unique_activity_id.sql`

### Purpose

Confirms that `mart.fact_emissions` has a stable unique activity grain.

### Risk Addressed

Duplicate `activity_id` values could indicate broken grain logic, duplicate conformance output, or unreliable row-level traceability.

### Pass Condition

No `activity_id` appears more than once in `mart.fact_emissions`.

### Remediation

If duplicate activity IDs exist:

1. Identify the duplicated `activity_id` values.
2. Trace them back to `source_system` and `source_record_id`.
3. Review `int.int_ghg_activity_all` ID generation logic.
4. Add additional source fields to the hash key if needed.

---

## GHG-QA-003 — Reportable Emissions Not Null

**Type:** QA check  
**Severity:** Critical  
**SQL location:** `sql/qa/03_check_reportable_emissions_not_null.sql`

### Purpose

Confirms that every row marked as reportable has a calculated emissions value.

### Risk Addressed

Rows may be included in reportable emissions totals even though `metric_tons_co2e` is null.

### Pass Condition

No row in `mart.fact_emissions` has:

```text
is_reportable_emissions_row = true
and metric_tons_co2e is null
```

### Remediation

If this check fails:

1. Review the affected rows in `mart.fact_emissions`.
2. Check factor join fields: `factor_type`, `activity_unit`, `region`, and `activity_month`.
3. Confirm `factor_value_kg_co2e_per_unit` is not null.
4. Confirm the reportable-row logic is excluding rows with missing factor joins.

---

## GHG-QA-004 — Clean Rows Have Factor Joins

**Type:** QA check
**Severity:** Critical
**SQL location:** `sql/qa/04_check_clean_rows_have_factor.sql`

### Purpose

Confirms that otherwise-valid activity rows successfully join to an emission factor.

### Risk Addressed

Valid activity rows may be excluded from emissions reporting due to missing factor mappings.

### Pass Condition

No otherwise-clean row has `has_missing_factor_join = true`.

A row is treated as not clean if it has:

* negative activity amount
* missing facility ID
* invalid activity month
* unknown activity type
* missing facility join

### Remediation

If this check fails:

1. Group failures by `source_system`, `factor_type`, `activity_unit`, `grid_region`, and `activity_month`.
2. Compare failed rows to `stg.stg_ghg_emission_factors`.
3. Determine whether the issue is factor type, unit, region, or effective date.
4. Fix staging classification logic or add the missing factor reference.

### Example

A natural gas row reported in `gallon` should not map to `natural_gas_therm`.

Instead, it should be classified as an unknown activity type and surfaced in:

```text
mart.controls_unknown_activity_type
```

---

## GHG-QA-005 — QA Summary

**Type:** QA summary
**Severity:** Medium
**SQL location:** `sql/qa/05_qa_summary.sql`

### Purpose

Provides a source-level summary of reportable rows, exception rows, and reportable emissions.

### Risk Addressed

Stakeholders need a quick way to understand data quality health before reviewing emissions outputs.

### Output Includes

* total rows
* reportable rows
* negative activity rows
* missing facility ID rows
* missing product line ID rows
* invalid activity month rows
* unknown activity type rows
* missing facility join rows
* missing product line join rows
* missing factor join rows
* reportable metric tons CO2e

### Remediation

Use the summary to identify which source system needs review before publication.

---

## GHG-CTRL-001 — Missing Factor Joins

**Type:** Mart control view
**Severity:** High
**SQL object:** `mart.controls_missing_factor_joins`

### Purpose

Surfaces rows where activity could not be matched to an emission factor.

### Risk Addressed

Missing factor joins can cause emissions to be underreported.

### Typical Causes

* missing factor type
* unit mismatch
* region mismatch
* effective date gap
* incomplete factor reference table

### Remediation

1. Review `factor_type`, `activity_unit`, `activity_month`, and region.
2. Confirm whether the row is a source defect or a missing factor table entry.
3. Update staging logic or factor references as appropriate.

---

## GHG-CTRL-002 — Negative Activity Amounts

**Type:** Mart control view
**Severity:** High
**SQL object:** `mart.controls_negative_activity`

### Purpose

Surfaces activity records with negative usage or negative activity amounts.

### Risk Addressed

Negative activity values may incorrectly reduce reported emissions.

### Typical Causes

* source system correction rows
* returns/credits represented as negative activity
* data entry issue
* generated synthetic defect

### Remediation

1. Confirm whether the negative value represents a real correction.
2. If it is a correction, document the treatment.
3. If it is invalid, request source correction.
4. Exclude from reportable emissions until resolved.

---

## GHG-CTRL-003 — Missing Dimension Joins

**Type:** Mart control view
**Severity:** High
**SQL object:** `mart.controls_missing_dim_joins`

### Purpose

Surfaces emissions activity records that fail facility or product-line joins.

### Risk Addressed

Rows with missing dimension joins may be difficult to report by facility, product line, geography, or scope.

### Typical Causes

* missing facility ID
* facility not present in master data
* missing product line ID
* product line not present in master data
* inconsistent source keys

### Remediation

1. Confirm whether the source key is missing or invalid.
2. Update source data or master data as appropriate.
3. Refresh the pipeline.
4. Confirm the control view no longer shows the issue.

---

## GHG-CTRL-004 — Unknown Activity Type

**Type:** Mart control view
**Severity:** High
**SQL object:** `mart.controls_unknown_activity_type`

### Purpose

Surfaces activity rows where the model could not classify the activity into an approved factor type.

### Risk Addressed

Unknown activity types cannot be safely calculated into emissions.

### Example

Natural gas reported in `gallon` is invalid for the current factor table because the approved natural gas factor is:

```text
natural_gas_therm
```

and expects:

```text
activity_unit = therm
```

### Remediation

1. Review the source activity category and unit.
2. Confirm the approved unit for that factor type.
3. Correct the source extract or update mapping rules if the source value is valid.
4. Rerun the pipeline and QA checks.

---

## Reporting Use

These controls support:

* SQL QA validation
* Power BI data quality cards
* exception review tables
* audit and assurance documentation
* source owner remediation workflows

Recommended Power BI control cards:

| Card                        | Source                                |
| --------------------------- | ------------------------------------- |
| Reportable Rows             | `mart.fact_emissions`                 |
| Unknown Activity Type Rows  | `mart.controls_unknown_activity_type` |
| Missing Factor Join Rows    | `mart.controls_missing_factor_joins`  |
| Negative Activity Rows      | `mart.controls_negative_activity`     |
| Missing Dimension Join Rows | `mart.controls_missing_dim_joins`     |

---

## Future Enhancements

Potential future control improvements:

* persist QA results by run ID
* add source file checksum checks
* add source owner assignment
* add exception resolution status
* add severity scoring by metric impact
* add automated release certification status
* add freshness controls by source extract
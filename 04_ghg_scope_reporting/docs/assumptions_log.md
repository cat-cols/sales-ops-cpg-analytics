# Assumptions Log — GHG Scope Reporting

## Purpose

This assumptions log documents key modeling, reporting, and data quality assumptions used in Project 4: GHG Scope Reporting + Audit-Ready Documentation.

The purpose is to make reporting decisions transparent and reviewable. In an audit or assurance process, assumptions should be documented so reviewers can understand how reported emissions were calculated, what limitations exist, and where future improvements are needed.

---

## Assumptions Summary

| Assumption ID | Category | Assumption | Impact | Status |
|---|---|---|---|---|
| A001 | Data scope | Only synthetic Scope 1, Scope 2, and selected Scope 3 activity sources are included | Reported emissions are not a complete organizational footprint | Active |
| A002 | Factor source | Emission factors are synthetic and used for demonstration only | Results are not official emissions values | Active |
| A003 | Scope 2 region | Electricity factors are matched using facility grid region | Scope 2 emissions vary by facility region | Active |
| A004 | Scope 1/3 region | Scope 1 and Scope 3 factors use `US` as the factor region | Regional variation is simplified | Active |
| A005 | Natural gas unit | Natural gas must be reported in `therm` to map to `natural_gas_therm` | Natural gas rows reported as gallons are excluded from reportable emissions | Active |
| A006 | Reportability | Rows with source defects are retained but excluded from reportable emissions totals | Audit trail is preserved while protecting final metrics | Active |
| A007 | Product line relevance | Product line is required for shipping and packaging activity, but not for electricity or fuel | Missing product line affects Scope 3 detail reporting | Active |
| A008 | Activity grain | Each source record is treated as one emissions activity event | `activity_id` defines the fact grain | Active |
| A009 | Cost denominator | Emissions intensity currently supports cost-based intensity | Future models may add production volume, units sold, or revenue denominators | Active |
| A010 | Duplicates | Duplicate source rows are preserved in raw/staging and controlled through QA visibility | Source duplication risk is visible but not automatically deduped yet | Active |

---

## Detailed Assumptions

## A001 — Reporting boundary is limited to synthetic source extracts

**Category:** Data scope  
**Status:** Active

This project includes selected synthetic activity sources for Scope 1, Scope 2, and Scope 3 emissions.

Included sources:

- fuel usage
- electricity bills
- shipping miles
- packaging materials
- facility master
- product line master
- emission factor reference

This project does not include every possible emissions category, such as employee commuting, business travel, purchased goods beyond packaging, waste, refrigeration leaks, or capital goods.

**Impact:**  
Reported emissions should be interpreted as a simulated reporting model, not a complete corporate GHG inventory.

**Future improvement:**  
Add additional Scope 3 categories and document organizational/reporting boundary decisions.

---

## A002 — Emission factors are synthetic

**Category:** Factor source  
**Status:** Active

The emission factor table uses synthetic factor values for portfolio demonstration.

The model is designed to demonstrate:

- factor versioning
- effective date logic
- factor matching
- calculation transparency
- QA controls

**Impact:**  
Calculated emissions are not official reporting values.

**Future improvement:**  
Replace synthetic factors with approved factors from official or company-approved sources.

---

## A003 — Scope 2 electricity uses facility grid region

**Category:** Factor matching  
**Status:** Active

Scope 2 electricity emissions are matched to emission factors using the facility `grid_region`.

Example:

```text
facility_id → facility master → grid_region → electricity factor region
````

**Impact:**
Electricity emissions vary by facility geography.

**Future improvement:**
Use more detailed utility-specific or market-based factors if available.

---

## A004 — Scope 1 and Scope 3 factors use US region

**Category:** Factor matching
**Status:** Active

Scope 1 fuel factors and Scope 3 shipping/packaging factors use `US` as the factor region in the synthetic factor table.

**Impact:**
The model simplifies regional variation for Scope 1 and Scope 3.

**Future improvement:**
Add region-specific Scope 1 and Scope 3 factors where appropriate.

---

## A005 — Natural gas must be reported in therms

**Category:** Unit standardization
**Status:** Active

Natural gas activity maps to the `natural_gas_therm` factor only when the activity unit is `therm`.

Rows where natural gas is reported as `gallon` are flagged as unknown activity type exceptions.

**Impact:**
Natural gas rows with invalid units are excluded from reportable emissions totals until corrected.

**Current control:**
These rows are surfaced in:

```text
mart.controls_unknown_activity_type
```

**Future improvement:**
Add source-owner remediation workflow for invalid fuel unit corrections.

---

## A006 — Defective rows are retained but excluded from reportable totals

**Category:** Reportability
**Status:** Active

Rows with source defects are not deleted. They remain visible in the model with QA flags.

A row is excluded from reportable emissions when it has:

* negative activity amount
* missing facility ID
* invalid activity month
* unknown activity type
* missing facility join
* missing factor join

**Impact:**
This preserves audit traceability while protecting final reportable totals.

**Future improvement:**
Create a persistent exception table with resolution status and owner assignment.

---

## A007 — Product line is required only where applicable

**Category:** Dimensional modeling
**Status:** Active

Product line is meaningful for shipping and packaging activity.

Product line is not required for electricity or fuel activity because those are facility-level sources.

**Impact:**
Missing product line is treated as an issue for Scope 3 shipping and packaging detail, but not for Scope 1 fuel or Scope 2 electricity.

**Future improvement:**
Add allocation logic if facility-level energy needs to be allocated to product lines.

---

## A008 — Activity ID defines the emissions fact grain

**Category:** Fact grain
**Status:** Active

The model generates `activity_id` to identify each emissions activity row.

The intended grain is:

```text
one row per source activity record / source event
```

**Impact:**
The model can validate uniqueness and support row-level traceability.

**Current QA check:**

```text
mart.fact_emissions activity_id is unique
```

**Future improvement:**
Persist run IDs and source file IDs to support historical reload comparisons.

---

## A009 — Emissions intensity currently uses cost-based denominator

**Category:** KPI design
**Status:** Active

The current monthly emissions intensity view supports emissions per dollar of cost where cost fields are available.

**Impact:**
This is useful for demonstration but may not be the best business denominator.

**Future improvement:**
Add production units, net sales, cases shipped, or revenue to support more meaningful intensity metrics.

---

## A010 — Duplicate source rows are not automatically deduped yet

**Category:** Data quality
**Status:** Active

The source simulator intentionally creates duplicate rows.

The current model preserves rows and surfaces QA/control issues, but does not yet implement source-specific deduplication rules.

**Impact:**
Some totals may include duplicate source records unless future deduplication logic is added.

**Future improvement:**
Add source-specific deduplication views in the `int` layer using invoice number, shipment ID, facility, month, and latest load timestamp.

---

## Review Notes

This assumptions log should be updated when:

* new source extracts are added
* emission factor sources change
* factor matching logic changes
* reportability rules change
* new QA controls are added
* Power BI KPI definitions are finalized
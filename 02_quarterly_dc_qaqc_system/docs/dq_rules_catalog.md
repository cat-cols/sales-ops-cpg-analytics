# DQ Rules Catalog

## Purpose

This document translates the governed data quality rule catalog into business-readable documentation for the Quarterly Data Collection + QA/QC System. It summarizes what each rule checks, why it matters, who owns remediation, and whether the rule is currently implemented in the active validation workflow.

This catalog is intended to support:
- business stakeholders reviewing QA coverage,
- analysts and reviewers interpreting failures,
- future maintenance of the governed rule set,
- Power BI and reporting consumers who need rule context.

---

## Rule Categories

### Completeness
Checks whether required keys, required fields, or required reporting periods are present.

### Uniqueness
Checks whether source submissions remain unique at the intended business grain.

### Validity
Checks whether dates, quantities, values, or business conditions fall within acceptable logic boundaries.

### Timeliness
Checks whether required submissions arrive on time and with the approved template/version.

### Reconciliation
Checks whether related measures from different systems tie out within an approved tolerance.

---

## Implemented Rules

The following rules are currently implemented in the active SQL validation workflow.

| Rule Name | Category | Target Table | Severity | Owner Team | Failure Meaning | Status |
|---|---|---|---|---|---|---|
| Required key present - retail sales | Completeness | `stg.stg_retail_account_sales_quarterly` | Critical | Sales Operations | One or more required business keys is null | Implemented |
| Required key present - wholesale sales | Completeness | `stg.stg_wholesale_account_sales_quarterly` | Critical | Commercial / Wholesale | One or more required business keys is null | Implemented |
| Required key present - inventory | Completeness | `stg.stg_inventory_quarterly` | Critical | Supply Chain / Inventory Control | One or more required business keys is null | Implemented |
| No duplicate business grain - retail sales | Uniqueness | `stg.stg_retail_account_sales_quarterly` | Critical | Sales Operations | More than one row exists for the same retail business grain | Implemented |
| No duplicate business grain - wholesale sales | Uniqueness | `stg.stg_wholesale_account_sales_quarterly` | Critical | Commercial / Wholesale | More than one row exists for the same wholesale business grain | Implemented |
| No duplicate business grain - inventory | Uniqueness | `stg.stg_inventory_quarterly` | Critical | Supply Chain / Inventory Control | More than one row exists for the same inventory business grain | Implemented |
| Quarter dates within expected range | Validity | `stg.stg_retail_account_sales_quarterly` | High | Sales Operations | `week_end_date` falls outside the expected quarter window | Implemented |
| Quarter dates within expected range - trade adjustments | Validity | `stg.stg_trade_adjustments` | High | Trade Marketing / Finance | `adjustment_date` falls outside the expected quarter window | Implemented |
| No negative quantity - inventory | Validity | `stg.stg_inventory_quarterly` | High | Supply Chain / Inventory Control | `on_hand_units` is negative | Implemented |
| Negative trade adjustments require valid reason code | Validity | `stg.stg_trade_adjustments` | High | Trade Marketing / Finance | Negative trade adjustment is missing a required reason code | Implemented |
| Sales vs Finance reconciliation within tolerance | Reconciliation | cross-source comparison | Critical | Finance | Operational sales totals and finance net revenue do not reconcile within tolerance | Implemented |

---

## Cataloged but Not Yet Fully Executed

The following rules exist in the governed catalog but are not yet fully executed in the current first-pass validation workflow.

| Rule Name | Category | Target Table | Severity | Owner Team | Intended Meaning | Status |
|---|---|---|---|---|---|---|
| Weekly continuity by source - retail sales | Completeness | `stg.stg_retail_account_sales_quarterly` | Medium | Sales Operations | Expected reporting weeks should all be present within the quarter | Cataloged |
| Approved template version submitted | Timeliness | `ops.intake_submission_log` | Critical | Finance | Submitted file must match the approved template version | Cataloged |
| Submission timeliness against due date | Timeliness | `ops.intake_submission_log` | Critical | Finance | Submission must arrive by the expected due date | Cataloged |
| Margin percent within tolerance | Validity | `stg.stg_wholesale_account_sales_quarterly` | Medium | Commercial / Wholesale | Wholesale net-to-gross behavior should remain within acceptable tolerance | Cataloged |

---

## Severity Definitions

### Critical
Failure materially affects reporting trust, certification readiness, or business-grain integrity. Critical failures should generally block certification until resolved, waived, or formally documented.

### High
Failure indicates a serious business logic or period issue that meaningfully reduces trust in the affected source. High-severity issues require review and remediation before final signoff.

### Medium
Failure indicates a quality concern that may not immediately block certification but still warrants investigation, tracking, or business review.

### Low
Failure indicates a lower-impact quality concern or warning-level condition. Low-severity rules are available for future expansion but are not a major focus of the current first-pass implementation.

---

## Ownership Model

Rule ownership and remediation follow the business process that produced the source data:

- **Sales Operations** owns retail sales completeness and retail period-quality issues.
- **Commercial / Wholesale** owns wholesale sales completeness and uniqueness issues.
- **Supply Chain / Inventory Control** owns inventory completeness, uniqueness, and invalid quantity issues.
- **Trade Marketing / Finance** owns trade-adjustment validity issues.
- **Finance** owns quarter-level reconciliation approval and timeliness-related intake controls.

---

## How This Catalog Connects to the SQL Workflow

The rule catalog is governed in `dq.dq_rules`. During a validation run:

1. a run is logged in `dq.dq_run_log`,
2. rule-level summary outcomes are written to `dq.dq_results_fact`,
3. record-level failures are written to `dq.dq_exceptions_detail`,
4. reconciliation outcomes are written to `dq.recon_results`.

Reporting views then expose these outputs in business-friendly form:
- `reporting.vw_dq_scorecard`
- `reporting.vw_open_exceptions`
- `reporting.vw_reconciliation_summary`

---

## Notes

- This project uses simulated quarterly submissions for portfolio purposes.
- The active rule set is intentionally first-pass and focused on the highest-value failure patterns.
- Additional rule families can be added over time without changing the overall framework design.
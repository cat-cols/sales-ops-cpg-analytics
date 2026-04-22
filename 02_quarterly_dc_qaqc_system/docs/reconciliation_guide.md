# Reconciliation Guide

## Purpose

This guide explains how reconciliation is performed in the Quarterly Data Collection + QA/QC System, what is being compared, how variance is calculated, how tolerance is applied, and how to interpret reconciliation outcomes.

The goal of reconciliation is to determine whether operational reporting totals align closely enough with finance actuals to support trusted quarterly reporting.

---

## What Reconciliation Means in This Project

In this project, reconciliation is the process of comparing:

- **operational net sales totals** from quarterly sales submissions
- **finance net revenue totals** from quarterly finance actuals

The comparison is performed at the **quarter level** for the current first-pass implementation.

A reconciliation result helps answer:

> Do the operational sales submissions agree with finance closely enough to support reporting certification?

---

## Current Implemented Reconciliation

### Rule Name
**Sales vs Finance reconciliation within tolerance**

### Metric
**net_sales_vs_finance_net_revenue**

### Current Grain
**One row per quarter per reconciliation test**

### Sources Compared

#### Left source: operational sales
Operational sales are calculated as:

- sum of `net_sales` from `stg.stg_retail_account_sales_quarterly`
- plus sum of `net_sales` from `stg.stg_wholesale_account_sales_quarterly`

#### Right source: finance actuals
Finance net revenue is calculated as:

- sum of `actual_amount` from `stg.stg_finance_quarterly_actuals`
- filtered to `reporting_category = 'net_revenue'`

---

## Calculation Logic

### Operational Net Sales

Operational net sales are calculated by appending retail and wholesale sales together and summing `net_sales`.

Conceptually:

```sql
operational_net_sales
=
sum(retail net_sales)
+
sum(wholesale net_sales)
````

Equivalent SQL pattern:

```sql
select
    coalesce(sum(net_sales), 0)::numeric(18,2) as operational_net_sales
from (
    select net_sales
    from stg.stg_retail_account_sales_quarterly

    union all

    select net_sales
    from stg.stg_wholesale_account_sales_quarterly
) s;
```

### Finance Net Revenue

Finance net revenue is calculated by summing finance actuals for rows classified as `net_revenue`.

Conceptually:

```sql
finance_net_revenue
=
sum(actual_amount where reporting_category = 'net_revenue')
```

Equivalent SQL pattern:

```sql
select
    coalesce(sum(actual_amount), 0)::numeric(18,2) as finance_net_revenue
from stg.stg_finance_quarterly_actuals
where reporting_category = 'net_revenue';
```

---

## Variance Logic

### Variance Value

Variance value is calculated as:

```sql
variance_value = left_value - right_value
```

In this project:

```sql
variance_value = operational_net_sales - finance_net_revenue
```

A positive value means operational sales are higher than finance.
A negative value means finance is higher than operational sales.

### Variance Percent

Variance percent is calculated as:

```sql
abs(left_value - right_value) / right_value
```

In this project, the finance total is used as the denominator.

This means the reconciliation evaluates how far the operational result is from finance relative to the finance number.

### Tolerance

The current tolerance is pulled from the governed rule catalog:

```text
threshold_pct = 0.0100
```

This means the reconciliation passes only if the variance percent is **less than or equal to 1.00%**.

---

## Pass / Fail Logic

A reconciliation result is evaluated as follows:

* **Pass** if `variance_pct <= tolerance_pct`
* **Fail** if `variance_pct > tolerance_pct`
* **Fail** if the finance denominator is zero and variance percent cannot be safely evaluated

This makes the reconciliation strict enough to support certification review.

---

## Where Results Are Stored

Reconciliation outputs are written to:

### `dq.recon_results`

This table stores:

* run identifier
* quarter
* reconciliation name
* left and right sources
* metric name
* left value
* right value
* variance value
* variance percent
* tolerance percent
* final status

### Reporting View

The latest reconciliation result is exposed through:

### `reporting.vw_reconciliation_summary`

This view is intended for dashboarding and stakeholder review.

---

## Current Example Result

In the current implemented sample run, the reconciliation produces:

* **left_value** = `7740.00`
* **right_value** = `7527.15`
* **variance_value** = `212.85`
* **variance_pct** = `0.0283`
* **tolerance_pct** = `0.0100`
* **status** = `fail`

Interpretation:

* operational sales exceed finance net revenue by `212.85`
* the difference is about `2.83%` of finance net revenue
* because `2.83% > 1.00%`, the reconciliation fails

This is expected in the sample project because the source data was intentionally designed to produce a mismatch for QA/QC demonstration purposes.

---

## How to Run Reconciliation

The current reconciliation logic is executed through:

### `sql/dq/04_run_reconciliation_checks.sql`

Typical run flow:

1. run DQ checks first
2. run reconciliation checks
3. inspect `dq.recon_results`
4. inspect `reporting.vw_reconciliation_summary`
5. determine whether the quarter is ready for certification or requires remediation

---

## How to Interpret a Failed Reconciliation

A failed reconciliation does **not** automatically mean the reporting process is broken. It means the current quarter requires review.

Common causes of reconciliation failure may include:

* missing or duplicate operational sales rows
* out-of-period operational records
* invalid adjustments
* incomplete finance actuals
* timing differences between operational and finance source readiness
* source mapping issues
* intentional sample-data mismatches in a portfolio environment

A failed reconciliation should trigger:

* review of open DQ exceptions
* review of finance classification logic
* review of known quarter-specific adjustments
* documentation of remediation or waiver decisions

---

## Recommended Review Workflow

When reconciliation fails:

1. confirm the latest run completed successfully
2. review `reporting.vw_dq_scorecard`
3. review `reporting.vw_open_exceptions`
4. validate the operational sales totals
5. validate the finance net revenue total
6. confirm the tolerance threshold
7. decide whether to remediate, rerun, or document a known variance

This keeps reconciliation tied to the broader QA/QC process rather than treating it as an isolated check.

---

## Known Limitations

* Current reconciliation is quarter-level only.
* Current reconciliation focuses on one primary metric: operational net sales versus finance net revenue.
* Current logic uses latest-run state rather than full historical run comparison.
* Future versions could add:

  * channel-level reconciliation
  * adjustment bridge reconciliation
  * account-level variance review
  * reconciliations beyond sales and finance

---

## Related Objects

### SQL

* `sql/dq/04_run_reconciliation_checks.sql`

### Core Tables

* `dq.recon_results`
* `dq.dq_run_log`
* `dq.dq_results_fact`
* `dq.dq_exceptions_detail`

### Reporting Views

* `reporting.vw_dq_scorecard`
* `reporting.vw_open_exceptions`
* `reporting.vw_reconciliation_summary`
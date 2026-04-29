# Data Quality Controls

## Objective

This document explains the QA controls used in Project 3 to make the forecast and variance model trustworthy.

The goal is to prove that the model is not only producing outputs, but producing outputs that are complete, unique, reconciled, and safe for reporting.

---

## Pipeline QA philosophy

Project 3 uses a simple but disciplined QA pattern:

```text
source extract → raw table → staging view → integration view → variance bridge → mart views → QA checks
````

The QA checks are designed to answer:

1. Did the expected number of rows load?
2. Did the model preserve the expected grain?
3. Are required keys populated?
4. Do forecast and actual values behave as expected?
5. Does the variance math tie out?
6. Does the bridge tie out?
7. Are partial actuals isolated to the expected reporting period?

---

## Row count checks

The pipeline validates row counts across the main layers:

```text
raw.forecast_actuals_weekly
stg.stg_forecast_actuals_weekly
int.int_forecast_vs_actual_weekly
int.int_price_volume_mix_variance
mart.fact_forecast_vs_actual_weekly
```

Expected row count:

```text
39,000 rows
```

This comes from:

```text
65 weeks × 20 stores × 10 SKUs × 3 channels = 39,000
```

---

## Grain uniqueness check

The expected grain is:

```text
week_start_date + store_code + sku + channel + plan_version
```

The QA process checks for duplicate rows at this grain.

If duplicates are found, the model should fail because forecast and actual metrics would be double-counted.

---

## Required key checks

The following fields must not be null:

```text
week_start_date
store_code
sku
channel
plan_version
```

These fields define the reporting grain and Power BI relationship paths.

---

## Negative value checks

Forecast values should not be negative:

```text
forecast_units
forecast_net_sales
forecast_unit_price
```

Negative forecast values would indicate either a source-generation issue or a type conversion problem.

---

## Partial actuals control

The simulator intentionally creates missing actuals in the latest week to represent reporting lag.

The QA process checks missing actuals by week.

Expected behavior:

```text
latest week may have missing actuals
older weeks should have complete actuals
```

This allows the report to distinguish between finalized periods and current partial periods.

---

## Sales variance tie-out

The model validates that stored sales variance matches recalculated sales variance.

Expected formula:

```sql
sales_variance = actual_net_sales - forecast_net_sales
```

The QA check confirms:

```text
recalculated_sales_variance = stored_sales_variance
```

---

## Bridge tie-out

The bridge validates that all driver effects reconcile to total variance.

Expected formula:

```sql
total_sales_variance = volume_effect + price_effect + mix_or_residual_effect
```

The QA check confirms:

```text
tie_out_difference = 0.00
```

This is one of the most important controls in the project.

---

## Business event checks

The model summarizes variance by business event:

```text
none
summer_retail_promo
holiday_stockout_pressure
```

This check confirms that the simulated business events are present and available for diagnostics.

---

## Forecast accuracy checks

The model calculates forecast accuracy using WAPE and forecast bias.

WAPE is calculated as:

```sql
sum(abs(actual_net_sales - forecast_net_sales)) / sum(actual_net_sales)
```

Forecast bias is calculated as:

```sql
sum(actual_net_sales - forecast_net_sales) / sum(forecast_net_sales)
```

These metrics help determine whether the forecast is directionally useful and whether it tends to overstate or understate sales.

---

## Reporting readiness

A model is considered reporting-ready when:

1. The full pipeline runs without errors.
2. Raw, staging, int, and mart row counts match expected values.
3. Grain uniqueness checks pass.
4. Required keys are populated.
5. Variance calculations tie out.
6. Bridge calculations tie out.
7. Partial actuals are isolated and explainable.


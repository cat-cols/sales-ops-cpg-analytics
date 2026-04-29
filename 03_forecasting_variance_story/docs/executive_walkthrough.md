# Executive Walkthrough

## Project question

How did actual sales perform against forecast, what drove the variance, and what should the business do next?

---

## Executive summary

Project 3 simulates a weekly forecasting and variance-analysis workflow.

The pipeline compares forecasted sales against actual sales, measures forecast accuracy, decomposes sales variance into price and volume effects, and identifies business events such as promotions and stockout pressure.

The model is designed to support a Power BI report with three core pages:

1. Forecast overview
2. Variance bridge
3. Driver diagnostics

---

## What happened?

Actual sales were compared against forecasted sales at the weekly store/SKU/channel grain.

The pipeline calculates:

```text
forecast net sales
actual net sales
sales variance
sales variance %
absolute sales error
forecast performance status
````

Rows with missing current-period actuals are flagged separately as partial actuals.

---

## Why did it happen?

The variance bridge decomposes sales variance into:

```text
volume effect
price effect
mix or residual effect
```

This allows the business to separate demand-driven changes from price-driven changes.

---

## Promo interpretation

The summer retail promo scenario shows a classic promotion tradeoff:

```text
volume effect positive
price effect negative
net effect positive if volume lift offsets discounting
```

Business interpretation:

> The promo increased unit sales, but part of the benefit was offset by lower realized price.

Recommended action:

> Compare promo lift against margin and inventory availability before repeating the promotion.

---

## Stockout interpretation

The holiday stockout pressure scenario shows a negative volume-driven variance.

Business interpretation:

> Forecast demand existed, but actual sales missed because product availability constrained units sold.

Recommended action:

> Review replenishment, production planning, and allocation logic for high-demand holiday SKUs.

---

## Forecast accuracy interpretation

Forecast accuracy is evaluated using WAPE and forecast bias.

WAPE helps measure the size of forecast error relative to actual sales.

Forecast bias shows whether the model tends to over-forecast or under-forecast.

Recommended action:

> Review recurring bias by channel, SKU, and region before refreshing future planning assumptions.

---

## Data quality interpretation

The pipeline includes QA controls for:

```text
row counts
grain uniqueness
required keys
negative values
partial actuals
variance math tie-out
bridge tie-out
```

The bridge tie-out is especially important because it proves the driver effects reconcile back to total sales variance.

---

## Recommended actions

1. Review holiday stockout patterns for high-demand SKUs.
2. Compare promo volume lift against price discounting.
3. Recalibrate forecasts for channels with recurring bias.
4. Separate partial current-period actuals from finalized reporting.
5. Monitor top variance-driving SKUs and stores weekly.
6. Add a simple baseline forecast to test whether the planning forecast adds value.

---

## Portfolio takeaway

This project demonstrates more than forecasting.

It shows the full business analysis workflow:

```text
source data generation
shared reference data
raw/staging/int/mart SQL modeling
forecast accuracy measurement
price/volume variance decomposition
QA controls
executive interpretation
```

The project is designed to show how an analyst can move from data pipeline to business story.
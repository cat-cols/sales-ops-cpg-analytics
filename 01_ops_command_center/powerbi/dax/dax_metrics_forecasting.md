# DAX Metrics - Forecasting & Planning

This is the "grown-up analyst" metric.

---

## Metrics

* **MAPE** (Mean Absolute Percentage Error)
* **Bias** (systematically over/under-forecasting)
* **Forecast Accuracy %** by SKU/state/week

Why it matters:

* Better forecasts improve production planning, inventory, and promo timing
* You become way more valuable when you improve decisions, not just report results

The Althea BA posting language around decision-making models and cross-functional support screams "forecasting and planning hygiene" even if they don't use that exact phrase.

---

## Forecast Accuracy (MAPE, Bias)

Best with a separate `Forecast` table related by date/product/account.

### Assumed `Forecast` table

* `Forecast[Date]`
* `Forecast[ProductID]`
* `Forecast[AccountID]`
* `Forecast[ForecastUnits]`

And actuals come from `Sales`.

### Forecast Units

```DAX
Forecast Units =
SUM(Forecast[ForecastUnits])
```

### Forecast Error

```DAX
Forecast Error Units =
[Volume Units] - [Forecast Units]
```

### Forecast Bias %

Positive = underforecasted actuals (depending on convention)

```DAX
Forecast Bias % =
DIVIDE([Forecast Error Units], [Forecast Units])
```

### MAPE (Mean Absolute Percentage Error)

This should be computed at a lower grain (date/product/account) then averaged.

```DAX
MAPE % =
AVERAGEX(
    SUMMARIZE(
        Sales,
        DimDate[Date],
        Sales[ProductID],
        Sales[AccountID]
    ),
    VAR ActualUnits = CALCULATE([Volume Units])
    VAR FcstUnits =
        CALCULATE([Forecast Units])
    RETURN
        IF(
            ActualUnits > 0,
            ABS(DIVIDE(ActualUnits - FcstUnits, ActualUnits)),
            BLANK()
        )
)
```

> This one is sensitive to table relationships. If Forecast granularity differs, we can tune it.

---

## "Forecast Accuracy" nuance (important)

MAPE gets weird when actuals are tiny or zero. Two alternatives often used:

* **WAPE** (Weighted Absolute Percentage Error)
* **MAE** (Mean Absolute Error)

If you want, I can add a more robust **WAPE** measure (usually better for sales dashboards).

---

## Variance Analysis (Price / Volume / Mix decomposition)

This is one of the most useful "finance + business analyst" outputs.

### Decompose revenue change into:

* **Price effect**
* **Volume effect**
* **Mix effect**
* (Sometimes distribution effect too)

Why it matters:

* Instead of saying "sales are up 8%," you can say:

  * "+3% from volume"
  * "+2% from favorable mix"
  * "+3% from net price"
* This is decision-grade analysis and exactly the kind of thing hiring managers love

### Period-over-period base measures

```DAX
Net Sales Prior Period =
CALCULATE(
    [Net Sales],
    DATEADD(DimDate[Date], -1, MONTH)
)
```

```DAX
Volume Prior Period =
CALCULATE(
    [Volume Units],
    DATEADD(DimDate[Date], -1, MONTH)
)
```

```DAX
Net VWAP Prior Period =
CALCULATE(
    [Net VWAP],
    DATEADD(DimDate[Date], -1, MONTH)
)
```

---

### Revenue Variance $

```DAX
Revenue Variance $ =
[Net Sales] - [Net Sales Prior Period]
```

---

### Price Effect $

Approximation: current volume × change in price

```DAX
Price Effect $ =
([Net VWAP] - [Net VWAP Prior Period]) * [Volume Prior Period]
```

### Volume Effect $

Approximation: prior price × change in volume

```DAX
Volume Effect $ =
([Volume Units] - [Volume Prior Period]) * [Net VWAP Prior Period]
```

### Mix Effect $

Residual method (very common in dashboarding)

```DAX
Mix Effect $ =
[Revenue Variance $] - [Price Effect $] - [Volume Effect $]
```

> This residual approach is practical and audit-friendly enough for many BI uses. Full mix decomposition at SKU level can be built too, but it gets heavier.

---

## The "minimum viable KPI stack" for Forecasting & Planning

If you want the practical shortlist (the stuff I'd build first in Power BI):

1. **Forecast Units**
2. **Forecast Error Units**
3. **Forecast Bias %**
4. **MAPE %**
5. **Revenue Variance $**
6. **Price Effect $**
7. **Volume Effect $**
8. **Mix Effect $**

That set covers forecast accuracy and variance analysis without turning the dashboard into a spaceship cockpit.

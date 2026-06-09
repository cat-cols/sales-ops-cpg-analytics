# DAX Metrics - Inventory & Operations

Necessary if you touch operations (and the Althea postings suggest cross-functional work across sales/ops/people).

---

## Core metrics

* **Days of Inventory on Hand (DOH / DIO)**
* **Inventory Turnover**
* **Stockout Rate**
* **Aging Inventory %**
* **Fill Rate / OTIF** (on-time, in-full), if supply chain data exists

Why it matters:

* Cannabis products are regulated, shelf-life-sensitive, and operationally messy
* Fast sell-through with frequent stockouts = lost sales
* Slow sell-through = cash tied up + risk of write-offs

---

## Inventory Health Metrics

These are best with a separate snapshot table (`InventorySnapshots`) at daily SKU/account grain.

### Assumed `InventorySnapshots` columns

* `InventorySnapshots[Date]`
* `InventorySnapshots[ProductID]`
* `InventorySnapshots[AccountID]`
* `InventorySnapshots[OnHandUnits]`
* `InventorySnapshots[InStockFlag]` (1/0)

### Inventory On Hand (Units)

```DAX
Inventory On Hand Units =
SUM(InventorySnapshots[OnHandUnits])
```

---

## Average Daily Units Sold

```DAX
Avg Daily Units Sold =
DIVIDE(
    [Volume Units],
    DISTINCTCOUNT(DimDate[Date])
)
```

---

## Days of Inventory on Hand (DOH / DIO)

```DAX
Days Inventory On Hand =
DIVIDE([Inventory On Hand Units], [Avg Daily Units Sold])
```

---

## Inventory Turnover (units-based proxy)

Traditional turnover uses COGS / Avg Inventory Value, but units-based is often easier.

```DAX
Average Inventory Units =
AVERAGEX(
    VALUES(DimDate[Date]),
    CALCULATE([Inventory On Hand Units])
)
```

```DAX
Inventory Turnover (Units) =
DIVIDE([Volume Units], [Average Inventory Units])
```

---

## Aging Inventory % (if you track received date / age buckets)

This needs inventory lot/aging data. Example assumes `InventorySnapshots[AgeBucket]`.

```DAX
Aged Inventory Units (90+ Days) =
CALCULATE(
    [Inventory On Hand Units],
    InventorySnapshots[AgeBucket] = "90+"
)
```

```DAX
Aged Inventory % (90+ Days) =
DIVIDE([Aged Inventory Units (90+ Days)], [Inventory On Hand Units])
```

---

## Stockout Rate

This depends on inventory snapshots. Best practice: calculate from a daily inventory table.

### If `InventorySnapshots[InStockFlag]` exists (1=in stock, 0=stockout)

#### In-stock Observations

```DAX
In-Stock Observations =
SUM(InventorySnapshots[InStockFlag])
```

#### Total Observations

```DAX
Total Inventory Observations =
COUNTROWS(InventorySnapshots)
```

#### In-Stock %

```DAX
In-Stock % =
DIVIDE([In-Stock Observations], [Total Inventory Observations])
```

#### Stockout Rate %

```DAX
Stockout Rate % =
1 - [In-Stock %]
```

---

### If you only have OnHandUnits

```DAX
Stockout Observations =
COUNTROWS(
    FILTER(
        InventorySnapshots,
        InventorySnapshots[OnHandUnits] <= 0
    )
)
```

```DAX
Stockout Rate % =
DIVIDE([Stockout Observations], [Total Inventory Observations])
```

---

## "Inventory Health Metrics" (bundle examples)

You asked for this as a category, so here's a useful mini-pack:

```DAX
Inventory Health Score (Example) =
VAR InStockScore = [In-Stock %]
VAR TurnScore =
    MIN(1, DIVIDE([Inventory Turnover (Units)], 4))   -- cap at 1 for display
VAR AgingPenalty =
    1 - COALESCE([Aged Inventory % (90+ Days)], 0)
RETURN
DIVIDE(InStockScore + TurnScore + AgingPenalty, 3)
```

That's optional, but teams love a rolled-up health indicator.

---

## The "minimum viable KPI stack" for Inventory & Operations

If you want the practical shortlist (the stuff I'd build first in Power BI):

1. **Inventory On Hand Units**
2. **Days of Inventory on Hand (DOH)**
3. **Inventory Turnover**
4. **Stockout Rate**
5. **In-Stock %**
6. **Aged Inventory % (90+ Days)**

That set covers inventory health, operational efficiency, and risk without turning the dashboard into a spaceship cockpit.

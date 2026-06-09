# DAX Metrics - Sales & Revenue

For a cannabis edibles company like Althea (multi-product, multi-state, promo-heavy, retail/distributor complexity), you usually need a **stack of pricing + volume + margin + inventory + mix metrics** working together. Althea's product positioning (consistent dosing, gummies, multiple cannabinoid/ratio formats) makes mix and price architecture especially important.

---

## Foundation Measures

These are the "atoms" everything else builds on.

```DAX
Volume Units =
SUM(Sales[UnitsSold])
```

```DAX
Gross Sales =
SUMX(
    Sales,
    Sales[GrossUnitPrice] * Sales[UnitsSold]
)
```

> If you already have a `Sales[GrossSalesAmount]` column, use `SUM(Sales[GrossSalesAmount])` instead.

```DAX
Net Sales =
SUMX(
    Sales,
    Sales[NetUnitPrice] * Sales[UnitsSold]
)
```

> If you already have `Sales[NetSalesAmount]`, use that directly.

```DAX
COGS $ =
SUM(Sales[COGSAmount])
```

```DAX
Gross Margin $ =
[Net Sales] - [COGS $]
```

```DAX
Gross Margin % =
DIVIDE([Gross Margin $], [Net Sales])
```

```DAX
Discount $ =
[Gross Sales] - [Net Sales]
```

```DAX
Discount Rate =
DIVIDE([Discount $], [Gross Sales])
```

---

## Net Sales and Gross Sales

These are foundational, not optional.

* **Gross Sales** = before discounts/promos
* **Net Sales** = after discounts/allowances

Why it matters:

* You can't interpret VWAP without knowing whether revenue is growing because of **price**, **volume**, or **discounting**
* Cannabis/CPG promos can make "sales growth" look better than realized profitability

**Useful pair with VWAP:**

* Gross VWAP vs Net VWAP
* Gross Sales vs Net Sales

---

## VWAP

```DAX
Gross VWAP =
DIVIDE([Gross Sales], [Volume Units])
```

```DAX
Net VWAP =
DIVIDE([Net Sales], [Volume Units])
```

### VWAP Delta (Promo Impact)

```DAX
VWAP Delta = [Gross VWAP] - [Net VWAP]
```

```DAX
VWAP Discount % = DIVIDE([Gross VWAP] - [Net VWAP], [Gross VWAP])
```

---

## Volume and Unit Velocity

VWAP tells you price realization. You also need to know whether products are moving.

### Key metrics

* **Units Sold**
* **Unit Growth % (MoM / YoY)**
* **SKU Velocity** (units per store per week, units per account per week)
* **Sell-through %** (if you have shipped vs retail sold data)

Why it matters:

* A rising VWAP can be bad if volume collapses
* A lower VWAP can be good if it drives velocity and margin dollars

This is especially relevant because Althea roles often call out tracking inventory movement and omnichannel performance, not just topline sales.

---

## Product Mix %

This one is sneaky-important in edibles.

### What to track

* % of revenue by:

  * **Flavor**
  * **Cannabinoid type** (THC / CBN / CBD / CBG / ratio)
  * **Pack size**
  * **State**
  * **Channel/account**
* % of units by the same slices

Why it matters:

* Your average price can move just because the mix shifts toward premium or higher-dose SKUs
* A "pricing issue" is often really a **mix issue**

Example:

* If CBN sleep gummies gain share, total VWAP might rise even with no list-price changes (and this kind of category shift has been happening in market trends).

### Product Mix % (Net Sales)

This works when slicing by product/cannabinoid/flavor/etc.

```DAX
Product Mix % (Net Sales) =
DIVIDE(
    [Net Sales],
    CALCULATE([Net Sales], ALLSELECTED(Sales[ProductName]))
)
```

If you want mix across all products regardless of slicer on product, use `ALL` instead of `ALLSELECTED`.

### Unit Mix %

```DAX
Product Mix % (Units) =
DIVIDE(
    [Volume Units],
    CALCULATE([Volume Units], ALLSELECTED(Sales[ProductName]))
)
```

---

## Gross Margin % and Gross Margin Dollars

If I had to pick a metric that fights with VWAP for "most important," this is it.

### Metrics

* **Gross Margin %**
* **Gross Margin $**
* **Margin per Unit**
* **Margin per SKU / State / Account**

Why it matters:

* VWAP can look healthy while margins get wrecked by COGS, promo spend, or wholesale concessions
* Finance teams care deeply about **profit dollars**, not just price realization

A lot of cannabis operator KPI guidance emphasizes margin metrics because taxes/fees/COGS/regulatory overhead make gross revenue misleading by itself.

---

## Discount Rate and Promo Lift

This is a business analyst goldmine.

### Metrics

* **Discount %** = (Gross Sales - Net Sales) / Gross Sales
* **Promo Penetration %** = % units sold on promo
* **Promo Lift** = (units during promo - baseline units) / baseline units
* **Promo ROI** = incremental margin / promo cost

Why it matters:

* Tells you whether discounts are creating real incremental demand or just giving away margin
* Helps answer the classic finance/sales food fight:

  * "We need more promos"
  * "No, promos are killing profitability"

VWAP + Discount % + Promo Lift is an elite combo.

### Promo Sales / Units

```DAX
Promo Units =
CALCULATE(
    [Volume Units],
    Sales[IsPromo] = TRUE()
)
```

```DAX
Non-Promo Units =
CALCULATE(
    [Volume Units],
    Sales[IsPromo] = FALSE()
)
```

```DAX
Promo Net Sales =
CALCULATE(
    [Net Sales],
    Sales[IsPromo] = TRUE()
)
```

### Promo Penetration %

```DAX
Promo Penetration % (Units) =
DIVIDE([Promo Units], [Volume Units])
```

### Promo Lift (simple pattern)

Promo Lift requires a **baseline**. The cleanest practical approach is:

* compare **promo velocity** vs **non-promo velocity** in same selected context

#### Promo ROS

```DAX
Promo ROS =
DIVIDE(
    [Promo Units],
    CALCULATE([Active Accounts (Sold)], Sales[IsPromo] = TRUE())
)
```

#### Non-Promo ROS

```DAX
Non-Promo ROS =
DIVIDE(
    [Non-Promo Units],
    CALCULATE([Active Accounts (Sold)], Sales[IsPromo] = FALSE())
)
```

#### Promo Lift %

```DAX
Promo Lift % =
DIVIDE(
    [Promo ROS] - [Non-Promo ROS],
    [Non-Promo ROS]
)
```

> Working theory note: this is a decent dashboard metric, but "true" lift analysis usually needs matched time windows (pre/post) or test-vs-control.

---

## Distribution and Rate of Sale

For a brand like Althea, this is huge.

### Metrics

* **Doors / Active Accounts** (how many retailers carry the product)
* **Weighted Distribution** (if available from syndicated data)
* **Rate of Sale** = units per active account per week
* **On-shelf availability / In-stock %**

Why it matters:

* Revenue can grow because you gained more stores, not because products are performing better
* Rate-of-sale tells you whether the product is actually winning where it's stocked

This also matches the "track, trace, and communicate omnichannel performance / inventory movement" flavor of the role.

### Distribution (Active Accounts / Doors)

This depends on what "distribution" means in your company.

#### A) Active Accounts (sold at least 1 unit in current context)

```DAX
Active Accounts (Sold) =
CALCULATE(
    DISTINCTCOUNT(Sales[AccountID]),
    Sales[UnitsSold] > 0
)
```

#### B) Total Eligible Accounts (if you have a store/account master table)

If you have `DimAccount[AccountID]` and a relationship:

```DAX
Total Accounts =
DISTINCTCOUNT(DimAccount[AccountID])
```

#### C) Numeric Distribution %

```DAX
Numeric Distribution % =
DIVIDE([Active Accounts (Sold)], [Total Accounts])
```

### Rate of Sale (ROS)

Usually "units per active account" over the selected period.

```DAX
Rate of Sale (Units per Active Account) =
DIVIDE([Volume Units], [Active Accounts (Sold)])
```

### Unit Velocity (Units / Store / Week)

If your context is monthly or arbitrary date ranges, normalize by weeks.

```DAX
Weeks in Context =
DIVIDE(
    DISTINCTCOUNT(DimDate[Date]),
    7
)
```

```DAX
Unit Velocity (Units/Store/Week) =
DIVIDE(
    [Volume Units],
    [Active Accounts (Sold)] * [Weeks in Context]
)
```

> If you have a proper `DimDate[WeekStart]`, use distinct weeks instead for cleaner math:

```DAX
Weeks in Context (Distinct) =
DISTINCTCOUNT(DimDate[WeekStart])
```

```DAX
Unit Velocity (Units/Store/Week) =
DIVIDE(
    [Volume Units],
    [Active Accounts (Sold)] * [Weeks in Context (Distinct)]
)
```

---

## Price Pack Architecture Metrics

Super important in edibles.

### Metrics

* **Price per Pack**
* **Price per Gummy**
* **Price per mg THC (or cannabinoid-specific mg)**
* **Net Revenue per mg**
* **Margin per mg**

Why it matters:

* Cannabis consumers compare value in weird ways (pack, dosage, cannabinoid, effect)
* For Althea's product variety (THC/CBN/CBD/ratio), potency-adjusted metrics can reveal what's really priced "premium" vs just packaged differently.

This is the cousin of VWAP that most analysts miss.

### Price per Pack (basically Net VWAP if one row = one pack)

```DAX
Net Price per Pack =
[Net VWAP]
```

### Price per Unit (same as above if unit = pack)

```DAX
Net Price per Unit =
[Net VWAP]
```

### Price per Gummy (if you have gummies per pack)

Assume `Sales[GummiesPerPack]`.

```DAX
Total Gummies Sold =
SUMX(Sales, Sales[UnitsSold] * Sales[GummiesPerPack])
```

```DAX
Net Price per Gummy =
DIVIDE([Net Sales], [Total Gummies Sold])
```

### Price per mg THC (or cannabinoid)

Assume `Sales[THCMgPerPack]` and `Sales[CBDMgPerPack]`.

```DAX
Total THC mg Sold =
SUMX(Sales, Sales[UnitsSold] * Sales[THCMgPerPack])
```

```DAX
Net Revenue per THC mg =
DIVIDE([Net Sales], [Total THC mg Sold])
```

```DAX
Gross Margin per THC mg =
DIVIDE([Gross Margin $], [Total THC mg Sold])
```

You can repeat this pattern for CBN/CBD/CBG.

---

## The "minimum viable KPI stack" for Sales & Revenue

If you want the practical shortlist (the stuff I'd build first in Power BI):

1. **Gross Sales**
2. **Net Sales**
3. **Units Sold**
4. **Gross VWAP**
5. **Net VWAP**
6. **Discount %**
7. **Gross Margin %**
8. **Gross Margin $**
9. **SKU Velocity (units/store/week)**
10. **Product Mix %**
11. **Promo Penetration %**
12. **Promo Lift %**

That set covers pricing, demand, profitability, and distribution without turning the dashboard into a spaceship cockpit.

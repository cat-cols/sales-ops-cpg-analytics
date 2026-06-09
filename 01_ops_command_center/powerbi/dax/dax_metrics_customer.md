# DAX Metrics - Customer & Account Analytics

For wholesale-heavy brands, concentration risk matters.

---

## Customer / Account Concentration

### Metrics

* **Top 10 accounts % of sales**
* **Revenue concentration by distributor / chain / region**
* **Account growth vs account dependency**

Why it matters:

* If one account drives too much volume, your revenue is fragile
* Helps sales leadership prioritize account diversification

---

## Total Net Sales (for concentration denominator)

```DAX
Total Net Sales (All Accounts) =
CALCULATE(
    [Net Sales],
    ALL(Sales[AccountID])
)
```

---

## Account Concentration % (current account row)

Use in a table by account.

```DAX
Account Revenue Share % =
DIVIDE([Net Sales], [Total Net Sales (All Accounts)])
```

---

## Top 10 Accounts % of Sales

```DAX
Top 10 Accounts Net Sales =
SUMX(
    TOPN(
        10,
        VALUES(Sales[AccountID]),
        [Net Sales],
        DESC
    ),
    [Net Sales]
)
```

```DAX
Top 10 Accounts % of Sales =
DIVIDE([Top 10 Accounts Net Sales], [Total Net Sales (All Accounts)])
```

---

## Repeat Purchase / Retention Signals

If you have retail scan or loyalty-level data, this becomes a cheat code.

### Metrics

* **Repeat Rate**
* **Time to Repeat**
* **Cohort retention**
* **Customer lifetime value (if DTC/hemp side data exists)**

Why it matters:

* Tells you whether growth is sustainable or just trial
* Great for product launches and new cannabinoid formats

---

This requires consumer/customer-level transaction data (`CustomerID`). If you only have wholesale account data, you can do **account retention** instead.

### A) Repeat Customer Rate (consumer-level)

Count customers with 2+ orders in selected period.

#### Orders per Customer

(Measure used inside iterators)

```DAX
Orders Count =
DISTINCTCOUNT(Sales[OrderID])
```

#### Repeat Customers

```DAX
Repeat Customers =
COUNTROWS(
    FILTER(
        VALUES(Sales[CustomerID]),
        CALCULATE(DISTINCTCOUNT(Sales[OrderID])) >= 2
    )
)
```

#### Total Customers

```DAX
Total Customers =
DISTINCTCOUNT(Sales[CustomerID])
```

#### Repeat Purchase Rate %

```DAX
Repeat Purchase Rate % =
DIVIDE([Repeat Customers], [Total Customers])
```

---

### B) Account Retention (wholesale-friendly)

Accounts that bought in current period and prior period.

#### Active Accounts Current Period

```DAX
Active Accounts Current =
CALCULATE(
    DISTINCTCOUNT(Sales[AccountID]),
    Sales[UnitsSold] > 0
)
```

#### Active Accounts Prior Period (example: prior month)

```DAX
Active Accounts Prior =
CALCULATE(
    DISTINCTCOUNT(Sales[AccountID]),
    DATEADD(DimDate[Date], -1, MONTH),
    Sales[UnitsSold] > 0
)
```

#### Retained Accounts

```DAX
Retained Accounts =
COUNTROWS(
    INTERSECT(
        CALCULATETABLE(VALUES(Sales[AccountID]), Sales[UnitsSold] > 0),
        CALCULATETABLE(VALUES(Sales[AccountID]), DATEADD(DimDate[Date], -1, MONTH), Sales[UnitsSold] > 0)
    )
)
```

#### Account Retention %

```DAX
Account Retention % =
DIVIDE([Retained Accounts], [Active Accounts Prior])
```

---

## The "minimum viable KPI stack" for Customer & Account Analytics

If you want the practical shortlist (the stuff I'd build first in Power BI):

1. **Total Net Sales (All Accounts)**
2. **Account Revenue Share %**
3. **Top 10 Accounts % of Sales**
4. **Active Accounts Current**
5. **Active Accounts Prior**
6. **Retained Accounts**
7. **Account Retention %**
8. **Repeat Purchase Rate %** (if customer-level data available)

That set covers concentration risk and retention without turning the dashboard into a spaceship cockpit.

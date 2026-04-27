# Repo-Wide Financial Metrics Cheat Sheet

**Repository:** `wyld-business-analyst`  
**Recommended path:** `docs/financial_metrics_cheat_sheet.md` or `shared/semantic_model/financial_metrics_cheat_sheet.md`  
**Purpose:** One shared reference for every financial, finance-adjacent, and business-driver metric used across the four portfolio projects.

This cheat sheet is meant to make the repo easier for a hiring manager, analyst, finance partner, or future you to understand. It explains what each metric means, where it appears, how it should be calculated, and what grain it should be trusted at.

---

## 0. Project Coverage

| Project | Status in repo | Financial metric role |
|---|---:|---|
| `01_ops_command_center` | Implemented / most complete | Daily sales, COGS, gross margin, labor cost, labor productivity, inventory-adjacent ops metrics, finance reconciliation |
| `02_quarterly_dc_qaqc_system` | Implemented / strong process-control project | Quarterly retail + wholesale sales, finance actuals, COGS, operating expense, inventory value, trade adjustments, reconciliation gaps |
| `03_forecasting_variance_story` | Planned / in progress | Forecast vs actual, budget vs actual, price/volume/mix variance, margin variance, driver explanation |
| `04_ghg_scope_reporting` | Planned / in progress | Sustainability metrics with financial interpretation: emissions intensity per revenue, cost exposure, reduction savings, payback, audit-ready lineage |

---

## 1. Global Metric Rules

### 1.1 Source-of-truth priority

Use this hierarchy when metrics disagree:

1. **Certified mart table or reporting view** — best for dashboards and executive reporting.
2. **Reconciled finance actuals** — best for book-of-record revenue, COGS, margin, and expense totals.
3. **Operational fact tables** — best for SKU/store/channel/day diagnostics.
4. **Raw/staging source extracts** — best for QA, exception tracing, and reconciliation root cause.

### 1.2 Grain rules

| Metric family | Safe additive grain | Be careful with |
|---|---|---|
| Sales dollars | Date + store/account + SKU + channel/source | Duplicates, mixed channel naming, source overlap between distributor and POS |
| Units / cases | Date/week + store/account + SKU | Units and cases are not the same unit of measure |
| Margin dollars | Same grain as net sales and COGS | Aggregating margin % directly; always recalculate from dollars |
| Labor cost / hours | Week/day + site + department/team | Payroll weekly grain vs daily timeclock grain |
| Inventory value | Snapshot date/week + warehouse/site + SKU | Snapshot metrics are point-in-time, not daily transaction flows |
| Forecast variance | Date/week + SKU/channel/store or comparable aggregate | Actual and forecast must use the same grain and same metric basis |
| GHG intensity | Reporting period + scope/category + denominator | Never mix location-based and market-based emissions without labeling |

### 1.3 Formatting standards

| Type | Display format | Example |
|---|---:|---:|
| Currency | `$#,##0` or `$#,##0.00` | `$125,430` |
| Percentage | `0.0%` | `42.8%` |
| Ratio | `0.00` | `1.35` |
| Units | `#,##0` | `18,245` |
| Emissions | `#,##0.00 tCO2e` | `128.44 tCO2e` |
| Intensity | `0.0000 tCO2e / $` or `tCO2e / $1M sales` | `4.2 tCO2e / $1M` |

---

# 2. Core Revenue Metrics

These metrics appear directly in Projects 1 and 2 and become the actuals foundation for Project 3.

## 2.1 Gross Sales

| Attribute | Definition |
|---|---|
| Metric name | `gross_sales` |
| Business meaning | Sales before discounts, rebates, returns, trade credits, or other deductions. |
| Default formula | `SUM(gross_sales)` |
| Project 1 fields | `gross_sales`, `gross_amount`, finance metric label `Gross Sales` |
| Project 2 fields | `gross_sales` in retail and wholesale quarterly extracts |
| Project 3 usage | Actual sales baseline before variance decomposition |
| Project 4 usage | Possible denominator for emissions intensity if net sales is unavailable, but net sales is preferred |
| Grain | Transaction, daily distributor line, weekly/quarterly source line, or monthly finance metric |
| QA checks | `gross_sales >= net_sales`; gross sales should usually be non-negative; gross sales should reconcile to finance within tolerance |

**SQL pattern**

```sql
sum(gross_sales) as gross_sales
```

**Power BI / DAX pattern**

```DAX
Gross Sales = SUM('fact_sales'[gross_sales])
```

---

## 2.2 Discount Amount

| Attribute | Definition |
|---|---|
| Metric name | `discount_amount` |
| Business meaning | Dollar reduction between gross and net sales. |
| Default formula | `SUM(discount_amount)` or `SUM(gross_sales) - SUM(net_sales)` |
| Project 1 fields | `discount_amount`; finance discount amount may be implied as `gross_sales - net_sales` |
| Project 2 fields | `discount_amount` in retail quarterly extract; wholesale data may not separately provide discounts |
| Project 3 usage | Helps explain price/discount-driven variance |
| Project 4 usage | Usually not used directly, but can affect revenue denominator if net sales is used |
| Grain | Same as sales grain |
| QA checks | `discount_amount >= 0`; `gross_sales - discount_amount = net_sales` where all fields exist |

**SQL pattern**

```sql
sum(coalesce(discount_amount, gross_sales - net_sales)) as discount_amount
```

**Power BI / DAX pattern**

```DAX
Discount Amount = [Gross Sales] - [Net Sales]
```

---

## 2.3 Discount Rate

| Attribute | Definition |
|---|---|
| Metric name | `discount_rate` / `discount_pct` |
| Business meaning | Discount as a percentage of gross sales. |
| Default formula | `SUM(discount_amount) / NULLIF(SUM(gross_sales), 0)` |
| Project 1 fields | `discount_rate`, `discount_pct`, `discount_amount`, `gross_sales`, `net_sales` |
| Project 2 fields | Derived from `discount_amount / gross_sales` for retail |
| Project 3 usage | Explains whether sales variance was caused by pricing/discounting instead of unit volume |
| Grain | Recalculate at report grain; do not average row-level rates unless intentionally analyzing row-level behavior |
| QA checks | Rate should normally be between `0` and `1`; investigate negative or >100% discounts |

**SQL pattern**

```sql
sum(discount_amount) / nullif(sum(gross_sales), 0) as discount_rate
```

**Power BI / DAX pattern**

```DAX
Discount Rate = DIVIDE([Discount Amount], [Gross Sales])
```

---

## 2.4 Net Sales

| Attribute | Definition |
|---|---|
| Metric name | `net_sales` |
| Business meaning | Sales after discounts; primary revenue metric for margin, productivity, forecast actuals, and most executive reporting. |
| Default formula | `SUM(net_sales)` or `SUM(gross_sales) - SUM(discount_amount)` |
| Project 1 fields | `net_sales`, `net_amount`, finance metric label `Net Sales` |
| Project 2 fields | `net_sales` in retail and wholesale quarterly extracts; finance category `net_revenue` |
| Project 3 usage | Main actuals metric for forecast variance and revenue bridge |
| Project 4 usage | Preferred denominator for emissions intensity per revenue |
| Grain | Sales line, transaction, daily fact, weekly submission, monthly finance actual, quarterly certified output |
| QA checks | `net_sales <= gross_sales`; operational net sales should reconcile to finance net revenue within tolerance |

**SQL pattern**

```sql
sum(net_sales) as net_sales
```

**Power BI / DAX pattern**

```DAX
Net Sales = SUM('fact_sales'[net_sales])
```

---

## 2.5 Net Revenue

| Attribute | Definition |
|---|---|
| Metric name | `net_revenue` |
| Business meaning | Finance-facing equivalent of net sales, usually sourced from finance actuals. |
| Default formula | `SUM(actual_amount) WHERE reporting_category = 'net_revenue'` |
| Project 1 fields | Finance actuals: metric names normalized to `net_sales` |
| Project 2 fields | `finance_quarterly_actuals.actual_amount` where `reporting_category = 'net_revenue'` |
| Project 3 usage | Budget/actual comparison if finance actuals are treated as official actuals |
| Project 4 usage | Preferred revenue denominator for emissions intensity if finance-certified |
| Grain | Month or quarter, depending on finance source |
| QA checks | Compare to operational `net_sales`; difference should be within agreed tolerance |

**SQL pattern**

```sql
sum(case when reporting_category = 'net_revenue' then actual_amount else 0 end) as finance_net_revenue
```

**Power BI / DAX pattern**

```DAX
Finance Net Revenue =
CALCULATE(
    SUM('fact_finance_actuals'[actual_amount]),
    'fact_finance_actuals'[reporting_category] = "net_revenue"
)
```

---

## 2.6 Units Sold

| Attribute | Definition |
|---|---|
| Metric name | `units_sold` / `qty` |
| Business meaning | Number of sellable units sold. |
| Default formula | `SUM(qty)` or `SUM(units_sold)` |
| Project 1 fields | `qty` in distributor and POS facts |
| Project 2 fields | `units_sold` in retail quarterly extract |
| Project 3 usage | Main volume driver for price/volume/mix variance |
| Project 4 usage | Possible operational denominator for emissions per unit |
| Grain | Date/week + store/account + SKU + channel/source |
| QA checks | Units should be non-negative; confirm case-vs-unit conversions before combining wholesale and retail |

**SQL pattern**

```sql
sum(qty) as units_sold
```

**Power BI / DAX pattern**

```DAX
Units Sold = SUM('fact_sales'[qty])
```

---

## 2.7 Cases Sold

| Attribute | Definition |
|---|---|
| Metric name | `cases_sold` |
| Business meaning | Wholesale case volume sold. Not the same as units unless a case-pack conversion is supplied. |
| Default formula | `SUM(cases_sold)` |
| Project 2 fields | `cases_sold` in wholesale quarterly extract |
| Project 3 usage | Wholesale volume driver; convert to units before combining with retail unit volume |
| Grain | Week + wholesale account + SKU |
| QA checks | Do not union with units without a `units_per_case` conversion |

**SQL pattern**

```sql
sum(cases_sold) as cases_sold
```

---

## 2.8 Average Selling Price / ASP

| Attribute | Definition |
|---|---|
| Metric name | `average_selling_price` / `asp` |
| Business meaning | Average net sales dollars earned per unit sold. |
| Default formula | `SUM(net_sales) / NULLIF(SUM(units_sold), 0)` |
| Project 1 fields | `net_sales / qty`; POS: `net_amount / qty` |
| Project 2 fields | Retail: `net_sales / units_sold`; Wholesale: `net_sales / cases_sold` as case ASP |
| Project 3 usage | Price effect and discounting analysis |
| Grain | Recalculate at current report grain |
| QA checks | Do not average row-level ASPs; weighted ASP is required |

**SQL pattern**

```sql
sum(net_sales) / nullif(sum(qty), 0) as asp
```

**Power BI / DAX pattern**

```DAX
ASP = DIVIDE([Net Sales], [Units Sold])
```

---

# 3. Margin and Cost Metrics

## 3.1 COGS

| Attribute | Definition |
|---|---|
| Metric name | `cogs` |
| Business meaning | Cost of goods sold associated with revenue. |
| Default formula | `SUM(cogs)` |
| Project 1 fields | `cogs`; finance metric label `COGS` or `Cost of Goods` |
| Project 2 fields | Finance actuals category `cogs` |
| Project 3 usage | Margin variance and profitability bridge |
| Project 4 usage | Not a core GHG metric, but useful for financial impact context |
| Grain | Sales line or monthly/quarterly finance actual |
| QA checks | COGS should usually be non-negative; COGS should be less than or reasonably near net sales depending on business model |

**SQL pattern**

```sql
sum(cogs) as cogs
```

**Power BI / DAX pattern**

```DAX
COGS = SUM('fact_sales'[cogs])
```

---

## 3.2 Gross Margin Dollars

| Attribute | Definition |
|---|---|
| Metric name | `gross_margin` |
| Business meaning | Revenue remaining after COGS. |
| Default formula | `SUM(net_sales) - SUM(cogs)` |
| Project 1 fields | Finance actuals include `gross_margin`; mart KPI can derive it from net sales and COGS |
| Project 2 fields | Derived from finance actuals as `net_revenue - cogs` if not provided |
| Project 3 usage | Margin bridge and margin variance analysis |
| Project 4 usage | Financial context only |
| Grain | Recalculate from additive dollars at the current grain |
| QA checks | `gross_margin = net_sales - cogs`; do not sum pre-aggregated margin if it overlaps another source |

**SQL pattern**

```sql
sum(net_sales) - sum(cogs) as gross_margin
```

**Power BI / DAX pattern**

```DAX
Gross Margin = [Net Sales] - [COGS]
```

---

## 3.3 Gross Margin Percent

| Attribute | Definition |
|---|---|
| Metric name | `gross_margin_pct` |
| Business meaning | Share of net sales left after COGS. |
| Default formula | `Gross Margin / Net Sales` |
| Project 1 usage | Finance and executive KPI |
| Project 2 usage | Quarterly finance health indicator |
| Project 3 usage | Margin rate effect / margin bridge |
| Grain | Always recalculate from aggregated dollars |
| QA checks | Never average row-level margin percentages for executive totals |

**SQL pattern**

```sql
(sum(net_sales) - sum(cogs)) / nullif(sum(net_sales), 0) as gross_margin_pct
```

**Power BI / DAX pattern**

```DAX
Gross Margin % = DIVIDE([Gross Margin], [Net Sales])
```

---

## 3.4 Labor Cost

| Attribute | Definition |
|---|---|
| Metric name | `labor_cost` |
| Business meaning | Payroll or labor dollars associated with a site/team/department/time period. |
| Default formula | `SUM(labor_cost)` |
| Project 1 fields | Payroll export `labor_cost`; finance actuals include `labor_cost` |
| Project 2 fields | Not core in current quarterly generator, but finance expense pattern supports department-level expense tracking |
| Project 3 usage | Optional operating variance driver |
| Project 4 usage | Not core, unless labor is included in sustainability project cost calculations |
| Grain | Weekly payroll + site + team/department; monthly finance actual |
| QA checks | Zero hours with positive cost should be flagged; finance labor cost should reconcile to payroll within tolerance |

**SQL pattern**

```sql
sum(labor_cost) as labor_cost
```

**Power BI / DAX pattern**

```DAX
Labor Cost = SUM('fact_labor'[labor_cost])
```

---

## 3.5 Labor Cost Percent of Sales

| Attribute | Definition |
|---|---|
| Metric name | `labor_cost_pct_of_sales` |
| Business meaning | Labor cost as a percentage of net sales. |
| Default formula | `SUM(labor_cost) / SUM(net_sales)` |
| Project 1 usage | People/productivity KPI; useful in Ops Command Center |
| Project 3 usage | Labor efficiency variance |
| Grain | Date/week/month + store/site where both labor and sales are aligned |
| QA checks | Requires conformed site/store keys and aligned dates; weekly payroll may need spreading or week-based sales aggregation |

**SQL pattern**

```sql
sum(labor_cost) / nullif(sum(net_sales), 0) as labor_cost_pct_of_sales
```

**Power BI / DAX pattern**

```DAX
Labor Cost % of Sales = DIVIDE([Labor Cost], [Net Sales])
```

---

## 3.6 Operating Expense

| Attribute | Definition |
|---|---|
| Metric name | `operating_expense` |
| Business meaning | Non-COGS operating expense, such as G&A, departmental expense, or overhead. |
| Default formula | `SUM(actual_amount) WHERE reporting_category = 'operating_expense'` |
| Project 2 fields | `finance_quarterly_actuals.actual_amount` with `reporting_category = 'operating_expense'` |
| Project 3 usage | Optional actual vs budget expense variance |
| Project 4 usage | Can be part of sustainability project-cost tracking |
| Grain | Quarter + department/account |
| QA checks | Validate account/category mapping and sign convention |

---

# 4. Productivity and Efficiency Metrics

## 4.1 Sales per Labor Hour

| Attribute | Definition |
|---|---|
| Metric name | `sales_per_labor_hour` |
| Business meaning | Net sales generated for each labor hour. |
| Default formula | `SUM(net_sales) / SUM(hours_worked)` |
| Project 1 mart | `mart.kpi_sales_per_labor_hour_daily` concept |
| Project 3 usage | Labor productivity variance |
| Grain | Store/site + day/week/month, after sales and labor are conformed |
| QA checks | Avoid division by zero; investigate positive sales with zero labor hours and positive labor cost with zero hours |

**SQL pattern**

```sql
sum(net_sales) / nullif(sum(hours_worked), 0) as sales_per_labor_hour
```

**Power BI / DAX pattern**

```DAX
Sales per Labor Hour = DIVIDE([Net Sales], [Labor Hours])
```

---

## 4.2 Labor Hours

| Attribute | Definition |
|---|---|
| Metric name | `hours_worked` / `labor_hours` |
| Business meaning | Hours worked from payroll or derived from timeclock punches. |
| Default formula | `SUM(hours_worked)` |
| Project 1 fields | Payroll `hours_worked`; timeclock can derive worked time from IN/OUT punches |
| Project 3 usage | Labor volume driver |
| Grain | Payroll week + site + department/team; timeclock day + employee + site |
| QA checks | Missing OUT punches, zero hours with cost, unrealistic long shifts |

---

## 4.3 Units per Labor Hour

| Attribute | Definition |
|---|---|
| Metric name | `units_per_labor_hour` |
| Business meaning | Volume productivity. |
| Default formula | `SUM(units_sold) / SUM(hours_worked)` |
| Project 1 usage | Optional Ops/Labor KPI |
| Project 3 usage | Volume productivity diagnostic |
| Grain | Store/site + date/week/month after conformance |
| QA checks | Requires units and labor aligned to same location and time grain |

---

# 5. Inventory and Working-Capital-Adjacent Metrics

## 5.1 Inventory Value

| Attribute | Definition |
|---|---|
| Metric name | `inventory_value` |
| Business meaning | Dollar value of inventory on hand or available at snapshot time. |
| Default formula | `SUM(inventory_value)` at snapshot grain |
| Project 1 usage | Can be derived if standard cost is added to inventory snapshots; not currently a main raw Project 1 field |
| Project 2 fields | `inventory_quarterly_extract.inventory_value` |
| Project 3 usage | Optional supply constraint or demand planning feature |
| Project 4 usage | Not core; may be used to contextualize operations scale |
| Grain | Snapshot week/date + warehouse/site + SKU |
| QA checks | Snapshot metric; do not sum across dates unless intentionally measuring cumulative snapshots; negative inventory value should be flagged |

**SQL pattern**

```sql
sum(inventory_value) as inventory_value
```

---

## 5.2 On-Hand Units

| Attribute | Definition |
|---|---|
| Metric name | `on_hand_units` / `on_hand` |
| Business meaning | Units physically in inventory at snapshot time. |
| Default formula | `SUM(on_hand_units)` at one snapshot date |
| Project 1 fields | `on_hand` in inventory ERP snapshot |
| Project 2 fields | `on_hand_units` |
| Project 3 usage | Forecast coverage / stockout risk |
| Grain | Snapshot date/week + site/warehouse + SKU |
| QA checks | Negative on-hand values should be flagged; avoid summing across multiple snapshot dates |

---

## 5.3 Available Units

| Attribute | Definition |
|---|---|
| Metric name | `available_units` |
| Business meaning | Units available to sell or ship after holds/reservations. |
| Default formula | `SUM(available_units)` at snapshot grain |
| Project 2 fields | `available_units` |
| Project 3 usage | Forecast fulfillment risk and stockout diagnostics |
| Grain | Snapshot week/date + warehouse/site + SKU |
| QA checks | Available units should usually be `<= on_hand_units` |

---

## 5.4 Days of Supply

| Attribute | Definition |
|---|---|
| Metric name | `days_of_supply` |
| Business meaning | Estimated number of days current inventory can cover recent or forecasted demand. |
| Default formula | `On-Hand Units / Average Daily Units Sold` |
| Project 1 usage | Ops KPI concept from inventory + sales |
| Project 3 usage | Forecast-driven replenishment diagnostic |
| Grain | SKU + site/store/warehouse + snapshot date |
| QA checks | Use trailing demand window consistently, such as 28 days; handle zero demand separately |

**SQL pattern**

```sql
sum(on_hand_units) / nullif(avg_daily_units_sold, 0) as days_of_supply
```

**Power BI / DAX pattern**

```DAX
Days of Supply = DIVIDE([On Hand Units], [Avg Daily Units Sold])
```

---

# 6. Finance Actuals and Reconciliation Metrics

## 6.1 Actual Amount

| Attribute | Definition |
|---|---|
| Metric name | `actual_amount` |
| Business meaning | Finance-book amount for a mapped reporting category. |
| Default formula | `SUM(actual_amount)` filtered by category |
| Project 1 fields | Finance actuals summary: `actual_amount` with normalized metric names |
| Project 2 fields | Finance quarterly actuals: `actual_amount` with `reporting_category` |
| Project 3 usage | Actual side of budget/forecast variance |
| Project 4 usage | Actual spend, savings, or cost exposure if sustainability finance data is included |
| Grain | Month or quarter + account/category/department |
| QA checks | Validate sign convention and category mapping before reconciling |

---

## 6.2 Operational Net Sales

| Attribute | Definition |
|---|---|
| Metric name | `operational_net_sales` |
| Business meaning | Net sales total from operational sales sources before finance reconciliation. |
| Default formula | `SUM(retail net_sales) + SUM(wholesale net_sales)` or sales mart equivalent |
| Project 1 usage | Distributor/POS sales mart vs finance actuals |
| Project 2 usage | Retail + wholesale submission total |
| Project 3 usage | Actuals base if operational source is used instead of finance |
| Grain | Period + source/channel/account/SKU depending on reconciliation level |
| QA checks | Compare to finance net revenue; investigate duplicates, missing weeks, out-of-period rows, and source overlap |

---

## 6.3 Reconciliation Difference

| Attribute | Definition |
|---|---|
| Metric name | `reconciliation_difference` / `recon_diff` |
| Business meaning | Dollar gap between operational totals and finance totals. |
| Default formula | `Operational Amount - Finance Amount` |
| Project 1 usage | Sales-to-GL or sales-to-finance monthly reconciliation |
| Project 2 usage | Quarterly operational sales vs finance net revenue reconciliation |
| Project 3 usage | Actuals certification before forecasting or variance storytelling |
| Grain | Month/quarter + metric/category + optional source |
| QA checks | Must have a tolerance threshold; large positive/negative values require root-cause notes |

**SQL pattern**

```sql
operational_net_sales - finance_net_revenue as reconciliation_difference
```

**Power BI / DAX pattern**

```DAX
Recon Difference = [Operational Net Sales] - [Finance Net Revenue]
```

---

## 6.4 Reconciliation Difference Percent

| Attribute | Definition |
|---|---|
| Metric name | `reconciliation_difference_pct` |
| Business meaning | Reconciliation gap as a percent of the finance book amount. |
| Default formula | `(Operational Amount - Finance Amount) / Finance Amount` |
| Project 1 usage | Monthly sales-to-finance controls |
| Project 2 usage | Quarterly certification / hold decision |
| Project 3 usage | Confirms actuals are usable before variance analysis |
| Grain | Same as reconciliation difference |
| QA checks | Use absolute value when comparing to tolerance; keep signed value for diagnosis |

**SQL pattern**

```sql
(operational_net_sales - finance_net_revenue)
/ nullif(finance_net_revenue, 0) as reconciliation_difference_pct
```

**Power BI / DAX pattern**

```DAX
Recon Difference % = DIVIDE([Recon Difference], [Finance Net Revenue])
```

---

## 6.5 Reconciliation Status

| Attribute | Definition |
|---|---|
| Metric name | `reconciliation_status` |
| Business meaning | Pass/fail flag based on tolerance. |
| Default formula | `PASS` if `ABS(recon_diff_pct) <= tolerance_pct`, else `FAIL` |
| Project 1 usage | Controls/recon marts |
| Project 2 usage | Certification workflow |
| Project 3 usage | Prevents storytelling from uncertified actuals |
| Grain | Period + metric/category/source |
| QA checks | Tolerance must be documented; common starting point: 1% for portfolio simulation |

**SQL pattern**

```sql
case
  when abs(recon_difference_pct) <= 0.01 then 'PASS'
  else 'FAIL'
end as reconciliation_status
```

---

# 7. Trade Spend, Adjustments, and Netting Metrics

## 7.1 Trade Adjustment Amount

| Attribute | Definition |
|---|---|
| Metric name | `adjustment_amount` |
| Business meaning | Trade spend, rebate, promo credit, return adjustment, or other revenue adjustment. |
| Default formula | `SUM(adjustment_amount)` |
| Project 2 fields | `trade_adjustments_extract.adjustment_amount` |
| Project 3 usage | Explains variance caused by rebates, returns, promo credits, or price protection |
| Grain | Adjustment ID + account + date + type |
| QA checks | Negative adjustments require a reason code; duplicate adjustment IDs should fail DQ; out-of-period adjustments should be flagged |

**SQL pattern**

```sql
sum(adjustment_amount) as trade_adjustment_amount
```

---

## 7.2 Net Sales After Trade Adjustments

| Attribute | Definition |
|---|---|
| Metric name | `net_sales_after_trade_adjustments` |
| Business meaning | Net sales after applying trade credits, rebates, returns, or promo adjustments. |
| Default formula | `SUM(net_sales) + SUM(adjustment_amount)` if negative adjustments reduce revenue |
| Project 2 usage | Optional certified reporting metric after trade adjustments are validated |
| Project 3 usage | Explains actual-vs-plan revenue gap when trade spend is material |
| Grain | Quarter/account/SKU if adjustments can be allocated; otherwise quarter/account |
| QA checks | Sign convention must be documented; do not apply trade adjustments twice if already included in net sales |

**SQL pattern**

```sql
sum(net_sales) + sum(adjustment_amount) as net_sales_after_trade_adjustments
```

---

# 8. Forecasting and Variance Metrics — Project 3 Standards

Project 3 should use the same sales and margin definitions from Projects 1 and 2 so the story is consistent across the repo.

## 8.1 Forecast Sales

| Attribute | Definition |
|---|---|
| Metric name | `forecast_sales` |
| Business meaning | Expected future sales based on forecast model or planning assumption. |
| Default formula | `SUM(forecast_sales)` |
| Project 3 usage | Main forecast output |
| Recommended basis | Net sales unless the report explicitly says gross sales |
| Grain | Week/date + SKU + store/channel, or the grain the model was trained on |
| QA checks | Forecast and actuals must use the same metric basis and grain |

---

## 8.2 Forecast Variance Dollars

| Attribute | Definition |
|---|---|
| Metric name | `forecast_variance_amount` |
| Business meaning | Dollar difference between actual and forecast. |
| Default formula | `Actual Net Sales - Forecast Net Sales` |
| Project 3 usage | Forecast page KPI and variance bridge |
| Grain | Same as forecast |
| QA checks | Actuals should be certified/reconciled before variance is reported |

**SQL pattern**

```sql
sum(actual_net_sales) - sum(forecast_net_sales) as forecast_variance_amount
```

**Power BI / DAX pattern**

```DAX
Forecast Variance $ = [Actual Net Sales] - [Forecast Net Sales]
```

---

## 8.3 Forecast Variance Percent

| Attribute | Definition |
|---|---|
| Metric name | `forecast_variance_pct` |
| Business meaning | Forecast error or gap as a percentage of forecast. |
| Default formula | `(Actual - Forecast) / Forecast` |
| Project 3 usage | Forecast accuracy diagnostics |
| Grain | Same as forecast |
| QA checks | Use absolute percent error separately if measuring model accuracy |

**Power BI / DAX pattern**

```DAX
Forecast Variance % = DIVIDE([Forecast Variance $], [Forecast Net Sales])
```

---

## 8.4 Absolute Percent Error

| Attribute | Definition |
|---|---|
| Metric name | `absolute_percent_error` / `ape` |
| Business meaning | Absolute forecast error as a percent of actual or forecast. |
| Default formula | `ABS(Actual - Forecast) / Actual` |
| Project 3 usage | Forecast model diagnostics |
| Grain | Forecast grain |
| QA checks | Choose denominator consistently and document it |

---

## 8.5 Mean Absolute Percent Error

| Attribute | Definition |
|---|---|
| Metric name | `mape` |
| Business meaning | Average absolute forecast error percentage. |
| Default formula | `AVG(ABS(Actual - Forecast) / Actual)` |
| Project 3 usage | Forecast model quality score |
| Grain | Evaluation window + forecast grain |
| QA checks | MAPE behaves badly when actuals are zero; use WAPE if many zeros exist |

---

## 8.6 Weighted Absolute Percent Error

| Attribute | Definition |
|---|---|
| Metric name | `wape` |
| Business meaning | Weighted forecast error; better for business totals than simple MAPE. |
| Default formula | `SUM(ABS(Actual - Forecast)) / SUM(Actual)` |
| Project 3 usage | Recommended executive forecast accuracy metric |
| Grain | Evaluation window |
| QA checks | Requires positive actual totals |

---

## 8.7 Budget Variance Dollars

| Attribute | Definition |
|---|---|
| Metric name | `budget_variance_amount` |
| Business meaning | Difference between actual and budget/plan. |
| Default formula | `Actual - Budget` |
| Project 3 usage | Budget vs actual waterfall |
| Grain | Period + SKU/channel/store/account depending on budget grain |
| QA checks | Confirm budget and actuals use the same metric basis |

---

## 8.8 Budget Variance Percent

| Attribute | Definition |
|---|---|
| Metric name | `budget_variance_pct` |
| Business meaning | Budget gap as a percentage of budget. |
| Default formula | `(Actual - Budget) / Budget` |
| Project 3 usage | Executive KPI and variance bridge |
| QA checks | Use signed percent for story; use absolute percent for accuracy/scoring |

---

## 8.9 Price Effect

| Attribute | Definition |
|---|---|
| Metric name | `price_effect` |
| Business meaning | Portion of sales variance caused by actual prices differing from planned/forecast prices. |
| Simple formula | `(Actual ASP - Planned ASP) * Actual Units` |
| Better SKU-level formula | `SUM(Actual Units_i * (Actual Price_i - Planned Price_i))` |
| Project 3 usage | Price/volume/mix waterfall |
| Grain | SKU/channel/store recommended |
| QA checks | Requires comparable actual and planned price at the same grain |

---

## 8.10 Volume Effect

| Attribute | Definition |
|---|---|
| Metric name | `volume_effect` |
| Business meaning | Portion of sales variance caused by selling more or fewer units than planned. |
| Simple formula | `(Actual Units - Planned Units) * Planned ASP` |
| Better aggregate formula | `(Total Actual Units - Total Planned Units) * Planned Weighted ASP` |
| Project 3 usage | Price/volume/mix waterfall |
| Grain | SKU/channel/store recommended |
| QA checks | Separate unit volume from case volume before calculating |

---

## 8.11 Mix Effect

| Attribute | Definition |
|---|---|
| Metric name | `mix_effect` |
| Business meaning | Portion of variance caused by selling a different product/channel mix than planned. |
| Practical portfolio formula | `Total Revenue Variance - Price Effect - Volume Effect` |
| More explicit formula | `SUM((Actual Units_i - Actual Total Units * Planned Mix_i) * Planned Price_i)` |
| Project 3 usage | Final bridge component when SKU mix matters |
| Grain | SKU/channel required |
| QA checks | If mix is calculated as residual, label it clearly as residual/mix |

---

## 8.12 Margin Rate Effect

| Attribute | Definition |
|---|---|
| Metric name | `margin_rate_effect` |
| Business meaning | Margin variance caused by actual margin rate changing. |
| Formula | `(Actual Gross Margin % - Planned Gross Margin %) * Actual Net Sales` |
| Project 3 usage | Margin bridge |
| Grain | Product/channel/time where both sales and COGS exist |
| QA checks | Use recalculated gross margin percentages, not averaged percentages |

---

## 8.13 Margin Volume Effect

| Attribute | Definition |
|---|---|
| Metric name | `margin_volume_effect` |
| Business meaning | Margin variance caused by sales volume/revenue changing at planned margin rate. |
| Formula | `(Actual Net Sales - Planned Net Sales) * Planned Gross Margin %` |
| Project 3 usage | Margin bridge |
| Grain | Product/channel/time |
| QA checks | Planned margin rate must be available and comparable |

---

# 9. Sustainability / GHG Financial Metrics — Project 4 Standards

Project 4 is not only “environmental.” For a business analyst portfolio, the strongest angle is tying sustainability reporting to financial reporting discipline: lineage, controls, auditability, and business impact.

## 9.1 Total Emissions

| Attribute | Definition |
|---|---|
| Metric name | `total_emissions_tco2e` |
| Business meaning | Total greenhouse gas emissions in metric tons of CO2 equivalent. |
| Default formula | `SUM(activity_amount * emission_factor)` |
| Project 4 usage | Primary sustainability reporting metric |
| Grain | Period + scope + category + location/source |
| QA checks | Factor version, unit conversion, scope/category, and calculation method must be documented |

---

## 9.2 Scope 1 Emissions

| Attribute | Definition |
|---|---|
| Metric name | `scope_1_emissions_tco2e` |
| Business meaning | Direct emissions from owned or controlled sources. |
| Default formula | `SUM(emissions_tco2e) WHERE scope = 'Scope 1'` |
| Project 4 usage | GHG scorecard and assurance package |
| QA checks | Confirm source category and organizational boundary |

---

## 9.3 Scope 2 Emissions

| Attribute | Definition |
|---|---|
| Metric name | `scope_2_emissions_tco2e` |
| Business meaning | Indirect emissions from purchased electricity, steam, heat, or cooling. |
| Default formula | `SUM(emissions_tco2e) WHERE scope = 'Scope 2'` |
| Project 4 usage | Energy/emissions reporting |
| QA checks | Label location-based vs market-based method |

---

## 9.4 Scope 3 Emissions

| Attribute | Definition |
|---|---|
| Metric name | `scope_3_emissions_tco2e` |
| Business meaning | Other indirect value-chain emissions. |
| Default formula | `SUM(emissions_tco2e) WHERE scope = 'Scope 3'` |
| Project 4 usage | Optional advanced reporting scope |
| QA checks | Scope 3 categories must be documented; estimates should be labeled |

---

## 9.5 Emissions Intensity per Net Sales

| Attribute | Definition |
|---|---|
| Metric name | `emissions_intensity_per_net_sales` |
| Business meaning | Emissions produced per dollar of revenue. |
| Default formula | `Total tCO2e / Net Sales` or `Total tCO2e / ($ Net Sales / 1,000,000)` |
| Project 4 usage | Finance-linked sustainability KPI |
| Project 1/2 dependency | Uses certified or reconciled `net_sales` / `net_revenue` |
| Grain | Period + scope/category + revenue boundary |
| QA checks | Revenue boundary must match emissions boundary; use finance-certified revenue where possible |

**Power BI / DAX pattern**

```DAX
Emissions per $1M Net Sales =
DIVIDE([Total Emissions tCO2e], DIVIDE([Net Sales], 1000000))
```

---

## 9.6 Energy Cost

| Attribute | Definition |
|---|---|
| Metric name | `energy_cost` |
| Business meaning | Dollars spent on electricity, fuel, gas, or energy source. |
| Default formula | `SUM(energy_cost)` |
| Project 4 usage | Financial side of emissions reporting if utility/fuel cost data is modeled |
| Grain | Period + location + energy source/vendor |
| QA checks | Separate cost from consumption units; do not calculate emissions from cost unless using spend-based factors intentionally |

---

## 9.7 Carbon Cost Exposure

| Attribute | Definition |
|---|---|
| Metric name | `carbon_cost_exposure` |
| Business meaning | Estimated financial exposure if emissions carried a carbon price. |
| Default formula | `Total Emissions tCO2e * Carbon Price per tCO2e` |
| Project 4 usage | Scenario planning / executive impact metric |
| Grain | Period + scope/category + scenario |
| QA checks | Carbon price is an assumption, not an actual unless tied to a real fee/tax/credit market |

---

## 9.8 Reduction Savings

| Attribute | Definition |
|---|---|
| Metric name | `reduction_savings` |
| Business meaning | Estimated dollar savings from emissions or energy reduction project. |
| Default formula | `Baseline Cost - Actual Cost` or `Avoided Consumption * Unit Cost` |
| Project 4 usage | Sustainability ROI story |
| Grain | Project + period + location |
| QA checks | Baseline method must be documented; avoid claiming savings without baseline and actuals |

---

## 9.9 Sustainability Project ROI

| Attribute | Definition |
|---|---|
| Metric name | `sustainability_project_roi` |
| Business meaning | Return on investment for a sustainability initiative. |
| Default formula | `(Annual Savings - Annual Operating Cost) / Project Investment` |
| Project 4 usage | Business case metric |
| Grain | Project / initiative |
| QA checks | Separate one-time capex from recurring operating savings |

---

## 9.10 Simple Payback Period

| Attribute | Definition |
|---|---|
| Metric name | `simple_payback_years` |
| Business meaning | Number of years for savings to recover initial investment. |
| Default formula | `Project Investment / Annual Savings` |
| Project 4 usage | Executive decision metric |
| Grain | Project / initiative |
| QA checks | Annual savings must be positive; document whether incentives/rebates are included |

---

# 10. Data Quality and Certification Metrics with Financial Impact

These are not traditional finance metrics, but they protect the trustworthiness of financial reporting.

## 10.1 Checked Records

| Attribute | Definition |
|---|---|
| Metric name | `checked_records` |
| Business meaning | Number of records evaluated by a DQ rule. |
| Project 2 usage | DQ scorecard denominator |
| Financial relevance | Determines whether financial submissions are complete enough to certify |

---

## 10.2 Failed Records

| Attribute | Definition |
|---|---|
| Metric name | `failed_records` |
| Business meaning | Number of records that failed a DQ rule. |
| Project 2 usage | DQ scorecard and exception reporting |
| Financial relevance | Failed records can cause misstated sales, inventory, expense, or reconciliation results |

---

## 10.3 DQ Failure Rate

| Attribute | Definition |
|---|---|
| Metric name | `dq_failure_rate` |
| Business meaning | Percent of checked records that failed. |
| Default formula | `Failed Records / Checked Records` |
| Project 2 usage | Data quality monitor KPI |
| Financial relevance | High failure rates reduce confidence in certified financial metrics |

**Power BI / DAX pattern**

```DAX
DQ Failure Rate = DIVIDE([Failed Records], [Checked Records])
```

---

## 10.4 Certification Status

| Attribute | Definition |
|---|---|
| Metric name | `certification_status` |
| Business meaning | Indicates whether reporting outputs are safe to publish. |
| Default formula | `CERTIFIED`, `HOLD`, or `FAIL` based on DQ and reconciliation thresholds |
| Project 2 usage | Quarterly reporting gate |
| Financial relevance | Prevents unreliable financial numbers from reaching reporting layer |

---

# 11. Metric Crosswalk by Project

| Metric | Project 1 | Project 2 | Project 3 | Project 4 |
|---|---:|---:|---:|---:|
| Gross Sales | ✅ | ✅ | ✅ actual/budget basis | Optional denominator |
| Discount Amount | ✅ | ✅ retail | ✅ discount driver | — |
| Discount Rate | ✅ | Derived | ✅ price driver | — |
| Net Sales | ✅ | ✅ | ✅ primary actual | ✅ preferred revenue denominator |
| Net Revenue | ✅ finance actual | ✅ finance actual | ✅ finance actual basis | ✅ certified denominator |
| Units Sold | ✅ | ✅ retail | ✅ volume driver | Optional intensity denominator |
| Cases Sold | — | ✅ wholesale | ✅ wholesale volume | — |
| ASP | ✅ derived | ✅ derived | ✅ price effect | — |
| COGS | ✅ | ✅ finance | ✅ margin bridge | — |
| Gross Margin | ✅ | Derived | ✅ margin bridge | — |
| Gross Margin % | ✅ | Derived | ✅ margin rate effect | — |
| Labor Cost | ✅ | Optional finance expense | ✅ productivity/expense variance | Optional project cost |
| Labor Cost % Sales | ✅ | Optional | ✅ efficiency variance | — |
| Sales per Labor Hour | ✅ | — | ✅ productivity driver | — |
| Inventory Value | Optional/derived | ✅ | Optional supply diagnostic | — |
| On-Hand Units | ✅ | ✅ | ✅ stockout/supply diagnostic | Optional unit denominator |
| Available Units | — | ✅ | ✅ stockout/supply diagnostic | — |
| Days of Supply | ✅ | Optional | ✅ forecast coverage | — |
| Actual Amount | ✅ | ✅ | ✅ actuals basis | Optional spend/savings |
| Recon Difference | ✅ | ✅ | ✅ actuals certification | ✅ source-to-metric lineage |
| Recon Difference % | ✅ | ✅ | ✅ actuals certification | ✅ controls metric |
| Trade Adjustment Amount | — | ✅ | ✅ trade-spend driver | — |
| Forecast Sales | — | — | ✅ | — |
| Forecast Variance $ | — | — | ✅ | — |
| Forecast Variance % | — | — | ✅ | — |
| Price Effect | — | — | ✅ | — |
| Volume Effect | — | — | ✅ | — |
| Mix Effect | — | — | ✅ | — |
| Total Emissions tCO2e | — | — | — | ✅ |
| Emissions / $1M Net Sales | — | — | — | ✅ |
| Carbon Cost Exposure | — | — | — | ✅ scenario |
| Sustainability ROI | — | — | — | ✅ scenario/project |
| Simple Payback | — | — | — | ✅ scenario/project |

---

# 12. Recommended Semantic Model Measure Names

Use this naming pattern in Power BI so the model reads clearly.

## Revenue

```text
Gross Sales
Discount Amount
Discount Rate
Net Sales
Finance Net Revenue
Operational Net Sales
ASP
Units Sold
Cases Sold
```

## Margin

```text
COGS
Gross Margin
Gross Margin %
Gross Margin Variance $
Gross Margin Variance %
Margin Rate Effect
Margin Volume Effect
```

## Labor / productivity

```text
Labor Cost
Labor Hours
Labor Cost % of Sales
Sales per Labor Hour
Units per Labor Hour
```

## Reconciliation / controls

```text
Recon Difference $
Recon Difference %
Recon Status
Checked Records
Failed Records
DQ Failure Rate
Certification Status
```

## Forecasting / variance

```text
Forecast Net Sales
Forecast Variance $
Forecast Variance %
Absolute Forecast Error $
APE
MAPE
WAPE
Price Effect
Volume Effect
Mix Effect
```

## Sustainability finance

```text
Total Emissions tCO2e
Scope 1 Emissions tCO2e
Scope 2 Emissions tCO2e
Scope 3 Emissions tCO2e
Emissions per $1M Net Sales
Energy Cost
Carbon Cost Exposure
Reduction Savings
Sustainability Project ROI
Simple Payback Years
```

---

# 13. Common Pitfalls to Avoid

## 13.1 Do not average percentages

Wrong:

```sql
avg(gross_margin_pct)
```

Right:

```sql
sum(gross_margin) / nullif(sum(net_sales), 0)
```

## 13.2 Do not mix units and cases without conversion

Retail `units_sold` and wholesale `cases_sold` are different measures. Add `units_per_case` before combining.

## 13.3 Do not sum inventory snapshots across time

Inventory is a point-in-time balance. Summing inventory value across weeks usually overstates inventory.

Better options:

```sql
-- period-ending inventory
where snapshot_date = max_snapshot_date

-- average inventory over period
avg(inventory_value)
```

## 13.4 Do not double-count operational and finance sales

Operational sales are diagnostic. Finance actuals are usually book-of-record. Reconciliation compares them; it does not add them together.

## 13.5 Do not tell a forecast story from uncertified actuals

Before Project 3 variance analysis, actuals should pass:

```text
DQ checks + reconciliation tolerance + complete date coverage
```

## 13.6 Label scenario metrics clearly

Carbon cost exposure, sustainability ROI, and payback may use assumptions. Label them as scenario/project estimates unless they are tied to actual accounting records.

---

# 14. Suggested Control Queries

## 14.1 Gross sales should be greater than or equal to net sales

```sql
select *
from mart.fact_sales_daily
where gross_sales < net_sales;
```

## 14.2 Margin should equal net sales minus COGS

```sql
select
    period_month,
    sum(net_sales) as net_sales,
    sum(cogs) as cogs,
    sum(gross_margin) as gross_margin,
    sum(net_sales) - sum(cogs) as expected_gross_margin,
    sum(gross_margin) - (sum(net_sales) - sum(cogs)) as margin_diff
from mart.fact_actuals_monthly
group by 1
having abs(sum(gross_margin) - (sum(net_sales) - sum(cogs))) > 0.01;
```

## 14.3 Operational sales vs finance revenue reconciliation

```sql
select
    period_month,
    operational_net_sales,
    finance_net_revenue,
    operational_net_sales - finance_net_revenue as recon_diff,
    (operational_net_sales - finance_net_revenue)
        / nullif(finance_net_revenue, 0) as recon_diff_pct,
    case
        when abs((operational_net_sales - finance_net_revenue)
            / nullif(finance_net_revenue, 0)) <= 0.01 then 'PASS'
        else 'FAIL'
    end as recon_status
from mart.recon_sales_to_gl_monthly;
```

## 14.4 Labor cost with zero labor hours

```sql
select *
from mart.fact_labor_daily
where coalesce(hours_worked, 0) = 0
  and coalesce(labor_cost, 0) > 0;
```

## 14.5 Negative inventory value

```sql
select *
from stg.stg_inventory_quarterly
where inventory_value < 0;
```

---

# 15. Recommended README Blurb

Use this in the repo README or `docs/README.md` if you want a short explanation.

```md
## Financial Metrics Cheat Sheet

This repository uses a shared financial metric dictionary across all four projects so that Sales, Finance, Operations, Forecasting, and Sustainability reporting use consistent definitions. The cheat sheet covers revenue, discounts, COGS, margin, labor productivity, inventory value, reconciliation controls, forecast variance, and GHG financial-intensity metrics.

Start here: [`docs/financial_metrics_cheat_sheet.md`](docs/financial_metrics_cheat_sheet.md)
```

---

# 16. Recommended Next Improvements

1. Add a matching machine-readable file: `shared/semantic_model/metrics_registry.csv`.
2. Add `metric_owner`, `source_table`, `certification_status`, and `allowed_grains` columns.
3. Add one SQL test per metric family.
4. Add Power BI measure definitions in `shared/semantic_model/dax_measures.md`.
5. Link each metric to the mart table or reporting view that owns it.


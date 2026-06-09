# Tableau Calculated Fields Reference

**Project:** 01_ops_command_center
**Purpose:** Reference for all Tableau calculated fields and LOD expressions
**Data Source:** PostgreSQL mart views

---

## Core Sales Calculations

### Net Sales
```tableau
// Total net sales after discounts
SUM([net_sales_amount])
```

### Gross Sales
```tableau
// Total sales before discounts
SUM([gross_sales_amount])
```

### Discount Amount
```tableau
// Total discount dollars
SUM([discount_amount])
```

### Discount Rate
```tableau
// Weighted average discount rate
SUM([discount_amount]) / SUM([gross_sales_amount])
```

### Units Sold
```tableau
// Total units sold
SUM([units_sold])
```

### Order Count
```tableau
// Total number of orders
SUM([order_count])
```

### Customer Count
```tableau
// Total number of customers
SUM([customer_count])
```

### Average Order Value (AOV)
```tableau
// Revenue per order
SUM([net_sales_amount]) / SUM([order_count])
```

### Units per Order
```tableau
// Average units per order
SUM([units_sold]) / SUM([order_count])
```

---

## Profitability Calculations

### COGS
```tableau
// Cost of goods sold
SUM([cogs_amount])
```

### Gross Margin Dollars
```tableau
// Gross margin in dollars
SUM([net_sales_amount]) - SUM([cogs_amount])
```

### Gross Margin Percentage
```tableau
// Gross margin as percentage of net sales
(SUM([net_sales_amount]) - SUM([cogs_amount])) / SUM([net_sales_amount])
```

### Gross Margin % (Formatted)
```tableau
// Gross margin with percentage formatting
[Net Sales] - [COGS]) / [Net Sales]
```

---

## Labor Productivity Calculations

### Labor Hours
```tableau
// Total labor hours
SUM([labor_hours])
```

### Overtime Hours
```tableau
// Total overtime hours
SUM([overtime_hours])
```

### Labor Cost
```tableau
// Total labor cost
SUM([labor_cost_amount])
```

### Sales per Labor Hour
```tableau
// Net sales per labor hour
SUM([net_sales_amount]) / SUM([labor_hours])
```

### Gross Sales per Labor Hour
```tableau
// Gross sales per labor hour
SUM([gross_sales_amount]) / SUM([labor_hours])
```

### Labor Cost % of Sales
```tableau
// Labor cost as percentage of net sales
SUM([labor_cost_amount]) / SUM([net_sales_amount])
```

### Overtime Rate
```tableau
// Overtime as percentage of total hours
SUM([overtime_hours]) / (SUM([labor_hours]) + SUM([overtime_hours]))
```

---

## Inventory Calculations

### On Hand Units
```tableau
// Total on-hand inventory units
SUM([on_hand_units])
```

### Received Units
```tableau
// Total units received
SUM([received_units])
```

### Shipped Units
```tableau
// Total units shipped
SUM([shipped_units])
```

### Requested Units
```tableau
// Total units requested
SUM([requested_units])
```

### Backordered Units
```tableau
// Total backordered units
SUM([backordered_units])
```

### Fill Rate
```tableau
// Percentage of requested units shipped
SUM([shipped_units]) / SUM([requested_units])
```

### Backorder Rate
```tableau
// Percentage of requested units backordered
SUM([backordered_units]) / SUM([requested_units])
```

### In-Stock Rate
```tableau
// Percentage of SKUs in stock
AVG(IF [on_hand_units] > 0 THEN 1 ELSE 0 END)
```

### Days of Supply
```tableau
// Days of inventory on hand
AVG([on_hand_units]) / AVG([daily_demand])
```

---

## Level of Detail (LOD) Expressions

### Store-Level Aggregations

#### Store Average Sales
```tableau
// Average sales per store (independent of current view)
{FIXED [store_key]: AVG([net_sales_amount])}
```

#### Store Total Sales
```tableau
// Total sales per store (independent of current view)
{FIXED [store_key]: SUM([net_sales_amount])}
```

#### Store Rank by Sales
```tableau
// Rank stores by total sales
RANK({FIXED [store_key]: SUM([net_sales_amount])})
```

### SKU-Level Aggregations

#### SKU Average Sales
```tableau
// Average sales per SKU
{FIXED [sku_key]: AVG([net_sales_amount])}
```

#### SKU Total Sales
```tableau
// Total sales per SKU
{FIXED [sku_key]: SUM([net_sales_amount])}
```

#### SKU Rank by Sales
```tableau
// Rank SKUs by total sales
RANK({FIXED [sku_key]: SUM([net_sales_amount])})
```

### Date-Level Aggregations

#### Daily Total Sales
```tableau
// Total sales per day
{FIXED [date_key]: SUM([net_sales_amount])}
```

#### Monthly Total Sales
```tableau
// Total sales per month
{FIXED DATETRUNC('month', [date]): SUM([net_sales_amount])}
```

#### Quarterly Total Sales
```tableau
// Total sales per quarter
{FIXED DATETRUNC('quarter', [date]): SUM([net_sales_amount])}
```

### Percent of Total Calculations

#### Percent of Total Sales
```tableau
// Current sales as percentage of total
SUM([net_sales_amount]) / {SUM([net_sales_amount])}
```

#### Store Percent of Total
```tableau
// Store sales as percentage of total
{FIXED [store_key]: SUM([net_sales_amount])} / {SUM([net_sales_amount])}
```

#### SKU Percent of Total
```tableau
// SKU sales as percentage of total
{FIXED [sku_key]: SUM([net_sales_amount])} / {SUM([net_sales_amount])}
```

### Time-Based Comparisons

#### Year-over-Year Sales Growth
```tableau
// Sales growth vs. same period last year
(SUM([net_sales_amount]) - LOOKUP(SUM([net_sales_amount]), -12)) / 
ABS(LOOKUP(SUM([net_sales_amount]), -12))
```

#### Month-over-Month Sales Growth
```tableau
// Sales growth vs. previous month
(SUM([net_sales_amount]) - LOOKUP(SUM([net_sales_amount]), -1)) / 
ABS(LOOKUP(SUM([net_sales_amount]), -1))
```

#### Period-over-Period Growth (Parameterized)
```tableau
// Growth vs. selected period
// Create parameter [Period Offset] with values 1, 12, etc.
(SUM([net_sales_amount]) - LOOKUP(SUM([net_sales_amount]), [Period Offset])) / 
ABS(LOOKUP(SUM([net_sales_amount]), [Period Offset]))
```

### Advanced LOD Expressions

#### Top 10% SKUs by Sales
```tableau
// Flag SKUs in top 10% by sales
IF {FIXED [sku_key]: SUM([net_sales_amount])} >= 
   {FIXED : PERCENTILE({FIXED [sku_key]: SUM([net_sales_amount])}, 0.9)} 
THEN "Top 10%" ELSE "Bottom 90%" END
```

#### Store Performance vs. Average
```tableau
// Compare store sales to company average
(SUM([net_sales_amount]) - {FIXED : AVG({FIXED [store_key]: SUM([net_sales_amount])})}) / 
{FIXED : AVG({FIXED [store_key]: SUM([net_sales_amount])})}
```

#### Customer Lifetime Value (CLV) Estimate
```tableau
// Estimated CLV based on average purchase value and frequency
{FIXED [customer_key]: AVG([net_sales_amount])} * 
{FIXED [customer_key]: COUNT([order_count])} * 
12 // Assuming monthly frequency
```

#### Cohort Analysis (First Purchase Month)
```tableau
// Identify customer's first purchase month
{FIXED [customer_key]: MIN(DATETRUNC('month', [date]))}
```

---

## Date Calculations

### Date Parts
```tableau
// Year
YEAR([date])

// Quarter
"Q" + STR(DATEPART('quarter', [date])) + " " + STR(YEAR([date]))

// Month
DATEPART('month', [date])

// Month Name
DATENAME('month', [date])

// Week
DATEPART('week', [date])

// Day of Week
DATENAME('weekday', [date])
```

### Date Arithmetic
```tableau
// Days since a reference date
DATEDIFF('day', [reference_date], [date])

// Months since a reference date
DATEDIFF('month', [reference_date], [date])

// Year to Date flag
IF [date] <= TODAY() AND 
   DATETRUNC('year', [date]) = DATETRUNC('year', TODAY()) 
THEN "YTD" ELSE "Prior" END

// Quarter to Date flag
IF [date] <= TODAY() AND 
   DATETRUNC('quarter', [date]) = DATETRUNC('quarter', TODAY()) 
THEN "QTD" ELSE "Prior" END
```

### Rolling Calculations
```tableau
// 7-day rolling average sales
WINDOW_AVG(SUM([net_sales_amount]), -6, 0)

// 30-day rolling average sales
WINDOW_AVG(SUM([net_sales_amount]), -29, 0)

// 3-month rolling total
WINDOW_SUM(SUM([net_sales_amount]), -2, 0)
```

---

## Conditional Logic

### Performance Tiers
```tableau
// Categorize stores by performance
IF [Store Sales Percent of Total] >= 0.10 THEN "Top Tier"
ELSEIF [Store Sales Percent of Total] >= 0.05 THEN "Mid Tier"
ELSE "Low Tier"
END
```

### Margin Health
```tableau
// Categorize margin performance
IF [Gross Margin %] >= 0.45 THEN "Excellent"
ELSEIF [Gross Margin %] >= 0.40 THEN "Good"
ELSEIF [Gross Margin %] >= 0.35 THEN "Fair"
ELSE "Poor"
END
```

### Inventory Status
```tableau
// Categorize inventory health
IF [Days of Supply] <= 7 THEN "Critical"
ELSEIF [Days of Supply] <= 14 THEN "Low"
ELSEIF [Days of Supply] <= 30 THEN "Adequate"
ELSE "Excess"
END
```

### Labor Efficiency
```tableau
// Categorize labor productivity
IF [Sales per Labor Hour] >= 200 THEN "Excellent"
ELSEIF [Sales per Labor Hour] >= 150 THEN "Good"
ELSEIF [Sales per Labor Hour] >= 100 THEN "Fair"
ELSE "Poor"
END
```

---

## Parameter-Driven Calculations

### Dynamic Metric Selection
```tableau
// Create parameter [Selected Metric] with values: Net Sales, Gross Margin, Labor Productivity
// Then use this calculated field:
CASE [Selected Metric]
    WHEN 'Net Sales' THEN SUM([net_sales_amount])
    WHEN 'Gross Margin' THEN [Gross Margin %]
    WHEN 'Labor Productivity' THEN [Sales per Labor Hour]
    WHEN 'In-Stock Rate' THEN [In-Stock Rate]
END
```

### Dynamic Date Range
```tableau
// Create parameters [Start Date] and [End Date]
// Then filter using:
[date] >= [Start Date] AND [date] <= [End Date]
```

### Dynamic Comparison Period
```tableau
// Create parameter [Comparison Type] with values: Prior Year, Prior Month, Prior Quarter
// Then use:
CASE [Comparison Type]
    WHEN 'Prior Year' THEN LOOKUP(SUM([net_sales_amount]), -12)
    WHEN 'Prior Month' THEN LOOKUP(SUM([net_sales_amount]), -1)
    WHEN 'Prior Quarter' THEN LOOKUP(SUM([net_sales_amount]), -3)
END
```

---

## Reconciliation Calculations

### Sales vs. GL Variance
```tableau
// Variance between operational sales and finance GL
[Operational Sales] - [GL Sales]
```

### Sales vs. GL Variance Percentage
```tableau
// Variance as percentage
([Operational Sales] - [GL Sales]) / [GL Sales]
```

### Variance Status
```tableau
// Categorize variance based on tolerance
IF ABS([Sales vs. GL Variance %]) <= 0.01 THEN "Within Tolerance"
ELSEIF ABS([Sales vs. GL Variance %]) <= 0.05 THEN "Warning"
ELSE "Critical"
END
```

### Data Quality Score
```tableau
// Calculate overall data quality score
// Assuming you have pass/fail flags for various checks
(
    IF [Completeness Check] = "Pass" THEN 1 ELSE 0 END +
    IF [Uniqueness Check] = "Pass" THEN 1 ELSE 0 END +
    IF [Validity Check] = "Pass" THEN 1 ELSE 0 END +
    IF [Reconciliation Check] = "Pass" THEN 1 ELSE 0 END
) / 4
```

---

## Advanced Analytics

### Pareto Analysis (80/20 Rule)
```tableau
// Calculate cumulative percentage of sales
RUNNING_SUM(SUM([net_sales_amount])) / TOTAL(SUM([net_sales_amount]))
```

### ABC Analysis
```tableau
// Classify SKUs by revenue contribution (ABC analysis)
IF {FIXED [sku_key]: SUM([net_sales_amount])} / 
   {SUM([net_sales_amount])} >= 0.70 THEN "A"
ELSEIF {FIXED [sku_key]: SUM([net_sales_amount])} / 
   {SUM([net_sales_amount])} >= 0.90 THEN "B"
ELSE "C"
END
```

### Moving Average
```tableau
// Simple moving average
WINDOW_AVG(SUM([net_sales_amount]), -[Window Size] + 1, 0)
```

### Exponential Smoothing
```tableau
// Simple exponential smoothing
// Create parameter [Alpha] (smoothing factor, 0-1)
[Alpha] * SUM([net_sales_amount]) + 
(1 - [Alpha]) * LOOKUP(SUM([net_sales_amount]), -1)
```

### Seasonality Detection
```tableau
// Compare current period to same period last year
(SUM([net_sales_amount]) - {FIXED DATETRUNC('month', [date]): AVG([net_sales_amount])}) / 
{FIXED DATETRUNC('month', [date]): AVG([net_sales_amount])}
```

---

## Formatting Calculations

### Currency Formatting
```tableau
// Format as currency with 2 decimal places
// Use Tableau's default formatting, or:
STR(CURRENCY(ROUND([Net Sales], 2)))
```

### Percentage Formatting
```tableau
// Format as percentage
// Use Tableau's default formatting, or:
STR(ROUND([Gross Margin %] * 100, 1)) + "%"
```

### Number Formatting
```tableau
// Format with thousands separator
// Use Tableau's default formatting, or:
STR(ROUND([Net Sales], 0))
```

---

## Security and Row-Level Filtering

### User-Specific Data Access
```tableau
// Filter data based on user (requires USER function)
// Create calculated field:
[store_key] = [USER_STORE_KEY]
// Then use as data source filter
```

### Region-Based Filtering
```tableau
// Filter to specific regions
// Create parameter [User Region]
// Then use calculated field:
[region] = [User Region] OR [User Region] = "All"
```

---

## Performance Optimization

### Context Filters
```tableau
// Use context filters for high-cardinality dimensions
// Right-click filter → "Add to Context"
// This improves performance for LOD expressions
```

### Fixed LOD for Performance
```tableau
// Use FIXED LODs instead of table calculations when possible
// FIXED LODs are computed at data source level, improving performance
{FIXED [store_key]: SUM([net_sales_amount])}
```

### Avoid Nested Calculations
```tableau
// Break complex calculations into simpler steps
// Instead of:
SUM([net_sales_amount]) / SUM([labor_hours]) / SUM([headcount])
// Use:
[Sales per Labor Hour] / [Headcount]
// Where [Sales per Labor Hour] is a separate calculated field
```

---

## Testing and Validation

### Calculation Validation
```tableau
// Test that calculated field matches expected value
IF [Calculated Field] = [Expected Value] THEN "Pass" ELSE "Fail" END
```

### Null Check
```tableau
// Identify null values
IF ISNULL([Field]) THEN "Null" ELSE "Valid" END
```

### Range Check
```tableau
// Validate that values are within expected range
IF [Value] >= [Min Expected] AND [Value] <= [Max Expected] 
THEN "In Range" ELSE "Out of Range" END
```

---

## Best Practices

1. **Use Descriptive Names:** Name calculated fields clearly (e.g., `Gross Margin %` not `calc1`)
2. **Document Complex Logic:** Add comments in calculated field editor
3. **Test Incrementally:** Build complex calculations step by step
4. **Use LOD Expressions Appropriately:** FIXED for independent aggregates, INCLUDE/EXCLUDE for view-dependent
5. **Optimize Performance:** Use context filters and FIXED LODs for better performance
6. **Format Appropriately:** Use Tableau's formatting instead of string conversion where possible
7. **Handle Nulls:** Use IFNULL or ZN functions to handle null values gracefully
8. **Validate Against Source:** Compare Tableau calculations with SQL results for accuracy

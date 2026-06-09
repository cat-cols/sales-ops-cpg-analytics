# Project 1 Data Pipeline - End-to-End Visualization

## Overview
This document visualizes the complete data pipeline for Project 1 (Ops Command Center), from messy source extracts to actionable business insights. This demonstrates the full business analyst capability stack.

---

## High-Level Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           MESSY SOURCE EXTRACTS                                     │
│  Sales CSVs, Inventory Spreadsheets, Labor Reports, Finance Files                   │
│  Issues: Inconsistent formats, missing values, duplicates, grain misalignment       │
│  Volume: Multiple files, 5K-50K rows each, manual reconciliation required           │
└────────────────────────────┬────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        DATA GENERATION LAYER                                        │
│  Python Scripts + Shared Seeds → Realistic Synthetic Data with Quality Issues       │
│  Input: shared/seeds/*.csv (products, locations, channels, calendar)                │
│  Process: generate_project1_data.py → make_sales_data(), make_inventory_data()      │
│  Output: data/sample/*.csv (sales_sample.csv, inventory_sample.csv, etc.)           │
│  Volume: ~10K sales rows, ~4K inventory rows, ~2K labor rows                        │
│  Quality: 5% missing values, 2% duplicates, 1% out-of-range dates (mess injectors)  │
└────────────────────────────┬────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                      STANDARDIZATION LAYER                                          │
│  Column Renaming → Data Type Conversion → Quality Checks → Grain Alignment          │
│  Input: data/sample/*.csv (raw generated data)                                      │
│  Process:                                                                           │
│    - Rename: transaction_date → transaction_date (standard format)                  │
│    - Convert: text → numeric for amounts, text → date for dates                     │
│    - Validate: remove duplicates, handle missing values, check ranges               │
│    - Align: ensure daily grain for all fact tables                                  │
│  Output: data/sample/*.csv (cleaned, typed, validated)                              │
│  Quality: 100% complete, consistent data types, proper grain                        │
└────────────────────────────┬────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         SEMANTIC MODEL (STAR SCHEMA)                                │
│  Fact Tables (Sales, Inventory, Labor) + Dimensions (Date, Product, Location)       │
│  Input: data/sample/*.csv (cleaned data)                                            │
│  Process:                                                                           │
│    - Load: Load CSVs into Power BI Desktop                                          │
│    - Relate: Create 1:* relationships (DimDate → FactSales, etc.)                   │
│    - Mark: Mark DimDate as date table                                               │
│    - Configure: Set cross-filter direction to Single                                │
│  Output: Star schema model with 3 facts + 4 dimensions                              │
│  Relationships: 7 total (3 per fact table, shared dimensions)                       │
│  Performance: Optimized for fast queries (star schema benefits)                     │
└────────────────────────────┬────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           DAX MEASURES LAYER                                        │
│  Foundation Measures → Domain Measures → Business Logic Measures                    │
│  Input: Semantic Model (tables + relationships)                                     │
│  Process:                                                                           │
│    - Foundation: Volume Units, Net Sales, COGS $, Gross Margin $                    │
│    - Pricing: VWAP, Discount Rate, Price per mg THC                                 │
│    - Distribution: Active Accounts, Rate of Sale, Unit Velocity                     │
│    - Inventory: DOH, Turnover, In-Stock %, Stockout Rate                            │
│    - Customer: Account Concentration, Retention %, Revenue Share                    │
│  Output: 30+ reusable measures organized by domain                                  │
│  Files: dax_metrics_sales.md, dax_metrics_inventory.md, etc.                        │
│  Performance: CALCULATE for filtering, DIVIDE for safe division                     │
└────────────────────────────┬────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        POWER BI VISUALIZATION LAYER                                 │
│  KPI Cards → Trend Charts → Matrix Visuals → Conditional Formatting                 │
│  Input: Measures + Dimensions from semantic model                                   │
│  Process:                                                                           │
│    - Page 1: Executive Overview (5 KPI cards, 3 trend charts, 1 matrix)             │
│    - Page 2: Sales Performance (VWAP analysis, product mix, promo metrics)          │
│    - Page 3: Inventory Operations (DOH, turnover, stockout analysis)                │
│    - Page 4: Customer Analytics (concentration, retention, account growth)          │
│    - Interactivity: Slicers, cross-filtering, drill-through                         │
│  Output: 4-page interactive Power BI report                                         │
│  Visuals: 35+ visuals across all pages                                              │
│  Interactivity: 3 global slicers, page-specific slicers, drill-through navigation   │
└────────────────────────────┬────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          BUSINESS INSIGHTS                                          │
│  Pattern Recognition → Root Cause Analysis → Actionable Recommendations             │
│  Input: Power BI visualizations + business context                                  │
│  Process:                                                                           │
│    - Analyze: Identify patterns in trends, outliers, concentrations                 │
│    - Diagnose: Root cause analysis (why is margin declining?)                       │
│    - Recommend: Actionable insights with quantified impact                          │
│  Output: Strategic business recommendations                                         │
│  Examples: Pricing optimization, inventory rebalancing, account diversification     │
│  Impact: Quantified business value (e.g., "+$50K monthly margin")                   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Stage 1: Messy Source Extracts

### What They Look Like

**Sales Extract (Example):**
```
File: sales_export_202401.xlsx
Columns: Date, Store, SKU, Qty, Price, Discount, Net, COGS
Issues:
- Inconsistent date formats (MM/DD/YYYY vs DD-MM-YYYY)
- Missing values in discount column
- Duplicate rows
- Store names not standardized ("Portland Store" vs "PDX Store")
```

**Inventory Extract (Example):**
```
File: inventory_snapshot_jan.xlsx
Columns: Date, Product, Location, OnHand, Received, Shipped
Issues:
- Daily snapshots mixed with weekly
- Negative inventory values
- Missing dates for weekends
- Product codes don't match sales system
```

**Labor Extract (Example):**
```
File: labor_hours_jan.csv
Columns: Date, Store, Team, Hours, Headcount, Cost
Issues:
- Hours stored as text ("8.5" vs "8:30")
- Missing cost data for contractors
- Team names inconsistent ("Sales" vs "Sales Team")
- Some dates missing entirely
```

### Business Problem
- Data lives in silos (different systems, formats, owners)
- No single source of truth
- Manual reconciliation required
- Slow time-to-insight (days to weeks)
- High risk of errors

---

## Stage 2: Data Generation Layer

### Python Script Architecture

```
generate_project1_data.py
│
├─ Configuration
│  ├─ Date range: 2024-01-01 to 2024-12-31
│  ├─ Seed values for reproducibility
│  └─ Business rules (seasonality, promo patterns)
│
├─ Shared Seed Loading
│  ├─ shared/seeds/product_seed.csv (15 SKUs)
│  ├─ shared/seeds/location_seed.csv (8 states)
│  ├─ shared/seeds/channel_seed.csv (3 channels)
│  └─ shared/seeds/calendar_seed.csv (date dimensions)
│
├─ Data Generation Functions
│  ├─ make_sales_data() → sales_sample.csv
│  ├─ make_inventory_data() → inventory_sample.csv
│  ├─ make_labor_data() → labor_sample.csv
│  └─ make_finance_data() → finance_sample.csv
│
└─ "Mess Injectors"
   ├─ Add missing values (5% of rows)
   ├─ Add duplicates (2% of rows)
   ├─ Add out-of-range dates (1% of rows)
   └─ Add inconsistent formats (3% of rows)
```

### Output: Standardized Sample Data

**After Generation:**
```
sales_sample.csv
- Consistent date format: YYYY-MM-DD
- Standardized store codes: OR001, WA002, etc.
- Clean numeric columns (no text in number fields)
- Proper decimal precision (2 decimal places for currency)
```

### Business Value
- Reproducible data generation (same seed = same data)
- Consistent across projects (shared seeds)
- Realistic data quality issues (mess injectors)
- Scalable (can generate any date range)

---

## Stage 3: Standardization Layer

### Data Cleaning Process

```
Raw Sample Data
│
├─ Column Standardization
│  ├─ Rename columns to snake_case
│  ├─ Standardize date formats
│  └─ Convert data types (text → numeric, etc.)
│
├─ Data Quality Checks
│  ├─ Remove duplicates
│  ├─ Handle missing values (impute or flag)
│  ├─ Validate ranges (negative values, etc.)
│  └─ Check referential integrity
│
└─ Grain Alignment
   ├─ Ensure daily grain for sales
   ├─ Ensure daily snapshots for inventory
   └─ Ensure daily grain for labor
```

### Output: Clean Data Tables

**Dimension Tables:**
```
dim_date_sample.csv
- date_key, full_date, year, month, quarter, week_start
- One row per date (365 rows for 2024)
- Marked as date table in Power BI

dim_product_sample.csv
- product_sku, product_name, cannabinoid_family, flavor
- One row per product (15 rows)
- Standardized product attributes

dim_location_sample.csv
- state_code, state_name, location_type
- One row per state (8 rows)
- Geographic hierarchy

dim_channel_sample.csv
- channel, channel_description
- One row per channel (3 rows)
- Sales channel taxonomy
```

**Fact Tables:**
```
sales_sample.csv
- transaction_id, transaction_date, product_sku, state_code, channel
- units_sold, gross_sales_amount, discount_amount, net_sales_amount, cogs_amount
- ~10K rows (transaction-level grain)

inventory_sample.csv
- snapshot_date, product_sku, state_code, on_hand_units, in_stock_flag
- ~4K rows (daily snapshot grain)

labor_sample.csv
- labor_date, state_code, team_name, labor_hours, headcount, labor_cost_amount
- ~2K rows (daily grain)
```

### Business Value
- Single source of truth
- Consistent data definitions
- Fast query performance
- Ready for semantic modeling

---

## Stage 4: Semantic Model (Star Schema)

### Model Architecture

```
                    ┌──────────────┐
                    │   DimDate    │
                    │  (365 rows)  │
                    └──────┬───────┘
                           │
                           │ 1:*
          ┌────────────────┼────────────────┐
          │                │                │
    ┌─────▼──────┐  ┌─────▼──────┐  ┌─────▼──────┐
    │  FactSales │  │FactInventory│  │  FactLabor │
    │ (10K rows) │  │  (4K rows)  │  │  (2K rows) │
    └─────┬──────┘  └─────┬──────┘  └─────┬──────┘
          │                │                │
          │ *:1            │ *:1            │ *:1
    ┌─────▼──────┐  ┌─────▼──────┐  ┌─────▼──────┐
    │ DimProduct │  │DimLocation │  │DimChannel  │
    │  (15 rows) │  │  (8 rows)  │  │  (3 rows)  │
    └────────────┘  └────────────┘  └────────────┘
```

### Relationship Definitions

**FactSales Relationships:**
- `FactSales[transaction_date]` → `DimDate[full_date]` (1:*)
- `FactSales[product_sku]` → `DimProduct[product_sku]` (1:*)
- `FactSales[state_code]` → `DimLocation[state_code]` (1:*)
- `FactSales[channel]` → `DimChannel[channel]` (1:*)

**FactInventory Relationships:**
- `FactInventory[snapshot_date]` → `DimDate[full_date]` (1:*)
- `FactInventory[product_sku]` → `DimProduct[product_sku]` (1:*)
- `FactInventory[state_code]` → `DimLocation[state_code]` (1:*)

**FactLabor Relationships:**
- `FactLabor[labor_date]` → `DimDate[full_date]` (1:*)
- `FactLabor[state_code]` → `DimLocation[state_code]` (1:*)
- `FactLabor[team_name]` → `DimEmployeeGroup[team_name]` (1:*)

### Business Value
- Fast query performance (star schema optimization)
- Consistent filtering (dimension-based)
- Reusable across reports
- Scalable to larger datasets

---

## Stage 5: DAX Measures Layer

### Measure Organization

```
Measures (by Domain)
│
├─ Foundation Measures (dax_metrics_sales.md)
│  ├─ Volume Units = SUM(FactSales[units_sold])
│  ├─ Gross Sales = SUM(FactSales[gross_sales_amount])
│  ├─ Net Sales = SUM(FactSales[net_sales_amount])
│  ├─ COGS $ = SUM(FactSales[cogs_amount])
│  ├─ Gross Margin $ = [Net Sales] - [COGS $]
│  └─ Gross Margin % = DIVIDE([Gross Margin $], [Net Sales])
│
├─ Pricing Measures (dax_metrics_sales.md)
│  ├─ Gross VWAP = DIVIDE([Gross Sales], [Volume Units])
│  ├─ Net VWAP = DIVIDE([Net Sales], [Volume Units])
│  ├─ VWAP Delta = [Gross VWAP] - [Net VWAP]
│  ├─ Discount Rate = DIVIDE([Discount $], [Gross Sales])
│  └─ Price per mg THC = DIVIDE([Net Sales], [Total THC mg])
│
├─ Distribution Measures (dax_metrics_sales.md)
│  ├─ Active Accounts = DISTINCTCOUNT(FactSales[state_code])
│  ├─ Rate of Sale = DIVIDE([Volume Units], [Active Accounts])
│  └─ Unit Velocity = DIVIDE([Volume Units], [Active Accounts] * [Weeks])
│
├─ Inventory Measures (dax_metrics_inventory.md)
│  ├─ Inventory On Hand = SUM(FactInventory[on_hand_units])
│  ├─ Days of Inventory = DIVIDE([On Hand], [Avg Daily Sales])
│  ├─ Inventory Turnover = DIVIDE([Volume Units], [Avg Inventory])
│  ├─ In-Stock % = DIVIDE([In-Stock Observations], [Total Observations])
│  └─ Stockout Rate % = 1 - [In-Stock %]
│
└─ Customer Measures (dax_metrics_customer.md)
   ├─ Account Revenue Share = DIVIDE([Net Sales], [Total Net Sales])
   ├─ Top 10 Accounts % = DIVIDE([Top 10 Sales], [Total Sales])
   ├─ Account Retention % = DIVIDE([Retained Accounts], [Prior Accounts])
   └─ Repeat Purchase Rate = DIVIDE([Repeat Customers], [Total Customers])
```

### Measure Dependencies

```
Foundation Measures
│
├─ Volume Units
│  └─ Used by: VWAP, Rate of Sale, Unit Velocity, Turnover
│
├─ Net Sales
│  ├─ Used by: Gross Margin $, Gross Margin %, VWAP, Revenue Share
│  └─ Dependent on: Volume Units (for VWAP)
│
└─ Gross Margin $
   ├─ Used by: Gross Margin %, Margin per mg
   └─ Dependent on: Net Sales, COGS $
```

### Business Value
- Reusable business logic
- Consistent calculations across visuals
- Single source of truth for metrics
- Easy to maintain and update

---

## Stage 6: Power BI Visualization Layer

### Report Architecture

```
Althea Ops Command Center (Power BI Report)
│
├─ Page 1: Executive Overview
│  ├─ KPI Cards: Net Sales, Gross Margin, Units, VWAP, Active Accounts
│  ├─ Revenue Trend Chart (Line)
│  ├─ Margin Trend Chart (Line with threshold)
│  ├─ Volume Trend Chart (Column by product family)
│  └─ State Performance Matrix (Conditional formatting)
│
├─ Page 2: Sales & Revenue Performance
│  ├─ KPI Cards: VWAP, Discount Rate, Promo Lift
│  ├─ VWAP Trend Chart (Line)
│  ├─ Product Mix Donut Chart
│  ├─ Price/Volume/Mix Decomposition (Stacked column)
│  └─ Channel Performance (Stacked column)
│
├─ Page 3: Inventory & Operations
│  ├─ KPI Cards: DOH, Turnover, In-Stock %, Stockout Rate
│  ├─ Inventory Trend Chart (Line by state)
│  ├─ DOH Trend Chart (Line with thresholds)
│  ├─ Aging Inventory Distribution (Stacked column)
│  └─ Inventory Health Score (Gauge)
│
└─ Page 4: Customer & Account Analytics
   ├─ KPI Cards: Account Concentration, Retention %
   ├─ Concentration Trend Chart (Line with threshold)
   ├─ Top Accounts Table (With conditional formatting)
   ├─ Account Growth vs Dependency (Scatter plot)
   └─ Account Lifecycle (Donut chart)
```

### Interactivity Flow

```
User Action: Select "Oregon" in State Slicer
│
├─ Filters Applied:
│  ├─ All KPI cards update to Oregon values
│  ├─ All charts filter to Oregon data
│  ├─ Matrix shows Oregon-only rows
│  └─ Measures recalculate with Oregon context
│
├─ Cross-Filtering:
│  ├─ Click on "CBN" in product mix → Filters other visuals to CBN products
│  ├─ Click on "Retail" in channel → Filters to retail channel only
│  └─ Click on specific month → Filters to that month across all visuals
│
└─ Drill-Through:
   ├─ Click on state → Navigate to State Detail page
   ├─ Click on product → Navigate to Product Detail page
   └─ Click on account → Navigate to Account Detail page
```

### Business Value
- Self-service analytics
- Fast time-to-insight (seconds vs days)
- Interactive exploration
- Clear visual hierarchy

---

## Stage 7: Business Insights

### Insight Generation Process

```
Power BI Visualizations
│
├─ Pattern Recognition
│  ├─ Revenue trending up in Oregon (+15% MoM)
│  ├─ Margin declining in California (32% → 28%)
│  ├─ Stockout rate elevated in Washington (12% vs 5% target)
│  └─ Account concentration increasing (45% → 52%)
│
├─ Root Cause Analysis
│  ├─ Oregon growth driven by CBN gummies mix shift
│  ├─ California margin decline from promo intensity
│  ├─ Washington stockouts from THC product shortages
│  └─ Concentration from 2 large account wins
│
└─ Actionable Recommendations
   ├─ Pricing: Increase CBN prices by 5% (demand inelastic)
   ├─ Inventory: Increase THC safety stock in Washington
   ├─ Promo: Reduce promo frequency in California
   └─ Sales: Diversify account base in top 3 states
```

### Example Insights

**Insight 1: Pricing Opportunity**
```
Observation: CBN gummies have 40% higher VWAP than THC gummies
Analysis: CBN demand is inelastic (sleep aid category)
Recommendation: Increase CBN prices by 5-7%
Expected Impact: +$50K monthly margin with minimal volume impact
```

**Insight 2: Inventory Risk**
```
Observation: Washington stockout rate at 12% (target: 5%)
Analysis: THC products understocked, CBN overstocked
Recommendation: Rebalance safety stock by product family
Expected Impact: Reduce lost sales by $30K monthly
```

**Insight 3: Account Concentration**
```
Observation: Top 10 accounts now 52% of revenue (target: 40%)
Analysis: 2 new large distributor wins in Q1
Recommendation: Accelerate small account acquisition program
Expected Impact: Reduce concentration risk, improve resilience
```

### Business Value
- Data-driven decision making
- Proactive vs reactive management
- Quantified impact estimates
- Clear action plans

---

## Complete Pipeline Summary

### Before Pipeline
- **Time to Insight**: 5-7 days
- **Data Quality**: Low (manual errors)
- **Consistency**: Low (different definitions)
- **Scalability**: Low (manual processes)
- **Trust**: Low (reconciliation required)

### After Pipeline
- **Time to Insight**: Seconds (interactive)
- **Data Quality**: High (automated validation)
- **Consistency**: High (standardized definitions)
- **Scalability**: High (automated processes)
- **Trust**: High (single source of truth)

### Business Analyst Capabilities Demonstrated

1. **Data Engineering**: Python data generation, standardization
2. **Data Modeling**: Star schema design, relationship management
3. **Business Logic**: DAX measure development
4. **Visualization**: Power BI report design
5. **Analysis**: Pattern recognition, root cause analysis
6. **Communication**: Actionable recommendations

### Portfolio Value

This pipeline demonstrates you're not just a "report builder" but a **full-stack business analyst** who can:
- Understand messy source data
- Build scalable data infrastructure
- Translate business requirements into technical solutions
- Deliver actionable insights
- Drive business decisions

This is the type of end-to-end capability that hiring managers in business analyst roles are looking for.

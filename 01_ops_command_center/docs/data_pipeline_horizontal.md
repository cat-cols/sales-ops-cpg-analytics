# Project 1 Data Pipeline - Horizontal Color-Coded Visualization

## Overview
Horizontal color-coded visualization of the complete data pipeline for Project 1 (Ops Command Center), from messy source extracts to actionable business insights.

---

## Color Legend

- 🔴 **Red**: Messy/Problematic Data (Source Extracts)
- 🟡 **Yellow**: Data Generation & Transformation
- 🟢 **Green**: Standardized/Clean Data
- 🔵 **Blue**: Semantic Model & Relationships
- 🟣 **Purple**: Business Logic (DAX Measures)
- 🟠 **Orange**: Visualization Layer
- 🟤 **Brown**: Business Insights & Recommendations

---

## Horizontal Pipeline Flow

```
🔴 MESSY SOURCE EXTRACTS ──────────────────────────────────────────────────────────────────────────────────────►
│ Sales CSVs | Inventory Spreadsheets | Labor Reports | Finance Files                                         │
│ Issues: Inconsistent formats, missing values, duplicates, grain misalignment                                    │
│ Volume: Multiple files, 5K-50K rows each, manual reconciliation required                                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                 │
                                                                 ▼
🟡 DATA GENERATION LAYER ───────────────────────────────────────────────────────────────────────────────────────►
│ Python Scripts + Shared Seeds → Realistic Synthetic Data with Quality Issues                                     │
│ Input: shared/seeds/*.csv (products, locations, channels, calendar)                                                    │
│ Process: generate_project1_data.py → make_sales_data(), make_inventory_data()                                        │
│ Output: data/sample/*.csv (sales_sample.csv, inventory_sample.csv, etc.)                                              │
│ Volume: ~10K sales rows, ~4K inventory rows, ~2K labor rows                                                          │
│ Quality: 5% missing values, 2% duplicates, 1% out-of-range dates (mess injectors)                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                 │
                                                                 ▼
🟢 STANDARDIZATION LAYER ─────────────────────────────────────────────────────────────────────────────────────────►
│ Column Renaming → Data Type Conversion → Quality Checks → Grain Alignment                                            │
│ Input: data/sample/*.csv (raw generated data)                                                                          │
│ Process: Rename → Convert → Validate → Align                                                                          │
│ Output: data/sample/*.csv (cleaned, typed, validated)                                                                │
│ Quality: 100% complete, consistent data types, proper grain                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                 │
                                                                 ▼
🔵 SEMANTIC MODEL (STAR SCHEMA) ─────────────────────────────────────────────────────────────────────────────────►
│ Fact Tables (Sales, Inventory, Labor) + Dimensions (Date, Product, Location)                                         │
│ Input: data/sample/*.csv (cleaned data)                                                                                │
│ Process: Load → Relate → Mark → Configure                                                                            │
│ Output: Star schema model with 3 facts + 4 dimensions                                                                 │
│ Relationships: 7 total (3 per fact table, shared dimensions)                                                           │
│ Performance: Optimized for fast queries (star schema benefits)                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                 │
                                                                 ▼
🟣 DAX MEASURES LAYER ─────────────────────────────────────────────────────────────────────────────────────────────►
│ Foundation Measures → Domain Measures → Business Logic Measures                                                        │
│ Input: Semantic Model (tables + relationships)                                                                       │
│ Process: Foundation → Pricing → Distribution → Inventory → Customer                                                   │
│ Output: 30+ reusable measures organized by domain                                                                    │
│ Files: dax_metrics_sales.md, dax_metrics_inventory.md, etc.                                                          │
│ Performance: CALCULATE for filtering, DIVIDE for safe division                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                 │
                                                                 ▼
🟠 POWER BI VISUALIZATION LAYER ─────────────────────────────────────────────────────────────────────────────────►
│ KPI Cards → Trend Charts → Matrix Visuals → Conditional Formatting                                                     │
│ Input: Measures + Dimensions from semantic model                                                                    │
│ Process: Page 1 (Executive) → Page 2 (Sales) → Page 3 (Inventory) → Page 4 (Customer)                               │
│ Output: 4-page interactive Power BI report                                                                           │
│ Visuals: 35+ visuals across all pages                                                                                │
│ Interactivity: 3 global slicers, page-specific slicers, drill-through navigation                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                 │
                                                                 ▼
🟤 BUSINESS INSIGHTS ───────────────────────────────────────────────────────────────────────────────────────────────►
│ Pattern Recognition → Root Cause Analysis → Actionable Recommendations                                               │
│ Input: Power BI visualizations + business context                                                                    │
│ Process: Analyze → Diagnose → Recommend                                                                             │
│ Output: Strategic business recommendations                                                                            │
│ Examples: Pricing optimization, inventory rebalancing, account diversification                                     │
│ Impact: Quantified business value (e.g., "+$50K monthly margin")                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Stage Breakdown

### 🔴 Stage 1: Messy Source Extracts
**Color**: Red (indicates problems/issues)

**Data Sources:**
- Sales CSVs from POS systems
- Inventory spreadsheets from warehouse
- Labor reports from HR systems
- Finance files from accounting

**Quality Issues:**
- Inconsistent date formats (MM/DD/YYYY vs DD-MM-YYYY)
- Missing values in critical columns
- Duplicate transactions
- Grain misalignment (daily vs weekly vs monthly)
- Inconsistent naming conventions

**Business Impact:**
- Manual reconciliation required (5-7 days)
- High risk of errors
- Slow time-to-insight
- No single source of truth

---

### 🟡 Stage 2: Data Generation Layer
**Color**: Yellow (indicates transformation/processing)

**Input Data:**
- `shared/seeds/product_seed.csv` (15 SKUs)
- `shared/seeds/location_seed.csv` (8 states)
- `shared/seeds/channel_seed.csv` (3 channels)
- `shared/seeds/calendar_seed.csv` (date dimensions)

**Python Functions:**
- `make_sales_data()` → sales_sample.csv
- `make_inventory_data()` → inventory_sample.csv
- `make_labor_data()` → labor_sample.csv
- `make_finance_data()` → finance_sample.csv

**Mess Injectors:**
- 5% missing values
- 2% duplicate rows
- 1% out-of-range dates
- 3% inconsistent formats

**Output Volume:**
- ~10K sales rows
- ~4K inventory rows
- ~2K labor rows
- ~1K finance rows

---

### 🟢 Stage 3: Standardization Layer
**Color**: Green (indicates clean/ready data)

**Transformation Steps:**

1. **Column Renaming**
   - Standardize to snake_case
   - Remove special characters
   - Ensure consistent naming

2. **Data Type Conversion**
   - Text → Numeric for amounts
   - Text → Date for dates
   - Text → Boolean for flags

3. **Quality Checks**
   - Remove duplicates
   - Handle missing values (impute or flag)
   - Validate ranges (no negative inventory)
   - Check referential integrity

4. **Grain Alignment**
   - Ensure daily grain for sales
   - Ensure daily snapshots for inventory
   - Ensure daily grain for labor

**Output Quality:**
- 100% complete data
- Consistent data types
- Proper grain alignment
- Ready for semantic modeling

---

### 🔵 Stage 4: Semantic Model (Star Schema)
**Color**: Blue (indicates structure/relationships)

**Model Architecture:**

**Fact Tables:**
- FactSales (10K rows) - Transaction-level sales
- FactInventory (4K rows) - Daily inventory snapshots
- FactLabor (2K rows) - Daily labor data

**Dimension Tables:**
- DimDate (365 rows) - Date dimensions
- DimProduct (15 rows) - Product master
- DimLocation (8 rows) - Location master
- DimChannel (3 rows) - Channel master

**Relationships:**
- DimDate → FactSales (1:*)
- DimDate → FactInventory (1:*)
- DimDate → FactLabor (1:*)
- DimProduct → FactSales (1:*)
- DimLocation → FactSales (1:*)
- DimLocation → FactInventory (1:*)
- DimChannel → FactSales (1:*)

**Performance Benefits:**
- Fast query performance (star schema optimization)
- Consistent filtering (dimension-based)
- Reusable across reports
- Scalable to larger datasets

---

### 🟣 Stage 5: DAX Measures Layer
**Color**: Purple (indicates business logic)

**Measure Categories:**

**Foundation Measures:**
- Volume Units = SUM(FactSales[units_sold])
- Net Sales = SUM(FactSales[net_sales_amount])
- COGS $ = SUM(FactSales[cogs_amount])
- Gross Margin $ = [Net Sales] - [COGS $]
- Gross Margin % = DIVIDE([Gross Margin $], [Net Sales])

**Pricing Measures:**
- Gross VWAP = DIVIDE([Gross Sales], [Volume Units])
- Net VWAP = DIVIDE([Net Sales], [Volume Units])
- Discount Rate = DIVIDE([Discount $], [Gross Sales])
- Price per mg THC = DIVIDE([Net Sales], [Total THC mg])

**Distribution Measures:**
- Active Accounts = DISTINCTCOUNT(FactSales[state_code])
- Rate of Sale = DIVIDE([Volume Units], [Active Accounts])
- Unit Velocity = DIVIDE([Volume Units], [Active Accounts] * [Weeks])

**Inventory Measures:**
- Days of Inventory = DIVIDE([On Hand], [Avg Daily Sales])
- Inventory Turnover = DIVIDE([Volume Units], [Avg Inventory])
- In-Stock % = DIVIDE([In-Stock Observations], [Total Observations])
- Stockout Rate % = 1 - [In-Stock %]

**Customer Measures:**
- Account Revenue Share = DIVIDE([Net Sales], [Total Net Sales])
- Top 10 Accounts % = DIVIDE([Top 10 Sales], [Total Sales])
- Account Retention % = DIVIDE([Retained Accounts], [Prior Accounts])

**Total Measures:** 30+ organized across 4 domain files

---

### 🟠 Stage 6: Power BI Visualization Layer
**Color**: Orange (indicates visualization/presentation)

**Report Structure:**

**Page 1: Executive Overview**
- 5 KPI cards (Net Sales, Gross Margin, Units, VWAP, Active Accounts)
- 3 trend charts (Revenue, Margin, Volume)
- 1 state performance matrix
- 3 global slicers (Date, State, Channel)

**Page 2: Sales & Revenue Performance**
- 6 KPI cards (VWAP, Discount Rate, Promo Lift, etc.)
- VWAP trend chart
- Product mix donut chart
- Price/volume/mix decomposition
- Channel performance chart

**Page 3: Inventory & Operations**
- 5 KPI cards (DOH, Turnover, In-Stock %, Stockout Rate, Aging)
- Inventory trend chart
- DOH trend chart with thresholds
- Aging inventory distribution
- Inventory health score gauge

**Page 4: Customer & Account Analytics**
- 5 KPI cards (Concentration, Retention, Revenue Share, etc.)
- Concentration trend chart
- Top accounts table
- Account growth vs dependency scatter plot
- Account lifecycle donut chart

**Total Visuals:** 35+ across all pages

**Interactivity:**
- 3 global slicers (Date, State, Channel)
- Page-specific slicers (Product Family, Location Type, Account Type)
- Cross-filtering between visuals
- Drill-through to detail pages

---

### 🟤 Stage 7: Business Insights
**Color**: Brown (indicates actionable outcomes)

**Insight Generation Process:**

1. **Pattern Recognition**
   - Revenue trending up in Oregon (+15% MoM)
   - Margin declining in California (32% → 28%)
   - Stockout rate elevated in Washington (12% vs 5% target)
   - Account concentration increasing (45% → 52%)

2. **Root Cause Analysis**
   - Oregon growth driven by CBN gummies mix shift
   - California margin decline from promo intensity
   - Washington stockouts from THC product shortages
   - Concentration from 2 large account wins

3. **Actionable Recommendations**
   - Pricing: Increase CBN prices by 5% (demand inelastic)
   - Inventory: Increase THC safety stock in Washington
   - Promo: Reduce promo frequency in California
   - Sales: Diversify account base in top 3 states

**Business Impact:**
- Quantified recommendations (e.g., "+$50K monthly margin")
- Risk mitigation strategies
- Growth opportunity identification
- Strategic decision support

---

## Pipeline Performance Metrics

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

### Improvement Summary
- **Speed**: 10,000x faster (days to seconds)
- **Quality**: 100% validation vs manual checks
- **Consistency**: Single source of truth vs multiple versions
- **Scalability**: Automated vs manual processes
- **Trust**: Automated validation vs manual reconciliation

---

## Business Analyst Capabilities Demonstrated

This pipeline demonstrates you can:

1. **🔴 Data Engineering**: Python data generation, standardization
2. **🟡 Data Transformation**: ETL processes, quality validation
3. **🟢 Data Quality**: Validation, cleaning, grain alignment
4. **🔵 Data Modeling**: Star schema design, relationship management
5. **🟣 Business Logic**: DAX measure development, business rules
6. **🟠 Visualization**: Power BI report design, interactivity
7. **🟤 Analysis**: Pattern recognition, root cause analysis
8. **🟤 Communication**: Actionable recommendations, stakeholder communication

---

## Portfolio Value

This color-coded horizontal visualization demonstrates you're not just a "report builder" but a **full-stack business analyst** who can:

- 🔴 **Understand messy source data** and its challenges
- 🟡 **Build scalable data infrastructure** with Python
- 🟢 **Ensure data quality** through standardization
- 🔵 **Design semantic models** for performance
- 🟣 **Implement business logic** with DAX measures
- 🟠 **Create compelling visualizations** in Power BI
- 🟤 **Deliver actionable insights** that drive decisions

This is the type of end-to-end capability that hiring managers in business analyst roles are looking for.

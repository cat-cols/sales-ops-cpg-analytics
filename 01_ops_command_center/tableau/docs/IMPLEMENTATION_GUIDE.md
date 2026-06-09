# Tableau Implementation Guide — Ops Command Center

**Project:** 01_ops_command_center  
**BI Platform:** Tableau Desktop / Tableau Public  
**Data Source:** PostgreSQL mart views  
**Purpose:** Demonstrate BI dashboarding capability with cross-platform tool

---

## Why Tableau for This Portfolio

**Platform Advantages:**
- Cross-platform compatibility (works on Mac)
- Strong data visualization capabilities
- Widely recognized in analytics roles
- Tableau Public for free portfolio hosting
- Calculated fields and LOD expressions demonstrate analytical thinking

**Strategic Approach:**
- Build actual Tableau dashboards (unlike Power BI planning-only)
- Keep Power BI semantic model documentation (shows platform versatility)
- Demonstrate SQL → Tableau data modeling
- Compare implementation approaches between platforms

---

## Data Source Architecture

### PostgreSQL Connection

**Connection Details:**
- **Database:** `wyld_chyld` (or your local Postgres instance)
- **Schema:** `mart`
- **Authentication:** Environment variable or credentials file
- **Connection Type:** PostgreSQL native driver

**Data Sources:**

| Table | Purpose | Grain | Key Fields |
|-------|---------|-------|------------|
| `mart.fact_sales_daily` | Sales transactions | Daily × Store × SKU × Channel | date_key, store_key, sku_key, channel_key |
| `mart.fact_inventory_snapshot_daily` | Inventory levels | Daily × Store × SKU | date_key, store_key, sku_key |
| `mart.fact_labor_daily` | Labor metrics | Daily × Store × Employee Group | date_key, store_key, employee_group_key |
| `mart.fact_actuals_monthly` | Finance actuals | Monthly × Metric | month_start, metric_name |
| `mart.dim_date` | Date dimension | Date | date_key, date, month, quarter, year |
| `mart.dim_store` | Store/location dimension | Store | store_key, store_name, region, store_type |
| `mart.dim_sku` | Product dimension | SKU | sku_key, sku_name, category, brand |
| `mart.dim_employee` | Employee dimension | Employee | employee_key, employee_name, store_key, role |
| `mart.kpi_gross_margin_daily` | Gross margin KPI | Daily × Store × SKU | date_key, store_key, sku_key |
| `mart.kpi_sales_per_labor_hour_daily` | Labor productivity KPI | Daily × Store | date_key, store_key |
| `mart.kpi_instock_rate_daily` | Inventory health KPI | Daily × Store × SKU | date_key, store_key, sku_key |
| `mart.recon_sales_to_gl_monthly` | Finance reconciliation | Monthly | month_start, metric_name |
| `mart.recon_sales_distributor_vs_pos` | Source reconciliation | Daily | date_key |

### Tableau Data Source Structure

**Single Data Source vs. Multiple:**
- **Recommended:** Single data source with relationships (Tableau 2020.4+)
- **Alternative:** Multiple data sources with blends (legacy approach)

**Relationship Model:**
```
fact_sales_daily ──┬── dim_date
                   ├── dim_store
                   ├── dim_sku
                   ├── dim_channel (if exists)
                   └── kpi_gross_margin_daily

fact_inventory_snapshot_daily ──┬── dim_date
                               ├── dim_store
                               └── dim_sku

fact_labor_daily ──┬── dim_date
                  ├── dim_store
                  └── dim_employee

fact_actuals_monthly ── dim_date (at month level)
```

---

## Workbook Structure

### Dashboard Organization

**Workbook:** `ops_command_center.twb`

**Sheets (Logical Order):**

1. **Data Source Setup**
   - Connection to PostgreSQL
   - Relationship definitions
   - Initial data validation

2. **Executive Overview**
   - Key KPI cards (Net Sales, Gross Margin %, Labor Productivity, In-Stock Rate)
   - Trend charts (Sales trend, Margin trend, Labor trend)
   - Performance by store (bar chart, map if location data available)
   - Trust indicators (reconciliation status, data quality flags)

3. **Sales & Margin Analysis**
   - Sales by channel (stacked bar chart)
   - Sales by store (horizontal bar chart with target lines)
   - Margin trend over time (line chart with reference lines)
   - Discount impact analysis (scatter plot: discount rate vs. margin)
   - Top/bottom performing SKUs (bar chart)

4. **Inventory & Operations**
   - In-stock rate by store (heat map or bar chart)
   - Days of supply trend (line chart)
   - Inventory vs. sales correlation (scatter plot)
   - Stockout risk by SKU (highlight table)
   - Shipment volume trend (line chart)

5. **Labor & Productivity**
   - Labor hours by store (bar chart)
   - Sales per labor hour (scatter plot: labor hours vs. sales)
   - Labor cost trend (line chart with budget reference)
   - Staffing efficiency (calculated field: actual vs. optimal)
   - Employee productivity ranking (table)

6. **Reconciliation & Data Health**
   - Sales vs. GL variance (bar chart with tolerance lines)
   - Data quality scorecard (highlight table)
   - Missing dimension joins (text table or KPI card)
   - Freshness indicators (status indicators)
   - Control pass/fail summary (big number display)

7. **Detail Drillthrough**
   - Store detail page (all metrics for selected store)
   - SKU detail page (all metrics for selected SKU)
   - Date detail page (daily breakdown for selected date)

### Calculated Fields

**Core Calculations:**

```tableau
// Net Sales
SUM([net_sales_amount])

// Gross Margin %
(SUM([net_sales_amount]) - SUM([cogs_amount])) / SUM([net_sales_amount])

// Sales per Labor Hour
SUM([net_sales_amount]) / SUM([labor_hours])

// In-Stock Rate
AVG(IF [on_hand_units] > 0 THEN 1 ELSE 0 END)

// Days of Supply
AVG([on_hand_units]) / AVG([daily_demand])

// Discount Rate
SUM([discount_amount]) / SUM([gross_sales_amount])

// Variance vs. Target
[Actual] - [Target]

// Variance % vs. Target
([Actual] - [Target]) / [Target]
```

**LOD Expressions (Level of Detail):**

```tableau
// Store Average Sales (for comparison)
{FIXED [store_key]: AVG([net_sales_amount])}

// Percent of Total Sales
SUM([net_sales_amount]) / {SUM([net_sales_amount])}

// Year-over-Year Sales Growth
(SUM([net_sales_amount]) - LOOKUP(SUM([net_sales_amount]), -12)) / 
ABS(LOOKUP(SUM([net_sales_amount]), -12))

// Store Rank by Sales
RANK(SUM([net_sales_amount]))

// Top 10 SKUs by Sales
IF {FIXED [sku_key]: SUM([net_sales_amount])} >= 
   {FIXED : PERCENTILE({FIXED [sku_key]: SUM([net_sales_amount])}, 0.9)} 
THEN "Top 10%" ELSE "Bottom 90%" END
```

**Parameter Controls:**

```tableau
// Date Range Parameter
[Date Range Start] (date parameter)
[Date Range End] (date parameter)

// Store Selection Parameter
[Selected Store] (store parameter with "All" option)

// Metric Selection Parameter
[Selected KPI] (KPI parameter for dynamic views)

// Target Comparison
[Target Type] (parameter: Budget, Prior Year, Forecast)
```

---

## Dashboard Design Principles

### Visual Best Practices

**Color Palette:**
- Primary: #2E86AB (blue)
- Secondary: #A23B72 (purple)
- Success: #28A745 (green)
- Warning: #FFC107 (yellow)
- Danger: #DC3545 (red)
- Neutral: #6C757D (gray)

**Layout Guidelines:**
- KPI cards at top (4-6 key metrics)
- Trend charts below KPIs (time-series analysis)
- Comparison charts (store-to-store, period-to-period)
- Detail tables at bottom or on separate sheets
- Consistent sizing and alignment
- White space for readability

**Interactivity:**
- Filter actions (store, SKU, date range)
- Highlight actions (click to highlight across dashboard)
- Tooltip enhancements (contextual information)
- Parameter controls for dynamic analysis
- Drill-through to detail pages

### Performance Optimization

**Data Source Optimization:**
- Use extracts instead of live connections for better performance
- Schedule extract refreshes (if using Tableau Server/Online)
- Filter data at source (date filters, active stores only)
- Use data source filters to reduce row count

**Calculation Optimization:**
- Prefer LOD expressions over table calculations where appropriate
- Use FIXED LODs for aggregation-independent calculations
- Avoid complex nested calculations
- Use context filters to improve performance

**Visual Optimization:**
- Limit number of marks (avoid over-plotting)
- Use extract filters for large datasets
- Optimize data source queries
- Use data blending only when necessary

---

## Implementation Steps

### Phase 1: Data Source Setup (1-2 hours)

1. **Install Tableau Desktop** (trial version available)
2. **Connect to PostgreSQL**
   - Install PostgreSQL driver for Tableau
   - Test connection to `wyld_chyld` database
   - Verify access to `mart` schema

3. **Build Data Source**
   - Add fact tables (sales, inventory, labor, actuals)
   - Add dimension tables (date, store, SKU, employee)
   - Add KPI tables (gross margin, labor productivity, in-stock rate)
   - Add reconciliation tables
   - Define relationships between tables

4. **Validate Data**
   - Check row counts match expectations
   - Verify joins are working correctly
   - Test calculated fields
   - Confirm date ranges are correct

### Phase 2: Executive Overview (2-3 hours)

1. **Create KPI Cards**
   - Net Sales (big number with trend indicator)
   - Gross Margin % (big number with target comparison)
   - Sales per Labor Hour (big number with trend)
   - In-Stock Rate (big number with target)

2. **Add Trend Charts**
   - Sales trend (line chart, daily/weekly/monthly)
   - Margin trend (line chart with reference line)
   - Labor productivity trend (line chart)

3. **Add Performance Views**
   - Sales by store (bar chart, sorted)
   - Regional performance (if region data available)
   - Channel performance (stacked bar)

4. **Add Trust Indicators**
   - Reconciliation status (text table or KPI cards)
   - Data quality score (big number with color coding)
   - Freshness indicator (status text)

### Phase 3: Detailed Analysis Dashboards (4-6 hours)

1. **Sales & Margin Dashboard**
   - Channel analysis
   - Store performance with targets
   - Margin trend and drivers
   - Discount impact analysis
   - SKU performance ranking

2. **Inventory & Operations Dashboard**
   - In-stock rate by store
   - Days of supply analysis
   - Stockout risk identification
   - Shipment volume trends

3. **Labor & Productivity Dashboard**
   - Labor hours by store
   - Sales per labor hour scatter
   - Labor cost vs. budget
   - Staffing efficiency analysis

4. **Reconciliation & Data Health Dashboard**
   - Sales vs. GL variance
   - Data quality scorecard
   - Missing dimension joins
   - Control pass/fail summary

### Phase 4: Interactivity & Polish (2-3 hours)

1. **Add Filters**
   - Date range filter
   - Store selector
   - Category/brand filters
   - Channel filters

2. **Add Actions**
   - Filter actions (click store to filter all views)
   - Highlight actions (click SKU to highlight across dashboards)
   - Go to URL actions (drill-through to detail pages)

3. **Add Parameters**
   - Date range parameters
   - Metric selection parameters
   - Target comparison parameters

4. **Polish Design**
   - Apply consistent color palette
   - Add titles and descriptions
   - Format tooltips
   - Add context (reference lines, annotations)
   - Test user flows

### Phase 5: Documentation & Publishing (1-2 hours)

1. **Create Documentation**
   - Dashboard user guide
   - Data source documentation
   - Calculated field reference
   - Parameter usage guide

2. **Publish to Tableau Public**
   - Create Tableau Public account
   - Publish workbook
   - Set permissions and description
   - Test embedded views

3. **Update Repository**
   - Add screenshots to README
   - Document implementation approach
   - Add Tableau-specific files to repo
   - Update tech stack documentation

---

## File Structure

```
01_ops_command_center/
├── tableau/
│   ├── IMPLEMENTATION_GUIDE.md          # This file
│   ├── DATA_SOURCE_GUIDE.md            # Data source setup instructions
│   ├── DASHBOARD_GUIDE.md               # Dashboard user guide
│   ├── CALCULATED_FIELDS.md            # Reference for all calculated fields
│   ├── ops_command_center.twb           # Tableau workbook file
│   ├── ops_command_center.tds           # Tableau data source file (optional)
│   ├── extracts/                        # Tableau extract files (if using extracts)
│   └── screenshots/                     # Dashboard screenshots for documentation
│       ├── executive_overview.png
│       ├── sales_margin.png
│       ├── inventory_ops.png
│       └── labor_productivity.png
```

---

## Comparison: Tableau vs. Power BI Implementation

### Data Modeling

**Power BI Approach:**
- Semantic model with star schema
- DAX measures for calculations
- Managed relationships in data model
- Row-level security via roles

**Tableau Approach:**
- Relationships in data source (Tableau 2020.4+)
- Calculated fields and LOD expressions
- Context filters for security
- Data source filters for row-level filtering

### Calculations

**Power BI (DAX):**
```dax
// Gross Margin %
DIVIDE(
    SUM(fact_sales[net_sales_amount]) - SUM(fact_sales[cogs_amount]),
    SUM(fact_sales[net_sales_amount])
)
```

**Tableau (Calculated Field):**
```tableau
// Gross Margin %
(SUM([net_sales_amount]) - SUM([cogs_amount])) / SUM([net_sales_amount])
```

### Interactivity

**Power BI:**
- Slicers for filtering
- Cross-filtering by default
- Bookmarks for views
- Drill-through pages

**Tableau:**
- Filters and quick filters
- Actions (filter, highlight, URL)
- Parameters for dynamic analysis
- Dashboard navigation

### Strengths by Platform

**Tableau Strengths:**
- Superior data visualization capabilities
- Flexible calculation engine (LOD expressions)
- Better for exploratory analysis
- Strong community and resources

**Power BI Strengths:**
- Better integration with Microsoft ecosystem
- Free Desktop version
- Strong in corporate/enterprise environments
- DAX is powerful for complex calculations

---

## Next Steps

1. **Install Tableau Desktop** (trial version)
2. **Set up PostgreSQL connection**
3. **Build data source with relationships**
4. **Create Executive Overview dashboard**
5. **Add detailed analysis dashboards**
6. **Publish to Tableau Public**
7. **Update repository documentation**

---

## Resources

**Tableau Learning:**
- Tableau Desktop Training: https://www.tableau.com/learn/training
- Tableau Public Gallery: https://public.tableau.com/
- Tableau Community: https://community.tableau.com/

**Data Visualization Best Practices:**
- Stephen Few's books on data visualization
- Edward Tufte's principles
- Tableau "Whitepaper" on visual best practices

**Portfolio Integration:**
- Link Tableau Public profile in README
- Embed dashboards in documentation
- Include screenshots in executive summary
- Document calculation logic for transparency

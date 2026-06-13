# Dashboard Guide — Executive Overview & Reconciliation

**Project:** 01_ops_command_center
**Dashboards:** Executive Overview, Reconciliation & Data Health
**Platform:** Tableau Desktop / Tableau Public
**Data Source:** PostgreSQL mart views

---

># Executive Overview Dashboard

### Purpose

The Executive Overview dashboard provides leadership with a single, trusted view of business performance across Sales, Operations, Labor, and Finance. It demonstrates the ability to translate complex cross-functional data into actionable business insights.

### Business Questions Answered

- How is the business performing overall?
- Are we hitting our key financial targets?
- Where are the performance outliers?
- Can we trust the data behind these numbers?
- What trends should we investigate further?

### KPI Cards

#### Net Sales
**Definition:** Total net sales amount after discounts and returns
**Grain:** Daily, aggregatable to weekly/monthly
**Source:** `mart.fact_sales_daily.net_sales_amount`
**Calculation:** `SUM([net_sales_amount])`
**Display:** Big number with:
- Current period value
- Period-over-period growth (WoW, MoM, YoY)
- Trend indicator (up/down arrow with color)
- Comparison to target (if available)

#### Gross Margin %
**Definition:** (Net Sales - COGS) / Net Sales
**Grain:** Daily, aggregatable to weekly/monthly
**Source:** `mart.kpi_gross_margin_daily`
**Calculation:** `(SUM([net_sales_amount]) - SUM([cogs_amount])) / SUM([net_sales_amount])`
**Display:** Big number with:
- Current period value
- Target comparison (reference line)
- Variance from target (absolute and percentage)
- Color coding (green = above target, red = below)

#### Sales per Labor Hour
**Definition:** Net Sales / Total Labor Hours
**Grain:** Daily by store
**Source:** `mart.kpi_sales_per_labor_hour_daily`
**Calculation:** `SUM([net_sales_amount]) / SUM([labor_hours])`
**Display:** Big number with:
- Current period value
- Trend over time
- Store-level comparison (bar chart below)
- Efficiency ranking

#### In-Stock Rate
**Definition:** Percentage of SKUs with on-hand inventory > 0
**Grain:** Daily by store/SKU
**Source:** `mart.kpi_instock_rate_daily`
**Calculation:** `AVG(IF [on_hand_units] > 0 THEN 1 ELSE 0 END)`
**Display:** Big number with:
- Current period value
- Target (typically 95%+)
- Store-level heat map
- Stockout risk indicator

### Trend Charts

#### Sales Trend
**Type:** Line chart  
**X-Axis:** Date (daily/weekly/monthly)  
**Y-Axis:** Net Sales  
**Features:**
- Multiple lines: Gross Sales, Net Sales, Target
- Reference lines for budget/forecast
- Tooltip with detailed breakdown
- Color coding by channel (B2B, Direct, Sell-through)
- Annotation for significant events

#### Margin Trend
**Type:** Line chart  
**X-Axis:** Date (daily/weekly/monthly)  
**Y-Axis:** Gross Margin %  
**Features:**
- Margin trend over time
- Reference line for target margin
- Band for acceptable variance range
- Tooltip with COGS breakdown
- Channel comparison (small multiples)

#### Labor Productivity Trend
**Type:** Line chart  
**X-Axis:** Date (daily/weekly/monthly)  
**Y-Axis:** Sales per Labor Hour  
**Features:**
- Productivity trend
- Store comparison (highlight selected store)
- Seasonal pattern identification
- Labor cost trend (dual-axis)

### Performance Views

#### Sales by Store
**Type:** Horizontal bar chart  
**Dimensions:** Store (y-axis), Net Sales (x-axis)  
**Features:**
- Sorted by sales (descending)
- Color coding by region
- Target line (if available)
- Tooltip with store details
- Click to filter other views

#### Channel Performance
**Type:** Stacked bar chart  
**Dimensions:** Date (x-axis), Sales (y-axis), Channel (color)  
**Channels:** B2B, Direct, Sell-through  
**Features:**
- Channel contribution over time
- Channel growth rates
- Mix shift analysis
- Tooltip with channel-specific metrics

### Trust Indicators

#### Reconciliation Status
**Type:** KPI card or small table  
**Source:** `mart.recon_sales_to_gl_monthly`  
**Display:**
- Overall reconciliation status (Pass/Fail)
- Variance percentage (with tolerance band)
- Last reconciliation date
- Number of open exceptions
- Color coding: Green (pass), Yellow (warning), Red (fail)

#### Data Quality Score
**Type:** Big number with gauge  
**Source:** `mart.controls_rowcounts_daily`, `mart.controls_missing_dim_joins`  
**Calculation:** Weighted score based on:
- Row count freshness
- Missing dimension joins
- Null key violations
- Grain uniqueness  
**Display:**
- Overall score (0-100)
- Score trend over time
- Breakdown by category
- Color coding: Green (>90), Yellow (70-90), Red (<70)

#### Freshness Indicator
**Type:** Status text with timestamp  
**Source:** System metadata or max date in fact tables  
**Display:**
- Last data update timestamp
- Data age (hours/days since last update)
- Expected update frequency
- Status indicator (current/stale)

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│                    EXECUTIVE OVERVIEW                        │
├─────────────────────────────────────────────────────────────┤
│  [Net Sales]  [Gross Margin %]  [Sales/Labor Hr]  [In-Stock]│
│  $1.2M ↑5%     42% ↓2%            $850/hr ↑3%        94% ✓   │
├─────────────────────────────────────────────────────────────┤
│  Sales Trend              Margin Trend              Labor    │
│  [Line Chart]             [Line Chart]             [Line]    │
├─────────────────────────────────────────────────────────────┤
│  Sales by Store           Channel Performance              │
│  [Bar Chart]              [Stacked Bar]                    │
├─────────────────────────────────────────────────────────────┤
│  Reconciliation: PASS    Data Quality: 92%    Fresh: 2hr   │
└─────────────────────────────────────────────────────────────┘
```

### Interactivity

**Filters:**
- Date range (last 7 days, 30 days, 90 days, YTD, custom)
- Store selector (All, specific stores, region)
- Channel filter (All, B2B, Direct, Sell-through)
- Category/brand filter (if applicable)

**Actions:**
- Click store in bar chart → filter all views to that store
- Click channel in stacked bar → highlight that channel across dashboard
- Click date in trend chart → show detail for that date
- Hover over KPI cards → show detailed breakdown

**Parameters:**
- Date range start/end
- Comparison period (prior year, prior month)
- Target type (budget, forecast, prior year)

---

## Reconciliation & Data Health Dashboard

### Purpose

The Reconciliation & Data Health dashboard demonstrates technical rigor and data governance discipline. It proves that modeled numbers are trustworthy by showing reconciliation status, data quality controls, and pipeline health indicators.

### Business Questions Answered

- Do our modeled numbers agree with finance actuals?
- Are there data quality issues we need to address?
- Is our data pipeline running correctly?
- What are the current data trust issues?
- When was the last successful data refresh?

### Sales vs. GL Variance

#### Variance Chart
**Type:** Bar chart with tolerance lines  
**X-Axis:** Month  
**Y-Axis:** Variance % (modeled vs. actual)  
**Source:** `mart.recon_sales_to_gl_monthly`  
**Metrics:**
- Net Sales variance
- Gross Sales variance
- COGS variance
- Gross Margin variance  
**Features:**
- Green zone: within ±2% tolerance
- Yellow zone: ±2% to ±5% tolerance
- Red zone: > ±5% variance
- Reference lines at tolerance thresholds
- Tooltip with absolute variance amounts
- Color coding by variance severity

#### Variance Detail Table
**Type:** Text table  
**Columns:** Month, Metric, Modeled, Actual, Variance $, Variance %, Status  
**Features:**
- Sortable by any column
- Conditional formatting on variance %
- Drill-through to detail level
- Export capability
- Status indicators (Pass/Fail/Warning)

### Data Quality Scorecard

#### Overall Score
**Type:** Gauge or big number  
**Source:** Aggregated from multiple control tables  
**Calculation:** Weighted average of:
- Completeness (40%)
- Uniqueness (20%)
- Validity (20%)
- Freshness (10%)
- Reconciliation (10%)  
**Display:**
- Overall score (0-100)
- Score trend (sparkline)
- Target score (typically 95+)
- Color coding based on score bands

#### Category Breakdown
**Type:** Bar chart or bullet chart  
**Categories:** Completeness, Uniqueness, Validity, Freshness, Reconciliation  
**Features:**
- Score per category
- Target per category
- Trend over time
- Drill-through to detailed checks

#### Detailed Checks Table
**Type:** Highlight table  
**Source:** `mart.controls_rowcounts_daily`, `mart.controls_missing_dim_joins`  
**Columns:** Check Name, Table, Expected, Actual, Status, Last Run  
**Features:**
- Color coding: Green (pass), Yellow (warning), Red (fail)
- Sort by status or last run
- Click to see check details
- Filter by table or check type

### Missing Dimension Joins

#### Missing Joins Summary
**Type:** KPI card or small bar chart  
**Source:** `mart.controls_missing_dim_joins`  
**Display:**
- Total missing joins count
- Trend over time
- Breakdown by fact table
- Most affected dimensions

#### Missing Joins Detail
**Type:** Text table  
**Columns:** Fact Table, Dimension Table, Missing Count, % Missing, Impact  
**Features:**
- Sort by missing count or impact
- Filter by fact table
- Color coding by severity
- Recommended action per row

### Freshness Indicators

#### Data Freshness Status
**Type:** Status indicator table  
**Source:** System metadata or max dates in fact tables  
**Columns:** Source/Table, Last Update, Expected Update, Age, Status  
**Features:**
- Color coding: Green (fresh), Yellow (stale), Red (critical)
- Age calculation (current time - last update)
- Expected update frequency
- Alert if age > threshold

#### Freshness Trend
**Type:** Line chart  
**X-Axis:** Date  
**Y-Axis:** Data age (hours)  
**Features:**
- Freshness trend over time
- Reference line for SLA
- Multiple lines for different sources
- Annotation for incidents

### Control Pass/Fail Summary

#### Overall Status
**Type:** Big number with status indicator  
**Display:**
- Total controls: X
- Passed: Y
- Failed: Z
- Warning: W  
**Color coding:** Green (all pass), Yellow (warnings), Red (failures)

#### Control Results by Category
**Type:** Stacked bar chart  
**Categories:** INT checks, MART checks, Dimension checks, Recon checks  
**Features:**
- Pass/Fail/Warning breakdown
- Trend over time
- Filter by category
- Drill-through to specific checks

#### Failed Controls Detail
**Type:** Text table  
**Columns:** Control Name, Category, Last Result, Expected, Actual, Error Message  
**Features:**
- Filter to show only failed controls
- Sort by last failure time
- Click to see control definition
- Export for troubleshooting

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│              RECONCILIATION & DATA HEALTH                   │
├─────────────────────────────────────────────────────────────┤
│  Sales vs. GL Variance          Data Quality Score          │
│  [Bar Chart with Tolerance]     [Gauge: 92%]                │
├─────────────────────────────────────────────────────────────┤
│  Variance Detail Table          Category Breakdown           │
│  [Text Table]                   [Bar Chart]                  │
├─────────────────────────────────────────────────────────────┤
│  Missing Joins Summary          Freshness Indicators        │
│  [KPI Cards]                    [Status Table]              │
├─────────────────────────────────────────────────────────────┤
│  Control Pass/Fail Summary      Failed Controls Detail       │
│  [Big Number]                   [Text Table]                │
└─────────────────────────────────────────────────────────────┘
```

### Interactivity

**Filters:**
- Date range (month, quarter, YTD)
- Metric type (sales, margin, inventory, labor)
- Table/filter (specific fact tables)
- Status filter (pass, fail, warning)

**Actions:**
- Click variance bar → show detailed breakdown for that month
- Click check in scorecard → show check definition and history
- Click missing join → show affected records
- Hover over status → see detailed error message

**Parameters:**
- Tolerance threshold (adjustable)
- Freshness SLA (hours)
- Score target (adjustable)
- Date range for trend analysis

---

## Implementation Steps

### Executive Overview

**Phase 1: KPI Cards (30 minutes)**
1. Create calculated fields for each KPI
2. Build KPI card sheets (4 sheets)
3. Add trend indicators (table calculations or LODs)
4. Add target comparisons
5. Format with consistent styling

**Phase 2: Trend Charts (45 minutes)**
1. Create line chart sheets (3 sheets)
2. Add reference lines for targets
3. Add color coding by channel
4. Configure tooltips
5. Add annotations for key events

**Phase 3: Performance Views (30 minutes)**
1. Create sales by store bar chart
2. Create channel performance stacked bar
3. Add sorting and filtering
4. Configure drill-through actions

**Phase 4: Trust Indicators (30 minutes)**
1. Create reconciliation status sheet
2. Create data quality score sheet
3. Create freshness indicator
4. Add color coding and status logic

**Phase 5: Dashboard Assembly (30 minutes)**
1. Create dashboard layout
2. Add all sheets
3. Configure filters and actions
4. Add parameters
5. Test interactivity
6. Polish formatting

### Reconciliation & Data Health

**Phase 1: Variance Analysis (45 minutes)**
1. Create variance bar chart
2. Add tolerance reference lines
3. Create variance detail table
4. Add conditional formatting
5. Configure drill-through

**Phase 2: Data Quality Scorecard (45 minutes)**
1. Create overall score calculation
2. Create gauge or big number
3. Create category breakdown chart
4. Create detailed checks table
5. Add color coding logic

**Phase 3: Missing Joins (30 minutes)**
1. Create missing joins summary
2. Create missing joins detail table
3. Add impact analysis
4. Configure filtering

**Phase 4: Freshness Monitoring (30 minutes)**
1. Create freshness status table
2. Create freshness trend chart
3. Add SLA reference lines
4. Configure alert logic

**Phase 5: Control Summary (30 minutes)**
1. Create overall status display
2. Create control results by category
3. Create failed controls detail
4. Add drill-through to control definitions

**Phase 6: Dashboard Assembly (30 minutes)**
1. Create dashboard layout
2. Add all sheets
3. Configure filters and actions
4. Add parameters
5. Test interactivity
6. Polish formatting

---

## Calculated Fields Reference

### Executive Overview

```tableau
// Net Sales
[Net Sales] = SUM([net_sales_amount])

// Net Sales WoW Growth
[Net Sales WoW] = 
(SUM([net_sales_amount]) - LOOKUP(SUM([net_sales_amount]), -1)) / 
ABS(LOOKUP(SUM([net_sales_amount]), -1))

// Gross Margin %
[Gross Margin %] = 
(SUM([net_sales_amount]) - SUM([cogs_amount])) / SUM([net_sales_amount])

// Gross Margin Variance vs Target
[GM Variance %] = [Gross Margin %] - [Target GM %]

// Sales per Labor Hour
[Sales per Labor Hour] = 
SUM([net_sales_amount]) / SUM([labor_hours])

// In-Stock Rate
[In-Stock Rate] = 
AVG(IF [on_hand_units] > 0 THEN 1 ELSE 0 END)

// Reconciliation Status
[Recon Status] = 
IF ABS([Variance %]) <= 0.02 THEN "PASS"
ELSEIF ABS([Variance %]) <= 0.05 THEN "WARNING"
ELSE "FAIL" END

// Data Quality Score
[DQ Score] = 
0.40 * [Completeness Score] +
0.20 * [Uniqueness Score] +
0.20 * [Validity Score] +
0.10 * [Freshness Score] +
0.10 * [Reconciliation Score]
```

### Reconciliation & Data Health

```tableau
// Variance %
[Variance %] = 
([Modeled Value] - [Actual Value]) / [Actual Value]

// Variance Status
[Variance Status] = 
IF ABS([Variance %]) <= [Tolerance %] THEN "PASS"
ELSEIF ABS([Variance %]) <= [Warning Threshold %] THEN "WARNING"
ELSE "FAIL" END

// Data Age (Hours)
[Data Age Hours] = 
DATEDIFF('hour', [Last Update], NOW())

// Freshness Status
[Freshness Status] = 
IF [Data Age Hours] <= [SLA Hours] THEN "FRESH"
ELSEIF [Data Age Hours] <= [Warning Hours] THEN "STALE"
ELSE "CRITICAL" END

// Missing Joins %
[Missing Joins %] = 
[Missing Join Count] / [Total Record Count]

// Control Pass Rate
[Control Pass Rate] = 
[Passed Controls] / [Total Controls]

// Overall Health Status
[Overall Status] = 
IF [DQ Score] >= 95 AND [Control Pass Rate] = 1 THEN "HEALTHY"
ELSEIF [DQ Score] >= 80 AND [Control Pass Rate] >= 0.9 THEN "WARNING"
ELSE "CRITICAL" END
```

---

## Best Practices

### Design Principles

**Color Consistency:**
- Green: Pass, healthy, within tolerance
- Yellow: Warning, attention needed
- Red: Fail, critical, action required
- Blue: Neutral information
- Gray: Reference/context

**Layout:**
- KPI cards at top (left to right by priority)
- Trend charts below KPIs
- Detail views at bottom
- Consistent spacing and alignment
- White space for readability

**Typography:**
- Clear, readable fonts
- Consistent sizing hierarchy
- Bold for key metrics
- Italic for secondary information
- Color for emphasis (not as primary indicator)

### Performance Optimization

**Data Source:**
- Use extracts for better performance
- Schedule extract refreshes
- Filter data at source (date filters)
- Use context filters for performance

**Calculations:**
- Prefer LOD expressions over table calculations
- Use FIXED LODs for aggregation-independent calculations
- Avoid complex nested calculations
- Use data source filters to reduce row count

**Visuals:**
- Limit number of marks (avoid over-plotting)
- Use extract filters for large datasets
- Optimize data source queries
- Use data blending only when necessary

### User Experience

**Filters:**
- Provide sensible defaults
- Group related filters
- Use filter actions for interactivity
- Show filter counts

**Tooltips:**
- Include context and explanation
- Show relevant metrics
- Add calculated fields for insights
- Format for readability

**Actions:**
- Make interactions discoverable
- Provide clear visual feedback
- Use consistent action patterns
- Test user flows

---

## Testing Checklist

### Executive Overview

**KPI Cards:**
- [ ] Values match SQL mart queries
- [ ] Trend indicators calculate correctly
- [ ] Target comparisons work
- [ ] Color coding is correct
- [ ] Tooltips show expected information

**Trend Charts:**
- [ ] Date ranges filter correctly
- [ ] Reference lines display properly
- [ ] Color coding by channel works
- [ ] Tooltips show detailed breakdown
- [ ] Annotations display correctly

**Performance Views:**
- [ ] Sorting works as expected
- [ ] Filtering updates all views
- [ ] Drill-through actions work
- [ ] Color coding is consistent
- [ ] Export functionality works

**Trust Indicators:**
- [ ] Reconciliation status updates correctly
- [ ] Data quality score calculates accurately
- [ ] Freshness indicator shows current status
- [ ] Color coding reflects actual status
- [ ] Status logic is correct

### Reconciliation & Data Health

**Variance Analysis:**
- [ ] Variance calculations match SQL
- [ ] Tolerance lines display correctly
- [ ] Color coding reflects variance severity
- [ ] Detail table shows correct data
- [ ] Drill-through works

**Data Quality Scorecard:**
- [ ] Overall score calculates correctly
- [ ] Category breakdown is accurate
- [ ] Trend shows correct history
- [ ] Detail table shows all checks
- [ ] Color coding is correct

**Missing Joins:**
- [ ] Summary shows correct counts
- [ ] Detail table shows affected records
- [ ] Impact analysis is accurate
- [ ] Filtering works correctly
- [ ] Export functionality works

**Freshness Monitoring:**
- [ ] Age calculations are correct
- [ ] Status logic works as expected
- [ ] Trend shows correct history
- [ ] SLA reference lines display
- [ ] Alert logic triggers correctly

**Control Summary:**
- [ ] Overall status is accurate
- [ ] Category breakdown is correct
- [ ] Failed controls show correctly
- [ ] Drill-through to definitions works
- [ ] Export functionality works

---

## Next Steps

1. **Build Executive Overview Dashboard**
   - Follow implementation steps
   - Test against checklist
   - Document any deviations

2. **Build Reconciliation & Data Health Dashboard**
   - Follow implementation steps
   - Test against checklist
   - Document any deviations

3. **Publish to Tableau Public**
   - Create Tableau Public account
   - Publish both dashboards
   - Set permissions and descriptions
   - Test embedded views

4. **Update Documentation**
   - Add screenshots to README
   - Document implementation approach
   - Add calculated field reference
   - Update tech stack documentation

5. **Gather Feedback**
   - Share with stakeholders
   - Collect usability feedback
   - Iterate on design
   - Refine calculations

---

## Resources

**Tableau Documentation:**
- Tableau Desktop Help: https://help.tableau.com/
- Calculated Fields: https://help.tableau.com/current/pro/desktop/en-us/calculations.htm
- LOD Expressions: https://help.tableau.com/current/pro/desktop/en-us/calculations_lod.htm

**Data Visualization Best Practices:**
- Stephen Few: "Information Dashboard Design"
- Edward Tufte: "The Visual Display of Quantitative Information"
- Tableau Whitepaper: "Visual Best Practices"

**Portfolio Integration:**
- Link Tableau Public profile in README
- Embed dashboards in documentation
- Include screenshots in executive summary
- Document calculation logic for transparency

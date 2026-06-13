# Sales Performance Leaderboard Dashboard Guide

**Project:** 01_ops_command_center - Business Analyst Portfolio  
**Dashboard:** Sales Performance Leaderboard  
**Platform:** Tableau Desktop  
**Data Source:** PostgreSQL CTE (mart.vw_sales_rankings)  
**Purpose:** Real-time performance tracking and competitive benchmarking using optimized CTE

---

## Overview

This guide walks through building the Sales Performance Leaderboard Dashboard for your business analyst portfolio. This dashboard demonstrates advanced SQL CTE optimization, performance analytics, and competitive benchmarking capabilities using pre-calculated ranking metrics.

**Business Value:** Enable data-driven performance management, identify top/bottom performers, and support sales team optimization through objective performance metrics.

---

## Data Source

### Primary Data Source: mart.vw_sales_rankings

**Purpose:** Pre-calculated sales performance rankings with multiple time granularities (daily/weekly/monthly/annual) and SKU-level detail using CTE for optimized Tableau performance

**Key Fields:**
- `location_key` - Unique location identifier
- `location_name` - Business name
- `county` - County location
- `city` - City location
- `state` - State location
- `sale_date` - Date of sales (NULL for weekly/monthly/annual)
- `sale_week` - Week of sales (NULL for daily/monthly/annual)
- `sale_month` - Month of sales (NULL for daily/weekly/annual)
- `sale_year` - Year of sales
- `total_sales` - Total net sales amount (location-level)
- `total_units` - Total units sold (location-level)
- `total_cases` - Total cases sold (location-level)
- `gross_profit` - Gross profit (sales - COGS)
- `gross_margin_pct` - Gross margin percentage
- `county_rank` - Rank within county (1 = best)
- `state_rank` - Rank within state (1 = best)
- `sales_percentile` - Percentile ranking (0-1)
- `sales_decile` - Decile grouping (1-10)
- `performance_tier` - Performance categorization
- `county_position` - Position within county
- `sku` - SKU identifier (NULL for location-level rows)
- `product_name` - Product name (NULL for location-level rows)
- `pack_size` - Pack size (units per case)
- `adjusted_sku_units` - SKU units sold with variation applied
- `adjusted_sku_sales` - SKU net sales with variation applied
- `adjusted_cases_sold` - SKU cases sold (units/pack_size) with variation applied
- `location_sku_rank` - SKU rank within location/time period (1 = best)
- `county_sku_rank` - SKU rank within county/time period (1 = best)
- `data_level` - Data granularity (DAILY_LOCATION, WEEKLY_LOCATION, MONTHLY_LOCATION, ANNUAL_LOCATION, DAILY_SKU, WEEKLY_SKU, MONTHLY_SKU, ANNUAL_SKU)

**CTE Optimization Benefits:**
- Rankings pre-calculated in SQL for instant Tableau performance
- Multiple time granularities in single view for flexible analysis
- Percentile calculations done server-side
- Performance tiers pre-computed for filtering
- Case calculations with realistic variation patterns
- Eliminates complex table calculations in Tableau

---

## Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│              SALES PERFORMANCE LEADERBOARD                 │
├─────────────────────────────────────────────────────────────┤
│  [Time Granularity: Monthly ▼]  [Date Range: Jan-Dec 2024]│
│  [Top Performer: Name]  [State Rank: #5]  [Decile: Top 10%]│
│  [Total Sales: $125K]  [Gross Margin: 42%]  [Cases: 1.2K]│
├─────────────────────────────────────────────────────────────┤
│  State Performance Leaderboard (Top 20)                     │
│  [Bar Chart: Locations ranked by total_sales]              │
│  Color: performance_tier (Top/Average/Bottom)              │
├─────────────────────────────────────────────────────────────┤
│  SKU Performance Leaderboard (Top 15)                       │
│  [Bar Chart: SKUs ranked by adjusted_cases_sold]           │
│  Color: location_sku_rank, Size: adjusted_sku_sales        │
├─────────────────────────────────────────────────────────────┤
│  Performance Distribution Analysis                          │
│  [Histogram: Sales percentile distribution]                │
│  [Box Plot: Sales distribution by performance tier]        │
├─────────────────────────────────────────────────────────────┤
│  County Champions Analysis                                 │
│  [Bar Chart: Top performer in each county]                │
│  Show county_rank and county_position                      │
├─────────────────────────────────────────────────────────────┤
│  Efficiency Analysis                                       │
│  [Scatter Plot: Total Sales vs Gross Margin %]            │
│  Size: total_cases, Color: performance_tier               │
├─────────────────────────────────────────────────────────────┤
│  Time Series Trend Analysis                                │
│  [Line Chart: Sales over time by performance tier]         │
│  Show seasonal patterns and trends                         │
├─────────────────────────────────────────────────────────────┤
│  Performance Tier Breakdown                                 │
│  [Treemap: Performance tiers with location count]          │
│  [Pie Chart: Performance tier distribution]                │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Connect to Data (5 minutes)

1. **Open Tableau Desktop**
2. **Connect to PostgreSQL** (if not already connected)
3. **Add Data Source:**
   - In Data Source tab, expand `althea_ops` → `mart` schema
   - Drag `vw_sales_rankings` to the canvas
   - Verify connection shows all fields including new time granularity fields

### Step 2: Create Parameters for Interactivity (10 minutes)

1. **Create Time Granularity Parameter:**
   - Right-click in Data pane → Create Parameter
   - Name: `Time Granularity`
   - Data Type: String
   - Allowable Values: List
   - List of Values: `MONTHLY_LOCATION`, `MONTHLY_SKU`, `WEEKLY_LOCATION`, `WEEKLY_SKU`, `DAILY_LOCATION`, `DAILY_SKU`, `ANNUAL_LOCATION`, `ANNUAL_SKU`
   - Current Value: `MONTHLY_LOCATION`

2. **Create Date Range Parameters:**
   - Name: `Date Range Start` (Date type)
   - Name: `Date Range End` (Date type)
   - Set appropriate default values

### Step 3: Create Calculated Fields (10 minutes)

1. **Data Level Filter:**
   ```
   [Data Level Filter] = [data_level] = [Time Granularity]
   ```

2. **Date Filter:**
   ```
   [Date Filter] = 
   IF CONTAINS([Time Granularity], 'DAILY') THEN
       [sale_date] >= [Date Range Start] AND [sale_date] <= [Date Range End]
   ELSEIF CONTAINS([Time Granularity], 'WEEKLY') THEN
       [sale_week] >= [Date Range Start] AND [sale_week] <= [Date Range End]
   ELSEIF CONTAINS([Time Granularity], 'MONTHLY') THEN
       [sale_month] >= [Date Range Start] AND [sale_month] <= [Date Range End]
   ELSEIF CONTAINS([Time Granularity], 'ANNUAL') THEN
       [sale_year] >= YEAR([Date Range Start]) AND [sale_year] <= YEAR([Date Range End])
   END
   ```

3. **Cases Display:**
   ```
   [Cases Display] = IFNULL([adjusted_cases_sold], [total_cases])
   ```

4. **Sales Display:**
   ```
   [Sales Display] = IFNULL([adjusted_sku_sales], [total_sales])
   ```

### Step 4: Create State Leaderboard (15 minutes)

1. **Create New Sheet:** "State Leaderboard"
2. **Build Leaderboard:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Drag `location_name` to Rows
   - Drag `[Sales Display]` to Columns
   - Sort descending by `[Sales Display]`
   - Limit to top 20 locations
   - Drag `performance_tier` to Color
   - Drag `state_rank` to Tooltip
   - Drag `sales_percentile` to Tooltip
   - Drag `gross_margin_pct` to Tooltip
   - Drag `[Cases Display]` to Tooltip

3. **Enhance Visualization:**
   - Add labels to bars showing sales amounts
   - Set color palette: Green (Top Performer), Blue (Average), Red (Bottom)
   - Add reference line for average sales
   - Add title: "State Performance Leaderboard (Top 20)"

### Step 5: Create SKU Performance Leaderboard (15 minutes)

1. **Create New Sheet:** "SKU Leaderboard"
2. **Build SKU Leaderboard:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Drag `sku` to Rows
   - Drag `product_name` to Rows
   - Drag `[Cases Display]` to Columns
   - Sort descending by `[Cases Display]`
   - Limit to top 15 SKUs
   - Drag `location_sku_rank` to Color
   - Drag `pack_size` to Tooltip
   - Drag `[Sales Display]` to Tooltip
   - Drag `county_sku_rank` to Tooltip

3. **Enhance Visualization:**
   - Add labels showing cases and sales
   - Color by SKU rank (gradient from best to worst)
   - Add title: "SKU Performance Leaderboard (Top 15)"
   - Add subtitle: "By cases sold with variation applied"

### Step 6: Create Performance Distribution (15 minutes)

1. **Create New Sheet:** "Performance Distribution"
2. **Build Histogram:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Drag `sales_percentile` to Columns
   - Drag `COUNT(location_key)` to Rows
   - Change mark type to Bar
   - Drag `performance_tier` to Color
   - Add title: "Sales Percentile Distribution"

3. **Create Box Plot:**
   - Drag `performance_tier` to Columns
   - Drag `[Sales Display]` to Rows
   - Change mark type to Box Plot
   - Add title: "Sales Distribution by Performance Tier"

4. **Combine Views:**
   - Use dashboard layout to combine histogram and box plot
   - Align horizontally for comparison

### Step 7: Create County Champions (15 minutes)

1. **Create New Sheet:** "County Champions"
2. **Build County Analysis:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Drag `county` to Rows
   - Drag `[Sales Display]` to Columns
   - Drag `county_rank` to Tooltip
   - Drag `county_position` to Tooltip
   - Drag `location_name` to Tooltip
   - Sort by county_rank ascending (rank 1 first)

3. **Enhance Visualization:**
   - Filter to show only county_rank = 1 (top performers)
   - Add county labels
   - Color by county
   - Add title: "County Champions - Top Performer by County"

### Step 8: Create Efficiency Analysis (15 minutes)

1. **Create New Sheet:** "Efficiency Analysis"
2. **Build Scatter Plot:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Drag `[Sales Display]` to Columns
   - Drag `gross_margin_pct` to Rows
   - Change mark type to Circle
   - Drag `[Cases Display]` to Size
   - Drag `performance_tier` to Color
   - Drag `location_name` to Tooltip
   - Drag `county` to Tooltip

3. **Enhance Visualization:**
   - Add trend line
   - Add quadrant lines for high/low sales and margin
   - Add title: "Efficiency Analysis: Sales vs Margin"
   - Add quadrant labels: "High Sales/High Margin", etc.

### Step 9: Create Time Series Trend Analysis (15 minutes)

1. **Create New Sheet:** "Time Series Trends"
2. **Build Time Series:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Create date field based on time granularity:
     - If daily: Use `sale_date`
     - If weekly: Use `sale_week`
     - If monthly: Use `sale_month`
     - If annual: Use `sale_year`
   - Drag date field to Columns → Set to continuous
   - Drag `[Sales Display]` to Rows
   - Drag `performance_tier` to Color
   - Change mark type to Line

3. **Enhance Visualization:**
   - Add trend lines
   - Add moving average for smoothing
   - Add title: "Sales Trends Over Time"
   - Add subtitle: "By Performance Tier"

### Step 10: Create Performance Tier Breakdown (10 minutes)

1. **Create New Sheet:** "Performance Tier Breakdown"
2. **Build Treemap:**
   - Drag `[Data Level Filter]` to Filters → Set to True
   - Drag `[Date Filter]` to Filters → Set to True
   - Drag `performance_tier` to Color
   - Drag `COUNT(location_key)` to Size
   - Change mark type to Square
   - Add labels showing tier name and count
   - Add title: "Performance Tier Distribution"

3. **Create Pie Chart:**
   - Drag `performance_tier` to Color
   - Drag `COUNT(location_key)` to Angle
   - Change mark type to Pie
   - Add percentage labels
   - Add title: "Performance Tier Percentage"

### Step 11: Create KPI Cards (10 minutes)

1. **Create New Sheet:** "KPI Cards"
2. **Build KPI 1 - Top Performer:**
   - Create calculated field: `[Top Performer] = FIXED() : MAX(location_name)`
   - Filter to state_rank = 1
   - Drag location_name to Text
   - Add label: "Top Performer"

3. **Build KPI 2 - Best State Rank:**
   - Create calculated field: `[Best Rank] = FIXED() : MIN(state_rank)`
   - Drag state_rank to Text
   - Add label: "Best State Rank"

4. **Build Additional KPIs:**
   - Total Sales (SUM of `[Sales Display]`)
   - Average Gross Margin (AVG of gross_margin_pct)
   - Total Cases (SUM of `[Cases Display]`)
   - Total Units (SUM of total_units)

### Step 12: Assemble Dashboard (15 minutes)

1. **Create Dashboard:** "Sales Performance Leaderboard"
2. **Set Layout:**
   - Size: Automatic (or 1400x1000 for fixed)
   - Background: Light gray or white

3. **Add Parameter Controls:**
   - Drag `[Time Granularity]` parameter to top-left
   - Drag `[Date Range Start]` parameter to top-left
   - Drag `[Date Range End]` parameter to top-left
   - Format as compact parameter controls

4. **Add Sheets:**
   - Drag "KPI Cards" to top row (below parameters)
   - Drag "State Leaderboard" to middle-left
   - Drag "SKU Leaderboard" to middle-center
   - Drag "Performance Distribution" to middle-right
   - Drag "County Champions" to bottom-left
   - Drag "Efficiency Analysis" to bottom-center
   - Drag "Time Series Trends" to bottom-right
   - Drag "Performance Tier Breakdown" to bottom (optional)

5. **Add Filters:**
   - Drag `county` to Filters
   - Drag `performance_tier` to Filters
   - Drag `sales_decile` to Filters
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

6. **Add Interactivity:**
   - Use filter actions: Click on county in County Champions → filter other views
   - Use filter actions: Click on SKU in SKU Leaderboard → filter State Leaderboard
   - Use highlight actions: Hover over performance tier → highlight locations
   - Add tooltip enhancements
   - Add parameter actions: Button to switch between location and SKU views

7. **Add Title and Description:**
   - Dashboard title: "Sales Performance Leaderboard"
   - Subtitle: "Multi-granularity performance tracking with SKU-level detail"
   - Add data source note: "Source: mart.vw_sales_rankings with daily/weekly/monthly/annual granularity"

---

## Calculated Fields Reference

### Performance Analysis Calculations

```tableau
// Top Performer Identification
[Top Performer] = FIXED() : MAX([location_name])

// Performance Tier Filter
[Is Top Performer] = [performance_tier] = 'Top Performer'

// Sales Above Average
[Above Average Sales] = [Sales Display] > WINDOW_AVG([Sales Display])

// High Margin Indicator
[High Margin] = [gross_margin_pct] > 0.40

// Efficiency Score
[Efficiency Score] = ([Sales Display] * [gross_margin_pct]) / [total_units]

// Performance Change (if time series available)
[Performance Change] = ([Sales Display] - LOOKUP([Sales Display], -1)) / LOOKUP([Sales Display], -1)

// Cases Per Unit
[Cases Per Unit] = [Cases Display] / [total_units]

// SKU Performance Score
[SKU Performance Score] = ([adjusted_sku_sales] * [gross_margin_pct]) / [adjusted_sku_units]
```

### Advanced Analysis Calculations

```tableau
// Quadrant Analysis
[Quadrant] =
IF [Sales Display] > WINDOW_AVG([Sales Display]) AND [gross_margin_pct] > WINDOW_AVG([gross_margin_pct]) THEN 'High Sales/High Margin'
ELSEIF [Sales Display] > WINDOW_AVG([Sales Display]) AND [gross_margin_pct] <= WINDOW_AVG([gross_margin_pct]) THEN 'High Sales/Low Margin'
ELSEIF [Sales Display] <= WINDOW_AVG([Sales Display]) AND [gross_margin_pct] > WINDOW_AVG([gross_margin_pct]) THEN 'Low Sales/High Margin'
ELSE 'Low Sales/Low Margin' END

// Performance Gap Analysis
[Performance Gap] = [Sales Display] - WINDOW_MAX([Sales Display])

// Time Granularity Date Field
[Date Field] =
IF CONTAINS([Time Granularity], 'DAILY') THEN [sale_date]
ELSEIF CONTAINS([Time Granularity], 'WEEKLY') THEN [sale_week]
ELSEIF CONTAINS([Time Granularity], 'MONTHLY') THEN [sale_month]
ELSEIF CONTAINS([Time Granularity], 'ANNUAL') THEN [sale_year]
END

// SKU Rank Color
[SKU Rank Color] =
IF [location_sku_rank] <= 3 THEN 'Green'
ELSEIF [location_sku_rank] <= 7 THEN 'Yellow'
ELSE 'Red'
END

// County Leader Identification
[County Leader] = [county_rank] = 1

// Decile Performance
[Decile Performance] =
CASE [sales_decile]
WHEN 1 THEN 'Top 10%'
WHEN 2 THEN '10-20%'
WHEN 3 THEN '20-30%'
WHEN 4 THEN '30-40%'
WHEN 5 THEN '40-50%'
WHEN 6 THEN '50-60%'
WHEN 7 THEN '60-70%'
WHEN 8 THEN '70-80%'
WHEN 9 THEN '80-90%'
WHEN 10 THEN 'Bottom 10%'
END
```

---

## Interactivity and Actions

### Filter Actions

**County Filter:**
- Click on county in County Champions → filter State Leaderboard and Efficiency Analysis
- Show county-specific performance metrics

**Performance Tier Filter:**
- Select performance tier → highlight retailers in State Leaderboard
- Filter Efficiency Analysis to show only selected tier

**Decile Filter:**
- Select decile range → filter all views to show performance range
- Useful for focusing on top/bottom performers

### Highlight Actions

**Retailer Highlight:**
- Hover over retailer in State Leaderboard → highlight same retailer in other views
- Show comprehensive retailer profile across all visualizations

**Performance Tier Highlight:**
- Click on performance tier → highlight all retailers in that tier
- Useful for tier-based analysis

### Tooltip Enhancements

**State Leaderboard Tooltip:**
- Retailer name, county, city
- Total sales, gross margin, units sold
- State rank, county rank, percentile
- Performance tier, county position

**Efficiency Analysis Tooltip:**
- Retailer name, location
- Sales, margin, units
- Efficiency score
- Performance tier
- Quadrant classification

---

## Performance Optimization

### CTE Benefits

**Pre-calculated Rankings:**
- No table calculations needed in Tableau
- Instant filtering and sorting
- Consistent ranking logic across all views

**Server-Side Processing:**
- Complex window functions executed in PostgreSQL
- Reduced data transfer to Tableau
- Faster dashboard performance

**Memory Efficiency:**
- Single pass through data for all calculations
- Optimized query execution plan
- Reduced Tableau Desktop memory usage

### Tableau Optimization

**Extract Usage:**
- Create extract for better performance
- Schedule extract refreshes
- Use extract filters for large datasets

**Context Filters:**
- Use performance_tier as context filter
- Reduces query complexity
- Improves interactivity

**Data Source Filters:**
- Filter to active retailers only
- Remove unnecessary data at source
- Improve overall performance

---

## Testing Checklist

### Data Validation
- [ ] Rankings match SQL CTE results
- [ ] Performance tiers are consistent across views
- [ ] Percentile calculations are accurate
- [ ] County champions are correctly identified

### Visualization Testing
- [ ] Leaderboard sorts correctly
- [ ] Color coding reflects performance tiers
- [ ] Tooltips show expected information
- [ ] Filters work across all views

### Interactivity Testing
- [ ] Filter actions work correctly
- [ ] Highlight actions function as expected
- [ ] Dashboard responds quickly to interactions
- [ ] Cross-filtering works between views

### Performance Testing
- [ ] Dashboard loads within 5 seconds
- [ ] Filters respond within 2 seconds
- [ ] No lag on hover actions
- [ ] Extract refresh completes successfully

---

## Portfolio Presentation

### Key Talking Points

**Technical Excellence:**
- "Used CTEs to pre-calculate rankings for optimal Tableau performance"
- "Implemented multi-granularity analysis (daily/weekly/monthly/annual) in single view"
- "Added SKU-level detail with case-level metrics for inventory planning"
- "Eliminated complex table calculations through server-side processing"
- "Created realistic variation patterns for purchasing behavior analysis"

**Business Impact:**
- "Enables real-time performance tracking across all locations and SKUs"
- "Supports inventory planning with case-level purchasing data"
- "Identifies top and bottom performers for targeted interventions"
- "Provides time-flexible analysis for operational, tactical, and strategic decisions"
- "Supports data-driven sales team optimization and inventory management"

**Problem Solving:**
- "Optimized dashboard performance through CTE pre-calculation"
- "Created comprehensive performance analysis framework with multiple time granularities"
- "Balanced technical complexity with business usability"
- "Implemented scalable solution for performance and inventory tracking"
- "Designed flexible architecture supporting both location and SKU-level analysis"

### Presentation Structure

**Technical Depth (3 minutes):**
- Explain CTE architecture with multi-granularity optimization benefits
- Show ranking calculations, tier logic, and variation patterns
- Demonstrate case calculations and SKU-level detail implementation
- Highlight time granularity switching capabilities

**Business Value (2 minutes):**
- Explain performance management and inventory planning use cases
- Show how dashboard supports sales optimization and inventory preparation
- Discuss decision-making impact across operational timeframes
- Demonstrate purchasing behavior analysis for event preparation

**Portfolio Integration (1 minute):**
- Highlight advanced SQL skills with complex CTE architecture
- Demonstrate Tableau optimization techniques with parameter-driven interactivity
- Show data-driven decision-making capabilities with multiple analysis perspectives
- Emphasize end-to-end solution from data engineering to visualization

---

## Next Steps

1. **Build Dashboard** - Follow implementation steps with multi-granularity parameters
2. **Test Performance** - Verify CTE optimization benefits with all time granularities
3. **Test SKU Analysis** - Validate SKU-level leaderboards and case calculations
4. **Test Time Series** - Verify trend analysis works across daily/weekly/monthly/annual views
5. **Enhance Interactivity** - Add drill-through to detailed location/SKU analysis
6. **Publish and Share** - Add to portfolio and Tableau Public

---

*This guide provides step-by-step instructions for building a performance leaderboard dashboard that demonstrates advanced SQL CTE optimization and Tableau performance techniques for portfolio development.*

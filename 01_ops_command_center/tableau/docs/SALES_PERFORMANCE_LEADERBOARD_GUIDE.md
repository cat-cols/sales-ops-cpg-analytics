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

**Purpose:** Pre-calculated sales performance rankings using CTE for optimized Tableau performance

**Key Fields:**
- `location_key` - Unique location identifier
- `location_name` - Business name
- `county` - County location
- `city` - City location
- `total_sales` - Total net sales amount
- `total_units` - Total units sold
- `gross_profit` - Gross profit (sales - COGS)
- `gross_margin_pct` - Gross margin percentage
- `county_rank` - Rank within county (1 = best)
- `state_rank` - Rank within state (1 = best)
- `sales_percentile` - Percentile ranking (0-1)
- `sales_decile` - Decile grouping (1-10)
- `performance_tier` - Performance categorization
- `county_position` - Position within county

**CTE Optimization Benefits:**
- Rankings pre-calculated in SQL for instant Tableau performance
- Percentile calculations done server-side
- Performance tiers pre-computed for filtering
- Eliminates complex table calculations in Tableau

---

## Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│              SALES PERFORMANCE LEADERBOARD                 │
├─────────────────────────────────────────────────────────────┤
│  [Top Performer: Name]  [State Rank: #5]  [Decile: Top 10%]│
│  [Total Sales: $125K]  [Gross Margin: 42%]  [Units: 5.2K]│
├─────────────────────────────────────────────────────────────┤
│  State Performance Leaderboard (Top 20)                     │
│  [Bar Chart: Retailers ranked by total_sales]              │
│  Color: performance_tier (Top/Average/Bottom)              │
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
│  Size: total_units, Color: performance_tier                │
├─────────────────────────────────────────────────────────────┤
│  Performance Tier Breakdown                                 │
│  [Treemap: Performance tiers with retailer count]          │
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
   - Verify connection shows all fields

### Step 2: Create State Leaderboard (15 minutes)

1. **Create New Sheet:** "State Leaderboard"
2. **Build Leaderboard:**
   - Drag `location_name` to Rows
   - Drag `total_sales` to Columns
   - Sort descending by total_sales
   - Limit to top 20 retailers
   - Drag `performance_tier` to Color
   - Drag `state_rank` to Tooltip
   - Drag `sales_percentile` to Tooltip
   - Drag `gross_margin_pct` to Tooltip

3. **Enhance Visualization:**
   - Add labels to bars showing sales amounts
   - Set color palette: Green (Top Performer), Blue (Average), Red (Bottom)
   - Add reference line for average sales
   - Add title: "State Performance Leaderboard (Top 20)"

### Step 3: Create Performance Distribution (15 minutes)

1. **Create New Sheet:** "Performance Distribution"
2. **Build Histogram:**
   - Drag `sales_percentile` to Columns
   - Drag `COUNT(location_key)` to Rows
   - Change mark type to Bar
   - Drag `performance_tier` to Color
   - Add title: "Sales Percentile Distribution"

3. **Create Box Plot:**
   - Drag `performance_tier` to Columns
   - Drag `total_sales` to Rows
   - Change mark type to Box Plot
   - Add title: "Sales Distribution by Performance Tier"

4. **Combine Views:**
   - Use dashboard layout to combine histogram and box plot
   - Align horizontally for comparison

### Step 4: Create County Champions (15 minutes)

1. **Create New Sheet:** "County Champions"
2. **Build County Analysis:**
   - Drag `county` to Rows
   - Drag `total_sales` to Columns
   - Drag `county_rank` to Tooltip
   - Drag `county_position` to Tooltip
   - Drag `location_name` to Tooltip
   - Sort by county_rank ascending (rank 1 first)

3. **Enhance Visualization:**
   - Filter to show only county_rank = 1 (top performers)
   - Add county labels
   - Color by county
   - Add title: "County Champions - Top Performer by County"

### Step 5: Create Efficiency Analysis (15 minutes)

1. **Create New Sheet:** "Efficiency Analysis"
2. **Build Scatter Plot:**
   - Drag `total_sales` to Columns
   - Drag `gross_margin_pct` to Rows
   - Change mark type to Circle
   - Drag `total_units` to Size
   - Drag `performance_tier` to Color
   - Drag `location_name` to Tooltip
   - Drag `county` to Tooltip

3. **Enhance Visualization:**
   - Add trend line
   - Add quadrant lines for high/low sales and margin
   - Add title: "Efficiency Analysis: Sales vs Margin"
   - Add quadrant labels: "High Sales/High Margin", etc.

### Step 6: Create Performance Tier Breakdown (10 minutes)

1. **Create New Sheet:** "Performance Tier Breakdown"
2. **Build Treemap:**
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

### Step 7: Create KPI Cards (10 minutes)

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
   - Total Sales (SUM of total_sales)
   - Average Gross Margin (AVG of gross_margin_pct)
   - Total Units (SUM of total_units)

### Step 8: Assemble Dashboard (15 minutes)

1. **Create Dashboard:** "Sales Performance Leaderboard"
2. **Set Layout:**
   - Size: Automatic (or 1200x900 for fixed)
   - Background: Light gray or white

3. **Add Sheets:**
   - Drag "KPI Cards" to top row
   - Drag "State Leaderboard" to middle-left
   - Drag "Performance Distribution" to middle-right
   - Drag "County Champions" to bottom-left
   - Drag "Efficiency Analysis" to bottom-center
   - Drag "Performance Tier Breakdown" to bottom-right

4. **Add Filters:**
   - Drag `county` to Filters
   - Drag `performance_tier` to Filters
   - Drag `sales_decile` to Filters
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

5. **Add Interactivity:**
   - Use filter actions: Click on county in County Champions → filter other views
   - Use highlight actions: Hover over performance tier → highlight retailers
   - Add tooltip enhancements

6. **Add Title and Description:**
   - Dashboard title: "Sales Performance Leaderboard"
   - Subtitle: "Real-time performance tracking using CTE-optimized rankings"
   - Add data source note: "Source: mart.vw_sales_rankings CTE"

---

## Calculated Fields Reference

### Performance Analysis Calculations

```tableau
// Top Performer Identification
[Top Performer] = FIXED() : MAX([location_name])

// Performance Tier Filter
[Is Top Performer] = [performance_tier] = 'Top Performer'

// Sales Above Average
[Above Average Sales] = [total_sales] > WINDOW_AVG([total_sales])

// High Margin Indicator
[High Margin] = [gross_margin_pct] > 0.40

// Efficiency Score
[Efficiency Score] = ([total_sales] * [gross_margin_pct]) / [total_units]

// Performance Change (if time series available)
[Performance Change] = ([total_sales] - LOOKUP([total_sales], -1)) / LOOKUP([total_sales], -1)
```

### Advanced Analysis Calculations

```tableau
// Quadrant Analysis
[Quadrant] = 
IF [total_sales] > WINDOW_AVG([total_sales]) AND [gross_margin_pct] > WINDOW_AVG([gross_margin_pct]) THEN 'High Sales/High Margin'
ELSEIF [total_sales] > WINDOW_AVG([total_sales]) AND [gross_margin_pct] <= WINDOW_AVG([gross_margin_pct]) THEN 'High Sales/Low Margin'
ELSEIF [total_sales] <= WINDOW_AVG([total_sales]) AND [gross_margin_pct] > WINDOW_AVG([gross_margin_pct]) THEN 'Low Sales/High Margin'
ELSE 'Low Sales/Low Margin' END

// Performance Gap Analysis
[Performance Gap] = [total_sales] - WINDOW_MAX([total_sales])

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
- "Eliminated complex table calculations through server-side processing"
- "Implemented performance tiers and percentile rankings in SQL"
- "Created comprehensive performance analysis with efficiency metrics"

**Business Impact:**
- "Enables real-time performance tracking across all locations"
- "Identifies top and bottom performers for targeted interventions"
- "Supports data-driven sales team optimization"
- "Provides objective metrics for performance management"

**Problem Solving:**
- "Optimized dashboard performance through CTE pre-calculation"
- "Created comprehensive performance analysis framework"
- "Balanced technical complexity with business usability"
- "Implemented scalable solution for performance tracking"

### Presentation Structure

**Technical Depth (2 minutes):**
- Explain CTE architecture and optimization benefits
- Show ranking calculations and tier logic
- Demonstrate performance improvements

**Business Value (2 minutes):**
- Explain performance management use cases
- Show how dashboard supports sales optimization
- Discuss decision-making impact

**Portfolio Integration (1 minute):**
- Highlight advanced SQL skills
- Demonstrate Tableau optimization techniques
- Show data-driven decision-making capabilities

---

## Next Steps

1. **Build Dashboard** - Follow implementation steps
2. **Test Performance** - Verify CTE optimization benefits
3. **Add Time Series** - Incorporate time_calculations CTE for trend analysis
4. **Enhance Interactivity** - Add drill-through to detailed retailer analysis
5. **Publish and Share** - Add to portfolio and Tableau Public

---

*This guide provides step-by-step instructions for building a performance leaderboard dashboard that demonstrates advanced SQL CTE optimization and Tableau performance techniques for portfolio development.*

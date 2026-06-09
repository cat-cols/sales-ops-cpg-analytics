# Market Dynamics Dashboard Guide

**Project:** 01_ops_command_center - Business Analyst Portfolio  
**Dashboard:** Market Dynamics Dashboard  
**Platform:** Tableau Desktop  
**Data Source:** PostgreSQL CTEs (mart.vw_market_analysis + mart.vw_geo_aggregations)  
**Purpose:** Competitive intelligence and market positioning using optimized CTEs

---

## Overview

This guide walks through building the Market Dynamics Dashboard for your business analyst portfolio. This dashboard demonstrates advanced SQL CTE optimization, competitive intelligence analysis, and market positioning capabilities using pre-calculated market metrics.

**Business Value:** Enable data-driven competitive analysis, identify market opportunities, and support strategic positioning through objective market intelligence.

---

## Data Sources

### Primary Data Source: mart.vw_market_analysis

**Purpose:** Pre-calculated market share and competitive metrics using CTE

**Key Fields:**
- `county` - County name
- `geographic_region` - Regional classification
- `county_sales` - Total sales in county
- `county_units` - Total units sold in county
- `retailer_count` - Number of retailers in county
- `avg_sales_per_retailer` - Average sales per retailer
- `avg_units_per_retailer` - Average units per retailer
- `sales_rank` - Rank within state by sales (1 = best)
- `retailer_rank` - Rank by retailer count (1 = most)
- `efficiency_rank` - Rank by sales per retailer (1 = most efficient)
- `market_classification` - Market position (Market Leader, Major, Emerging)
- `efficiency_classification` - Efficiency level (High, Above Average, Low)

### Secondary Data Source: mart.vw_geo_aggregations

**Purpose:** Pre-calculated geographic aggregations for regional analysis

**Key Fields:**
- `county` - County name
- `geographic_region` - Regional classification
- `retailer_count` - Number of retailers
- `active_count` - Active retailers
- `recreational_count` - Recreational licenses
- `medical_count` - Medical licenses
- `city_count` - Number of cities in county
- `avg_latitude`, `avg_longitude` - Geographic coordinates
- `avg_distance_from_portland` - Average distance from Portland
- `active_percentage` - Percentage of active retailers
- `recreational_percentage` - Percentage of recreational licenses

**CTE Optimization Benefits:**
- Market share calculations pre-computed in SQL
- Efficiency rankings calculated server-side
- Market classifications pre-determined
- Eliminates complex aggregations in Tableau

---

## Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│                  MARKET DYNAMICS DASHBOARD                  │
├─────────────────────────────────────────────────────────────┤
│  [Total Market: $2.5M]  [Counties: 30]  [Avg Efficiency: $8.2K]│
│  [Top Region: Portland Metro]  [Market Leaders: 5 counties] │
├─────────────────────────────────────────────────────────────┤
│  Market Share Filled Map                                    │
│  [Filled Map: Oregon counties colored by county_sales]       │
│  Labels: county name, market share %                       │
├─────────────────────────────────────────────────────────────┤
│  Market Classification Analysis                             │
│  [Treemap: Market classifications with county_sales]          │
│  Color: market_classification                               │
├─────────────────────────────────────────────────────────────┤
│  Efficiency Analysis                                        │
│  [Scatter Plot: retailer_count vs avg_sales_per_retailer]  │
│  Size: county_sales, Color: efficiency_classification       │
├─────────────────────────────────────────────────────────────┤
│  Regional Comparison                                        │
│  [Bar Chart: Regional sales comparison]                     │
│  Group by geographic_region, sum county_sales              │
├─────────────────────────────────────────────────────────────┤
│  Growth Opportunity Analysis                                 │
│  [Scatter Plot: sales_rank vs efficiency_rank]              │
│  Color: market_classification, Size: county_sales           │
├─────────────────────────────────────────────────────────────┤
│  License Type Distribution                                  │
│  [Bar Chart: recreational vs medical by region]             │
├─────────────────────────────────────────────────────────────┤
│  Distance Analysis                                          │
│  [Line Chart: avg_distance_from_portland vs county_sales]   │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Connect to Data (5 minutes)

1. **Open Tableau Desktop**
2. **Add Data Sources:**
   - In Data Source tab, expand `althea_ops` → `mart` schema
   - Drag `vw_market_analysis` to the canvas
   - Drag `vw_geo_aggregations` to the canvas
   - Auto-join on `county` and `geographic_region`
   - Verify join relationships are correct

### Step 2: Create Market Share Filled Map (20 minutes)

1. **Create New Sheet:** "Market Share Map"
2. **Build Filled Map:**
   - Drag `county` to Detail on Marks card
   - Change mark type to "Map"
   - Drag `county_sales` to Color on Marks card
   - Set color palette: Sequential (Orange or Blue)
   - Add county labels to map
   - Add county_sales labels to map

3. **Enhance Map:**
   - Add map layers: Map → Map Layers → Add "State Borders"
   - Add map layers: Map → Map Layers → Add "County Borders"
   - Create calculated field: `[Market Share %] = [county_sales] / SUM([county_sales]) * 100`
   - Add market share % to labels
   - Add title: "Market Share by County"
   - Add tooltip with county, sales, market share, retailer count

### Step 3: Create Market Classification Analysis (15 minutes)

1. **Create New Sheet:** "Market Classification"
2. **Build Treemap:**
   - Drag `market_classification` to Color
   - Drag `county_sales` to Size
   - Drag `county` to Label
   - Change mark type to Square
   - Add county_sales labels to squares
   - Add title: "Market Classification by County"

3. **Enhance Visualization:**
   - Sort by county_sales descending
   - Add retailer_count to tooltip
   - Add efficiency_rank to tooltip
   - Use distinct colors for each market classification

### Step 4: Create Efficiency Analysis (15 minutes)

1. **Create New Sheet:** "Efficiency Analysis"
2. **Build Scatter Plot:**
   - Drag `retailer_count` to Columns
   - Drag `avg_sales_per_retailer` to Rows
   - Change mark type to Circle
   - Drag `county_sales` to Size
   - Drag `efficiency_classification` to Color
   - Drag `county` to Tooltip
   - Drag `sales_rank` to Tooltip

3. **Enhance Visualization:**
   - Add trend line
   - Add quadrant lines for high/low retailer count and efficiency
   - Create calculated field: `[Quadrant]` (see Calculated Fields section)
   - Add quadrant labels: "High Count/High Efficiency", etc.
   - Add title: "Market Efficiency Analysis"

### Step 5: Create Regional Comparison (10 minutes)

1. **Create New Sheet:** "Regional Comparison"
2. **Build Bar Chart:**
   - Drag `geographic_region` to Columns
   - Drag `county_sales` to Rows
   - Sort descending by county_sales
   - Drag `retailer_count` to Tooltip
   - Drag `county` to Tooltip
   - Add title: "Regional Sales Comparison"

3. **Enhance Visualization:**
   - Add labels to bars showing sales amounts
   - Color by geographic_region
   - Add reference line for average regional sales

### Step 6: Create Growth Opportunity Analysis (15 minutes)

1. **Create New Sheet:** "Growth Opportunities"
2. **Build Scatter Plot:**
   - Drag `sales_rank` to Columns (reverse axis)
   - Drag `efficiency_rank` to Rows (reverse axis)
   - Change mark type to Circle
   - Drag `county_sales` to Size
   - Drag `market_classification` to Color
   - Drag `county` to Tooltip
   - Drag `retailer_count` to Tooltip

3. **Enhance Visualization:**
   - Reverse both axes (lower rank = better)
   - Add quadrant lines
   - Highlight top-left quadrant (high efficiency, high sales rank)
   - Add title: "Growth Opportunity Analysis"
   - Add annotation for "High Opportunity" quadrant

### Step 7: Create License Type Distribution (10 minutes)

1. **Create New Sheet:** "License Distribution"
2. **Build Stacked Bar Chart:**
   - Drag `geographic_region` to Columns
   - Drag `recreational_count` to Rows
   - Drag `medical_count` to Rows (stacked)
   - Add table calculation for percent of total
   - Add title: "License Type Distribution by Region"

3. **Enhance Visualization:**
   - Color by license type
   - Add percentage labels
   - Add retailer_count to tooltip

### Step 8: Create Distance Analysis (10 minutes)

1. **Create New Sheet:** "Distance Analysis"
2. **Build Line Chart:**
   - Drag `avg_distance_from_portland` to Columns
   - Drag `county_sales` to Rows
   - Change mark type to Circle
   - Drag `county` to Tooltip
   - Drag `retailer_count` to Tooltip
   - Add title: "Distance from Portland vs Sales"

3. **Enhance Visualization:**
   - Add trend line
   - Color by geographic_region
   - Add reference line for average distance

### Step 9: Create KPI Cards (10 minutes)

1. **Create New Sheet:** "KPI Cards"
2. **Build KPI 1 - Total Market:**
   - Drag `SUM(county_sales)` to Text
   - Format as currency
   - Add label: "Total Market"

3. **Build KPI 2 - County Count:**
   - Drag `COUNTD(county)` to Text
   - Add label: "Counties"

4. **Build KPI 3 - Average Efficiency:**
   - Drag `AVG(avg_sales_per_retailer)` to Text
   - Format as currency
   - Add label: "Avg Efficiency"

5. **Build Additional KPIs:**
   - Top Region (highest sales)
   - Market Leaders count (market_classification = 'Market Leader')
   - High Efficiency count (efficiency_classification = 'High Efficiency')

### Step 10: Assemble Dashboard (15 minutes)

1. **Create Dashboard:** "Market Dynamics Dashboard"
2. **Set Layout:**
   - Size: Automatic (or 1400x1000 for fixed)
   - Background: Light gray or white

3. **Add Sheets:**
   - Drag "KPI Cards" to top row
   - Drag "Market Share Map" to middle-left (main section)
   - Drag "Market Classification" to middle-right
   - Drag "Efficiency Analysis" to bottom-left
   - Drag "Regional Comparison" to bottom-center
   - Drag "Growth Opportunities" to bottom-right
   - Drag "License Distribution" and "Distance Analysis" to bottom (optional)

4. **Add Filters:**
   - Drag `geographic_region` to Filters
   - Drag `market_classification` to Filters
   - Drag `efficiency_classification` to Filters
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

5. **Add Interactivity:**
   - Use filter actions: Click on region → filter all views
   - Use highlight actions: Hover over county → highlight in all views
   - Add tooltip enhancements

6. **Add Title and Description:**
   - Dashboard title: "Market Dynamics Dashboard"
   - Subtitle: "Competitive intelligence using CTE-optimized market analysis"
   - Add data source note: "Source: mart.vw_market_analysis + mart.vw_geo_aggregations CTEs"

---

## Calculated Fields Reference

### Market Analysis Calculations

```tableau
// Market Share Percentage
[Market Share %] = [county_sales] / SUM([county_sales]) * 100

// Regional Market Share
[Regional Market Share] = [county_sales] / SUM([county_sales]) OVER (PARTITION BY [geographic_region]) * 100

// Efficiency Score
[Efficiency Score] = [avg_sales_per_retailer] / [retailer_count]

// Growth Opportunity Score
[Growth Opportunity] = 
IF [sales_rank] <= 10 AND [efficiency_rank] <= 10 THEN "High Opportunity"
ELSEIF [sales_rank] <= 20 AND [efficiency_rank] <= 20 THEN "Medium Opportunity"
ELSE "Low Opportunity" END

// Market Concentration
[Market Concentration] = [county_sales] / SUM([county_sales]) OVER ()
```

### Advanced Analysis Calculations

```tableau
// Quadrant Analysis for Efficiency
[Efficiency Quadrant] = 
IF [retailer_count] > WINDOW_AVG([retailer_count]) AND [avg_sales_per_retailer] > WINDOW_AVG([avg_sales_per_retailer]) THEN "High Count/High Efficiency"
ELSEIF [retailer_count] > WINDOW_AVG([retailer_count]) AND [avg_sales_per_retailer] <= WINDOW_AVG([avg_sales_per_retailer]) THEN "High Count/Low Efficiency"
ELSEIF [retailer_count] <= WINDOW_AVG([retailer_count]) AND [avg_sales_per_retailer] > WINDOW_AVG([avg_sales_per_retailer]) THEN "Low Count/High Efficiency"
ELSE "Low Count/Low Efficiency" END

// Distance Impact Analysis
[Distance Impact] = 
IF [avg_distance_from_portland] < 50 THEN "Close to Portland"
ELSEIF [avg_distance_from_portland] < 100 THEN "Mid Distance"
ELSE "Remote" END

// Market Saturation
[Market Saturation] = [retailer_count] / [city_count]

// Competitive Intensity
[Competitive Intensity] = [retailer_count] / [county_sales] * 1000
```

---

## Interactivity and Actions

### Filter Actions

**Geographic Region Filter:**
- Click on region in Regional Comparison → filter Market Share Map
- Show region-specific market dynamics

**Market Classification Filter:**
- Select market classification → highlight counties in Market Classification
- Filter Efficiency Analysis to show only selected classification

**Efficiency Classification Filter:**
- Select efficiency level → highlight counties in Efficiency Analysis
- Filter Growth Opportunities to show only selected efficiency level

### Highlight Actions

**County Highlight:**
- Hover over county in Market Share Map → highlight same county in other views
- Show comprehensive county profile across all visualizations

**Region Highlight:**
- Click on region → highlight all counties in that region
- Useful for regional analysis

### Tooltip Enhancements

**Market Share Map Tooltip:**
- County name, geographic region
- County sales, market share percentage
- Retailer count, average efficiency
- Market classification, efficiency classification

**Efficiency Analysis Tooltip:**
- County name, retailer count
- Average sales per retailer
- Efficiency classification
- Sales rank, efficiency rank
- Quadrant classification

---

## Performance Optimization

### CTE Benefits

**Pre-calculated Market Metrics:**
- Market share calculations done in SQL
- Efficiency rankings computed server-side
- Market classifications pre-determined
- Instant filtering and sorting

**Multi-CTE Optimization:**
- Market analysis CTE handles sales and efficiency
- Geographic aggregation CTE handles regional metrics
- Reduced data transfer to Tableau
- Optimized query execution plans

**Complex Aggregations:**
- Window functions executed in PostgreSQL
- Eliminates complex table calculations
- Consistent calculation logic across views
- Reduced Tableau Desktop memory usage

### Tableau Optimization

**Extract Usage:**
- Create extract for better performance
- Schedule extract refreshes
- Use extract filters for large datasets

**Context Filters:**
- Use geographic_region as context filter
- Reduces query complexity
- Improves interactivity

**Data Source Filters:**
- Filter to active counties only
- Remove unnecessary data at source
- Improve overall performance

---

## Testing Checklist

### Data Validation
- [ ] Market share calculations match SQL CTE results
- [ ] Efficiency rankings are consistent across views
- [ ] Market classifications are correct
- [ ] Geographic aggregations are accurate

### Visualization Testing
- [ ] Market share map displays correctly
- [ ] Efficiency scatter plot shows proper quadrants
- [ ] Regional comparison sorts correctly
- [ ] Growth opportunity analysis highlights correct quadrant

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
- "Used multiple CTEs to pre-calculate market metrics for optimal performance"
- "Implemented complex market analysis with server-side processing"
- "Created market classification and efficiency rankings in SQL"
- "Built competitive intelligence framework with geographic analysis"

**Business Impact:**
- "Enables data-driven competitive analysis across Oregon"
- "Identifies market opportunities and competitive threats"
- "Supports strategic positioning and market entry decisions"
- "Provides objective metrics for market intelligence"

**Problem Solving:**
- "Optimized dashboard performance through multi-CTE architecture"
- "Created comprehensive market analysis framework"
- "Balanced technical complexity with business usability"
- "Implemented scalable solution for competitive intelligence"

### Presentation Structure

**Technical Depth (2 minutes):**
- Explain multi-CTE architecture and optimization benefits
- Show market share and efficiency calculations
- Demonstrate performance improvements

**Business Value (2 minutes):**
- Explain competitive intelligence use cases
- Show how dashboard supports strategic decision-making
- Discuss market opportunity identification

**Portfolio Integration (1 minute):**
- Highlight advanced SQL skills with multiple CTEs
- Demonstrate Tableau optimization techniques
- Show data-driven competitive analysis capabilities

---

## Next Steps

1. **Build Dashboard** - Follow implementation steps
2. **Test Performance** - Verify CTE optimization benefits
3. **Add Predictive Analytics** - Incorporate forecasting capabilities
4. **Enhance Interactivity** - Add drill-through to detailed county analysis
5. **Publish and Share** - Add to portfolio and Tableau Public

---

*This guide provides step-by-step instructions for building a market dynamics dashboard that demonstrates advanced SQL multi-CTE optimization and competitive intelligence techniques for portfolio development.*

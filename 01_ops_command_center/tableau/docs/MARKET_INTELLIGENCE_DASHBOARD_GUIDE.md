# Oregon Cannabis Market Intelligence Dashboard Guide

**Project:** 01_ops_command_center - Business Analyst Portfolio  
**Dashboard:** Oregon Cannabis Market Intelligence  
**Platform:** Tableau Desktop  
**Data Source:** PostgreSQL mart views (OLCC retailer data)  

---

## Overview

This guide walks through building the Oregon Cannabis Market Intelligence Dashboard for your business analyst portfolio. This dashboard demonstrates geographic analysis, market intelligence, and strategic planning capabilities using real OLCC retailer data with geocoding.

**Business Value:** Enable data-driven territory planning, market expansion decisions, and competitive intelligence for CPG companies in the Oregon cannabis market.

---

## Data Sources

### Primary Data Source: mart.vw_market_intelligence
**Purpose:** Main analysis view with retailer locations and market metrics  
**Key Fields:**
- `license_number` - Unique retailer identifier
- `retailer_name` - Business name
- `city`, `county`, `state` - Geographic hierarchy
- `latitude`, `longitude` - Geocoded coordinates for mapping
- `market_competition_level` - Competition classification (High/Medium/Low)
- `geographic_region` - Regional clustering (Portland Metro, Willamette Valley, etc.)
- `distance_from_portland_miles` - Distance calculation for spatial analysis
- `is_active_retailer` - Boolean flag for active licenses
- `retailer_category` - License type (Recreational/Medical/Other)

### Supporting Data Sources

**mart.vw_county_market_summary**
- Pre-aggregated county-level data for performance
- Use for county KPIs and regional comparisons

**mart.vw_city_market_summary**
- Pre-aggregated city-level data for detailed analysis
- Use for city-specific analysis and territory planning

---

## Dashboard 1: Oregon Cannabis Market Intelligence Dashboard

### Purpose
Provide comprehensive market overview of Oregon cannabis retailer landscape for strategic decision-making.

### Business Questions Answered
- What is the geographic distribution of cannabis retailers across Oregon?
- Which counties/cities have the highest retailer density?
- What are the competitive dynamics by region?
- How are license types distributed across the state?

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│              OREGON CANNABIS MARKET INTELLIGENCE             │
├─────────────────────────────────────────────────────────────┤
│  [Total Retailers: 761]  [Counties: 30]  [Cities: 115]     │
│  [Top County: Multnomah]  [Avg Retailers/County: 25]       │
├─────────────────────────────────────────────────────────────┤
│  Geographic Map with Retailer Locations & Competition Heat  │
│  [Symbol Map: Retailer locations colored by competition]    │
├─────────────────────────────────────────────────────────────┤
│  Top 10 Counties by Retailer Count   License Type Dist.     │
│  [Bar Chart]                        [Pie Chart]              │
├─────────────────────────────────────────────────────────────┤
│  Market Share by Region            Competition Analysis      │
│  [Tree Map]                        [Heat Map]               │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Connect to Data (5 minutes)

1. **Open Tableau Desktop**
2. **Connect to PostgreSQL:**
   - Connect → To a Server → PostgreSQL
   - Server: localhost
   - Port: 5432
   - Database: althea_ops
   - Authentication: Username and Password
   - Click "Sign In"

3. **Add Data Source:**
   - In Data Source tab, expand `althea_ops` → `mart` schema
   - Drag `vw_market_intelligence` to the canvas
   - Drag `vw_county_market_summary` to the canvas (auto-join on county_name)
   - Drag `vw_city_market_summary` to the canvas (auto-join on city_name)
   - Verify joins are correct (county_name, city_name)

### Step 2: Create Geographic Map (15 minutes)

1. **Create New Sheet:** "Retailer Map"
2. **Build Map:**
   - Drag `latitude` to Rows
   - Drag `longitude` to Columns
   - Change mark type to "Map"
   - Drag `retailer_name` to Detail on Marks card
   - Drag `market_competition_level` to Color on Marks card
   - Drag `city` to Tooltip on Marks card
   - Drag `county` to Tooltip on Marks card

3. **Enhance Map:**
   - Add map layers: Map → Map Layers → Add "State Borders"
   - Add map layers: Map → Map Layers → Add "County Borders"
   - Adjust size of marks (make them larger for visibility)
   - Set color palette: Use "Orange-Blue Diverging" for competition levels
   - Add title: "Oregon Cannabis Retailer Locations"

4. **Test Map:**
   - You should see Oregon with 761 retailer points
   - Different colors for competition levels
   - Tooltips showing retailer information

### Step 3: Create KPI Cards (10 minutes)

1. **Create Sheet:** "KPI Cards"
2. **Build KPI 1 - Total Retailers:**
   - Drag `license_number` to Rows
   - Change to "COUNT" aggregation
   - Drag to Text on Marks card
   - Format as large number
   - Add label: "Total Retailers"

3. **Build KPI 2 - Counties Served:**
   - Drag `county_name` to Rows
   - Change to "COUNTD" (count distinct)
   - Drag to Text on Marks card
   - Format as large number
   - Add label: "Counties Served"

4. **Build KPI 3 - Cities Served:**
   - Drag `city_name` to Rows
   - Change to "COUNTD"
   - Drag to Text on Marks card
   - Format as large number
   - Add label: "Cities Served"

5. **Build KPI 4 - Top County:**
   - Create calculated field: `[Top County] = FIXED() : FIRST()`
   - Drag `county_name` to Rows
   - Sort by retailer count descending
   - Limit to top 1
   - Drag to Text on Marks card
   - Add label: "Top County"

### Step 4: Create Top Counties Chart (10 minutes)

1. **Create Sheet:** "Top Counties"
2. **Build Bar Chart:**
   - Drag `county_name` to Rows
   - Drag `COUNT(license_number)` to Columns
   - Sort descending by retailer count
   - Limit to top 10 counties
   - Drag `market_competition_level` to Color
   - Add title: "Top 10 Counties by Retailer Count"
   - Add labels to bars

### Step 5: Create License Type Distribution (10 minutes)

1. **Create Sheet:** "License Types"
2. **Build Pie Chart:**
   - Drag `retailer_category` to Color
   - Drag `COUNT(license_number)` to Angle
   - Change mark type to "Pie"
   - Add labels to pie slices
   - Add title: "License Type Distribution"
   - Add percentage labels

### Step 6: Create Regional Market Share (10 minutes)

1. **Create Sheet:** "Regional Market Share"
2. **Build Tree Map:**
   - Drag `geographic_region` to Color
   - Drag `COUNT(license_number)` to Size
   - Change mark type to "Square"
   - Add labels to squares
   - Add title: "Market Share by Geographic Region"
   - Add retailer count labels

### Step 7: Create Competition Heat Map (10 minutes)

1. **Create Sheet:** "Competition Analysis"
2. **Build Heat Map:**
   - Drag `county_name` to Rows
   - Drag `market_competition_level` to Columns
   - Drag `COUNT(license_number)` to Color
   - Drag `COUNT(license_number)` to Size
   - Add title: "Competition Analysis by County"
   - Use color palette: Green (Low), Yellow (Medium), Red (High)

### Step 8: Assemble Dashboard (15 minutes)

1. **Create Dashboard:** "Oregon Cannabis Market Intelligence"
2. **Set Layout:**
   - Size: Automatic (or 1200x800 for fixed)
   - Background: Light gray or white

3. **Add Sheets:**
   - Drag "KPI Cards" to top row
   - Drag "Retailer Map" to middle (main section)
   - Drag "Top Counties" to bottom left
   - Drag "License Types" to bottom center
   - Drag "Regional Market Share" to bottom right
   - Drag "Competition Analysis" to bottom (optional)

4. **Add Filters:**
   - Drag `market_competition_level` to Filters
   - Drag `geographic_region` to Filters
   - Drag `retailer_category` to Filters
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

5. **Add Interactivity:**
   - Use filter actions: Click on county in bar chart → filter map
   - Use highlight actions: Hover over region → highlight retailers
   - Add tooltip enhancements

6. **Add Title and Description:**
   - Dashboard title: "Oregon Cannabis Market Intelligence"
   - Subtitle: "761 Active Retailers Across 30 Counties"
   - Add data source note: "Source: OLCC Public Records, Geocoded 2026"

### Step 9: Formatting and Polish (10 minutes)

1. **Consistent Styling:**
   - Use consistent color palette across all sheets
   - Standardize font (Arial or Tableau font)
   - Consistent title formatting

2. **Performance Optimization:**
   - Use extract if performance is slow
   - Add data source filters if needed
   - Optimize calculated fields

3. **Testing:**
   - Test all filters work correctly
   - Test interactivity
   - Verify tooltips show correct information
   - Check for data accuracy

---

## Calculated Fields Reference

### Market Intelligence Calculations

```tableau
// Market Opportunity Score
[Market Opportunity Score] = 
IF [Market Competition Level] = "Low Competition" THEN "High"
ELSEIF [Market Competition Level] = "Medium Competition" THEN "Medium"
ELSE "Low" END

// High Priority Territory
[Is High Priority] = 
[Market Competition Level] = "Low Competition" AND 
[Distance from Portland Miles] < 100

// Retailer Density per County
[Retailer Density] = 
[Active Retailers in County] / [County Population] * 1000

// Growth Potential Index
[Growth Potential] = 
IF [Market Competition Level] = "Low Competition" AND 
[Geographic Region] = "Southern Oregon" THEN "High"
ELSEIF [Market Competition Level] = "Medium Competition" THEN "Medium"
ELSE "Low" END

// Competitive Intensity
[Competitive Intensity] = 
[Active Retailers in County] / [Total Retailers in State]

// Market Saturation Score
[Market Saturation] = 
[Active Retailers in County] / [Total Addressable Market]
```

---

## Dashboard 2: Territory Planning Dashboard

### Purpose
Enable strategic territory planning and sales optimization through geographic analysis and competitor gap analysis.

### Key Visualizations

1. **Territory Map with Drive-Time Rings**
   - Map showing retailer locations
   - Drive-time rings (30min, 60min, 90min from major cities)
   - Territory boundaries
   - Priority scoring

2. **Territory Priority Matrix**
   - Scatter plot: Competition vs Opportunity
   - Color-coded priority levels
   - Size by retailer count

3. **Sales Opportunity Analysis**
   - Bar chart: Retailers by territory
   - Growth potential indicators
   - Market penetration rates

### Implementation Notes

Use the same data sources as Dashboard 1, but focus on:
- `distance_from_portland_miles` for proximity analysis
- `market_competition_level` for competitive assessment
- `geographic_region` for territory clustering
- Custom calculated fields for territory scoring

---

## Dashboard 3: Market Trends Dashboard

### Purpose
Analyze historical trends and forecast future market expansion for strategic planning and investment decisions.

### Key Visualizations

1. **License Issuance Trends**
   - Line chart: License issuance over time
   - Trend lines for growth forecasting
   - Regional comparison

2. **Seasonal Patterns**
   - Heat map: Monthly license applications
   - Seasonal indices
   - Peak season identification

3. **Growth Velocity Analysis**
   - Bar chart: New licenses by quarter
   - Growth rate calculations
   - Regional growth comparison

### Implementation Notes

This dashboard requires time-series data. Since OLCC data is a snapshot, you may need to:
- Simulate historical trends based on current distribution
- Use `loaded_at` timestamp for data freshness
- Create synthetic time series for demonstration purposes

---

## Portfolio Presentation Tips

### Storytelling Framework

**Problem Statement:** "Oregon cannabis market lacks comprehensive intelligence for strategic planning"

**Solution:** "Built market intelligence platform integrating OLCC data with geographic analysis"

**Impact:** "Enables data-driven territory planning and market expansion decisions"

**Skills Demonstrated:** Data engineering, SQL development, geographic analysis, business intelligence

### Presentation Structure

1. **Executive Summary (2 minutes)**
   - Show dashboard overview
   - Highlight key insights
   - Demonstrate interactivity

2. **Technical Depth (3 minutes)**
   - Explain data pipeline
   - Show SQL views
   - Discuss geocoding implementation

3. **Business Value (2 minutes)**
   - Explain use cases
   - Discuss decision-making impact
   - Show ROI potential

4. **Future Enhancements (1 minute)**
   - Discuss scalability
   - Mention additional data sources
   - Outline advanced analytics

### Key Talking Points

**Technical:**
- "Processed 761 retailer records with 100% address parsing accuracy"
- "Implemented geocoding using Python and APIs"
- "Designed layered database architecture for performance"
- "Created complex SQL views with calculated metrics"

**Business:**
- "Solution enables data-driven territory planning"
- "Provides competitive intelligence for strategic positioning"
- "Supports market expansion decisions with geographic analysis"
- "Delivers actionable insights for sales optimization"

**Problem Solving:**
- "Solved data quality issues through robust parsing"
- "Addressed scalability through proper database design"
- "Implemented fallback mechanisms for edge cases"
- "Balanced technical complexity with business usability"

---

## Testing Checklist

### Data Connection
- [ ] PostgreSQL connection works
- [ ] All views are accessible
- [ ] Data loads correctly
- [ ] No connection errors

### Geographic Map
- [ ] Map displays Oregon correctly
- [ ] All 761 retailers show on map
- [ ] Color coding works for competition levels
- [ ] Tooltips show correct information
- [ ] Map layers display properly

### KPI Cards
- [ ] Total retailers: 761
- [ ] Counties: 30
- [ ] Cities: 115
- [ ] Top county: Multnomah
- [ ] Values match SQL queries

### Charts
- [ ] Top counties chart sorts correctly
- [ ] License type pie chart sums to 100%
- [ ] Regional tree map shows correct regions
- [ ] Competition heat map colors correctly
- [ ] All charts filter properly

### Dashboard
- [ ] Layout is clean and professional
- [ ] Filters work across all sheets
- [ ] Interactivity works as expected
- [ ] Performance is acceptable
- [ ] Formatting is consistent

### Portfolio Ready
- [ ] Dashboard tells a clear story
- [ ] Demonstrates required skills
- [ ] Shows business value
- [ ] Ready for presentation
- [ ] Documented for portfolio

---

## Next Steps

1. **Complete Dashboard 1** (Market Intelligence)
   - Follow implementation steps
   - Test against checklist
   - Polish formatting

2. **Build Dashboard 2** (Territory Planning)
   - Use same data sources
   - Focus on territory analysis
   - Add drive-time calculations

3. **Build Dashboard 3** (Market Trends)
   - Create time-series analysis
   - Add forecasting elements
   - Show seasonal patterns

4. **Portfolio Documentation**
   - Take screenshots of dashboards
   - Update portfolio documentation
   - Create presentation materials
   - Prepare talking points

5. **Publish and Share**
   - Publish to Tableau Public
   - Add to portfolio website
   - Share with network
   - Gather feedback

---

## Troubleshooting

### Map Not Displaying
- Ensure latitude/longitude fields are numeric
- Check mark type is set to "Map"
- Verify data contains valid coordinates
- Try refreshing the data source

### Performance Issues
- Create data extract for better performance
- Use data source filters to reduce row count
- Optimize calculated fields
- Use context filters for complex views

### Data Accuracy Issues
- Verify SQL view calculations
- Check data source joins
- Validate against raw data
- Test calculated fields independently

### Connection Issues
- Verify PostgreSQL is running
- Check connection credentials
- Test connection in psql first
- Ensure driver is installed correctly

---

## Resources

**Tableau Documentation:**
- Tableau Desktop Help: https://help.tableau.com/
- Mapping in Tableau: https://help.tableau.com/current/pro/desktop/en-us/maps_howto.html
- Calculated Fields: https://help.tableau.com/current/pro/desktop/en-us/calculations.htm

**Project Documentation:**
- Tableau Dashboard Specifications: `/docs/tableau_dashboard_specifications.md`
- Business Analyst Portfolio: `/docs/business_analyst_portfolio.md`
- Data Dictionary: See SQL view comments

**Portfolio Resources:**
- Tableau Public: https://public.tableau.com/
- Portfolio Examples: Review for formatting and presentation
- LinkedIn: Optimize profile with dashboard links

---

*This guide provides step-by-step instructions for building a professional market intelligence dashboard that demonstrates business analyst skills for portfolio development.*

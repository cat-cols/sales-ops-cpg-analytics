# Tableau Dashboard Specifications for Business Analyst Portfolio

## Overview
This document outlines three comprehensive Tableau dashboards designed to showcase business analyst skills using Oregon cannabis market data. These dashboards demonstrate data integration, geographic analysis, market intelligence, and strategic planning capabilities.

---

## Dashboard 1: Oregon Cannabis Market Intelligence Dashboard

### Purpose
Provide comprehensive market overview of Oregon cannabis retailer landscape for strategic decision-making.

### Business Questions Answered
- What is the geographic distribution of cannabis retailers across Oregon?
- Which counties/cities have the highest retailer density?
- What are the competitive dynamics by region?
- How are license types distributed across the state?

### Data Sources
- `mart.vw_market_intelligence` - Primary data source
- `mart.vw_county_market_summary` - County-level aggregations
- `mart.vw_city_market_summary` - City-level aggregations

### Dashboard Layout

#### Section 1: Executive Summary (Top Row)
- **KPI Cards**: Total Active Retailers, Total Counties Served, Top County by Retailer Count, Average Retailers per County
- **Filters**: License Type, Status, Geographic Region

#### Section 2: Geographic Map (Main Visualization)
- **Map Type**: Symbol map with retailer locations
- **Color Coding**: Market competition level (High/Medium/Low)
- **Size Coding**: Number of retailers per location
- **Layers**: County boundaries, city labels, retailer density heat map
- **Tooltips**: Business name, address, license type, competition level

#### Section 3: Market Analysis (Bottom Row)
- **Bar Chart**: Top 10 counties by retailer count
- **Pie Chart**: License type distribution (Recreational vs Medical)
- **Tree Map**: Market share by geographic region
- **Scatter Plot**: Retailers per county vs population density (if available)

### Calculated Fields
```
[Market Competition Score] = 
IF [Active Retailers in County] > 50 THEN "High Competition"
ELSEIF [Active Retailers in County] > 20 THEN "Medium Competition"
ELSE "Low Competition" END

[Market Saturation Index] = 
[Active Retailers in County] / [County Population] * 1000

[Growth Potential] = 
IF [Market Competition Level] = "Low Competition" AND [Distance from Portland] < 100 THEN "High"
ELSEIF [Market Competition Level] = "Medium Competition" THEN "Medium"
ELSE "Low" END
```

### Interactivity
- Click on map to filter all charts by selected county
- Hover over retailers for detailed information
- Dynamic filtering by license type and status
- Drill-down from county to city level

---

## Dashboard 2: Territory Planning & Sales Optimization Dashboard

### Purpose
Enable strategic territory planning and sales optimization through geographic analysis and competitor gap analysis.

### Business Questions Answered
- What are the optimal territory boundaries based on retailer clusters?
- Which areas have the highest sales opportunity potential?
- What is the competitive landscape by geographic region?
- How can sales territories be optimized for maximum coverage?

### Data Sources
- `mart.vw_market_intelligence` - Primary data source
- `mart.vw_city_market_summary` - City-level aggregations
- Custom calculated fields for territory analysis

### Dashboard Layout

#### Section 1: Territory Overview (Top Row)
- **KPI Cards**: Total Territories, Average Retailers per Territory, High-Priority Territories, Untapped Markets
- **Filters**: Geographic Region, Competition Level, Distance Range

#### Section 2: Territory Map (Main Visualization)
- **Map Type**: Filled map with territory boundaries
- **Color Coding**: Priority level (High/Medium/Low)
- **Size Coding**: Retailer count per territory
- **Layers**: Drive-time rings (30min, 60min, 90min from major cities)
- **Tooltips**: Territory name, retailer count, competition level, growth potential

#### Section 3: Territory Analysis (Bottom Row)
- **Bar Chart**: Retailers by territory with growth potential
- **Heat Map**: Territory priority matrix (Competition vs Opportunity)
- **Scatter Plot**: Distance from Portland vs retailer density
- **Line Chart**: Cumulative retailer coverage by territory

### Calculated Fields
```
[Territory Priority Score] = 
([Growth Potential Weight] * [Growth Potential]) +
([Competition Weight] * (1 - [Competition Index])) +
([Distance Weight] * [Proximity Score])

[Sales Opportunity Index] = 
[Active Retailers in Territory] * [Average Order Value] * [Market Penetration Rate]

[Territory Efficiency] = 
[Active Retailers in Territory] / [Territory Area in Square Miles]

[Competitive Gap Analysis] = 
[Total Addressable Market] - [Current Market Coverage]
```

### Interactivity
- Click on territory to see detailed retailer list
- Adjust drive-time parameters to see territory changes
- Compare multiple territories side-by-side
- Export territory boundaries for external mapping tools

---

## Dashboard 3: Market Trends & Forecasting Dashboard

### Purpose
Analyze historical trends and forecast future market expansion for strategic planning and investment decisions.

### Business Questions Answered
- What are the historical trends in license issuance?
- Which regions are growing fastest?
- What is the projected market expansion over the next 12-24 months?
- Are there seasonal patterns in license applications?

### Data Sources
- `raw.olcc_retailers` - Historical license data
- `mart.vw_market_intelligence` - Current market state
- Time series calculations for trend analysis

### Dashboard Layout

#### Section 1: Trend Overview (Top Row)
- **KPI Cards**: YTD New Licenses, Growth Rate vs Last Year, Projected Q4 Licenses, Peak Season
- **Filters**: Time Range, License Type, Geographic Region

#### Section 2: Historical Trends (Main Visualization)
- **Line Chart**: License issuance over time (monthly)
- **Area Chart**: Cumulative retailer growth by region
- **Bar Chart**: Monthly license applications vs approvals
- **Trend Lines**: Linear regression for growth forecasting

#### Section 3: Forecasting & Analysis (Bottom Row)
- **Scatter Plot**: Historical growth vs projected growth by county
- **Heat Map**: Seasonal patterns in license applications
- **Bullet Chart**: Actual vs projected licenses by quarter
- **Box Plot**: License processing time distribution

### Calculated Fields
```
[Year Over Year Growth] = 
([Current Year Licenses] - [Previous Year Licenses]) / [Previous Year Licenses] * 100

[Growth Velocity] = 
[New Licenses in Last 90 Days] / [Total Licenses]

[Seasonal Index] = 
[Monthly Average] / [Annual Average] * 100

[Projected Licenses Q4] = 
[Q1-Q3 Average] * [Q4 Seasonal Factor] * [Growth Trend Factor]

[Market Maturity Score] = 
[Years Since First License] / [Total Licenses] * [Growth Rate]
```

### Interactivity
- Adjust forecast parameters (growth rate, seasonal factors)
- Compare historical periods with current trends
- Drill down from state to county level trends
- Export forecast data for external analysis

---

## Technical Implementation Details

### Tableau Data Connection
- **Connection Type**: PostgreSQL
- **Server**: localhost (or your PostgreSQL server)
- **Database**: althea_ops
- **Authentication**: Integrated Windows Authentication or username/password
- **Initial SQL**: Set timezone and date formats

### Performance Optimization
- Use data extracts for large datasets
- Create context filters for geographic regions
- Implement incremental refresh for time-series data
- Use LOD expressions for complex calculations

### Color Schemes
- **Primary**: Professional blue (#1F77B4) for standard data
- **Success**: Green (#2CA02C) for positive indicators
- **Warning**: Orange (#FF7F0E) for caution areas
- **Critical**: Red (#D62728) for high competition/risks
- **Neutral**: Gray (#7F7F7F) for baseline comparisons

### Dashboard Navigation
- Use action filters for drill-down functionality
- Implement dashboard navigation buttons
- Create parameter controls for user customization
- Add tooltip documentation for complex metrics

---

## Portfolio Presentation Strategy

### Storytelling Framework
1. **Problem Statement**: Oregon cannabis market lacks comprehensive intelligence for strategic planning
2. **Data Solution**: Integrated OLCC retailer data with geographic and competitive analysis
3. **Business Impact**: Enable data-driven territory planning and market expansion decisions
4. **Technical Demonstration**: Show data pipeline, SQL views, and Tableau visualization

### Key Skills Demonstrated
- **Data Integration**: Combining disparate data sources (OLCC data, geocoding, market analysis)
- **SQL Development**: Complex views, calculated fields, and aggregations
- **Geographic Analysis**: Spatial calculations, clustering, and mapping
- **Business Intelligence**: Dashboard design, KPI development, and data storytelling
- **Problem Solving**: Addressing real business questions with analytical solutions

### Presentation Tips
- Start with the executive summary dashboard to show immediate value
- Walk through the data pipeline to show technical depth
- Demonstrate interactivity to show user-centered design
- Explain business insights to show analytical thinking
- Discuss future enhancements to show strategic thinking

### Documentation Requirements
- Data dictionary for all calculated fields
- Business rules and assumptions
- Data quality and validation procedures
- Refresh schedule and maintenance procedures
- User guide for dashboard navigation

---

## Next Steps for Implementation

1. **Data Preparation**: Ensure all views are accessible and performant
2. **Dashboard Development**: Build dashboards in Tableau Desktop
3. **Testing**: Validate calculations and interactivity
4. **Documentation**: Create user guides and technical documentation
5. **Presentation**: Prepare portfolio presentation materials
6. **Enhancement**: Add advanced features based on feedback

---

## Contact & Support
For questions about these specifications or implementation guidance, refer to the project documentation or contact the development team.

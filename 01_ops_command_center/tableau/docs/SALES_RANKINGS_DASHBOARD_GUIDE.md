# Sales Rankings Dashboard Guide

**View:** `mart.vw_sales_rankings`  
**Dashboard Purpose:** SKU-level and location-level sales performance analysis with multiple time granularities  
**Tableau Version:** 2023.x or later  

---

## Overview

This guide walks through creating a comprehensive Tableau dashboard using the `mart.vw_sales_rankings` view, which provides SKU-level and location-level sales data with daily, weekly, monthly, and annual granularity. The dashboard enables purchasing behavior analysis, inventory planning, and performance tracking across dispensaries.

---

## Step 1: Connect to Data Source

### Database Connection Setup

1. **Open Tableau Desktop** and select **Connect → To a Server → PostgreSQL**
2. **Enter connection details:**
   - Server: `localhost` (or your PostgreSQL server address)
   - Port: `5432` (or your PostgreSQL port)
   - Database: `althea_ops`
   - Authentication: Username and Password
   - Require SSL: As per your security requirements

3. **Select the view:**
   - Navigate to `mart` schema
   - Select `vw_sales_rankings`
   - Drag to the data canvas

### Initial Data Source Configuration

1. **Set data extract refresh:**
   - Right-click on data source → Extract Data
   - Set refresh schedule: Daily for operational use, Weekly for tactical analysis
   - Enable incremental refresh if data volume is large

2. **Configure data types:**
   - Ensure `sale_date`, `sale_week`, `sale_month` are set to Date
   - Ensure `sale_year` is set to Number or Date
   - Ensure numeric fields (sales, cases, units) are set appropriately
   - Ensure `data_level` is set to String

---

## Step 2: Create Parameters for Dashboard Interactivity

### Time Granularity Parameter

1. **Create Parameter:**
   - Right-click in Data pane → Create Parameter
   - Name: `Time Granularity`
   - Data Type: String
   - Allowable Values: List
   - List of Values:
     - `DAILY_SKU`
     - `WEEKLY_SKU`
     - `MONTHLY_SKU`
     - `ANNUAL_SKU`
     - `DAILY_LOCATION`
     - `WEEKLY_LOCATION`
     - `MONTHLY_LOCATION`
     - `ANNUAL_LOCATION`
   - Current Value: `MONTHLY_SKU`

### Location Selection Parameter

1. **Create Parameter:**
   - Name: `Location Filter`
   - Data Type: String
   - Allowable Values: All
   - Current Value: (All)

### Product Category Parameter

1. **Create Parameter:**
   - Name: `Product Filter`
   - Data Type: String
   - Allowable Values: All
   - Current Value: (All)

### Date Range Parameter

1. **Create Parameter:**
   - Name: `Date Range Start`
   - Data Type: Date
   - Current Value: First date in your data

2. **Create Parameter:**
   - Name: `Date Range End`
   - Data Type: Date
   - Current Value: Current date

---

## Step 3: Create Calculated Fields

### Data Level Filter

```
[Data Level Filter] = [data_level] = [Time Granularity]
```

### Date Filter

```
[Date Filter] = 
IF [Time Granularity] = 'DAILY_SKU' OR [Time Granularity] = 'DAILY_LOCATION' THEN
    [sale_date] >= [Date Range Start] AND [sale_date] <= [Date Range End]
ELSEIF [Time Granularity] = 'WEEKLY_SKU' OR [Time Granularity] = 'WEEKLY_LOCATION' THEN
    [sale_week] >= [Date Range Start] AND [sale_week] <= [Date Range End]
ELSEIF [Time Granularity] = 'MONTHLY_SKU' OR [Time Granularity] = 'MONTHLY_LOCATION' THEN
    [sale_month] >= [Date Range Start] AND [sale_month] <= [Date Range End]
ELSEIF [Time Granularity] = 'ANNUAL_SKU' OR [Time Granularity] = 'ANNUAL_LOCATION' THEN
    [sale_year] >= YEAR([Date Range Start]) AND [sale_year] <= YEAR([Date Range End])
END
```

### Cases Sold Display

```
[Cases Sold Display] = 
IFNULL([adjusted_cases_sold], [total_cases])
```

### Sales Amount Display

```
[Sales Amount Display] = 
IFNULL([adjusted_sku_sales], [total_sales])
```

### Performance Tier Color

```
[Performance Tier Color] = 
IF [performance_tier] = 'Top Performer' THEN 'Green'
ELSEIF [performance_tier] = 'Average Performer' THEN 'Yellow'
ELSEIF [performance_tier] = 'Bottom Performer' THEN 'Red'
ELSE 'Gray'
```

---

## Step 4: Build Dashboard Worksheets

### Worksheet 1: SKU Performance Overview

**Purpose:** Top SKUs by cases sold with rankings

1. **Drag [data_level] to Filters** → Select [Time Granularity] parameter
2. **Drag [Date Filter] to Filters** → Set to True
3. **Drag [location_name] to Filters** → Select specific locations or use [Location Filter] parameter
4. **Drag [product_name] to Filters** → Filter by product category if needed
5. **Drag [sku] to Rows**
6. **Drag [product_name] to Rows**
7. **Drag [Cases Sold Display] to Columns**
8. **Drag [Sales Amount Display] to Columns**
9. **Drag [location_sku_rank] to Tooltip**
10. **Sort by [Cases Sold Display] descending**

**Visualization:** Horizontal bar chart

### Worksheet 2: Location Performance Leaderboard

**Purpose:** Location rankings by sales performance

1. **Drag [data_level] to Filters** → Select location-level values from [Time Granularity] parameter
2. **Drag [Date Filter] to Filters** → Set to True
3. **Drag [location_name] to Rows**
4. **Drag [total_sales] to Columns**
5. **Drag [total_cases] to Columns**
6. **Drag [gross_margin_pct] to Columns**
7. **Drag [county_rank] to Tooltip**
8. **Drag [state_rank] to Tooltip**
9. **Drag [performance_tier] to Color** → Use [Performance Tier Color] calculated field

**Visualization:** Horizontal bar chart with color coding

### Worksheet 3: Time Series Trend Analysis

**Purpose:** Track purchasing patterns over time

1. **Drag [data_level] to Filters** → Select [Time Granularity] parameter
2. **Drag [Date Filter] to Filters** → Set to True
3. **Drag [location_name] to Filters** → Select specific location
4. **Drag [sku] to Filters** → Select specific SKU
5. **Create date field:**
   - If daily: Use [sale_date]
   - If weekly: Use [sale_week]
   - If monthly: Use [sale_month]
   - If annual: Use [sale_year]
6. **Drag date field to Columns** → Set to continuous
7. **Drag [Cases Sold Display] to Rows**
8. **Drag [Sales Amount Display] to Rows** → Dual axis
9. **Add trend lines** → Right-click → Trend Lines → Show Trend Lines

**Visualization:** Dual-axis line chart

### Worksheet 4: Seasonal Pattern Analysis

**Purpose:** Identify seasonal purchasing patterns

1. **Drag [data_level] to Filters** → Select 'MONTHLY_SKU' or 'MONTHLY_LOCATION'
2. **Drag [Date Filter] to Filters** → Set to True
3. **Create [Month] calculated field:** `MONTH([sale_month])`
4. **Create [Month Name] calculated field:** `DATENAME('month', [sale_month])`
5. **Drag [Month Name] to Columns** → Sort by month order
6. **Drag [Cases Sold Display] to Rows**
7. **Drag [location_name] to Color**
8. **Drag [product_name] to Filters** → Select product category

**Visualization:** Line chart with multiple lines per location

### Worksheet 5: Inventory Preparation Heatmap

**Purpose:** Visualize case purchases by SKU and location

1. **Drag [data_level] to Filters** → Select [Time Granularity] parameter
2. **Drag [Date Filter] to Filters** → Set to True
3. **Drag [location_name] to Rows**
4. **Drag [sku] to Columns**
5. **Drag [Cases Sold Display] to Color**
6. **Drag [Cases Sold Display] to Label**
7. **Format color palette** → Use sequential color scheme

**Visualization:** Heatmap

### Worksheet 6: Top/Bottom Performer Analysis

**Purpose:** Compare top vs bottom performing locations/SKUs

1. **Drag [data_level] to Filters** → Select [Time Granularity] parameter
2. **Drag [Date Filter] to Filters** → Set to True
3. **Drag [performance_tier] to Filters** → Select 'Top Performer' and 'Bottom Performer'
4. **Drag [location_name] to Rows**
5. **Drag [total_sales] to Columns**
6. **Drag [gross_margin_pct] to Columns**
7. **Drag [performance_tier] to Color**
8. **Create calculated field [Performance Gap]:**
   ```
   [Performance Gap] = 
   IF [performance_tier] = 'Top Performer' THEN [total_sales]
   ELSEIF [performance_tier] = 'Bottom Performer' THEN -[total_sales]
   END
   ```
9. **Drag [Performance Gap] to Columns** → Create diverging bar chart

**Visualization:** Diverging bar chart

---

## Step 5: Create Dashboard Layout

### Dashboard Structure

**Layout:** 3-column layout with filters on left

**Left Panel (Filters):**
- [Time Granularity] parameter control
- [Location Filter] parameter control
- [Product Filter] parameter control
- [Date Range Start] parameter control
- [Date Range End] parameter control
- [data_level] filter (linked to parameter)

**Center Panel (Main Visualizations):**
- SKU Performance Overview (top)
- Time Series Trend Analysis (middle)
- Location Performance Leaderboard (bottom)

**Right Panel (Supporting Analysis):**
- Seasonal Pattern Analysis (top)
- Inventory Preparation Heatmap (middle)
- Top/Bottom Performer Analysis (bottom)

### Dashboard Actions

1. **Filter Actions:**
   - Click on location in leaderboard → Filter all worksheets
   - Click on SKU in overview → Filter trend analysis and heatmap
   - Select time period → Update all worksheets

2. **Highlight Actions:**
   - Hover over location → Highlight across all worksheets
   - Hover over SKU → Highlight in trend analysis

3. **URL Actions:**
   - Click on SKU → Link to product details page
   - Click on location → Link to location performance report

---

## Step 6: Set Up Interactivity and Navigation

### Parameter Controls

1. **Add parameter controls to dashboard:**
   - Right-click parameter → Show Parameter
   - Position in left filter panel
   - Format as dropdown or button controls

### Tooltip Configuration

**SKU Performance Tooltip:**
```
SKU: [sku]
Product: [product_name]
Cases Sold: [Cases Sold Display]
Sales Amount: [Sales Amount Display]
Location Rank: [location_sku_rank]
County Rank: [county_sku_rank]
Pack Size: [pack_size]
```

**Location Performance Tooltip:**
```
Location: [location_name]
County: [county]
Total Sales: [total_sales]
Total Cases: [total_cases]
Gross Margin: [gross_margin_pct]
County Rank: [county_rank]
State Rank: [state_rank]
Performance Tier: [performance_tier]
```

### Navigation Buttons

1. **Create navigation buttons:**
   - Add button objects for "Daily View", "Weekly View", "Monthly View", "Annual View"
   - Set each button to change [Time Granularity] parameter
   - Format as consistent button group

---

## Step 7: Configure Refresh Schedules

### Data Source Refresh

1. **Set extract refresh schedule:**
   - Right-click data source → Extract Refresh
   - Schedule: Daily at 6:00 AM for operational use
   - Schedule: Weekly on Monday at 7:00 AM for tactical analysis
   - Enable email notifications on refresh failure

### Dashboard Performance Optimization

1. **Use data extracts instead of live connections** for better performance
2. **Enable incremental refresh** if data volume is large
3. **Set up data source filters** to reduce data load
4. **Use context filters** for frequently used dimensions
5. **Hide unused fields** from data pane

---

## Step 8: Publish to Tableau Server/Online

### Publishing Steps

1. **Sign in to Tableau Server/Online**
2. **Select Project:** Ops Command Center
3. **Publish Workbook:**
   - Name: Sales Rankings Dashboard
   - Description: SKU-level and location-level sales performance analysis with multiple time granularities
   - Tags: sales, rankings, SKU, location, inventory, purchasing
   - Permissions: Set appropriate user access levels
4. **Configure embedded credentials** for database connection
5. **Set refresh schedule** on Tableau Server

### Sharing and Distribution

1. **Create subscription schedules:**
   - Daily inventory alerts for store managers
   - Weekly performance summaries for regional managers
   - Monthly strategic reviews for executives
2. **Set up email delivery** with PDF attachments
3. **Embed in internal portals** using Tableau JavaScript API

---

## Step 9: User Training and Documentation

### User Guide Sections

1. **Getting Started:**
   - How to access the dashboard
   - Overview of available parameters
   - Basic navigation

2. **Common Use Cases:**
   - Daily inventory monitoring
   - Weekly purchasing analysis
   - Monthly performance reviews
   - Annual strategic planning
   - Event preparation

3. **Interpretation Guide:**
   - Understanding rankings
   - Reading trend analysis
   - Interpreting seasonal patterns
   - Using the heatmap

4. **Troubleshooting:**
   - Data not refreshing
   - Filters not working
   - Performance issues
   - Access problems

---

## Best Practices

### Performance Optimization

1. **Use extracts** instead of live connections for better performance
2. **Limit data scope** with filters rather than loading all data
3. **Use context filters** for frequently used dimensions
4. **Avoid complex calculations** in filters
5. **Optimize data source** with appropriate indexes

### Design Best Practices

1. **Consistent color coding** across all worksheets
2. **Clear labeling** of all axes and measures
3. **Responsive tooltips** with relevant information
4. **Logical layout** following user workflow
5. **Mobile-friendly design** for on-the-go access

### Data Quality

1. **Monitor data freshness** with refresh schedules
2. **Validate calculations** against source data
3. **Set up alerts** for data quality issues
4. **Document data lineage** and transformation logic
5. **Regular audits** of ranking calculations

---

## Advanced Features

### Set Actions

1. **Create set for top 10 SKUs:**
   - Right-click [sku] → Create → Set
   - Condition: By field → [location_sku_rank] ≤ 10
   - Use set to filter other worksheets

### LOD Expressions

1. **Create LOD for average performance:**
   ```
   [Avg Sales by Location] = {FIXED [location_name]: AVG([total_sales])}
   ```
   - Use to compare individual locations against average

### Parameter Driven Calculations

1. **Create dynamic measures based on parameter:**
   ```
   [Selected Measure] = 
   CASE [Measure Parameter]
   WHEN 'Cases' THEN [Cases Sold Display]
   WHEN 'Sales' THEN [Sales Amount Display]
   WHEN 'Units' THEN [total_units]
   END
   ```

---

## Maintenance and Updates

### Regular Maintenance Tasks

1. **Weekly:** Check refresh schedules and error logs
2. **Monthly:** Review user feedback and usage statistics
3. **Quarterly:** Update parameter values and filter options
4. **Annually:** Review and optimize dashboard performance

### Update Process

1. **Test changes** in development environment first
2. **Document changes** in version control
3. **Communicate updates** to dashboard users
4. **Monitor performance** after deployment
5. **Roll back plan** for critical issues

---

## Troubleshooting

### Common Issues

**Issue: Dashboard not refreshing**
- Solution: Check extract refresh schedule, verify database connectivity

**Issue: Filters not working correctly**
- Solution: Verify parameter configurations, check filter actions

**Issue: Slow performance**
- Solution: Use data extracts, optimize calculations, reduce data scope

**Issue: Incorrect rankings**
- Solution: Verify data source calculations, check for data quality issues

**Issue: Users can't access dashboard**
- Solution: Check Tableau Server permissions, verify user authentication

---

## Support and Resources

### Internal Resources

- **Data Team:** For data quality and calculation issues
- **IT Support:** For Tableau Server access and performance
- **Business Analysts:** For interpretation and use case questions

### External Resources

- Tableau Documentation: https://help.tableau.com
- Tableau Community: https://community.tableau.com
- PostgreSQL Documentation: https://www.postgresql.org/docs/

---

## Appendix: Quick Reference

### Parameter Quick Reference

- **Time Granularity:** Switch between daily/weekly/monthly/annual views
- **Location Filter:** Filter by specific dispensary
- **Product Filter:** Filter by product category
- **Date Range:** Set custom date range for analysis

### Data Level Quick Reference

- **DAILY_SKU:** Daily SKU-level data
- **WEEKLY_SKU:** Weekly SKU-level data
- **MONTHLY_SKU:** Monthly SKU-level data
- **ANNUAL_SKU:** Annual SKU-level data
- **DAILY_LOCATION:** Daily location aggregates
- **WEEKLY_LOCATION:** Weekly location aggregates
- **MONTHLY_LOCATION:** Monthly location aggregates
- **ANNUAL_LOCATION:** Annual location aggregates

### Key Measures Quick Reference

- **Cases Sold:** Units ÷ Pack Size (with variation applied)
- **Sales Amount:** Net sales amount (with variation applied)
- **Gross Margin:** (Sales - COGS) ÷ Sales
- **Rankings:** Within location/county/state by time period

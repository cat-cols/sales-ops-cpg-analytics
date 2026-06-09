# Data Trust & Quality Dashboard Guide

**Project:** 01_ops_command_center - Business Analyst Portfolio  
**Dashboard:** Data Trust & Quality Dashboard  
**Platform:** Tableau Desktop  
**Data Source:** PostgreSQL CTE (mart.vw_data_quality)  
**Purpose:** Data governance and trust indicators for portfolio credibility using optimized CTE

---

## Overview

This guide walks through building the Data Trust & Quality Dashboard for your business analyst portfolio. This dashboard demonstrates advanced SQL CTE optimization, data governance capabilities, and quality assurance processes using pre-calculated quality metrics.

**Business Value:** Enable data-driven trust assessment, identify data quality issues proactively, and demonstrate data governance maturity for portfolio credibility and stakeholder confidence.

---

## Data Source

### Primary Data Source: mart.vw_data_quality

**Purpose:** Pre-calculated data quality metrics using CTE for trust indicators

**Key Fields:**
- `table_name` - Name of the table (olcc_retailers, fact_sales, dim_location)
- `data_domain` - Business domain description
- `total_records` - Total number of records in table
- `missing_latitude` - Count of records missing latitude
- `missing_longitude` - Count of records missing longitude
- `missing_city` - Count of records missing city
- `missing_county` - Count of records missing county
- `missing_zip` - Count of records missing zip code
- `active_records` - Count of active/valid records
- `missing_keys` - Count of records missing primary keys
- `unique_keys` - Count of unique key values
- `duplicate_keys` - Count of duplicate key values
- `geocoding_completeness_pct` - Percentage of records with geocoding
- `city_completeness_pct` - Percentage of records with city data
- `check_timestamp` - When quality check was performed
- `overall_quality_score` - Composite quality score (0-100)
- `quality_status` - Quality classification (EXCELLENT, GOOD, FAIR, POOR)
- `attention_required` - Issues requiring attention

**CTE Optimization Benefits:**
- Quality metrics pre-calculated in SQL for instant Tableau performance
- Composite quality scoring done server-side
- Quality status classifications pre-determined
- Eliminates complex quality calculations in Tableau

---

## Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│               DATA TRUST & QUALITY DASHBOARD                 │
├─────────────────────────────────────────────────────────────┤
│  [Overall Quality Score: 94.2]  [Status: EXCELLENT]         │
│  [Last Check: 2026-06-08 21:45:00]  [Tables: 3]            │
├─────────────────────────────────────────────────────────────┤
│  Overall Quality Score Gauge                                 │
│  [Gauge Chart: overall_quality_score with quality_status]    │
│  Color-coded by quality status (Green/Blue/Yellow/Red)       │
├─────────────────────────────────────────────────────────────┤
│  Quality by Domain Comparison                                 │
│  [Bar Chart: overall_quality_score by data_domain]           │
│  Color: quality_status                                       │
├─────────────────────────────────────────────────────────────┤
│  Completeness Metrics                                        │
│  [Progress Bars: geocoding_completeness_pct, city_completeness_pct]│
│  Group by table_name                                         │
├─────────────────────────────────────────────────────────────┤
│  Data Quality Issues Tracking                                 │
│  [Highlight Table: table_name, attention_required, missing_keys, duplicate_keys]│
├─────────────────────────────────────────────────────────────┤
│  Record Volume Analysis                                      │
│  [Bar Chart: total_records by table_name]                    │
│  Show active_records vs total_records                        │
├─────────────────────────────────────────────────────────────┤
│  Key Data Integrity                                          │
│  [Bar Chart: unique_keys vs duplicate_keys by table_name]    │
├─────────────────────────────────────────────────────────────┤
│  Missing Data Analysis                                       │
│  [Stacked Bar: missing_latitude, missing_longitude, missing_city, missing_county]│
├─────────────────────────────────────────────────────────────┤
│  Quality Status Distribution                                 │
│  [Pie Chart: quality_status distribution]                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Connect to Data (5 minutes)

1. **Open Tableau Desktop**
2. **Add Data Source:**
   - In Data Source tab, expand `althea_ops` → `mart` schema
   - Drag `vw_data_quality` to the canvas
   - Verify connection shows all fields
   - Check that quality metrics are populated

### Step 2: Create Overall Quality Score Gauge (15 minutes)

1. **Create New Sheet:** "Overall Quality Gauge"
2. **Build Gauge Chart:**
   - Drag `overall_quality_score` to Rows
   - Change mark type to "Gauge"
   - Set gauge range: 0-100
   - Drag `quality_status` to Color
   - Add reference lines: 90 (Excellent), 80 (Good), 70 (Fair)
   - Add title: "Overall Data Quality Score"

3. **Enhance Visualization:**
   - Set color palette: Green (>90), Blue (80-90), Yellow (70-80), Red (<70)
   - Add check_timestamp to tooltip
   - Add total_records to tooltip
   - Format as percentage with 1 decimal

### Step 3: Create Quality by Domain Comparison (10 minutes)

1. **Create New Sheet:** "Quality by Domain"
2. **Build Bar Chart:**
   - Drag `data_domain` to Columns
   - Drag `overall_quality_score` to Rows
   - Sort descending by overall_quality_score
   - Drag `quality_status` to Color
   - Drag `table_name` to Tooltip
   - Drag `total_records` to Tooltip

3. **Enhance Visualization:**
   - Add labels to bars showing quality scores
   - Add reference line for average quality score
   - Add title: "Quality Score by Data Domain"
   - Use same color palette as gauge

### Step 4: Create Completeness Metrics (15 minutes)

1. **Create New Sheet:** "Completeness Metrics"
2. **Build Progress Bars:**
   - Drag `table_name` to Columns
   - Drag `geocoding_completeness_pct` to Rows
   - Change mark type to "Bar"
   - Add reference line at 100%
   - Drag `city_completeness_pct` to Rows (dual axis)
   - Synchronize axes
   - Add title: "Data Completeness by Table"

3. **Enhance Visualization:**
   - Color by completeness level (>95% green, 80-95% yellow, <80% red)
   - Add percentage labels to bars
   - Add tooltip with specific completeness metrics
   - Use stacked bars to show both metrics

### Step 5: Create Data Quality Issues Tracking (15 minutes)

1. **Create New Sheet:** "Quality Issues"
2. **Build Highlight Table:**
   - Drag `table_name` to Rows
   - Drag `attention_required` to Columns
   - Drag `missing_keys` to Text
   - Drag `duplicate_keys` to Text
   - Drag `overall_quality_score` to Color
   - Add title: "Data Quality Issues Requiring Attention"

3. **Enhance Visualization:**
   - Format as highlight table
   - Add conditional formatting for quality scores
   - Add total_records to tooltip
   - Sort by overall_quality_score ascending (worst first)

### Step 6: Create Record Volume Analysis (10 minutes)

1. **Create New Sheet:** "Record Volume"
2. **Build Stacked Bar Chart:**
   - Drag `table_name` to Columns
   - Drag `total_records` to Rows
   - Drag `active_records` to Rows (stacked)
   - Add table calculation for percent of total
   - Add title: "Record Volume by Table"

3. **Enhance Visualization:**
   - Color by record type (total vs active)
   - Add percentage labels
   - Add tooltip with record counts
   - Add reference line for average record count

### Step 7: Create Key Data Integrity (10 minutes)

1. **Create New Sheet:** "Data Integrity"
2. **Build Side-by-Side Bar Chart:**
   - Drag `table_name` to Columns
   - Drag `unique_keys` to Rows
   - Drag `duplicate_keys` to Rows (dual axis)
   - Synchronize axes
   - Add title: "Key Data Integrity Analysis"

3. **Enhance Visualization:**
   - Color by key type (unique vs duplicate)
   - Add labels showing key counts
   - Add tooltip with key statistics
   - Add reference line for duplicate threshold

### Step 8: Create Missing Data Analysis (10 minutes)

1. **Create New Sheet:** "Missing Data"
2. **Build Stacked Bar Chart:**
   - Drag `table_name` to Columns
   - Drag `missing_latitude` to Rows
   - Drag `missing_longitude` to Rows (stacked)
   - Drag `missing_city` to Rows (stacked)
   - Drag `missing_county` to Rows (stacked)
   - Add title: "Missing Data Analysis by Table"

3. **Enhance Visualization:**
   - Color by missing data type
   - Add labels showing missing counts
   - Add tooltip with missing data details
   - Add reference line for acceptable missing threshold

### Step 9: Create Quality Status Distribution (10 minutes)

1. **Create New Sheet:** "Quality Distribution"
2. **Build Pie Chart:**
   - Drag `quality_status` to Color
   - Drag `COUNT(table_name)` to Angle
   - Change mark type to Pie
   - Add percentage labels
   - Add title: "Quality Status Distribution"

3. **Enhance Visualization:**
   - Use distinct colors for each quality status
   - Add count labels
   - Add tooltip with table details
   - Add donut chart style for modern look

### Step 10: Create KPI Cards (10 minutes)

1. **Create New Sheet:** "KPI Cards"
2. **Build KPI 1 - Overall Quality:**
   - Drag `AVG(overall_quality_score)` to Text
   - Format as percentage with 1 decimal
   - Add label: "Overall Quality Score"

3. **Build KPI 2 - Quality Status:**
   - Create calculated field: `[Primary Status] = FIXED() : MAX([quality_status])`
   - Drag to Text
   - Add label: "Quality Status"

4. **Build Additional KPIs:**
   - Total Tables (COUNTD of table_name)
   - Tables with Issues (COUNTD where attention_required != 'No critical issues')
   - Average Completeness (AVG of geocoding_completeness_pct)

### Step 11: Assemble Dashboard (15 minutes)

1. **Create Dashboard:** "Data Trust & Quality Dashboard"
2. **Set Layout:**
   - Size: Automatic (or 1200x900 for fixed)
   - Background: Light gray or white

3. **Add Sheets:**
   - Drag "KPI Cards" to top row
   - Drag "Overall Quality Gauge" to middle-left (main section)
   - Drag "Quality by Domain" to middle-right
   - Drag "Completeness Metrics" to bottom-left
   - Drag "Quality Issues" to bottom-center
   - Drag "Record Volume" to bottom-right
   - Drag "Data Integrity", "Missing Data", and "Quality Distribution" to bottom (optional)

4. **Add Filters:**
   - Drag `table_name` to Filters
   - Drag `quality_status` to Filters
   - Drag `attention_required` to Filters
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

5. **Add Interactivity:**
   - Use filter actions: Click on table → filter other views
   - Use highlight actions: Hover over quality status → highlight tables
   - Add tooltip enhancements

6. **Add Title and Description:**
   - Dashboard title: "Data Trust & Quality Dashboard"
   - Subtitle: "Data governance and trust indicators using CTE-optimized quality metrics"
   - Add data source note: "Source: mart.vw_data_quality CTE"
   - Add refresh note: "Quality checks run automatically"

---

## Calculated Fields Reference

### Quality Analysis Calculations

```tableau
// Quality Score Trend (if historical data available)
[Quality Trend] = 
LOOKUP([overall_quality_score], -1) - [overall_quality_score]

// Completeness Gap Analysis
[Completeness Gap] = 100 - [geocoding_completeness_pct]

// Data Integrity Score
[Integrity Score] = [unique_keys] / ([unique_keys] + [duplicate_keys]) * 100

// Issue Severity Score
[Issue Severity] = 
IF [attention_required] = 'No critical issues' THEN 0
ELSEIF [attention_required] = 'Missing key values' THEN 1
ELSEIF [attention_required] = 'Duplicate key issues' THEN 2
ELSEIF [attention_required] = 'Missing location data' THEN 3
ELSE 4 END

// Quality Improvement Potential
[Improvement Potential] = 100 - [overall_quality_score]

// Trust Score (weighted quality metrics)
[Trust Score] = 
([overall_quality_score] * 0.4) + 
([geocoding_completeness_pct] * 0.3) + 
([city_completeness_pct] * 0.3)
```

### Advanced Analysis Calculations

```tableau
// Data Freshness Indicator
[Data Freshness] = 
DATEDIFF('minute', [check_timestamp], NOW())

// Quality Threshold Breach
[Threshold Breach] = 
IF [overall_quality_score] < 90 THEN "Below Excellent Threshold"
ELSEIF [overall_quality_score] < 80 THEN "Below Good Threshold"
ELSEIF [overall_quality_score] < 70 THEN "Below Fair Threshold"
ELSE "All Thresholds Met" END

// Critical Issues Count
[Critical Issues] = 
[missing_keys] + [duplicate_keys] + 
[missing_latitude] + [missing_longitude]

// Data Domain Health
[Domain Health] = 
CASE [data_domain]
WHEN 'Retailer License Data' THEN [geocoding_completeness_pct]
WHEN 'Sales Transaction Data' THEN 100
WHEN 'Location Reference Data' THEN [city_completeness_pct]
END

// Quality Trend Direction
[Trend Direction] = 
SIGN([Quality Trend])
```

---

## Interactivity and Actions

### Filter Actions

**Table Filter:**
- Click on table name → filter all views to show specific table
- Show detailed quality metrics for selected table

**Quality Status Filter:**
- Select quality status → highlight tables with that status
- Filter quality distribution to show only selected status

**Attention Required Filter:**
- Select issue type → filter quality issues to show specific problems
- Useful for issue prioritization

### Highlight Actions

**Quality Status Highlight:**
- Hover over quality status → highlight tables with that status
- Show comprehensive quality profile across all visualizations

**Table Highlight:**
- Click on table → highlight same table in other views
- Useful for detailed table analysis

### Tooltip Enhancements

**Overall Quality Gauge Tooltip:**
- Overall quality score
- Quality status classification
- Last check timestamp
- Total records across all tables
- Tables with issues count

**Completeness Metrics Tooltip:**
- Table name
- Geocoding completeness percentage
- City completeness percentage
- Total records
- Missing data details

**Quality Issues Tooltip:**
- Table name
- Attention required description
- Missing keys count
- Duplicate keys count
- Overall quality score
- Quality status

---

## Performance Optimization

### CTE Benefits

**Pre-calculated Quality Metrics:**
- Quality scoring done in SQL
- Completeness calculations computed server-side
- Quality status classifications pre-determined
- Instant filtering and sorting

**Server-Side Processing:**
- Complex quality calculations executed in PostgreSQL
- Eliminates complex table calculations in Tableau
- Consistent quality logic across all views
- Reduced Tableau Desktop memory usage

**Real-Time Quality Monitoring:**
- Quality checks run automatically
- Timestamp tracking for freshness
- Consistent measurement methodology
- Scalable to additional data sources

### Tableau Optimization

**Extract Usage:**
- Create extract for better performance
- Schedule extract refreshes with quality checks
- Use extract filters for large datasets

**Context Filters:**
- Use quality_status as context filter
- Reduces query complexity
- Improves interactivity

**Data Source Filters:**
- Filter to active tables only
- Remove unnecessary data at source
- Improve overall performance

---

## Testing Checklist

### Data Validation
- [ ] Quality scores match SQL CTE results
- [ ] Quality status classifications are consistent
- [ ] Completeness percentages are accurate
- [ ] Missing data counts are correct

### Visualization Testing
- [ ] Quality gauge displays correctly
- [ ] Completeness progress bars show proper percentages
- [ ] Quality issues table highlights critical issues
- [ ] Quality distribution pie chart shows correct proportions

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
- "Used CTEs to pre-calculate quality metrics for optimal performance"
- "Implemented comprehensive data governance framework with trust indicators"
- "Created automated quality scoring and classification system"
- "Built scalable data quality monitoring solution"

**Business Impact:**
- "Enables proactive data quality management"
- "Provides trust indicators for stakeholder confidence"
- "Supports data-driven decision-making with quality assurance"
- "Demonstrates data governance maturity"

**Problem Solving:**
- "Optimized dashboard performance through CTE pre-calculation"
- "Created comprehensive data quality framework"
- "Balanced technical complexity with business usability"
- "Implemented scalable solution for data governance"

### Presentation Structure

**Technical Depth (2 minutes):**
- Explain CTE architecture and optimization benefits
- Show quality scoring calculations and classification logic
- Demonstrate performance improvements

**Business Value (2 minutes):**
- Explain data governance use cases
- Show how dashboard supports quality assurance
- Discuss stakeholder confidence and trust building

**Portfolio Integration (1 minute):**
- Highlight advanced SQL skills with quality CTEs
- Demonstrate Tableau optimization techniques
- Show data governance and trust capabilities

---

## Next Steps

1. **Build Dashboard** - Follow implementation steps
2. **Test Performance** - Verify CTE optimization benefits
3. **Add Historical Tracking** - Incorporate time-based quality trends
4. **Enhance Interactivity** - Add drill-through to detailed table analysis
5. **Publish and Share** - Add to portfolio and Tableau Public

---

*This guide provides step-by-step instructions for building a data trust and quality dashboard that demonstrates advanced SQL CTE optimization and data governance techniques for portfolio development.*

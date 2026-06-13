# Inventory Optimization Dashboard Guide

**Project:** 01_ops_command_center - Business Analyst Portfolio
**Dashboard:** Inventory Optimization Dashboard
**Platform:** Tableau Desktop
**Data Source:** PostgreSQL (mart.vw_sales_rankings)
**Purpose:** Operational inventory management and optimization for supply chain efficiency

---

## Business Context

**Business Question:** "Are we stocking the right products in the right locations?"

**Target Audience:** Inventory managers, buyers, supply chain managers, operations managers

**Decision Impact:** Purchasing decisions, stock allocation, waste reduction, customer satisfaction

**Time Horizon:** Weekly operational review, monthly strategic planning

---

## Dashboard Objectives

### Primary Objectives
1. **Optimize inventory levels** to balance stockouts and overstock situations
2. **Identify product performance patterns** for better purchasing decisions
3. **Reduce inventory waste** through data-driven allocation
4. **Improve customer satisfaction** through better product availability

### Secondary Objectives
1. **Track seasonal patterns** for proactive inventory planning
2. **Compare location performance** for best practice sharing
3. **Support purchasing decisions** with SKU-level insights
4. **Enable event-based planning** for holidays and promotions

---

## Key Business Metrics

### Inventory Health Metrics (Top Row)
- **Total Cases Sold:** Aggregate cases across network
- **Stockout Rate:** Percentage of SKUs out of stock
- **Overstock Rate:** Percentage of SKUs overstocked
- **Inventory Turnover:** Rate of inventory movement
- **Waste Reduction:** Year-over-year waste reduction percentage

### Product Performance Metrics (Middle Section)
- **Top SKUs by Cases:** Best-selling products by volume
- **SKU Performance Distribution:** Sales distribution across product categories
- **Seasonal Patterns:** Product performance by season/month
- **Pack Size Analysis:** Performance by packaging configuration

### Location Performance Metrics (Bottom Section)
- **Location Inventory Health:** Stockout/overstock by location
- **Regional Inventory Comparison:** Performance by geographic region
- **Purchasing Patterns:** Case purchase trends over time
- **Optimization Opportunities:** Locations requiring inventory attention

---

## Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│            INVENTORY OPTIMIZATION DASHBOARD               │
├─────────────────────────────────────────────────────────────┤
│  [Time Period: Weekly ▼]  [Region: All ▼]  [Category: All ▼]│
├─────────────────────────────────────────────────────────────┤
│  Inventory Health KPIs                                    │
│  [Total Cases: 12.4K]  [Stockout Rate: 8%]  [Overstock: 12%]│
│  [Turnover: 4.2x]  [Waste Reduction: +15%]  [Active SKUs: 245]│
├─────────────────────────────────────────────────────────────┤
│  Top SKUs by Cases Sold                                    │
│  [Bar Chart: SKUs ranked by cases sold]                   │
│  Color: Product category, Size: Sales revenue            │
├─────────────────────────────────────────────────────────────┤
│  SKU Performance Distribution                             │
│  [Treemap: Product categories with case volume]           │
│  [Histogram: Cases distribution by pack size]              │
├─────────────────────────────────────────────────────────────┤
│  Seasonal Pattern Analysis                                │
│  [Line Chart: Cases sold by month over 12 months]         │
│  [Heatmap: SKU performance by month and category]          │
├─────────────────────────────────────────────────────────────┤
│  Location Inventory Health                                │
│  [Map: Geographic inventory health by location]           │
│  [Bar Chart: Locations ranked by stockout rate]           │
├─────────────────────────────────────────────────────────────┤
│  Purchasing Trends and Optimization                        │
│  [Line Chart: Weekly case purchases over time]             │
│  [Scatter Plot: Sales vs cases by location]               │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Business Requirements Gathering (2-3 days)

**Stakeholder Interviews:**
- **Inventory Manager:** What inventory challenges do you face daily? What metrics help you make purchasing decisions?
- **Buyers:** What information do you need for purchasing decisions? How do you track product performance?
- **Supply Chain Manager:** What are your key inventory KPIs? What optimization opportunities exist?
- **Operations Manager:** How does inventory impact store operations and customer satisfaction?

**Key Questions to Ask:**
- What are your top 3 inventory challenges?
- How do you currently decide what to purchase and in what quantities?
- What information is missing or hard to access for inventory decisions?
- How do seasonal patterns affect your purchasing decisions?
- What metrics would help you reduce stockouts and overstock situations?
- How often do you need to review inventory performance?

**Document Requirements:**
- Create requirements document with stakeholder needs
- Prioritize metrics by business impact
- Define success criteria for dashboard adoption
- Establish data freshness requirements for operational decisions

### Step 2: Data Source Preparation (1 day)

**Connect to Data Source:**
1. Open Tableau Desktop
2. Connect to PostgreSQL database `althea_ops`
3. Navigate to `mart` schema
4. Select `vw_sales_rankings` view
5. Verify data quality and completeness for SKU-level analysis

**Data Validation:**
- Check for missing values in SKU and product fields
- Verify case calculations are accurate (units ÷ pack_size)
- Confirm pack_size data is complete
- Validate seasonal variation patterns are reasonable
- Test data refresh functionality

**Create Data Extract:**
- Extract data for improved performance
- Set refresh schedule (daily for operational, weekly for strategic)
- Configure incremental refresh if data volume is large
- Test extract refresh functionality

### Step 3: Create Inventory Health KPIs (2 hours)

**Worksheet: Inventory Health Summary**

1. **Total Cases Sold:**
   - Create calculated field: `[Total Cases] = SUM([adjusted_cases_sold])`
   - Filter to `data_level = 'WEEKLY_SKU'` or `MONTHLY_SKU`
   - Format as appropriate number format
   - Add comparison to previous period

2. **Stockout Rate:**
   - Create calculated field for low-stock SKU identification
   - Use threshold based on business requirements (e.g., cases < 10)
   - Calculate percentage of SKUs below threshold
   - Format as percentage with color coding

3. **Overstock Rate:**
   - Create calculated field for overstock identification
   - Use threshold based on business requirements (e.g., cases > 100)
   - Calculate percentage of SKUs above threshold
   - Format as percentage with color coding

4. **Inventory Turnover:**
   - Create calculated field: `[Turnover] = [Total Cases] / [Average Inventory]`
   - Filter to current period
   - Format as decimal (e.g., 4.2x)
   - Add comparison to industry benchmark

5. **Waste Reduction:**
   - Create calculated field for year-over-year comparison
   - Use LOOKUP() function for period-over-period comparison
   - Format as percentage with color coding
   - Add trend indicator

### Step 4: Create Top SKUs by Cases (2 hours)

**Worksheet: Top SKUs Leaderboard**

1. **Build SKU Leaderboard:**
   - Drag `sku` to Rows
   - Drag `product_name` to Rows
   - Drag `adjusted_cases_sold` to Columns
   - Sort descending by cases sold
   - Limit to top 15 SKUs
   - Drag `pack_size` to Tooltip
   - Drag `adjusted_sku_sales` to Tooltip

2. **Enhance Visualization:**
   - Add labels showing cases and sales amounts
   - Color by product category if available
   - Size by sales revenue
   - Add reference line for average cases
   - Add title: "Top SKUs by Cases Sold"
   - Add subtitle: "Weekly case volume with sales revenue"

3. **Add Context:**
   - Create calculated field for cases vs average
   - Include pack size information
   - Add product category context
   - Include location performance context

### Step 5: Create SKU Performance Distribution (2 hours)

**Worksheet: Product Category Treemap**

1. **Build Treemap:**
   - Drag `product_name` to Color (or category if available)
   - Drag `SUM([adjusted_cases_sold])` to Size
   - Change mark type to Square
   - Drag `COUNT([sku])` to Label
   - Add labels showing category, count, and case volume

2. **Enhance Treemap:**
   - Set color palette for product categories
   - Add percentage labels for volume contribution
   - Include SKU count per category
   - Add title: "Product Category Case Distribution"

**Worksheet: Pack Size Analysis**

1. **Build Histogram:**
   - Drag `pack_size` to Columns
   - Drag `SUM([adjusted_cases_sold])` to Rows
   - Change mark type to Bar
   - Add title: "Case Distribution by Pack Size"

2. **Enhance Analysis:**
   - Add average pack size reference line
   - Include SKU count by pack size
   - Add sales revenue context
   - Color by performance tier

### Step 6: Create Seasonal Pattern Analysis (2 hours)

**Worksheet: Seasonal Trend Analysis**

1. **Build Time Series:**
   - Drag `sale_month` to Columns (continuous)
   - Drag `SUM([adjusted_cases_sold])` to Rows
   - Drag `product_name` to Color
   - Change mark type to Line
   - Add trend lines
   - Add title: "Seasonal Case Purchasing Patterns"

2. **Enhance Trend Analysis:**
   - Add moving averages for smoothing
   - Include seasonal reference lines (holidays, events)
   - Add growth rate annotations
   - Color-code by product category

**Worksheet: Seasonal Heatmap**

1. **Build Heatmap:**
   - Drag `sale_month` to Columns
   - Drag `product_name` to Rows
   - Drag `SUM([adjusted_cases_sold])` to Color
   - Change mark type to Square
   - Add title: "SKU Seasonal Performance Heatmap"

2. **Enhance Heatmap:**
   - Set color scale for case volume
   - Add month labels
   - Include product category grouping
   - Add seasonal annotations

### Step 7: Create Location Inventory Health (2 hours)

**Worksheet: Location Inventory Map**

1. **Build Geographic View:**
   - Drag `state` to Marks → Map
   - Drag `SUM([adjusted_cases_sold])` to Size
   - Drag `COUNT([sku])` to Color
   - Drag `location_name` to Tooltip
   - Add county-level detail if available

2. **Enhance Map:**
   - Add regional labels
   - Set color scale for SKU variety
   - Add size scale for case volume
   - Include regional totals in tooltips
   - Add title: "Location Inventory Distribution"

**Worksheet: Stockout Analysis**

1. **Build Stockout Leaderboard:**
   - Drag `location_name` to Rows
   - Create calculated field for low-stock identification
   - Drag stockout rate to Columns
   - Sort descending by stockout rate
   - Limit to top 10 locations
   - Add title: "Locations with Highest Stockout Risk"

2. **Enhance Analysis:**
   - Add context on total SKUs per location
   - Include performance tier information
   - Add regional comparison
   - Color code by severity

### Step 8: Create Purchasing Trends (2 hours)

**Worksheet: Purchasing Trend Analysis**

1. **Build Trend Line:**
   - Drag `sale_week` to Columns (continuous)
   - Drag `SUM([adjusted_cases_sold])` to Rows
   - Drag `location_name` to Color
   - Change mark type to Line
   - Add trend lines
   - Add title: "Weekly Case Purchasing Trends"

2. **Enhance Trend Analysis:**
   - Add moving averages for smoothing
   - Include reference lines for targets
   - Add growth rate annotations
   - Color-code by region

**Worksheet: Efficiency Analysis**

1. **Build Scatter Plot:**
   - Drag `SUM([adjusted_sku_sales])` to Columns
   - Drag `SUM([adjusted_cases_sold])` to Rows
   - Change mark type to Circle
   - Drag `location_name` to Tooltip
   - Drag `performance_tier` to Color
   - Add title: "Sales vs Cases Efficiency Analysis"

2. **Enhance Analysis:**
   - Add trend line
   - Add quadrant lines for efficiency analysis
   - Add efficiency ratio calculations
   - Include optimization recommendations

### Step 9: Assemble Inventory Dashboard (2 hours)

**Dashboard Layout:**

1. **Create Dashboard:** "Inventory Optimization Dashboard"
2. **Set Layout:**
   - Size: 1400x1000 (operational-friendly format)
   - Background: Professional light theme for readability
   - Font: Clean, professional sans-serif

3. **Add Filters:**
   - Drag `sale_month` to Filters (date range selector)
   - Drag `state` to Filters (regional selector)
   - Drag `product_name` to Filters (category selector)
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

4. **Add Parameter Controls:**
   - Create time period parameter (Weekly/Monthly/Quarterly)
   - Create regional scope parameter (All/Specific Region)
   - Create category scope parameter (All/Specific Category)
   - Add parameter controls to dashboard header
   - Format as professional dropdown selectors

5. **Add Sheets:**
   - Drag "Inventory Health Summary" to top row
   - Drag "Top SKUs Leaderboard" to middle-left
   - Drag "SKU Performance Distribution" to middle-center
   - Drag "Seasonal Pattern Analysis" to middle-right
   - Drag "Location Inventory Health" to bottom-left
   - Drag "Purchasing Trends" to bottom-right

6. **Add Interactivity:**
   - Use filter actions: Click on region → filter all views
   - Use filter actions: Click on product category → filter SKU views
   - Use highlight actions: Hover over SKU → highlight across views
   - Add tooltip enhancements with operational language
   - Add navigation buttons for drill-down views

7. **Add Title and Branding:**
   - Dashboard title: "Inventory Optimization Dashboard"
   - Subtitle: "SKU-Level Inventory Management and Optimization"
   - Add last updated timestamp
   - Include data source attribution
   - Add company branding if applicable

### Step 10: Create Business Narrative (2 hours)

**Inventory Summary Document:**

1. **Inventory Health Overview:**
   - Summarize overall inventory performance
   - Highlight stockout and overstock concerns
   - Provide context for key metrics
   - Include operational summary bullet points

2. **Product Performance Insights:**
   - Identify top-performing SKUs and categories
   - Analyze seasonal patterns and trends
   - Highlight pack size optimization opportunities
   - Provide purchasing recommendations

3. **Location Performance Analysis:**
   - Identify locations with inventory challenges
   - Compare regional performance
   - Highlight best practices from top performers
   - Provide location-specific recommendations

4. **Optimization Recommendations:**
   - Prioritize 3-5 actionable inventory recommendations
   - Include expected cost savings and efficiency gains
   - Suggest timeline for implementation
   - Identify responsible parties

---

## Business Value Communication

### Operational Presentation Structure

**Slide 1: Inventory Health Summary (2 minutes)**
- Dashboard purpose and audience
- Key inventory metrics at a glance
- Overall inventory health assessment
- Top 3 insights and recommendations

**Slide 2: Product Performance Overview (3 minutes)**
- Top SKUs and categories by case volume
- Seasonal patterns and trends
- Pack size optimization opportunities
- Purchasing recommendations

**Slide 3: Location Inventory Analysis (3 minutes)**
- Geographic inventory distribution
- Stockout and overstock hotspots
- Regional performance comparison
- Location-specific recommendations

**Slide 4: Optimization Action Plan (2 minutes)**
- Specific inventory actions required
- Timeline and responsibilities
- Expected cost savings and efficiency gains
- Follow-up and monitoring plan

### Stakeholder Communication

**For Inventory Manager:**
- Focus on daily operational challenges
- Highlight stockout prevention opportunities
- Provide actionable purchasing recommendations
- Include inventory turnover optimization

**For Buyers:**
- Focus on purchasing decision support
- Provide SKU-level performance insights
- Highlight seasonal planning opportunities
- Include pack size optimization recommendations

**For Supply Chain Manager:**
- Focus on supply chain efficiency
- Highlight waste reduction opportunities
- Provide regional allocation insights
- Include inventory optimization strategies

**For Operations Manager:**
- Focus on customer satisfaction impact
- Highlight availability improvements
- Provide operational efficiency insights
- Include store-level recommendations

---

## Success Metrics

### Dashboard Adoption Metrics
- **Usage Frequency:** Number of unique users per week
- **Session Duration:** Average time spent per session
- **Feature Usage:** Which features are used most frequently
- **User Feedback:** Satisfaction scores and qualitative feedback

### Business Impact Metrics
- **Stockout Reduction:** Percentage reduction in stockout situations
- **Overstock Reduction:** Percentage reduction in overstock situations
- **Waste Reduction:** Quantified cost savings from reduced waste
- **Inventory Turnover:** Improvement in inventory turnover rate

### Operational Efficiency Metrics
- **Decision Speed:** Time from data access to purchasing decision
- **Order Accuracy:** Improvement in order accuracy and fulfillment
- **Cost Savings:** Quantified cost reductions from optimization
- **Customer Satisfaction:** Improvement in product availability metrics

---

## Maintenance and Enhancement

### Regular Maintenance Tasks

**Weekly:**
- Monitor data refresh schedules
- Check for data quality issues
- Review user feedback and usage patterns
- Address any technical issues

**Monthly:**
- Review inventory metrics for relevance
- Update seasonal patterns and benchmarks
- Gather stakeholder feedback
- Plan enhancements based on usage patterns

**Quarterly:**
- Comprehensive business value review
- Stakeholder satisfaction assessment
- Cost savings and ROI analysis
- Plan major enhancements or redesigns

### Enhancement Roadmap

**Phase 1 (Immediate):**
- Implement core dashboard functionality
- Establish data refresh schedules
- Train key stakeholders
- Gather initial feedback

**Phase 2 (3-6 months):**
- Add predictive inventory modeling
- Enhance seasonal pattern analysis
- Implement automated alerts for stockouts
- Expand regional analysis capabilities

**Phase 3 (6-12 months):**
- Add supplier performance integration
- Implement automated purchasing recommendations
- Enhance mobile accessibility for field teams
- Integrate with ERP systems

---

## Portfolio Presentation

### Key Talking Points

**Business Impact:**
- "Reduces stockouts by X% through data-driven inventory management"
- "Decreases overstock situations by Y% improving cash flow"
- "Optimizes purchasing decisions with SKU-level insights"
- "Supports seasonal planning with pattern analysis"

**Stakeholder Value:**
- "Answers the inventory manager's question: 'What should we order?'"
- "Helps buyers make data-driven purchasing decisions"
- "Supports supply chain optimization with regional insights"
- "Improves customer satisfaction through better availability"

**Process Improvement:**
- "Reduces time from data to purchasing decision from days to hours"
- "Eliminates manual spreadsheet analysis for inventory planning"
- "Provides consistent inventory metrics across the organization"
- "Enables proactive inventory management vs reactive ordering"

**Technical Excellence:**
- "Built on optimized data architecture for SKU-level analysis"
- "Designed for operational audience with clear action orientation"
- "Incorporates stakeholder feedback and business requirements"
- "Scalable architecture supporting future enhancements"

### Presentation Structure

**Introduction (1 minute):**
- Business problem and stakeholder needs
- Dashboard purpose and target audience
- Key business questions answered

**Demonstration (3 minutes):**
- Walk through dashboard sections
- Highlight key insights and recommendations
- Show interactivity and filtering capabilities
- Demonstrate business value through use cases

**Business Impact (2 minutes):**
- Quantify cost savings and efficiency gains
- Document stockout and overstock reductions
- Share stakeholder feedback and adoption metrics
- Discuss ROI and business outcomes

**Technical Approach (1 minute):**
- Brief overview of data architecture
- Emphasis on business requirements over technical complexity
- Focus on scalability and maintainability
- Highlight stakeholder-centered design process

---

## Best Practices

### Inventory Dashboard Design
- **Action-oriented:** Always include "what to do" recommendations
- **Operational focus:** Design for weekly operational decisions
- **Clear thresholds:** Use color coding for quick issue identification
- **Seasonal context:** Include time-based patterns for planning
- **SKU-level detail:** Provide product-specific insights

### Stakeholder Management
- **Regular communication:** Weekly check-ins with inventory team
- **Feedback loops:** Continuous improvement based on usage
- **Training and support:** Ensure stakeholders can effectively use dashboard
- **Success metrics:** Track adoption and business impact

### Data Quality
- **Case calculation accuracy:** Validate units ÷ pack_size calculations
- **Seasonal pattern validation:** Ensure variation patterns are realistic
- **Location data accuracy:** Verify geographic data completeness
- **Performance consistency:** Align with operational systems

---

## Troubleshooting

### Common Issues

**Issue: Dashboard not refreshing**
- Solution: Check extract refresh schedule, verify database connectivity

**Issue: Case calculations don't match physical inventory**
- Solution: Validate pack_size data, check unit calculations, align with warehouse systems

**Issue: Seasonal patterns seem incorrect**
- Solution: Validate variation factors, check data quality, align with business knowledge

**Issue: Stakeholders not using dashboard for purchasing**
- Solution: Gather feedback, provide training, integrate with purchasing systems

**Issue: Stockout alerts not triggering**
- Solution: Validate threshold calculations, check data freshness, adjust alert parameters

---

## Next Steps

1. **Complete stakeholder interviews** to finalize requirements
2. **Build dashboard prototype** for stakeholder review
3. **Gather feedback** and iterate on design
4. **Finalize dashboard** with approved metrics and layout
5. **Train stakeholders** on dashboard usage
6. **Launch dashboard** and monitor adoption
7. **Measure business impact** (stockout reduction, cost savings)
8. **Plan enhancements** based on usage and feedback

---

*This guide provides a business analyst-focused approach to building an inventory optimization dashboard that demonstrates business value, operational efficiency, and data-driven decision-making support.*

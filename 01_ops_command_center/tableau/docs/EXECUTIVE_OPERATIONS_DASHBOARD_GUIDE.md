# Executive Operations Dashboard Guide

**Project:** 01_ops_command_center - Business Analyst Portfolio  
**Dashboard:** Executive Operations Dashboard  
**Platform:** Tableau Desktop  
**Data Source:** PostgreSQL (mart.vw_sales_rankings)  
**Purpose:** Executive-level view of dispensary network performance for strategic decision-making  

---

## Business Context

**Business Question:** "How is our dispensary network performing?"

**Target Audience:** Operations executives, regional directors, senior leadership

**Decision Impact:** Resource allocation, performance management, strategic planning, investment decisions

**Time Horizon:** Monthly operational review, quarterly strategic planning

---

## Dashboard Objectives

### Primary Objectives
1. **Provide executive overview** of network performance across key metrics
2. **Identify performance outliers** requiring leadership attention
3. **Highlight strategic opportunities** for network optimization
4. **Enable data-driven decisions** on resource allocation and investments

### Secondary Objectives
1. **Track performance trends** over time for strategic planning
2. **Compare regional performance** for best practice sharing
3. **Support executive communication** with stakeholders and investors
4. **Demonstrate data-driven culture** to leadership team

---

## Key Business Metrics

### Executive Summary Metrics (Top Row)
- **Total Network Sales:** Aggregate revenue across all locations
- **YoY Growth:** Year-over-year sales growth percentage
- **Network Margin:** Average gross margin across network
- **Top Performer:** Best-performing location and key metrics
- **Bottom Performer:** Lowest-performing location requiring attention
- **Active Locations:** Number of operational dispensaries

### Performance Metrics (Middle Section)
- **Sales Distribution:** Revenue distribution across performance tiers
- **Regional Comparison:** Performance by geographic region
- **Margin Analysis:** Gross margin trends and outliers
- **Growth Trends:** Sales growth patterns over time

### Strategic Metrics (Bottom Section)
- **Performance Tiers:** Count and revenue by performance category
- **County Leaders:** Top performers by county for competitive analysis
- **Efficiency Metrics:** Sales per location, margin efficiency ratios
- **Trend Analysis:** 3-month and 12-month performance trends

---

## Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│              EXECUTIVE OPERATIONS DASHBOARD               │
├─────────────────────────────────────────────────────────────┤
│  [Month: December 2024 ▼]  [Region: All ▼]               │
├─────────────────────────────────────────────────────────────┤
│  Executive Summary KPIs                                   │
│  [Total Sales: $2.4M]  [YoY Growth: +12%]  [Margin: 44%] │
│  [Top: Store A ($180K)]  [Bottom: Store Z ($45K)]        │
│  [Active Locations: 42]  [Avg Sales/Location: $57K]       │
├─────────────────────────────────────────────────────────────┤
│  Network Performance Overview                              │
│  [Bar Chart: Locations ranked by sales]                   │
│  Color: Performance tier, Size: Margin                    │
├─────────────────────────────────────────────────────────────┤
│  Regional Performance Comparison                           │
│  [Map: Geographic performance by region]                   │
│  Size: Sales, Color: Growth rate                         │
├─────────────────────────────────────────────────────────────┤
│  Performance Distribution Analysis                          │
│  [Histogram: Sales distribution by tier]                   │
│  [Box Plot: Margin distribution by region]                │
├─────────────────────────────────────────────────────────────┤
│  Strategic Performance Insights                            │
│  [Treemap: Performance tiers with revenue contribution]   │
│  [Trend Line: 12-month sales and margin trends]           │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Business Requirements Gathering (2-3 days)

**Stakeholder Interviews:**
- **Operations VP:** What decisions do you make monthly? What metrics matter most?
- **Regional Directors:** What information helps you manage your territories?
- **Finance Director:** What financial metrics do you need for planning?
- **CEO:** What strategic questions should this dashboard answer?

**Key Questions to Ask:**
- What are your top 3 strategic priorities this quarter?
- What performance indicators do you track regularly?
- What decisions do you make based on operational data?
- What information is currently missing or hard to access?
- How often do you need to review performance data?
- What format works best for your decision-making?

**Document Requirements:**
- Create requirements document with stakeholder needs
- Prioritize metrics by business impact
- Define success criteria for dashboard adoption
- Establish data freshness requirements

### Step 2: Data Source Preparation (1 day)

**Connect to Data Source:**
1. Open Tableau Desktop
2. Connect to PostgreSQL database `althea_ops`
3. Navigate to `mart` schema
4. Select `vw_sales_rankings` view
5. Verify data quality and completeness

**Data Validation:**
- Check for missing values in key fields
- Verify date ranges are complete
- Confirm location data is accurate
- Validate sales totals match expectations
- Test data refresh functionality

**Create Data Extract:**
- Extract data for improved performance
- Set refresh schedule (daily for operational, weekly for strategic)
- Configure incremental refresh if data volume is large
- Test extract refresh functionality

### Step 3: Create Executive Summary KPIs (2 hours)

**Worksheet: Executive Summary**

1. **Total Network Sales:**
   - Create calculated field: `[Total Sales] = SUM([total_sales])`
   - Filter to `data_level = 'MONTHLY_LOCATION'`
   - Format as currency with appropriate scale
   - Add comparison to previous period

2. **YoY Growth:**
   - Create calculated field for year-over-year comparison
   - Use LOOKUP() function for period-over-period comparison
   - Format as percentage with color coding (green for positive, red for negative)
   - Add trend indicator

3. **Network Margin:**
   - Create calculated field: `[Network Margin] = AVG([gross_margin_pct])`
   - Filter to current period
   - Format as percentage
   - Add comparison to target or previous period

4. **Top/Bottom Performers:**
   - Create calculated fields for top and bottom performers
   - Use FIXED() LOD expressions for consistent ranking
   - Display location name and key metrics
   - Add color coding for quick identification

5. **Active Locations:**
   - Create calculated field: `[Active Locations] = COUNTD([location_key])`
   - Filter to current period
   - Display as simple count

### Step 4: Create Network Performance Overview (3 hours)

**Worksheet: Network Performance Leaderboard**

1. **Build Leaderboard:**
   - Drag `location_name` to Rows
   - Drag `total_sales` to Columns
   - Sort descending by sales
   - Limit to top 20 locations
   - Drag `performance_tier` to Color
   - Drag `gross_margin_pct` to Size
   - Drag `county` and `state` to Tooltip

2. **Enhance Visualization:**
   - Add reference line for average sales
   - Add labels showing sales amounts and margin
   - Set color palette: Green (Top Performer), Blue (Average), Red (Bottom)
   - Add title: "Network Performance Leaderboard"
   - Add subtitle: "Top 20 locations by sales revenue"

3. **Add Context:**
   - Add calculated field for sales vs average
   - Create performance gap indicator
   - Add county and regional context
   - Include performance tier labels

### Step 5: Create Regional Performance Comparison (2 hours)

**Worksheet: Regional Performance Map**

1. **Build Geographic View:**
   - Drag `state` to Marks → Map
   - Drag `total_sales` to Size
   - Drag `gross_margin_pct` to Color
   - Drag `location_name` to Tooltip
   - Add county-level detail if available

2. **Enhance Map:**
   - Add regional labels
   - Set color scale for margin analysis
   - Add size scale for sales volume
   - Include regional totals in tooltips
   - Add title: "Regional Performance Distribution"

3. **Add Regional Analysis:**
   - Create regional calculated fields
   - Add regional performance rankings
   - Include regional growth rates
   - Show regional margin comparisons

### Step 6: Create Performance Distribution Analysis (2 hours)

**Worksheet: Performance Distribution**

1. **Build Histogram:**
   - Drag `sales_percentile` to Columns
   - Drag `COUNT([location_key])` to Rows
   - Change mark type to Bar
   - Drag `performance_tier` to Color
   - Add title: "Sales Percentile Distribution"

2. **Build Box Plot:**
   - Drag `performance_tier` to Columns
   - Drag `total_sales` to Rows
   - Change mark type to Box Plot
   - Drag `county` to Color
   - Add title: "Sales Distribution by Performance Tier"

3. **Combine Views:**
   - Use dashboard layout to combine histogram and box plot
   - Align horizontally for comparison
   - Add consistent formatting
   - Include performance tier labels

### Step 7: Create Strategic Performance Insights (2 hours)

**Worksheet: Strategic Insights Treemap**

1. **Build Treemap:**
   - Drag `performance_tier` to Color
   - Drag `SUM([total_sales])` to Size
   - Change mark type to Square
   - Drag `COUNT([location_key])` to Label
   - Add labels showing tier name, count, and revenue contribution

2. **Enhance Treemap:**
   - Set color palette for performance tiers
   - Add percentage labels for revenue contribution
   - Include location count per tier
   - Add title: "Performance Tier Revenue Contribution"

**Worksheet: Trend Analysis**

1. **Build Trend Line:**
   - Drag `sale_month` to Columns (continuous)
   - Drag `SUM([total_sales])` to Rows
   - Drag `AVG([gross_margin_pct])` to Rows (dual axis)
   - Change mark types to Line
   - Add trend lines
   - Add title: "12-Month Sales and Margin Trends"

2. **Enhance Trend Analysis:**
   - Add moving averages for smoothing
   - Include reference lines for targets
   - Add growth rate annotations
   - Color-code periods by performance

### Step 8: Assemble Executive Dashboard (2 hours)

**Dashboard Layout:**

1. **Create Dashboard:** "Executive Operations Dashboard"
2. **Set Layout:**
   - Size: 1400x1000 (executive-friendly format)
   - Background: Professional dark or light theme
   - Font: Clean, professional sans-serif

3. **Add Filters:**
   - Drag `sale_month` to Filters (date range selector)
   - Drag `state` to Filters (regional selector)
   - Drag `performance_tier` to Filters (performance selector)
   - Set filters to "All" with "Apply to Worksheets" → "All Using This Data Source"

4. **Add Parameter Controls:**
   - Create time period parameter (Monthly/Quarterly/Annual)
   - Create regional scope parameter (All/Specific Region)
   - Add parameter controls to dashboard header
   - Format as professional dropdown selectors

5. **Add Sheets:**
   - Drag "Executive Summary" to top row
   - Drag "Network Performance Leaderboard" to middle-left
   - Drag "Regional Performance Map" to middle-right
   - Drag "Performance Distribution" to bottom-left
   - Drag "Strategic Insights" to bottom-right

6. **Add Interactivity:**
   - Use filter actions: Click on region → filter all views
   - Use highlight actions: Hover over location → highlight across views
   - Add tooltip enhancements with executive-friendly language
   - Add navigation buttons for drill-down views

7. **Add Title and Branding:**
   - Dashboard title: "Executive Operations Dashboard"
   - Subtitle: "Network Performance Overview"
   - Add last updated timestamp
   - Include data source attribution
   - Add company branding if applicable

### Step 9: Create Business Narrative (2 hours)

**Executive Summary Document:**

1. **Performance Overview:**
   - Summarize overall network performance
   - Highlight key achievements and concerns
   - Provide context for metrics
   - Include executive summary bullet points

2. **Key Insights:**
   - Identify top 3 performance strengths
   - Identify top 3 areas requiring attention
   - Explain performance trends
   - Provide regional performance highlights

3. **Recommendations:**
   - Prioritize 3-5 actionable recommendations
   - Include expected business impact
   - Suggest timeline for implementation
   - Identify responsible parties

4. **Appendix:**
   - Data definitions and methodology
   - Metric calculation explanations
   - Data quality notes
   - Contact information for questions

---

## Business Value Communication

### Executive Presentation Structure

**Slide 1: Executive Summary (2 minutes)**
- Dashboard purpose and audience
- Key metrics at a glance
- Overall performance assessment
- Top 3 insights and recommendations

**Slide 2: Network Performance Overview (3 minutes)**
- Sales distribution and trends
- Top and bottom performers
- Regional performance highlights
- Performance tier analysis

**Slide 3: Strategic Insights (3 minutes)**
- Margin analysis and trends
- Growth patterns and opportunities
- Resource allocation recommendations
- Strategic priorities for next quarter

**Slide 4: Action Plan (2 minutes)**
- Specific actions required
- Timeline and responsibilities
- Expected business impact
- Follow-up and monitoring plan

### Stakeholder Communication

**For Operations VP:**
- Focus on operational efficiency and performance management
- Highlight resource allocation opportunities
- Provide actionable recommendations for underperformers
- Include competitive analysis insights

**For Regional Directors:**
- Focus on territory-specific performance
- Provide benchmarking against other regions
- Highlight best practices from top performers
- Include actionable improvement recommendations

**For Finance Director:**
- Focus on financial metrics and margin analysis
- Provide ROI insights for investments
- Highlight revenue growth opportunities
- Include cost optimization recommendations

**For CEO:**
- Focus on strategic implications and business impact
- Provide high-level performance overview
- Highlight strategic opportunities and risks
- Include recommendations for board-level decisions

---

## Success Metrics

### Dashboard Adoption Metrics
- **Usage Frequency:** Number of unique users per week
- **Session Duration:** Average time spent per session
- **Feature Usage:** Which features are used most frequently
- **User Feedback:** Satisfaction scores and qualitative feedback

### Business Impact Metrics
- **Decision Speed:** Time from data access to decision
- **Decision Quality:** Measured by business outcomes
- **Process Improvement:** Documented process changes
- **ROI Analysis:** Quantified business impact

### Data Quality Metrics
- **Data Freshness:** Time from data generation to dashboard update
- **Data Accuracy:** Validation against source systems
- **Completeness:** Percentage of expected data available
- **Consistency:** Alignment with other reporting systems

---

## Maintenance and Enhancement

### Regular Maintenance Tasks

**Weekly:**
- Monitor data refresh schedules
- Check for data quality issues
- Review user feedback and usage patterns
- Address any technical issues

**Monthly:**
- Review business metrics for relevance
- Update performance targets and benchmarks
- Gather stakeholder feedback
- Plan enhancements based on usage patterns

**Quarterly:**
- Comprehensive business value review
- Stakeholder satisfaction assessment
- Strategic alignment check
- Plan major enhancements or redesigns

### Enhancement Roadmap

**Phase 1 (Immediate):**
- Implement core dashboard functionality
- Establish data refresh schedules
- Train key stakeholders
- Gather initial feedback

**Phase 2 (3-6 months):**
- Add drill-down capabilities
- Enhance interactivity and filtering
- Implement automated alerts
- Expand regional analysis

**Phase 3 (6-12 months):**
- Add predictive analytics
- Implement scenario planning
- Enhance mobile accessibility
- Integrate with other systems

---

## Portfolio Presentation

### Key Talking Points

**Business Impact:**
- "Provides executive-level visibility into network performance"
- "Enables data-driven resource allocation decisions"
- "Identifies performance outliers requiring leadership attention"
- "Supports strategic planning with actionable insights"

**Stakeholder Value:**
- "Answers the CEO's question: 'How are we performing?'"
- "Helps regional directors manage territories effectively"
- "Supports finance director with margin and growth analysis"
- "Provides operations VP with performance management insights"

**Process Improvement:**
- "Reduces time from data to decision from days to minutes"
- "Eliminates manual reporting and spreadsheet dependencies"
- "Provides consistent metrics across the organization"
- "Enables proactive performance management"

**Technical Excellence:**
- "Built on optimized data architecture for performance"
- "Designed for executive audience with clear visual hierarchy"
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
- Quantify time savings and efficiency gains
- Document decision-making improvements
- Share stakeholder feedback and adoption metrics
- Discuss ROI and business outcomes

**Technical Approach (1 minute):**
- Brief overview of data architecture
- Emphasis on business requirements over technical complexity
- Focus on scalability and maintainability
- Highlight stakeholder-centered design process

---

## Best Practices

### Executive Dashboard Design
- **Keep it simple:** 3-5 key metrics maximum
- **Clear visual hierarchy:** Most important information first
- **Executive-friendly language:** Avoid technical jargon
- **Action-oriented insights:** Always include "what to do"
- **Consistent formatting:** Professional appearance throughout

### Stakeholder Management
- **Regular communication:** Monthly check-ins with key stakeholders
- **Feedback loops:** Continuous improvement based on usage
- **Training and support:** Ensure stakeholders can effectively use dashboard
- **Success metrics:** Track adoption and business impact

### Data Quality
- **Single source of truth:** Align with other reporting systems
- **Clear definitions:** Document metric calculations and data sources
- **Regular validation:** Ongoing data quality monitoring
- **Transparency:** Communicate limitations and assumptions

---

## Troubleshooting

### Common Issues

**Issue: Dashboard not refreshing**
- Solution: Check extract refresh schedule, verify database connectivity

**Issue: Metrics don't match other reports**
- Solution: Validate data sources, check calculation definitions, align with finance

**Issue: Stakeholders not using dashboard**
- Solution: Gather feedback, provide training, address usability issues

**Issue: Performance too slow**
- Solution: Optimize extracts, reduce data volume, simplify calculations

**Issue: Insights not actionable**
- Solution: Refine metrics, add context, improve narrative

---

## Next Steps

1. **Complete stakeholder interviews** to finalize requirements
2. **Build dashboard prototype** for stakeholder review
3. **Gather feedback** and iterate on design
4. **Finalize dashboard** with approved metrics and layout
5. **Train stakeholders** on dashboard usage
6. **Launch dashboard** and monitor adoption
7. **Measure business impact** and report results
8. **Plan enhancements** based on usage and feedback

---

*This guide provides a business analyst-focused approach to building an executive operations dashboard that demonstrates business value, stakeholder communication, and strategic decision-making support.*

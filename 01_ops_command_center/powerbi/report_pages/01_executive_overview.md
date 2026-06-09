# Executive Overview Page

## Purpose
High-level KPI dashboard for leadership to quickly assess business health across sales, operations, and labor.

## Target Audience
- VP of Sales
- VP of Operations
- Finance Director
- Executive Leadership

## Page Layout

### Header Section
- **Title**: "Althea Executive Command Center"
- **Date Range Slicer**: Month/Quarter/Year selector
- **State Slicer**: Multi-select state filter
- **Channel Slicer**: Retail/Wholesale/DTC filter

### KPI Cards Row (Top)
1. **Net Sales** - Large card with YoY growth indicator
2. **Gross Margin $** - Large card with margin % trend
3. **Units Sold** - Large card with volume trend
4. **Net VWAP** - Medium card with discount rate below
5. **Active Accounts** - Medium card with retention rate below

### Trend Charts Row (Middle)

#### Left: Revenue Trend
- **Chart Type**: Line chart with area fill
- **Measures**: Net Sales, Gross Sales
- **Axis**: Month
- **Legend**: Gross vs Net
- **Tooltip**: Units, VWAP, Discount Rate

#### Center: Margin Trend
- **Chart Type**: Line chart
- **Measures**: Gross Margin %, Gross Margin $
- **Axis**: Month
- **Color coding**: Green for >40%, yellow for 30-40%, red for <30%

#### Right: Volume Trend
- **Chart Type**: Column chart
- **Measures**: Units Sold
- **Axis**: Month
- **Color**: By cannabinoid family (THC, CBD, CBN, Ratio)

### Performance Heatmap (Bottom)

#### State Performance Matrix
- **Chart Type**: Matrix visual
- **Rows**: States
- **Columns**: Net Sales, Units, Margin %, VWAP, Active Accounts
- **Conditional formatting**: 
  - Sales: Green scale
  - Margin: Red-green scale
  - VWAP: Blue scale

### Key Insights Callout (Bottom Right)
- **Card**: "Key Insights This Month"
- **Content**: Dynamic text based on top 3 performing/worsening metrics
- **Example**: "Oregon sales up 15% driven by CBN gummies mix shift"

## Interactivity

### Slicer Behavior
- Date range: Cascades to all visuals
- State: Filters all except state-by-state comparison
- Channel: Independent filter for channel comparison

### Drill-down Capabilities
- Click on state in matrix → Navigate to State Detail page
- Click on product in volume trend → Navigate to Product Mix page
- Click on account in KPI → Navigate to Account Detail page

## Data Model Dependencies

### Required Measures
- Net Sales
- Gross Sales
- Gross Margin $
- Gross Margin %
- Units Sold
- Net VWAP
- Gross VWAP
- Discount Rate
- Active Accounts (Sold)
- Account Retention %

### Required Dimensions
- DimDate (Month, Year)
- DimLocation (State)
- DimChannel (Channel Name)
- DimProduct (Cannabinoid Family)

## Business Questions Answered

1. **How is the business performing overall?**
   - Net Sales and margin trends show financial health
   - Volume trends show demand strength

2. **Which states are driving growth?**
   - State performance matrix highlights top/bottom performers
   - Geographic concentration visible

3. **Are we profitable?**
   - Margin trend and KPI cards show profitability trajectory
   - VWAP vs Discount Rate shows pricing discipline

4. **Is distribution expanding?**
   - Active Accounts KPI shows door count
   - Retention rate shows account health

## Visual Hierarchy

1. **Primary**: Net Sales, Gross Margin $ (large cards)
2. **Secondary**: Units Sold, VWAP, Active Accounts (medium cards)
3. **Tertiary**: Trend charts (middle row)
4. **Supporting**: State matrix and insights (bottom row)

## Color Scheme

- **Primary**: Althea brand colors (green/teal accents)
- **KPI Cards**: White background with colored trend indicators
- **Charts**: Professional palette with cannabinoid family differentiation
- **Conditional Formatting**: Green (good), yellow (caution), red (alert)

## Performance Considerations

- **Data Volume**: Monthly aggregates only (fast)
- **Measure Complexity**: Simple aggregations (fast)
- **Visual Count**: 8 visuals (acceptable load time)
- **Slicer Count**: 3 slicers (minimal impact)

## Next Steps for Implementation

1. Create measures from DAX metrics files
2. Build semantic model relationships
3. Create page layout in Power BI Desktop
4. Add conditional formatting rules
5. Test slicer interactions
6. Add drill-through navigation
7. Validate against business questions

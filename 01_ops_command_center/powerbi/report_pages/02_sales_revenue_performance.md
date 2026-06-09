# Sales & Revenue Performance Page

## Purpose
Detailed sales analysis focusing on pricing, product mix, promo effectiveness, and channel performance.

## Target Audience
- Sales Managers
- Category Managers
- Marketing Team
- Finance Analysts

## Page Layout

### Header Section
- **Title**: "Sales & Revenue Performance"
- **Date Range Slicer**: Month/Quarter/Year selector
- **State Slicer**: Multi-select state filter
- **Channel Slicer**: Retail/Wholesale/DTC filter
- **Product Family Slicer**: THC/CBD/CBN/Ratio filter

### KPI Cards Row (Top)
1. **Net Sales** - Large card with YoY growth
2. **Gross VWAP** - Medium card
3. **Net VWAP** - Medium card with VWAP Delta below
4. **Discount Rate** - Medium card
5. **Promo Penetration %** - Medium card
6. **Promo Lift %** - Medium card

### Pricing Analysis Row (Middle Left)

#### VWAP Trend Chart
- **Chart Type**: Line chart
- **Measures**: Gross VWAP, Net VWAP
- **Axis**: Month
- **Legend**: Gross vs Net
- **Tooltip**: Units, Discount Rate, Promo Lift
- **Annotation**: Call out significant promo periods

#### Price Volume Mix Decomposition
- **Chart Type**: Stacked column chart
- **Measures**: Price Effect $, Volume Effect $, Mix Effect $
- **Axis**: Month
- **Legend**: Effect type
- **Color coding**: Price (blue), Volume (green), Mix (orange)

### Product Mix Analysis Row (Middle Right)

#### Cannabinoid Family Mix
- **Chart Type**: Donut chart
- **Measures**: Net Sales
- **Legend**: Cannabinoid Family (THC, CBD, CBN, Ratio)
- **Center metric**: Total Net Sales
- **Detail**: Mix % in legend

#### Flavor Performance Matrix
- **Chart Type**: Matrix visual
- **Rows**: Flavors
- **Columns**: Net Sales, Units, Margin %, Mix %
- **Conditional formatting**: Sales (green scale), Margin (red-green scale)

### Promo Performance Row (Bottom Left)

#### Promo vs Non-Promo ROS
- **Chart Type**: Clustered column chart
- **Measures**: Promo ROS, Non-Promo ROS
- **Axis**: Month
- **Legend**: Promo vs Non-Promo
- **Color**: Promo (purple), Non-Promo (gray)

#### Promo Penetration Trend
- **Chart Type**: Line chart
- **Measures**: Promo Penetration % (Units)
- **Axis**: Month
- **Threshold line**: Target penetration rate

### Channel Performance Row (Bottom Right)

#### Channel Revenue Split
- **Chart Type**: Stacked column chart
- **Measures**: Net Sales
- **Axis**: Month
- **Legend**: Channel (Retail, Wholesale, DTC)
- **Color**: Channel-specific colors

#### Rate of Sale by Channel
- **Chart Type**: Clustered bar chart
- **Measures**: Rate of Sale (Units per Active Account)
- **Axis**: Channel
- **Legend**: Current Month vs Prior Month
- **Color**: Current (blue), Prior (light blue)

## Interactivity

### Slicer Behavior
- Date range: Cascades to all visuals
- State: Filters all except state comparison
- Channel: Independent for channel analysis
- Product Family: Filters product-specific visuals

### Cross-filtering
- Click on cannabinoid family in donut → Filters flavor matrix
- Click on flavor in matrix → Filters promo performance
- Click on channel in revenue split → Filters ROS chart

### Drill-through
- Click on product → Navigate to Product Detail page
- Click on state → Navigate to State Detail page
- Click on account → Navigate to Account Detail page

## Data Model Dependencies

### Required Measures
- Net Sales
- Gross Sales
- Gross VWAP
- Net VWAP
- VWAP Delta
- Discount Rate
- Promo Units
- Promo Penetration % (Units)
- Promo ROS
- Non-Promo ROS
- Promo Lift %
- Product Mix % (Net Sales)
- Product Mix % (Units)
- Rate of Sale (Units per Active Account)
- Price Effect $
- Volume Effect $
- Mix Effect $

### Required Dimensions
- DimDate (Month, Year)
- DimLocation (State)
- DimChannel (Channel Name)
- DimProduct (Cannabinoid Family, Flavor)

## Business Questions Answered

1. **How is pricing performing?**
   - VWAP trend shows price realization
   - Discount rate shows promo intensity
   - VWAP Delta shows promo impact on pricing

2. **What's driving sales growth?**
   - Price/Volume/Mix decomposition shows growth drivers
   - Product mix shows which products are contributing

3. **Are promos working?**
   - Promo lift shows incremental demand
   - Promo penetration shows promo reach
   - ROS comparison shows promo effectiveness

4. **Which channels are performing?**
   - Channel revenue split shows channel contribution
   - ROS by channel shows channel efficiency
   - Channel-specific trends show trajectory

5. **How is product mix evolving?**
   - Cannabinoid family mix shows category shifts
   - Flavor performance shows product-level performance
   - Mix % shows portfolio composition

## Visual Hierarchy

1. **Primary**: Net Sales, VWAP metrics (top cards)
2. **Secondary**: Pricing analysis (middle left)
3. **Secondary**: Product mix (middle right)
4. **Tertiary**: Promo performance (bottom left)
5. **Tertiary**: Channel performance (bottom right)

## Color Scheme

- **Primary**: Althea brand colors (green/teal)
- **Promo**: Purple to highlight promo activity
- **Cannabinoid Families**: THC (green), CBD (blue), CBN (orange), Ratio (purple)
- **Channels**: Retail (teal), Wholesale (navy), DTC (green)
- **Effects**: Price (blue), Volume (green), Mix (orange)

## Performance Considerations

- **Data Volume**: Monthly aggregates (fast)
- **Measure Complexity**: Mix calculations (moderate)
- **Visual Count**: 10 visuals (acceptable)
- **Slicer Count**: 4 slicers (moderate impact)

## Next Steps for Implementation

1. Create measures from dax_metrics_sales.md
2. Build product mix calculations
3. Create promo lift calculations
4. Implement price/volume/mix decomposition
5. Add conditional formatting for flavor matrix
6. Test cross-filtering between visuals
7. Add drill-through navigation
8. Validate against business questions

# Inventory & Operations Page

## Purpose
Operational health dashboard focusing on inventory metrics, stockouts, and operational efficiency.

## Target Audience
- Operations Managers
- Supply Chain Team
- Warehouse Managers
- Inventory Planners

## Page Layout

### Header Section
- **Title**: "Inventory & Operations Health"
- **Date Range Slicer**: Month/Quarter/Year selector
- **State Slicer**: Multi-select state filter
- **Product Family Slicer**: THC/CBD/CBN/Ratio filter
- **Location Type Slicer**: Retail/Distributor/Facility filter

### KPI Cards Row (Top)
1. **Inventory On Hand Units** - Large card with trend
2. **Days of Inventory on Hand (DOH)** - Large card with threshold indicator
3. **Inventory Turnover (Units)** - Medium card
4. **In-Stock %** - Medium card
5. **Stockout Rate %** - Medium card with alert threshold
6. **Aged Inventory % (90+ Days)** - Medium card

### Inventory Trend Row (Middle Left)

#### Inventory Level Trend
- **Chart Type**: Line chart
- **Measures**: Inventory On Hand Units
- **Axis**: Date (daily or weekly)
- **Color**: By state (multi-line)
- **Threshold line**: Target inventory level
- **Annotation**: Call out stockout events

#### DOH Trend
- **Chart Type**: Line chart
- **Measures**: Days Inventory On Hand
- **Axis**: Month
- **Threshold lines**: 
  - Green zone: 30-60 days (optimal)
  - Yellow zone: 60-90 days (caution)
  - Red zone: >90 days (overstock)
  - Red zone: <30 days (stockout risk)

### Turnover & Aging Row (Middle Right)

#### Inventory Turnover by Product
- **Chart Type**: Clustered bar chart
- **Measures**: Inventory Turnover (Units)
- **Axis**: Product Name
- **Color**: By cannabinoid family
- **Threshold line**: Target turnover rate
- **Sort**: Descending by turnover

#### Aging Inventory Distribution
- **Chart Type**: Stacked column chart
- **Measures**: Inventory On Hand Units
- **Axis**: Month
- **Legend**: Age buckets (0-30 days, 30-60 days, 60-90 days, 90+ days)
- **Color**: Age gradient (green to red)

### Stockout Analysis Row (Bottom Left)

#### Stockout Rate by State
- **Chart Type**: Map visual (if geocoding available) or clustered bar chart
- **Measures**: Stockout Rate %
- **Axis**: State
- **Color**: Conditional (green <5%, yellow 5-10%, red >10%)
- **Sort**: Descending by stockout rate

#### In-Stock % Trend
- **Chart Type**: Line chart
- **Measures**: In-Stock %
- **Axis**: Date (daily)
- **Threshold line**: 95% target
- **Color**: By product family

### Operational Efficiency Row (Bottom Right)

#### Inventory Health Score
- **Chart Type**: Gauge chart
- **Measures**: Inventory Health Score (Example)
- **Scale**: 0-100
- **Thresholds**: 
  - 80-100: Healthy (green)
  - 60-79: Caution (yellow)
  - 0-59: Critical (red)
- **Detail**: Breakdown by component (In-Stock, Turnover, Aging)

#### Top Stockout Products
- **Chart Type**: Table visual
- **Columns**: Product Name, State, Stockout Rate %, On Hand Units, Last Stockout Date
- **Sort**: Descending by stockout rate
- **Row highlighting**: Red for >10% stockout rate

## Interactivity

### Slicer Behavior
- Date range: Cascades to all visuals
- State: Filters all except state comparison
- Product Family: Filters product-specific visuals
- Location Type: Filters location-specific metrics

### Cross-filtering
- Click on product in turnover chart → Filters aging distribution
- Click on state in stockout rate → Filters in-stock trend
- Click on age bucket in aging chart → Filters product table

### Drill-through
- Click on product → Navigate to Product Inventory Detail page
- Click on state → Navigate to State Inventory Detail page
- Click on location → Navigate to Location Inventory Detail page

## Data Model Dependencies

### Required Measures
- Inventory On Hand Units
- Days Inventory On Hand
- Inventory Turnover (Units)
- In-Stock %
- Stockout Rate %
- Aged Inventory Units (90+ Days)
- Aged Inventory % (90+ Days)
- Inventory Health Score (Example)
- Avg Daily Units Sold

### Required Dimensions
- DimDate (Date, Month, Year)
- DimLocation (State, Location Type)
- DimProduct (Product Name, Cannabinoid Family)
- InventorySnapshots (Age Bucket, InStockFlag)

## Business Questions Answered

1. **Do we have enough inventory?**
   - Inventory on hand shows current stock levels
   - DOH shows days of supply
   - In-stock % shows availability

2. **Is inventory moving?**
   - Turnover rate shows velocity
   - Aging distribution shows stale inventory
   - Aged inventory % shows risk of write-offs

3. **Where are stockouts happening?**
   - Stockout rate by state shows problem areas
   - In-stock trend shows patterns
   - Top stockout products table shows specific SKUs

4. **Is inventory healthy overall?**
   - Inventory health score provides composite view
   - Component breakdown shows drivers
   - Threshold indicators show status

5. **Which products need attention?**
   - Low turnover products
   - High aged inventory products
   - Frequent stockout products

## Visual Hierarchy

1. **Primary**: Inventory On Hand, DOH (top cards)
2. **Secondary**: Inventory trend, DOH trend (middle left)
3. **Secondary**: Turnover, aging (middle right)
4. **Tertiary**: Stockout analysis (bottom left)
5. **Tertiary**: Operational efficiency (bottom right)

## Color Scheme

- **Primary**: Althea brand colors (green/teal)
- **Health Indicators**: Green (healthy), Yellow (caution), Red (critical)
- **Age Buckets**: 0-30 days (green), 30-60 days (yellow), 60-90 days (orange), 90+ days (red)
- **Stockout Rate**: Green <5%, Yellow 5-10%, Red >10%
- **Threshold Lines**: Dashed gray for targets

## Performance Considerations

- **Data Volume**: Daily inventory snapshots (moderate)
- **Measure Complexity**: Inventory calculations (moderate)
- **Visual Count**: 10 visuals (acceptable)
- **Slicer Count**: 4 slicers (moderate impact)

## Next Steps for Implementation

1. Create measures from dax_metrics_inventory.md
2. Build inventory snapshot model
3. Implement aging bucket calculations
4. Create inventory health score calculation
5. Add conditional formatting for thresholds
6. Test cross-filtering between visuals
7. Add drill-through navigation
8. Validate against business questions

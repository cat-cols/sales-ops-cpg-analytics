# Power BI Report Overview - Althea Ops Command Center

## Report Purpose
Executive command center dashboard for Althea's sales, operations, and labor performance. Provides leadership with real-time visibility into business health across all key operational dimensions.

## Target Audience
- Executive Leadership (CEO, CFO, VP Sales, VP Ops)
- Sales Directors and Managers
- Operations Managers
- Finance Directors and Analysts
- Account Managers

## Report Structure

### Page 1: Executive Overview
**Purpose**: High-level KPI dashboard for quick business health assessment
**Key Metrics**: Net Sales, Gross Margin, Units Sold, VWAP, Active Accounts
**Primary Audience**: Executive Leadership
**Navigation**: Drill-through to detail pages by clicking on KPIs, states, or products

### Page 2: Sales & Revenue Performance
**Purpose**: Detailed sales analysis focusing on pricing, mix, and promo effectiveness
**Key Metrics**: VWAP, Discount Rate, Promo Lift, Product Mix, Channel Performance
**Primary Audience**: Sales Managers, Category Managers, Marketing
**Navigation**: Drill-through to product, state, or account detail

### Page 3: Inventory & Operations
**Purpose**: Operational health dashboard for inventory metrics and efficiency
**Key Metrics**: DOH, Turnover, In-Stock %, Stockout Rate, Aging Inventory
**Primary Audience**: Operations Managers, Supply Chain, Inventory Planners
**Navigation**: Drill-through to product, state, or location detail

### Page 4: Customer & Account Analytics
**Purpose**: Customer and account analysis for concentration risk and retention
**Key Metrics**: Account Concentration, Retention %, Revenue Share, Account Growth
**Primary Audience**: Sales Directors, Account Managers, Business Development
**Navigation**: Drill-through to account, state, or account type detail

## Navigation Flow

### Executive Overview → Detail Pages
- Click on Net Sales KPI → Navigate to Sales & Revenue Performance
- Click on Active Accounts KPI → Navigate to Customer & Account Analytics
- Click on State in matrix → Navigate to State Detail (contextual)
- Click on Product in volume trend → Navigate to Product Detail (contextual)

### Sales & Revenue Performance → Detail Pages
- Click on Product in mix charts → Navigate to Product Detail
- Click on State in channel performance → Navigate to State Detail
- Click on Account in ROS chart → Navigate to Account Detail

### Inventory & Operations → Detail Pages
- Click on Product in turnover chart → Navigate to Product Inventory Detail
- Click on State in stockout rate → Navigate to State Inventory Detail
- Click on Location in health score → Navigate to Location Detail

### Customer & Account Analytics → Detail Pages
- Click on Account in table → Navigate to Account Detail
- Click on State in scatter plot → Navigate to State Account Detail
- Click on Account Type in lifecycle → Navigate to Account Type Analysis

## User Journey Examples

### Journey 1: Executive Review
1. Start on Executive Overview
2. Review top-level KPIs (Sales, Margin, Units)
3. Notice Net Sales is down in Oregon
4. Click on Oregon in state matrix → Navigate to Sales & Revenue Performance
5. Analyze pricing and mix for Oregon
6. Identify CBN gummies mix shift as driver
7. Return to Executive Overview with insight

### Journey 2: Operations Investigation
1. Start on Executive Overview
4. Notice Stockout Rate KPI is elevated
5. Click on Stockout Rate → Navigate to Inventory & Operations
6. Analyze stockout rate by state
7. Identify California as problem area
8. Review aging inventory for California
9. Identify slow-moving THC products
10. Return to Executive Overview with action items

### Journey 3: Account Review
1. Start on Executive Overview
4. Notice Top 10 Accounts % is above 50% threshold
5. Click on Top 10 Accounts % → Navigate to Customer & Account Analytics
6. Review concentration trend
7. Identify 3 accounts driving 60% of revenue
8. Analyze account growth vs dependency
9. Identify 1 account at risk (high share, declining growth)
10. Return to Executive Overview with retention strategy

## Common Slicers (Global)

All pages share these global slicers for consistent filtering:
- **Date Range**: Month/Quarter/Year selector
- **State**: Multi-select state filter
- **Channel**: Retail/Wholesale/DTC filter

Page-specific slicers:
- **Product Family**: THC/CBD/CBN/Ratio (Sales & Inventory pages)
- **Location Type**: Retail/Distributor/Facility (Inventory page)
- **Account Type**: Key Account/Regional Account/New Account (Customer page)

## Data Model Foundation

### Star Schema Structure
- **Fact Tables**: Sales, InventorySnapshots, Labor
- **Dimension Tables**: DimDate, DimProduct, DimLocation, DimChannel
- **Relationships**: All facts connect to dimensions via surrogate keys

### Key Measures by Domain
- **Sales**: Net Sales, Gross Sales, VWAP, Discount Rate, Promo Lift
- **Inventory**: DOH, Turnover, In-Stock %, Stockout Rate, Aging %
- **Customer**: Account Concentration, Retention %, Revenue Share
- **Foundation**: Units Sold, Active Accounts, Gross Margin

### DAX Implementation
- Measures organized by domain in separate files:
  - `dax_metrics_sales.md`
  - `dax_metrics_inventory.md`
  - `dax_metrics_forecasting.md`
  - `dax_metrics_customer.md`
- Foundation measures in `dax_metrics_sales.md`
- All measures follow naming convention: `[Measure Name]`

## Performance Considerations

### Data Volume
- **Grain**: Monthly aggregates for most visuals
- **Inventory**: Daily snapshots for inventory health
- **Row Count**: ~50K rows (manageable for Power BI)

### Measure Complexity
- **Simple**: Sum, Divide, Count (fast)
- **Moderate**: Mix calculations, retention (acceptable)
- **Complex**: Price/volume/mix decomposition (test performance)

### Visual Count
- **Per Page**: 8-10 visuals (acceptable)
- **Total**: ~40 visuals across 4 pages (manageable)

### Load Time Target
- **Initial Load**: <5 seconds
- **Slicer Change**: <2 seconds
- **Drill-through**: <1 second

## Color Scheme

### Brand Colors
- **Primary**: Althea green/teal (#00B894, #00CEC9)
- **Secondary**: Navy blue (#0984E3)
- **Accent**: Purple (#6C5CE7)

### Functional Colors
- **Positive/Good**: Green (#00B894)
- **Caution/Warning**: Yellow (#FDCB6E)
- **Negative/Alert**: Red (#FF7675)
- **Neutral**: Gray (#636E72)

### Category Colors
- **Cannabinoid Families**: THC (green), CBD (blue), CBN (orange), Ratio (purple)
- **Channels**: Retail (teal), Wholesale (navy), DTC (green)
- **Age Buckets**: Gradient from light green to dark red

## Accessibility

### Color Blindness
- Avoid red/green for critical distinctions
- Use patterns or labels in addition to color
- Test with color blind simulator

### Font Sizing
- **Headers**: 16-18pt
- **Body**: 11-12pt
- **KPI Cards**: 24-32pt for numbers

### Tooltips
- Include context in all tooltips
- Show relevant measures
- Use clear labels

## Mobile Responsiveness

### Layout Adjustments
- Stack KPI cards vertically on mobile
- Hide less critical visuals on small screens
- Use horizontal scroll for wide tables
- Simplify slicer layout

### Touch Targets
- Minimum 44x44 pixels for interactive elements
- Adequate spacing between controls
- Large tap areas for drill-through

## Deployment Considerations

### Power BI Service
- Publish to Premium capacity for better performance
- Set up scheduled refresh (daily)
- Configure row-level security if needed
- Create workspaces for different audiences

### Distribution
- Executive team: Full access with drill-through
- Sales team: Sales & Customer pages only
- Operations team: Inventory page only
- Finance team: All pages with financial focus

### Maintenance
- Monthly review of measure performance
- Quarterly update of business rules
- Annual refresh of visual design
- Ongoing monitoring of data quality

## Next Steps for Implementation

1. **Semantic Model**
   - Build star schema in Power BI Desktop
   - Create relationships between tables
   - Implement all measures from DAX files
   - Test measure calculations

2. **Report Pages**
   - Create each page following documentation
   - Add visuals in specified layout
   - Configure slicers and filters
   - Implement conditional formatting

3. **Navigation**
   - Set up drill-through pages
   - Configure button navigation
   - Test user journeys
   - Add back buttons

4. **Validation**
   - Validate against business questions
   - Test with sample stakeholders
   - Performance test with full data volume
   - Accessibility audit

5. **Documentation**
   - Create user guide
   - Document measure definitions
   - Create training materials
   - Set up support process

## Success Metrics

### Adoption
- Daily active users: >20
- Page views per session: >3
- Drill-through usage: >50% of sessions

### Performance
- Load time: <5 seconds
- Slicer response: <2 seconds
- Refresh success rate: >95%

### Business Impact
- Time to insight: Reduced by 50%
- Data-driven decisions: Increased by 30%
- Report satisfaction score: >4/5

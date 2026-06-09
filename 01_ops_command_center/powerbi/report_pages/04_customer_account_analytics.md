# Customer & Account Analytics Page

## Purpose
Customer and account analysis focusing on concentration risk, retention, and account performance.

## Target Audience
- Sales Directors
- Account Managers
- Business Development Team
- Finance Leadership

## Page Layout

### Header Section
- **Title**: "Customer & Account Analytics"
- **Date Range Slicer**: Month/Quarter/Year selector
- **State Slicer**: Multi-select state filter
- **Channel Slicer**: Retail/Wholesale/DTC filter
- **Account Type Slicer**: Key Account/Regional Account/New Account filter

### KPI Cards Row (Top)
1. **Total Net Sales (All Accounts)** - Large card with trend
2. **Active Accounts Current** - Large card with growth indicator
3. **Top 10 Accounts % of Sales** - Medium card with concentration risk indicator
4. **Account Retention %** - Medium card with trend
5. **Repeat Purchase Rate %** - Medium card (if customer-level data available)
6. **Avg Revenue per Account** - Medium card

### Concentration Analysis Row (Middle Left)

#### Account Concentration Trend
- **Chart Type**: Line chart
- **Measures**: Top 10 Accounts % of Sales, Top 5 Accounts % of Sales
- **Axis**: Month
- **Legend**: Top 10, Top 5
- **Threshold line**: 50% concentration risk threshold
- **Annotation**: Call out concentration spikes

#### Account Revenue Distribution
- **Chart Type**: Waterfall chart
- **Measures**: Net Sales
- **Axis**: Account (top 20 accounts)
- **Breakdown**: Revenue contribution per account
- **Color**: Positive contribution (green), top 10 highlight (teal)

### Account Performance Row (Middle Right)

#### Top Accounts Performance Table
- **Chart Type**: Table visual
- **Columns**: Account Name, State, Net Sales, Revenue Share %, YoY Growth, Active Months
- **Sort**: Descending by Net Sales
- **Conditional formatting**: 
  - Revenue Share: Green scale
  - YoY Growth: Green (positive), red (negative)
- **Row highlighting**: Top 10 accounts in teal

#### Account Growth vs Dependency
- **Chart Type**: Scatter plot
- **X-axis**: YoY Growth %
- **Y-axis**: Revenue Share %
- **Size**: Net Sales
- **Color**: By state
- **Quadrants**: 
  - High growth, high share (star)
  - High growth, low share (emerging)
  - Low growth, high share (at risk)
  - Low growth, low share (declining)

### Retention Analysis Row (Bottom Left)

#### Account Retention Trend
- **Chart Type**: Line chart
- **Measures**: Account Retention %
- **Axis**: Month
- **Threshold line**: 80% target retention
- **Color**: Above target (green), below target (red)
- **Tooltip**: Active Current, Active Prior, Retained

#### Churned Accounts Table
- **Chart Type**: Table visual
- **Columns**: Account Name, State, Last Active Month, Net Sales (Last 12M), Reason Code (if available)
- **Sort**: Descending by Net Sales (Last 12M)
- **Row highlighting**: Red for high-value churned accounts

### Account Lifecycle Row (Bottom Right)

#### New vs Retained Account Revenue
- **Chart Type**: Stacked column chart
- **Measures**: Net Sales
- **Axis**: Month
- **Legend**: New Accounts, Retained Accounts, Reactivated Accounts
- **Color**: New (green), Retained (teal), Reactivated (blue)

#### Account Tenure Distribution
- **Chart Type**: Donut chart
- **Measures**: Account Count
- **Legend**: Tenure buckets (0-3 months, 3-6 months, 6-12 months, 12+ months)
- **Center metric**: Total Active Accounts
- **Color**: Tenure gradient (light to dark)

## Interactivity

### Slicer Behavior
- Date range: Cascades to all visuals
- State: Filters all except state comparison
- Channel: Independent for channel analysis
- Account Type: Filters account-specific visuals

### Cross-filtering
- Click on account in table → Filters concentration trend
- Click on state in scatter plot → Filters account table
- Click on tenure bucket → Filters revenue chart

### Drill-through
- Click on account → Navigate to Account Detail page
- Click on state → Navigate to State Account Detail page
- Click on account type → Navigate to Account Type Analysis page

## Data Model Dependencies

### Required Measures
- Total Net Sales (All Accounts)
- Active Accounts (Sold)
- Active Accounts Current
- Active Accounts Prior
- Retained Accounts
- Account Retention %
- Account Revenue Share %
- Top 10 Accounts Net Sales
- Top 10 Accounts % of Sales
- Repeat Purchase Rate % (if customer-level data available)
- Avg Revenue per Account

### Required Dimensions
- DimDate (Month, Year)
- DimLocation (State, Account Name)
- DimChannel (Channel Name)
- DimAccount (Account Type, Tenure Bucket)

## Business Questions Answered

1. **Are we too concentrated?**
   - Top 10 accounts % shows concentration risk
   - Concentration trend shows if risk is increasing
   - Account revenue distribution shows dependency

2. **Which accounts are driving growth?**
   - Top accounts table shows performance
   - Growth vs dependency scatter shows account health
   - New vs retained revenue shows growth source

3. **Are we retaining accounts?**
   - Account retention trend shows retention health
   - Churned accounts table shows attrition
   - Reactivated accounts show win-back success

4. **What's our account mix?**
   - Account tenure distribution shows maturity
   - New vs retained revenue shows balance
   - Account type analysis shows segment performance

5. **Which accounts need attention?**
   - High share, low growth accounts (at risk)
   - Recently churned high-value accounts
   - New accounts not ramping

## Visual Hierarchy

1. **Primary**: Total Net Sales, Active Accounts (top cards)
2. **Secondary**: Concentration analysis (middle left)
3. **Secondary**: Account performance (middle right)
4. **Tertiary**: Retention analysis (bottom left)
5. **Tertiary**: Account lifecycle (bottom right)

## Color Scheme

- **Primary**: Althea brand colors (green/teal)
- **Concentration Risk**: Green <30%, Yellow 30-50%, Red >50%
- **Account Types**: Key Account (teal), Regional Account (navy), New Account (green)
- **Tenure**: 0-3 months (light green), 3-6 months (green), 6-12 months (teal), 12+ months (navy)
- **Growth**: Positive (green), Negative (red)
- **Scatter Quadrants**: Star (green), Emerging (blue), At Risk (orange), Declining (red)

## Performance Considerations

- **Data Volume**: Monthly account aggregates (fast)
- **Measure Complexity**: Account retention calculations (moderate)
- **Visual Count**: 10 visuals (acceptable)
- **Slicer Count**: 4 slicers (moderate impact)

## Next Steps for Implementation

1. Create measures from dax_metrics_customer.md
2. Build account retention calculations
3. Implement concentration risk calculations
4. Create account tenure bucket logic
5. Add conditional formatting for thresholds
6. Test cross-filtering between visuals
7. Add drill-through navigation
8. Validate against business questions

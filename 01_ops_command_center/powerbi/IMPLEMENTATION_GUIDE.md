# Power BI Implementation Guide - Althea Ops Command Center

## Overview
This guide walks you through building the actual Power BI report using your Project 1 sample data. This demonstrates end-to-end business analyst capabilities: data → model → measures → visualizations → insights.

## Prerequisites
- Power BI Desktop (free download from Microsoft)
- Project 1 sample data in `01_ops_command_center/data/sample/`
- DAX metrics files in `01_ops_command_center/powerbi/dax/`

## Step 1: Load Data into Power BI

### 1.1 Create New Report
1. Open Power BI Desktop
2. Select "Blank Report"
3. Save as `Althea_Ops_Command_Center.pbix`

### 1.2 Load Sample Data
1. Click "Get Data" → "Text/CSV"
2. Navigate to `01_ops_command_center/data/sample/`
3. Load these files in order:

**Dimension Tables (load first):**
- `dim_date_sample.csv` → Rename to `DimDate`
- `dim_product_sample.csv` → Rename to `DimProduct`
- `dim_location_sample.csv` → Rename to `DimLocation`
- `dim_channel_sample.csv` → Rename to `DimChannel`
- `dim_employee_group_sample.csv` → Rename to `DimEmployeeGroup`

**Fact Tables (load second):**
- `sales_sample.csv` → Rename to `FactSales`
- `inventory_sample.csv` → Rename to `FactInventory`
- `labor_sample.csv` → Rename to `FactLabor`
- `finance_sample.csv` → Rename to `FactFinance`

### 1.3 Data Type Settings
After loading, set correct data types in Power Query:

**DimDate:**
- `full_date`: Date
- `date_key`: Whole Number
- `year_num`: Whole Number
- `month_num`: Whole Number

**FactSales:**
- `transaction_date`: Date
- `units_sold`: Whole Number
- `gross_sales_amount`: Decimal number
- `net_sales_amount`: Decimal number
- `cogs_amount`: Decimal number
- `discount_amount`: Decimal number

**FactInventory:**
- `snapshot_date`: Date
- `on_hand_units`: Whole Number
- `in_stock_flag`: Whole Number (0/1)

**FactLabor:**
- `labor_date`: Date
- `labor_hours`: Decimal number
- `headcount`: Whole Number
- `labor_cost_amount`: Decimal number

Click "Close & Apply" to load data into the model.

## Step 2: Build Semantic Model (Star Schema)

### 2.1 Create Relationships
In Model view (left side), create these relationships:

**DimDate → FactSales:**
- `DimDate[full_date]` → `FactSales[transaction_date]`
- Relationship: One-to-many, Single direction
- Cardinality: 1:*

**DimDate → FactInventory:**
- `DimDate[full_date]` → `FactInventory[snapshot_date]`
- Relationship: One-to-many, Single direction

**DimDate → FactLabor:**
- `DimDate[full_date]` → `FactLabor[labor_date]`
- Relationship: One-to-many, Single direction

**DimProduct → FactSales:**
- `DimProduct[product_sku]` → `FactSales[product_sku]`
- Relationship: One-to-many, Single direction

**DimLocation → FactSales:**
- `DimLocation[state_code]` → `FactSales[state_code]`
- Relationship: One-to-many, Single direction

**DimChannel → FactSales:**
- `DimChannel[channel]` → `FactSales[channel]`
- Relationship: One-to-many, Single direction

**DimEmployeeGroup → FactLabor:**
- `DimEmployeeGroup[team_name]` → `FactLabor[team_name]`
- Relationship: One-to-many, Single direction

### 2.2 Mark Date Table
1. Select `DimDate` table
2. Click "Mark as date table" in the ribbon
3. Select `full_date` as the date column

## Step 3: Create DAX Measures

### 3.1 Foundation Measures
Create a new measure table called "Measures" and add these foundational measures:

```dax
Volume Units =
SUM(FactSales[units_sold])
```

```dax
Gross Sales =
SUM(FactSales[gross_sales_amount])
```

```dax
Net Sales =
SUM(FactSales[net_sales_amount])
```

```dax
COGS $ =
SUM(FactSales[cogs_amount])
```

```dax
Gross Margin $ =
[Net Sales] - [COGS $]
```

```dax
Gross Margin % =
DIVIDE([Gross Margin $], [Net Sales])
```

```dax
Discount $ =
[Gross Sales] - [Net Sales]
```

```dax
Discount Rate =
DIVIDE([Discount $], [Gross Sales])
```

### 3.2 VWAP Measures

```dax
Gross VWAP =
DIVIDE([Gross Sales], [Volume Units])
```

```dax
Net VWAP =
DIVIDE([Net Sales], [Volume Units])
```

```dax
VWAP Delta =
[Gross VWAP] - [Net VWAP]
```

### 3.3 Distribution Measures

```dax
Active Accounts (Sold) =
CALCULATE(
    DISTINCTCOUNT(FactSales[state_code]),
    FactSales[units_sold] > 0
)
```

```dax
Rate of Sale (Units per Active Account) =
DIVIDE([Volume Units], [Active Accounts (Sold)])
```

### 3.4 Inventory Measures

```dax
Inventory On Hand Units =
SUM(FactInventory[on_hand_units])
```

```dax
In-Stock Observations =
SUM(FactInventory[in_stock_flag])
```

```dax
Total Inventory Observations =
COUNTROWS(FactInventory)
```

```dax
In-Stock % =
DIVIDE([In-Stock Observations], [Total Inventory Observations])
```

```dax
Stockout Rate % =
1 - [In-Stock %]
```

### 3.5 Customer Measures

```dax
Total Net Sales (All Accounts) =
CALCULATE(
    [Net Sales],
    ALL(FactSales[state_code])
)
```

```dax
Account Revenue Share % =
DIVIDE([Net Sales], [Total Net Sales (All Accounts)])
```

```dax
Top 10 Accounts Net Sales =
SUMX(
    TOPN(
        10,
        VALUES(FactSales[state_code]),
        [Net Sales],
        DESC
    ),
    [Net Sales]
)
```

```dax
Top 10 Accounts % of Sales =
DIVIDE([Top 10 Accounts Net Sales], [Total Net Sales (All Accounts)])
```

## Step 4: Build Executive Overview Page

### 4.1 Create Page
1. Click "+" to add new page
2. Rename to "Executive Overview"
3. Set page size: 16:9 (standard)

### 4.2 Add Slicers (Top)
1. Add "Date Hierarchy" slicer (from DimDate)
2. Add "State Code" slicer (from DimLocation)
3. Add "Channel" slicer (from DimChannel)
4. Arrange horizontally at top

### 4.3 Add KPI Cards (Row 1)
Create these card visuals:

**Card 1 - Net Sales:**
- Field: `[Net Sales]`
- Format: Currency, 0 decimals
- Add trend indicator (if you have prior period data)

**Card 2 - Gross Margin $:**
- Field: `[Gross Margin $]`
- Format: Currency, 0 decimals

**Card 3 - Units Sold:**
- Field: `[Volume Units]`
- Format: Whole number, 0 decimals

**Card 4 - Net VWAP:**
- Field: `[Net VWAP]`
- Format: Currency, 2 decimals

**Card 5 - Active Accounts:**
- Field: `[Active Accounts (Sold)]`
- Format: Whole number

### 4.4 Add Revenue Trend Chart (Row 2, Left)
1. Add Line chart visual
2. Axis: `DimDate[Month]` (or `DimDate[full_date]` for daily)
3. Values: `[Net Sales]`, `[Gross Sales]`
4. Legend: Sales type
5. Title: "Revenue Trend"

### 4.5 Add Margin Trend Chart (Row 2, Center)
1. Add Line chart visual
2. Axis: `DimDate[Month]`
3. Values: `[Gross Margin %]`
4. Title: "Margin Trend"
5. Add constant line at 40% (target)

### 4.6 Add Volume Trend Chart (Row 2, Right)
1. Add Clustered column chart
2. Axis: `DimDate[Month]`
3. Values: `[Volume Units]`
4. Legend: `DimProduct[cannabinoid_family]` (if available)
5. Title: "Volume Trend by Product Family"

### 4.7 Add State Performance Matrix (Row 3)
1. Add Matrix visual
2. Rows: `DimLocation[state_name]`
3. Columns: Add these values:
   - `[Net Sales]`
   - `[Volume Units]`
   - `[Gross Margin %]`
   - `[Net VWAP]`
   - `[Active Accounts (Sold)]`
4. Enable conditional formatting:
   - Net Sales: Green scale
   - Margin %: Red-green scale (center at 40%)
5. Title: "State Performance"

## Step 5: Build Sales & Revenue Performance Page

### 5.1 Create Page
1. Add new page
2. Rename to "Sales & Revenue Performance"

### 5.2 Add KPI Cards (Top)
Create cards for:
- Net Sales
- Gross VWAP
- Net VWAP
- Discount Rate
- (Add promo measures if you have promo flags in data)

### 5.3 Add VWAP Trend Chart
1. Line chart
2. Axis: `DimDate[Month]`
3. Values: `[Gross VWAP]`, `[Net VWAP]`
4. Title: "VWAP Trend"

### 5.4 Add Product Mix Donut Chart
1. Donut chart
2. Values: `[Net Sales]`
3. Legend: `DimProduct[flavor_name]` or `DimProduct[cannabinoid_family]`
4. Title: "Product Mix"

### 5.5 Add Channel Performance Chart
1. Stacked column chart
2. Axis: `DimDate[Month]`
3. Values: `[Net Sales]`
4. Legend: `DimChannel[channel]`
5. Title: "Channel Performance"

## Step 6: Build Inventory & Operations Page

### 6.1 Create Page
1. Add new page
2. Rename to "Inventory & Operations"

### 6.2 Add KPI Cards (Top)
Create cards for:
- Inventory On Hand Units
- In-Stock %
- Stockout Rate %

### 6.3 Add Inventory Trend Chart
1. Line chart
2. Axis: `DimDate[full_date]` (daily)
3. Values: `[Inventory On Hand Units]`
4. Legend: `DimLocation[state_name]`
5. Title: "Inventory Level Trend"

### 6.4 Add In-Stock Trend Chart
1. Line chart
2. Axis: `DimDate[full_date]`
3. Values: `[In-Stock %]`
4. Add threshold line at 95%
5. Title: "In-Stock Rate Trend"

## Step 7: Build Customer & Account Analytics Page

### 7.1 Create Page
1. Add new page
2. Rename to "Customer & Account Analytics"

### 7.2 Add KPI Cards (Top)
Create cards for:
- Total Net Sales (All Accounts)
- Active Accounts (Sold)
- Top 10 Accounts % of Sales

### 7.3 Add Concentration Trend Chart
1. Line chart
2. Axis: `DimDate[Month]`
3. Values: `[Top 10 Accounts % of Sales]`
4. Add threshold line at 50%
5. Title: "Account Concentration Trend"

### 7.4 Add Top Accounts Table
1. Table visual
2. Columns:
   - `DimLocation[state_name]`
   - `[Net Sales]`
   - `[Account Revenue Share %]`
3. Sort by Net Sales descending
4. Title: "Top Performing Accounts"

## Step 8: Formatting and Polish

### 8.1 Apply Consistent Formatting
- Font: Segoe UI (default)
- Title size: 16pt bold
- Subtitle size: 12pt
- Background: White or light gray
- Card backgrounds: White with subtle border

### 8.2 Add Page Navigation
1. Add buttons to each page
2. Configure to navigate to other pages
3. Use consistent button styling

### 8.3 Add Tooltips
- Enable tooltips on key visuals
- Include relevant measures in tooltips
- Use clear labels

## Step 9: Test and Validate

### 9.1 Test Slicers
- Change date range - verify all visuals update
- Select state - verify filtering works
- Select channel - verify filtering works

### 9.2 Test Measures
- Verify calculations are correct
- Check for divide-by-zero errors
- Validate against manual calculations

### 9.3 Test Navigation
- Click drill-through buttons
- Verify page navigation works
- Test back buttons

## Step 10: Document and Export

### 10.1 Create Documentation
1. Take screenshots of each page
2. Add to `assets/screenshots/` folder
3. Create a README for the report

### 10.2 Export for Portfolio
1. File → Export → Export report data
2. Save screenshots
3. Document insights and business value

## Business Analyst Capabilities Demonstrated

This implementation shows you can:

1. **Data Modeling**: Build star schema with proper relationships
2. **DAX Development**: Create complex measures and calculations
3. **Visualization Design**: Build effective dashboards with clear hierarchy
4. **Business Logic**: Translate business requirements into technical solutions
5. **User Experience**: Design intuitive navigation and interactivity
6. **Data Validation**: Test and validate calculations
7. **Documentation**: Document technical and business aspects

## Next Steps

1. **Enhance Measures**: Add more complex measures (promo lift, retention, etc.)
2. **Add Drill-through**: Create detail pages for specific entities
3. **Conditional Formatting**: Add more sophisticated formatting rules
4. **Performance Optimization**: Optimize measures for large datasets
5. **Publish**: Deploy to Power BI Service (optional)
6. **Create Story**: Document the business insights and recommendations

## Troubleshooting

### Common Issues

**Relationship Errors:**
- Ensure cardinality is correct (1:*, not *:*)
- Check cross-filter direction (single for most cases)
- Verify key columns match data types

**Measure Errors:**
- Check for divide-by-zero (use DIVIDE function)
- Verify table references are correct
- Check filter context in CALCULATE

**Visual Issues:**
- Ensure data types are correct
- Check for null values
- Verify category (numeric vs text)

### Performance Tips

- Use integer keys for relationships
- Avoid complex measures in tooltips
- Use calculated columns for static calculations
- Limit visual count per page (<10)

## Portfolio Presentation

When presenting this work:

1. **Walk through the data journey**: From raw CSV to insights
2. **Explain the model**: Why star schema, why these measures
3. **Show business value**: What questions this answers
4. **Demonstrate interactivity**: Show slicers and drill-through
5. **Discuss trade-offs**: Why certain design decisions
6. **Talk about scalability**: How this would work with real data

This demonstrates you're not just a "report builder" but a business analyst who understands the full analytics lifecycle.

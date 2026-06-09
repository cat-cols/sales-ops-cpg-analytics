# Tableau Data Source Setup Guide

**Project:** 01_ops_command_center
**Database:** PostgreSQL
**Schema:** `mart`
**Purpose:** Step-by-step guide for connecting Tableau to the analytics mart layer

---

## Prerequisites

### Software Required

1. **Tableau Desktop** (trial or licensed)
   - Download: https://www.tableau.com/trial
   - Version: 2023.1 or later (for relationship model support)
   - Trial period: 14 days (sufficient for portfolio build)

2. **PostgreSQL Driver for Tableau**
   - Included with Tableau Desktop 2023.1+
   - Or download from: https://www.tableau.com/support/drivers

3. **PostgreSQL Database**
   - Local PostgreSQL instance with `wyld_chyld` database
   - Or cloud PostgreSQL (AWS RDS, Google Cloud SQL, etc.)
   - Mart layer views must be built (see SQL build scripts)

### Data Requirements

**Required Tables/Views:**
- `mart.fact_sales_daily`
- `mart.fact_inventory_snapshot_daily`
- `mart.fact_labor_daily`
- `mart.fact_actuals_monthly`
- `mart.dim_date`
- `mart.dim_store`
- `mart.dim_sku`
- `mart.dim_employee`
- `mart.kpi_gross_margin_daily`
- `mart.kpi_sales_per_labor_hour_daily`
- `mart.kpi_instock_rate_daily`
- `mart.recon_sales_to_gl_monthly`

**Data Validation:**
- Run SQL QA suite first: `psql "$P1_PG_OPS" -f 01_ops_command_center/sql/_qa/_run_qa.sql`
- Verify row counts are non-zero
- Confirm date ranges are populated

---

## Connection Setup

### Step 1: Open Tableau Desktop

1. Launch Tableau Desktop
2. Select "Connect to Server" → "More..." → "PostgreSQL"
3. Or use "Connect" pane on left sidebar

### Step 2: Configure Connection

**Connection Details:**

| Field | Value | Notes |
|-------|-------|-------|
| Server | `localhost` | Or your PostgreSQL host |
| Port | `5432` | Default PostgreSQL port |
| Database | `wyld_chyld` | Your database name |
| Authentication | `Username and Password` | Or use embedded credentials |
| Username | `postgres` | Your PostgreSQL username |
| Password | `*` | Your PostgreSQL password |
| Require SSL | `False` | For local development |

**Advanced Options (if needed):**
- **Initial SQL:** Run SQL on connection (optional)
- **Read uncommitted data:** False (default)
- **Single Transaction:** True (recommended for consistency)

### Step 3: Test Connection

1. Click "Test Connection" button
2. If successful, click "Sign In"
3. If failed, verify:
   - PostgreSQL is running
   - Database name is correct
   - Username/password are correct
   - Network/firewall allows connection

### Step 4: Select Schema

1. After connection, you'll see the Data Source page
2. In the "Data" pane, expand the database
3. Select the `mart` schema
4. You should see all the mart views listed

---

## Building the Data Source

### Step 5: Add Fact Tables

**Add Sales Fact:**
1. Drag `fact_sales_daily` to the canvas
2. Tableau will show the table structure
3. Verify key fields: `date_key`, `store_key`, `sku_key`, `channel_key`

**Add Inventory Fact:**
1. Drag `fact_inventory_snapshot_daily` to the canvas
2. Place it below or beside the sales fact
3. Verify key fields: `date_key`, `store_key`, `sku_key`

**Add Labor Fact:**
1. Drag `fact_labor_daily` to the canvas
2. Verify key fields: `date_key`, `store_key`, `employee_group_key`

**Add Finance Actuals:**
1. Drag `fact_actuals_monthly` to the canvas
2. Verify key fields: `month_start`, `metric_name`

### Step 6: Add Dimension Tables

**Add Date Dimension:**
1. Drag `dim_date` to the canvas
2. Verify key field: `date_key`
3. This will be the primary date dimension for all facts

**Add Store Dimension:**
1. Drag `dim_store` to the canvas
2. Verify key field: `store_key`
3. This will join to sales, inventory, and labor facts

**Add SKU Dimension:**
1. Drag `dim_sku` to the canvas
2. Verify key field: `sku_key`
3. This will join to sales and inventory facts

**Add Employee Dimension:**
1. Drag `dim_employee` to the canvas
2. Verify key field: `employee_key`
3. This will join to labor fact

### Step 7: Add KPI Tables

**Add KPI Tables:**
1. Drag `kpi_gross_margin_daily` to the canvas
2. Drag `kpi_sales_per_labor_hour_daily` to the canvas
3. Drag `kpi_instock_rate_daily` to the canvas
4. These are pre-calculated KPIs from the mart layer

### Step 8: Add Reconciliation Tables

**Add Reconciliation Tables:**
1. Drag `recon_sales_to_gl_monthly` to the canvas
2. Drag `recon_sales_distributor_vs_pos` to the canvas
3. These provide trust and control metrics

---

## Defining Relationships

### Step 9: Establish Relationships

**Tableau 2020.4+ Relationship Model:**

**Sales Fact Relationships:**
```
fact_sales_daily.date_key = dim_date.date_key
fact_sales_daily.store_key = dim_store.store_key
fact_sales_daily.sku_key = dim_sku.sku_key
```

**Inventory Fact Relationships:**
```
fact_inventory_snapshot_daily.date_key = dim_date.date_key
fact_inventory_snapshot_daily.store_key = dim_store.store_key
fact_inventory_snapshot_daily.sku_key = dim_sku.sku_key
```

**Labor Fact Relationships:**
```
fact_labor_daily.date_key = dim_date.date_key
fact_labor_daily.store_key = dim_store.store_key
fact_labor_daily.employee_group_key = dim_employee.employee_group_key
```

**Finance Actuals Relationships:**
```
fact_actuals_monthly.month_start = dim_date.date_key (at month level)
```

**How to Create Relationships:**
1. Drag a field from one table to the corresponding field in another table
2. Tableau will automatically create a relationship
3. The relationship line will appear between tables
4. Verify the relationship cardinality (many-to-one, one-to-one, etc.)

### Step 10: Verify Relationships

**Check Relationship Cardinality:**
- Fact to Dimension: Many-to-One (correct)
- Dimension to Dimension: One-to-One (if any)
- Fact to Fact: Many-to-Many (avoid if possible)

**Test Relationships:**
1. Drag `dim_store.store_name` to the Rows shelf
2. Drag `fact_sales_daily.net_sales_amount` to the Columns shelf
3. If data appears, relationships are working
4. If no data appears, check relationship definitions

---

## Data Source Filters

### Step 11: Add Data Source Filters

**Date Range Filter (Optional):**
1. Click "Add" next to "Data Source Filters" in the Data Source pane
2. Select `dim_date.date`
3. Set filter to exclude dates outside your analysis range
4. This improves performance by limiting data loaded

**Active Stores Filter (Optional):**
1. Add data source filter on `dim_store.store_status`
2. Filter to "Active" stores only
3. Excludes closed/test stores

**Date Freshness Filter (Optional):**
1. Add data source filter on `dim_date.date`
2. Set to "Last 365 days" or similar
3. Ensures dashboard shows recent data

---

## Performance Optimization

### Step 12: Create Extract (Recommended)

**Why Use Extracts:**
- Faster performance than live connections
- Works offline (no database connection required)
- Better for Tableau Public publishing
- Enables data source filters for performance

**How to Create Extract:**
1. In the Data Source pane, click "Extract" radio button
2. Click "Edit" next to Extract
3. Configure extract options:
   - **Extract Data:** All data or filtered
   - **Storage:** Single table or multiple tables
   - **Updates:** Incremental updates (if needed)
4. Click "OK"
5. Click "Refresh" to create the extract
6. Save the extract (`.hyper` file)

**Extract Refresh Schedule:**
- Manual refresh (right-click data source → Refresh)
- Schedule refresh (if using Tableau Server/Online)
- Incremental refresh (for large datasets)

### Step 13: Optimize Data Source

**Remove Unused Fields:**
1. Hide fields you won't use in analysis
2. Right-click field → "Hide"
3. This reduces extract size

**Change Data Types:**
1. Verify numeric fields are recognized as numbers
2. Verify date fields are recognized as dates
3. Convert text dates to date fields if needed

**Create Calculated Fields in Data Source:**
1. Create commonly used calculations at data source level
2. Examples: `Year = YEAR([date])`, `Month = MONTH([date])`
3. This improves performance and reusability

---

## Validation

### Step 14: Validate Data Source

**Row Count Validation:**
```sql
-- In PostgreSQL, verify row counts match expectations
SELECT 
    'fact_sales_daily' as table_name, COUNT(*) as row_count
FROM mart.fact_sales_daily
UNION ALL
SELECT 
    'fact_inventory_snapshot_daily', COUNT(*)
FROM mart.fact_inventory_snapshot_daily
UNION ALL
SELECT 
    'fact_labor_daily', COUNT(*)
FROM mart.fact_labor_daily;
```

**In Tableau:**
1. Create a sheet with each fact table
2. Drag `Number of Records` to the view
3. Compare with PostgreSQL row counts
4. Should match (or be close if filters applied)

**Data Quality Validation:**
1. Check for null values in key fields
2. Verify date ranges are correct
3. Check for duplicate records
4. Validate referential integrity (all foreign keys exist)

### Step 15: Test Calculations

**Test Simple Aggregation:**
1. Drag `net_sales_amount` to the view
2. Change aggregation to SUM
3. Verify total matches expected value

**Test Date Filtering:**
1. Drag `date` to the Filters shelf
2. Filter to a specific month
3. Verify data is filtered correctly

**Test Relationship Joins:**
1. Drag `store_name` and `sku_name` to the view
2. Drag `net_sales_amount` to the view
3. Verify data appears correctly (no nulls from failed joins)

---

## Saving the Data Source

### Step 16: Save Data Source

**Save as .tds File:**
1. Right-click the data source in the Data pane
2. Select "Add to Saved Data Sources"
3. Name it: `ops_command_center_mart.tds`
4. This saves the connection and relationships

**Save as .tdsx File (with extract):**
1. If you created an extract, save as .tdsx
2. This includes the extract data
3. Larger file size but self-contained

**Save Workbook:**
1. Save the workbook as `ops_command_center.twb`
2. The data source connection is saved with the workbook
3. For Tableau Public, save as `.twb` (without extract) or `.twbx` (with extract)

---

## Troubleshooting

### Common Issues

**Connection Failed:**
- Verify PostgreSQL is running
- Check database name, username, password
- Ensure PostgreSQL driver is installed
- Check firewall/network settings

**No Data Appears:**
- Verify relationships are correct
- Check for null key values
- Verify data source filters aren't excluding all data
- Check that tables have data

**Relationship Errors:**
- Verify key field names match exactly
- Check data types match (integer to integer, etc.)
- Ensure cardinality is correct
- Try using join clauses instead of relationships (legacy approach)

**Performance Issues:**
- Create an extract instead of live connection
- Add data source filters to limit data
- Hide unused fields
- Use context filters for complex calculations

### Getting Help

**Tableau Resources:**
- Tableau Knowledge Base: https://kb.tableau.com/
- Tableau Community: https://community.tableau.com/
- Tableau Desktop Help: Help menu in Tableau Desktop

**PostgreSQL Resources:**
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- PostgreSQL Connection Issues: Check PostgreSQL logs

---

## Next Steps

After setting up the data source:

1. **Start Building Dashboards**
   - Begin with Executive Overview
   - Use the data source you just created
   - Follow the dashboard design guide

2. **Create Calculated Fields**
   - Add business logic calculations
   - Implement LOD expressions
   - Create parameter-driven calculations

3. **Test and Validate**
   - Verify calculations match SQL logic
   - Test interactivity
   - Validate against source data

4. **Publish to Tableau Public**
   - Create Tableau Public account
   - Publish your workbook
   - Share in portfolio

---

## Quick Reference: Connection String

If you need to connect programmatically or use alternative tools:

```
postgresql://username:password@localhost:5432/wyld_chyld
```

**Environment Variables (recommended for security):**
```bash
export TABLEAU_PG_HOST=localhost
export TABLEAU_PG_PORT=5432
export TABLEAU_PG_DATABASE=wyld_chyld
export TABLEAU_PG_USER=postgres
export TABLEAU_PG_PASSWORD=your_password
```

Use these in Tableau's "Initial SQL" or connection parameters if supported.

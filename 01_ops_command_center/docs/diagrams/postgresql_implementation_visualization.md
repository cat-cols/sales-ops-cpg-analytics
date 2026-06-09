# PostgreSQL Implementation Visualization - Project 1

## Overview
This document visualizes how the PostgreSQL database was implemented for Project 1, showing the data flow from CSV files through the different database layers.

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           CSV FILES (data/sample/)                                   │
│  sales_sample.csv, inventory_sample.csv, labor_sample.csv, finance_sample.csv      │
└────────────────────────────┬──────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           RAW LAYER (raw schema)                                     │
│  Direct copy of CSV data into database tables                                      │
│  Tables: raw.pos_transactions_csv, raw.inventory_erp_snapshot, etc.                 │
└────────────────────────────┬──────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           STAGING LAYER (stg schema)                                 │
│  Clean and standardize data from raw tables                                        │
│  Views: stg.stg_pos_transactions, stg.stg_inventory_erp, etc.                     │
└────────────────────────────┬──────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         INTEGRATION LAYER (int schema)                                │
│  Conform and integrate data across sources                                         │
│  Views: int.int_pos_daily, int.int_sales_conformed, etc.                          │
└────────────────────────────┬──────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           MART LAYER (mart schema)                                  │
│  Business-ready data for reporting and analytics                                   │
│  Views: mart.fact_sales_daily, mart.dim_date, mart.kpi_days_of_supply, etc.       │
└────────────────────────────┬──────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        POWER BI (Visualization)                                      │
│  Connect to PostgreSQL mart views for reporting                                    │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Layer-by-Layer Explanation

### Layer 1: CSV Files → Raw Schema

**What happens:**
- CSV files from `data/sample/` are loaded directly into PostgreSQL tables
- No transformation, just direct copy
- Tables are in the `raw` schema

**Example:**
```
CSV: sales_sample.csv
  ↓
Database: raw.pos_transactions_csv (9,850 rows)
```

**Purpose:**
- Preserve original source data
- Allow for data lineage tracking
- Enable re-running transformations if needed

**Key Tables:**
- `raw.pos_transactions_csv` (9,850 rows)
- `raw.inventory_erp_snapshot` (8,400 rows)
- `raw.labor_hours_payroll_export` (640 rows)
- Plus 21 other raw tables

---

### Layer 2: Raw Schema → Staging Schema

**What happens:**
- SQL views clean and standardize data from raw tables
- Fix data types, handle nulls, standardize formats
- Views are in the `stg` schema

**Example:**
```
raw.pos_transactions_csv
  ↓ (stg.stg_pos_transactions.sql)
stg.stg_pos_transactions (view)
```

**Transformations:**
- Convert text dates to proper date types
- Handle missing values
- Standardize column names
- Remove duplicates
- Validate data ranges

**Key Views:**
- `stg.stg_pos_transactions` - Clean POS data
- `stg.stg_inventory_erp` - Clean inventory data
- `stg.stg_labor_payroll` - Clean labor data
- Plus 20 other staging views

**Purpose:**
- Create a clean, consistent data layer
- Handle data quality issues
- Prepare data for integration

---

### Layer 3: Staging Schema → Integration Schema

**What happens:**
- SQL views conform and integrate data across different sources
- Create canonical dimensions (stores, products, SKUs)
- Views are in the `int` schema

**Example:**
```
stg.stg_pos_transactions + stg.stg_dispensary_master
  ↓ (int.int_pos_daily.sql)
int.int_pos_daily (view)
```

**Transformations:**
- Deduplicate records
- Create canonical store IDs
- Integrate POS and distributor sales
- Build latest status views
- Create conformed dimensions

**Key Views:**
- `int.int_pos_daily` - Integrated POS data
- `int.int_sales_conformed` - Conformed sales data
- `int.int_dispensary_latest` - Latest dispensary status
- `int.int_inventory_snapshot_dedup` - Deduplicated inventory
- Plus 13 other integration views

**Purpose:**
- Create a single source of truth
- Integrate data from multiple systems
- Build reusable dimensions
- Enable cross-source analysis

---

### Layer 4: Integration Schema → Mart Schema

**What happens:**
- SQL views create business-ready data for reporting
- Build dimensional model (facts and dimensions)
- Create KPIs and controls
- Views are in the `mart` schema

**Example:**
```
int.int_pos_daily + mart.dim_date + mart.dim_store
  ↓ (mart.fact_sales_daily.sql)
mart.fact_sales_daily (view)
```

**Transformations:**
- Build star schema (facts + dimensions)
- Create business metrics (KPIs)
- Build data quality controls
- Create reconciliation views

**Key Views:**

**Dimensions:**
- `mart.dim_date` - Date dimension
- `mart.dim_sku` - Product dimension
- `mart.dim_store` - Store/location dimension
- `mart.dim_employee` - Employee dimension

**Facts:**
- `mart.fact_sales_daily` - Daily sales fact
- `mart.fact_sales_pos_daily` - POS sales fact
- `mart.fact_inventory_snapshot_daily` - Inventory fact
- `mart.fact_labor_daily` - Labor fact

**KPIs:**
- `mart.kpi_days_of_supply` - Days of inventory
- `mart.kpi_instock_rate_daily` - In-stock percentage
- `mart.kpi_sales_per_labor_hour_daily` - Sales productivity
- `mart.kpi_gross_margin_daily` - Gross margin

**Controls:**
- `mart.controls_freshness` - Data freshness checks
- `mart.controls_duplicate_source_records` - Duplicate detection
- `mart.controls_missing_dim_joins` - Missing dimension checks

**Purpose:**
- Create business-ready data for reporting
- Enable fast query performance
- Provide reusable business metrics
- Support data quality monitoring

---

## Data Transformation Examples

**Data transformations happen progressively at each layer:**

### Layer 1: CSV → Raw (No Transformation)
**What happens:** Direct copy, no changes
```
CSV: "2024-01-01,PDX001,WYLD-RASP-10,40,999.6"
↓
Raw: Same data, just copied to database table
```

### Layer 2: Raw → Staging (Cleaning & Typing)
**Transformations:**
- **Data type conversion**: Text → proper types
- **Null handling**: Handle missing values
- **Trimming**: Remove whitespace
- **Flagging**: Add quality flags

**Example:**
```
Raw: 
  store_code_raw = "PDX001 " (with space)
  qty_raw = "40" (text)
  unit_price_raw = "24.99" (text)

↓ Staging View

Staging:
  store_code = "PDX001" (trimmed, null if empty)
  qty = 40 (numeric)
  unit_price = 24.99 (numeric)
  is_missing_key = false (quality flag)
  is_duplicate_candidate = false (quality flag)
```

**Key changes:**
- `store_code_raw` → `store_code` (trimmed, null if empty)
- `qty_raw` → `qty` (text → numeric)
- Added quality flags (`is_missing_key`, `is_duplicate_candidate`)

### Layer 3: Staging → Integration (Deduplication & Aggregation)
**Transformations:**
- **Deduplication**: Remove duplicate transactions
- **Aggregation**: Group by date + store + SKU
- **Filtering**: Remove null keys
- **Integration**: Combine multiple sources

**Example:**
```
Staging (multiple rows per day):
  2024-01-01, PDX001, WYLD-RASP-10, 10 units, $249.90
  2024-01-01, PDX001, WYLD-RASP-10, 30 units, $749.70
  2024-01-01, PDX001, WYLD-RASP-10, 5 units, $124.95 (duplicate)

↓ Integration View

Integration (aggregated):
  2024-01-01, PDX001, WYLD-RASP-10, 40 units, $999.60
  (sum of units, sum of gross_sales, count of transactions)
```

**Key changes:**
- Multiple rows → 1 row per day/store/SKU
- Added `line_count` (number of source rows)
- Added `txn_count` (number of unique transactions)
- Summed measures: `units`, `gross_sales`, `net_sales`

### Layer 4: Integration → Mart (Business Logic & Dimensional Model)
**Transformations:**
- **Deduplication**: Remove duplicates using row_number
- **Aggregation**: Daily grain with business metrics
- **Dimension joins**: Add product names, dates
- **Business logic**: Calculate derived metrics
- **Channel assignment**: Add channel labels

**Example:**
```
Integration:
  2024-01-01, PDX001, WYLD-RASP-10, 40 units, $999.60 gross, $950.00 net

↓ Mart View

Mart:
  sale_date: 2024-01-01
  store_code: PDX001
  sku: WYLD-RASP-10
  channel: 'retail' (added)
  product_name: 'Raspberry Gummies 10pk' (from dim_sku)
  qty: 40
  gross_sales: 999.60
  discount_amount: 49.60 (calculated: gross - net)
  net_sales: 950.00
  cogs: null (POS has no COGS)
  orders: 1 (count of distinct transactions)
  unit_list_price_wavg: 24.99 (calculated: gross_sales / qty)
  unit_net_price_wavg: 23.75 (calculated: net_sales / qty)
  discount_rate_implied: 0.05 (calculated: discount_amount / gross_sales)
```

**Key changes:**
- Added `channel` = 'retail' (business logic)
- Joined to `mart.dim_sku` to get `product_name`
- Calculated `discount_amount` = gross_sales - net_sales
- Calculated `unit_list_price_wavg` = gross_sales / qty
- Calculated `unit_net_price_wavg` = net_sales / qty
- Calculated `discount_rate_implied` = discount_amount / gross_sales
- Added lineage columns (`n_source_rows`, `max_ingested_at`)

### Summary of Transformations

| Layer | Purpose | Key Transformations |
|-------|---------|-------------------|
| Raw | Preserve original | None (direct copy) |
| Staging | Clean & type | Data types, null handling, trimming, quality flags |
| Integration | Deduplicate & integrate | Deduplication, aggregation, filtering |
| Mart | Business-ready | Dimension joins, business logic, derived metrics |

**Result:** Data becomes progressively cleaner, more integrated, and more business-ready as it moves through the layers.

---

## How It Works - Step by Step

### Step 1: Data Loading (Already Done)
```bash
# CSV files were loaded into raw tables
# This happened before we started
```

**What this means:**
- Your CSV files from `data/sample/` were copied into PostgreSQL
- Created tables like `raw.pos_transactions_csv`
- No transformation, just direct copy
- This preserves the original source data

---

### Step 2: Staging Layer (We executed this)
```bash
# We ran these SQL scripts:
psql -d wyld_chyld -f sql/stg/stg_pos_transactions.sql
psql -d wyld_chyld -f sql/stg/stg_inventory_erp.sql
psql -d wyld_chyld -f sql/stg/stg_labor_payroll.sql
# ... and 10 more staging scripts
```

**What this does:**
- Each script creates a view in the `stg` schema
- The view reads from raw tables and applies transformations
- Example: `stg.stg_pos_transactions` reads from `raw.pos_transactions_csv`
- The view cleans the data (fixes dates, handles nulls, etc.)

**Why it's a view, not a table:**
- Views are virtual tables
- They don't store data, they just query the raw tables
- If raw data changes, the view automatically reflects changes
- More flexible than copying data to new tables

---

### Step 3: Integration Layer (We executed this)
```bash
# We ran these SQL scripts:
psql -d wyld_chyld -f sql/int/sales/int_pos_daily.sql
psql -d wyld_chyld -f sql/int/sales/int_sales_conformed.sql
psql -d wyld_chyld -f sql/int/ops/int_inventory_conformed.sql
# ... and 14 more integration scripts
```

**What this does:**
- Each script creates a view in the `int` schema
- The view reads from staging views and integrates data
- Example: `int.int_pos_daily` reads from `stg.stg_pos_transactions`
- The view deduplicates data and creates canonical IDs

**Key integration tasks:**
- Deduplicate records (remove duplicates)
- Create canonical store IDs (standardize store names)
- Integrate POS and distributor data (combine sources)
- Build latest status views (most recent record per entity)

---

### Step 4: Mart Layer (We executed this)
```bash
# We ran these SQL scripts:
psql -d wyld_chyld -f sql/mart/sales/fact_sales_pos_daily.sql
psql -d wyld_chyld -f sql/mart/ops/kpi_days_of_supply.sql
psql -d wyld_chyld -f sql/mart/core/dim_date.sql
# ... and 36 more mart scripts
```

**What this does:**
- Each script creates a view in the `mart` schema
- The view reads from integration views and creates business-ready data
- Example: `mart.fact_sales_daily` reads from `int.int_sales_conformed`
- The view builds the dimensional model (facts + dimensions)

**Key mart tasks:**
- Build star schema (facts + dimensions)
- Create business metrics (KPIs)
- Build data quality controls
- Create reconciliation views

---

## How to Query the Database

### Query Raw Data
```sql
-- See the original CSV data
SELECT * FROM raw.pos_transactions_csv LIMIT 10;
```

### Query Staging Data
```sql
-- See cleaned data
SELECT * FROM stg.stg_pos_transactions LIMIT 10;
```

### Query Integration Data
```sql
-- See integrated data
SELECT * FROM int.int_pos_daily LIMIT 10;
```

### Query Mart Data
```sql
-- See business-ready data
SELECT * FROM mart.fact_sales_daily LIMIT 10;
```

### Query with Dimensions
```sql
-- See sales with store and date information
SELECT 
    f.*,
    d.full_date,
    s.store_name
FROM mart.fact_sales_daily f
JOIN mart.dim_date d ON f.date_key = d.date_key
JOIN mart.dim_store s ON f.store_key = s.store_key
LIMIT 10;
```

---

## How This Connects to Power BI

### Before (CSV Approach)
```
CSV files → Power BI (direct import)
```

### After (PostgreSQL Approach)
```
PostgreSQL mart views → Power BI (database connection)
```

**In Power BI:**
1. Get Data → Database → PostgreSQL
2. Connect to `wyld_chyld` database
3. Load mart views (not raw tables)
4. Build relationships between dimensions and facts
5. Create DAX measures (same as before)
6. Build visualizations (same as before)

**Key difference:**
- Instead of importing CSV files, you connect to database
- Instead of CSV tables, you use mart views
- Everything else in Power BI is the same

---

## Why This Approach

### Benefits
1. **Scalability**: Can handle millions of rows (CSV files can't)
2. **Performance**: Database indexes make queries fast
3. **Data Quality**: Built-in validation and controls
4. **Reusability**: Views can be used by multiple tools
5. **Realistic**: This is how real companies do it

### Trade-offs
1. **Complexity**: Requires database setup and maintenance
2. **Learning curve**: Need to understand SQL and database concepts
3. **Infrastructure**: Need PostgreSQL running

---

## Summary

**What we did:**
1. ✅ Loaded CSV data into raw tables
2. ✅ Built staging views (clean data)
3. ✅ Built integration views (integrate data)
4. ✅ Built mart views (business-ready data)

**What this creates:**
- A complete data warehouse with 4 layers
- 79 total views (23 staging + 17 integration + 39 mart)
- Business-ready data for Power BI
- Data quality controls and KPIs

**Next step:**
- Connect Power BI to PostgreSQL
- Load mart views instead of CSV files
- Build the same visualizations using database data

This demonstrates you can implement a real-world data warehouse, which is more impressive to employers than CSV-only approaches.

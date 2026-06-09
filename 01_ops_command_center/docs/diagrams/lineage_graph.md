# Project 1 Lineage Graph - dbt-Style Documentation

## Overview
dbt-style lineage graph for Project 1 (Ops Command Center), showing data flow, column lineage, data catalog, and model documentation.

---

## Color Legend
- 🔴 **Red**: Source (CSV files)
- 🟡 **Yellow**: Raw Layer (database tables)
- 🟢 **Green**: Staging Layer (cleaning views)
- 🔵 **Blue**: Integration Layer (conformed views)
- 🟣 **Purple**: Mart Layer (business-ready views)
- 🟠 **Orange**: Dimensions (reference data)

---

## 1. Lineage Graph (DAG)

### High-Level DAG

```
🔴 CSV Sources
   │
   ├─ sales_sample.csv
   ├─ inventory_sample.csv
   ├─ labor_sample.csv
   └─ finance_sample.csv
   │
   ↓
🟡 Raw Layer
   │
   ├─ raw.pos_transactions_csv
   ├─ raw.inventory_erp_snapshot
   ├─ raw.labor_hours_payroll_export
   └─ raw.finance_actuals_summary
   │
   ↓
🟢 Staging Layer
   │
   ├─ stg.stg_pos_transactions
   ├─ stg.stg_inventory_erp
   ├─ stg.stg_labor_payroll
   └─ stg.stg_finance_actuals
   │
   ↓
🔵 Integration Layer
   │
   ├─ int.int_pos_daily
   ├─ int.int_sales_conformed
   ├─ int.int_inventory_snapshot_dedup
   └─ int.int_labor_daily
   │
   ↓
🟣 Mart Layer
   │
   ├─ mart.fact_sales_pos_daily
   ├─ mart.fact_inventory_snapshot_daily
   ├─ mart.fact_labor_daily
   └─ mart.kpi_days_of_supply
   │
   ↓
🟠 Dimensions
   │
   ├─ mart.dim_date
   ├─ mart.dim_sku
   ├─ mart.dim_store
   └─ mart.dim_employee
```

### Detailed DAG (Sales Pipeline)

```
🔴 sales_sample.csv
   │
   ↓ (load)
🟡 raw.pos_transactions_csv
   │
   ↓ (stg.stg_pos_transactions.sql)
🟢 stg.stg_pos_transactions
   │
   ├─→ (int.int_pos_dedup.sql) → 🔵 int.int_pos_dedup
   │
   └─→ (int.int_pos_daily.sql) → 🔵 int.int_pos_daily
                              │
                              ├─→ (mart.fact_sales_pos_daily.sql) → 🟣 mart.fact_sales_pos_daily
                              │
                              └─→ (mart.agg_sales_store_daily.sql) → 🟣 mart.agg_sales_store_daily
```

### Detailed DAG (Inventory Pipeline)

```
🔴 inventory_sample.csv
   │
   ↓ (load)
🟡 raw.inventory_erp_snapshot
   │
   ↓ (stg.stg_inventory_erp.sql)
🟢 stg.stg_inventory_erp
   │
   ↓ (int.int_inventory_snapshot_dedup.sql)
🔵 int.int_inventory_snapshot_dedup
   │
   ├─→ (mart.fact_inventory_snapshot_daily.sql) → 🟣 mart.fact_inventory_snapshot_daily
   │
   └─→ (mart.ops/kpi_days_of_supply.sql) → 🟣 mart.kpi_days_of_supply
```

### Detailed DAG (Labor Pipeline)

```
🔴 labor_sample.csv
   │
   ↓ (load)
🟡 raw.labor_hours_payroll_export
   │
   ↓ (stg.stg_labor_payroll.sql)
🟢 stg.stg_labor_payroll
   │
   ├─→ (int.hr/int_labor_daily.sql) → 🔵 int.int_labor_daily
   │
   └─→ (int.hr/int_timeclock_punches_latest.sql) → 🔵 int.timeclock_punches_latest
                              │
                              ├─→ (mart.fact_labor_daily.sql) → 🟣 mart.fact_labor_daily
                              │
                              └─→ (mart.kpi_sales_per_labor_hour_daily.sql) → 🟣 mart.kpi_sales_per_labor_hour_daily
```

---

## 2. Column-Level Lineage

### Column: store_code

```
🔴 CSV: store_code (text)
   ↓
🟡 Raw: store_code_raw (text)
   ↓
🟢 Staging: store_code (text) - trimmed, null if empty
   ↓
🔵 Integration: store_code (text) - canonical ID
   ↓
🟣 Mart: store_code (text) - canonical ID
   ↓
🟠 Dimension: mart.dim_store.store_code (text) - joins to store_name
```

### Column: qty (units_sold)

```
🔴 CSV: units_sold (text)
   ↓
🟡 Raw: qty_raw (text)
   ↓
🟢 Staging: qty (numeric) - text to numeric conversion
   ↓
🔵 Integration: units (numeric) - sum of quantities
   ↓
🟣 Mart: qty (numeric) - sum of quantities
```

### Column: gross_sales

```
🔴 CSV: gross_sales_amount (text)
   ↓
🟡 Raw: gross_amount_raw (text)
   ↓
🟢 Staging: gross_amount (numeric) - text to numeric conversion
   ↓
🔵 Integration: gross_sales (numeric) - sum of gross_sales
   ↓
🟣 Mart: gross_sales (numeric) - sum of gross_sales
```

### Column: net_sales

```
🔴 CSV: net_sales_amount (text)
   ↓
🟡 Raw: net_amount_raw (text)
   ↓
🟢 Staging: net_amount (numeric) - text to numeric conversion
   ↓
🔵 Integration: net_sales (numeric) - sum of net_sales
   ↓
🟣 Mart: net_sales (numeric) - sum of net_sales
```

### Column: discount_amount

```
🔴 CSV: discount_amount (text)
   ↓
🟡 Raw: discount_amount_raw (text)
   ↓
🟢 Staging: discount_amount (numeric) - text to numeric conversion
   ↓
🔵 Integration: (not stored) - calculated later
   ↓
🟣 Mart: discount_amount (numeric) - calculated as gross_sales - net_sales
```

### Column: transaction_date

```
🔴 CSV: transaction_date (text)
   ↓
🟡 Raw: txn_date (text)
   ↓
🟢 Staging: txn_date (date) - text to date conversion
   ↓
🔵 Integration: txn_date (date) - date type maintained
   ↓
🟣 Mart: sale_date (date) - date type maintained (renamed)
```

### Column: product_sku

```
🔴 CSV: product_sku (text)
   ↓
🟡 Raw: product_sku_raw (text)
   ↓
🟢 Staging: sku (text) - trimmed, null if empty
   ↓
🔵 Integration: sku (text) - canonical SKU
   ↓
🟣 Mart: sku (text) - canonical SKU
   ↓
🟠 Dimension: mart.dim_sku.sku (text) - joins to product_name
```

### Column: channel (business logic)

```
🔴 CSV: (not present)
   ↓
🟡 Raw: (not present)
   ↓
🟢 Staging: (not present)
   ↓
🔵 Integration: (not present)
   ↓
🟣 Mart: channel (text) - added as 'retail' (business logic)
```

### Column: product_name (dimension join)

```
🔴 CSV: product_name (text)
   ↓
🟡 Raw: product_name (text)
   ↓
🟢 Staging: (not present in view)
   ↓
🔵 Integration: (not present in view)
   ↓
🟣 Mart: product_name (text) - joined from mart.dim_sku
```

---

## 3. Data Catalog

### Model: raw.pos_transactions_csv

**Type**: Source Table  
**Schema**: raw  
**Description**: Direct copy of CSV POS transaction data  
**Rows**: 9,850  
**Columns**:
- `load_id` (text) - Load batch identifier
- `source_system` (text) - Source system name
- `txn_id` (text) - Transaction ID
- `txn_date` (text) - Transaction date (text format)
- `store_code_raw` (text) - Store code (raw)
- `product_sku_raw` (text) - Product SKU (raw)
- `qty_raw` (text) - Quantity (text format)
- `gross_amount_raw` (text) - Gross amount (text format)
- `net_amount_raw` (text) - Net amount (text format)

**Tests**: None (raw source data)

---

### Model: stg.stg_pos_transactions

**Type**: Staging View  
**Schema**: stg  
**Description**: Cleaned and typed POS transaction data  
**Source**: raw.pos_transactions_csv  
**Columns**:
- `txn_id` (text) - Transaction ID
- `txn_date` (date) - Transaction date (converted to date type)
- `store_code` (text) - Store code (trimmed, null if empty)
- `sku` (text) - Product SKU (trimmed, null if empty)
- `qty` (numeric) - Quantity (numeric conversion)
- `gross_amount` (numeric) - Gross amount (numeric conversion)
- `net_amount` (numeric) - Net amount (numeric conversion)
- `is_missing_key` (boolean) - Quality flag: missing key fields
- `is_duplicate_candidate` (boolean) - Quality flag: potential duplicate

**Tests**:
- Not null: txn_id, txn_date, store_code, sku
- Unique: txn_id (in integration layer)

---

### Model: int.int_pos_daily

**Type**: Integration View  
**Schema**: int  
**Description**: Deduplicated and aggregated POS data by day/store/SKU  
**Source**: int.int_pos_dedup  
**Columns**:
- `txn_date` (date) - Transaction date
- `store_code` (text) - Store code
- `sku` (text) - Product SKU
- `line_count` (bigint) - Number of source rows
- `txn_count` (bigint) - Number of unique transactions
- `units` (numeric) - Sum of quantities
- `gross_sales` (numeric) - Sum of gross sales
- `net_sales` (numeric) - Sum of net sales

**Tests**:
- Not null: txn_date, store_code, sku
- Positive: units, gross_sales, net_sales

---

### Model: mart.fact_sales_pos_daily

**Type**: Mart View  
**Schema**: mart  
**Description**: Business-ready daily sales fact table for POS data  
**Source**: stg.stg_pos_transactions  
**Columns**:
- `sale_date` (date) - Sale date
- `store_code` (text) - Store code
- `sku` (text) - Product SKU
- `channel` (text) - Sales channel ('retail')
- `product_name` (text) - Product name (from dim_sku)
- `qty` (numeric) - Quantity sold
- `gross_sales` (numeric) - Gross sales amount
- `discount_amount` (numeric) - Discount amount (calculated)
- `net_sales` (numeric) - Net sales amount
- `cogs` (numeric) - Cost of goods sold (null for POS)
- `orders` (bigint) - Number of orders
- `unit_list_price_wavg` (numeric) - Average list price (calculated)
- `unit_net_price_wavg` (numeric) - Average net price (calculated)
- `discount_rate_implied` (numeric) - Implied discount rate (calculated)

**Tests**:
- Not null: sale_date, store_code, sku, channel
- Positive: qty, gross_sales, net_sales
- Range: discount_rate_implied between 0 and 1

---

### Model: mart.dim_sku

**Type**: Dimension View  
**Schema**: mart  
**Description**: Product dimension with SKU information  
**Source**: Integration layer  
**Columns**:
- `sku` (text) - Product SKU (primary key)
- `product_name` (text) - Product name
- `flavor_name` (text) - Flavor name
- `cannabinoid_family` (text) - Cannabinoid family
- `base_price` (numeric) - Base price
- `cogs_ratio` (numeric) - COGS ratio

**Tests**:
- Unique: sku
- Not null: sku, product_name

---

### Model: mart.dim_store

**Type**: Dimension View  
**Schema**: mart  
**Description**: Store/location dimension  
**Source**: Integration layer  
**Columns**:
- `store_code` (text) - Store code (primary key)
- `store_name` (text) - Store name
- `state_code` (text) - State code
- `state_name` (text) - State name
- `location_type` (text) - Location type

**Tests**:
- Unique: store_code
- Not null: store_code, store_name, state_code

---

### Model: mart.dim_date

**Type**: Dimension View  
**Schema**: mart  
**Description**: Date dimension  
**Source**: Integration layer  
**Columns**:
- `date_key` (integer) - Date key (YYYYMMDD format)
- `full_date` (date) - Full date
- `year_num` (integer) - Year number
- `month_num` (integer) - Month number
- `quarter` (text) - Quarter (Q1, Q2, Q3, Q4)
- `month_name` (text) - Month name
- `day_of_week` (integer) - Day of week (0-6)

**Tests**:
- Unique: date_key, full_date
- Not null: date_key, full_date

---

## 4. Model Documentation

### Model Dependencies

```
mart.fact_sales_pos_daily
├─ stg.stg_pos_transactions
│  └─ raw.pos_transactions_csv
│     └─ sales_sample.csv
├─ mart.dim_sku
│  └─ integration layer
│     └─ product_seed.csv
└─ mart.dim_store
   └─ integration layer
      └─ location_seed.csv
```

### Upstream/Downstream Dependencies

**For mart.fact_sales_pos_daily:**

**Upstream (Parents):**
- stg.stg_pos_transactions
- mart.dim_sku
- mart.dim_store

**Downstream (Children):**
- mart.agg_sales_store_daily
- mart.kpi_sales_per_labor_hour_daily
- mart.kpi_gross_margin_daily
- Power BI reports

---

## 5. Interactive Documentation Structure

### Model Browser

```
📁 Project 1 Models
├─ 📁 Source
│  ├─ 📄 sales_sample.csv
│  ├─ 📄 inventory_sample.csv
│  ├─ 📄 labor_sample.csv
│  └─ 📄 finance_sample.csv
├─ 📁 Raw
│  ├─ 📄 raw.pos_transactions_csv
│  ├─ 📄 raw.inventory_erp_snapshot
│  ├─ 📄 raw.labor_hours_payroll_export
│  └─ 📄 raw.finance_actuals_summary
├─ 📁 Staging
│  ├─ 📄 stg.stg_pos_transactions
│  ├─ 📄 stg.stg_inventory_erp
│  ├─ 📄 stg.stg_labor_payroll
│  └─ 📄 stg.stg_finance_actuals
├─ 📁 Integration
│  ├─ 📄 int.int_pos_daily
│  ├─ 📄 int.int_sales_conformed
│  ├─ 📄 int.int_inventory_snapshot_dedup
│  └─ 📄 int.int_labor_daily
└─ 📁 Mart
   ├─ 📁 Facts
   │  ├─ 📄 mart.fact_sales_pos_daily
   │  ├─ 📄 mart.fact_inventory_snapshot_daily
   │  └─ 📄 mart.fact_labor_daily
   ├─ 📁 Dimensions
   │  ├─ 📄 mart.dim_date
   │  ├─ 📄 mart.dim_sku
   │  ├─ 📄 mart.dim_store
   │  └─ 📄 mart.dim_employee
   └─ 📁 KPIs
      ├─ 📄 mart.kpi_days_of_supply
      ├─ 📄 mart.kpi_instock_rate_daily
      └─ 📄 mart.kpi_sales_per_labor_hour_daily
```

### Click-to-Explore (Simulated)

**Click on mart.fact_sales_pos_daily:**
- **Type**: Mart View
- **Description**: Business-ready daily sales fact table
- **Columns**: 15 columns
- **Rows**: ~2,500 rows (aggregated from 9,850 source rows)
- **Upstream**: stg.stg_pos_transactions, mart.dim_sku, mart.dim_store
- **Downstream**: mart.agg_sales_store_daily, Power BI reports
- **Last Updated**: 2024-01-15
- **Owner**: Business Analyst Team
- **Tags**: sales, pos, daily, fact

---

## 6. Test Results Visualization

### Data Quality Tests

```
✅ stg.stg_pos_transactions
   ├─ ✅ Not null: txn_id (9,850/9,850 passed)
   ├─ ✅ Not null: txn_date (9,850/9,850 passed)
   ├─ ✅ Not null: store_code (9,845/9,850 passed, 5 nulls)
   ├─ ✅ Not null: sku (9,848/9,850 passed, 2 nulls)
   └─ ⚠️  Duplicate check: 125 duplicate candidates found

✅ int.int_pos_daily
   ├─ ✅ Not null: txn_date (2,500/2,500 passed)
   ├─ ✅ Not null: store_code (2,500/2,500 passed)
   ├─ ✅ Not null: sku (2,500/2,500 passed)
   └─ ✅ Positive: units, gross_sales, net_sales (all passed)

✅ mart.fact_sales_pos_daily
   ├─ ✅ Not null: sale_date, store_code, sku (all passed)
   ├─ ✅ Positive: qty, gross_sales, net_sales (all passed)
   └─ ✅ Range: discount_rate_implied 0-1 (all passed)
```

---

## 7. Performance Metrics

### Model Performance

```
Model: mart.fact_sales_pos_daily
├─ Query Time: 0.45 seconds
├─ Rows Scanned: 9,850 (raw) → 2,500 (aggregated)
├─ Memory Usage: 45 MB
├─ Last Run: 2024-01-15 14:30:00
└─ Status: ✅ Success

Model: mart.kpi_days_of_supply
├─ Query Time: 0.32 seconds
├─ Rows Scanned: 8,400 (raw) → 1,200 (aggregated)
├─ Memory Usage: 28 MB
├─ Last Run: 2024-01-15 14:32:00
└─ Status: ✅ Success
```

---

## 8. Searchable Data Dictionary

### Search by Column Name

**Search: "store_code"**
- Found in: raw.pos_transactions_csv, stg.stg_pos_transactions, int.int_pos_daily, mart.fact_sales_pos_daily, mart.dim_store
- Type: Identifier
- Data type: text
- Transformations: Trimmed → Canonical → Canonical → Canonical

**Search: "qty"**
- Found in: raw.pos_transactions_csv (qty_raw), stg.stg_pos_transactions (qty), int.int_pos_daily (units), mart.fact_sales_pos_daily (qty)
- Type: Measure
- Data type: text → numeric → numeric → numeric
- Transformations: Text → Numeric → Sum → Sum

**Search: "gross_sales"**
- Found in: raw.pos_transactions_csv (gross_amount_raw), stg.stg_pos_transactions (gross_amount), int.int_pos_daily (gross_sales), mart.fact_sales_pos_daily (gross_sales)
- Type: Measure
- Data type: text → numeric → numeric → numeric
- Transformations: Text → Numeric → Sum → Sum

---

## 9. Run History

### Model Run History

```
Model: mart.fact_sales_pos_daily
├─ 2024-01-15 14:30:00 ✅ Success (0.45s)
├─ 2024-01-14 09:15:00 ✅ Success (0.47s)
├─ 2024-01-13 16:45:00 ✅ Success (0.43s)
└─ 2024-01-12 11:20:00 ✅ Success (0.44s)

Model: mart.kpi_days_of_supply
├─ 2024-01-15 14:32:00 ✅ Success (0.32s)
├─ 2024-01-14 09:17:00 ✅ Success (0.35s)
├─ 2024-01-13 16:47:00 ✅ Success (0.31s)
└─ 2024-01-12 11:22:00 ✅ Success (0.33s)
```

---

## Summary

This dbt-style lineage graph provides:
1. **Lineage Graph (DAG)**: Visual data flow from source to mart
2. **Column-Level Lineage**: Track specific columns through transformations
3. **Data Catalog**: Model documentation with columns, types, descriptions
4. **Interactive Structure**: Model browser with upstream/downstream dependencies
5. **Test Visualization**: Data quality test results
6. **Performance Metrics**: Query time, memory usage, run history
7. **Searchable Dictionary**: Search by column name across all models

This demonstrates understanding of data lineage concepts and documentation practices, which is valuable for business analyst roles.

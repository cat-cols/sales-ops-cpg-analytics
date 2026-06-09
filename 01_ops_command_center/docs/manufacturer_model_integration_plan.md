# Manufacturer Model Integration Plan for Project 1

## Current State Analysis

**Current Project 1 Model:**
- Retail POS model with stores selling to end consumers
- 2,345 synthetic locations
- POS transactions (stg_pos_transactions.sql)
- Distributor sales (stg_sales_distributor.sql)
- Unified mart views combining both sources

**Current Data Sources:**
- POS transactions (retail end-consumer sales)
- Distributor sales (wholesale to distributors)
- Inventory data
- Labor data
- Finance data

## Althea Manufacturer Model Data

**New Data Sources:**
- B2B orders (wholesaler orders to Althea)
- Distributor shipments (Althea ships to wholesalers)
- Sell-through data (wholesalers sell to retailers)
- Direct-to-retailer data (Althea sells directly to large chains)
- Inventory snapshots (Althea warehouse inventory)

**Business Entities:**
- 258 wholesalers (from Oregon cannabis licenses)
- 795 retailers (from Oregon cannabis licenses)
- 12 Althea SKUs (ALT-PCH-100, ALT-RSP-100, etc.)

## Schema Mapping Plan

### 1. Replace POS Data with Manufacturer B2B Data

**Current POS Schema:**
- txn_id, txn_ts, store_code, sku, qty, unit_price, discount_pct, gross_amount, net_amount

**New Manufacturer B2B Schema:**
- order_date, order_id, wholesaler_license, wholesaler_name, wholesaler_county, sku, sku_name, category, pack_size, unit_price, quantity_packs, total_units, gross_amount, discount_percent, discount_amount, net_amount

**Mapping:**
- order_date → txn_date
- order_id → txn_id
- wholesaler_license → store_code (use wholesaler license as location key)
- sku → sku
- quantity_packs → qty
- unit_price → unit_price
- discount_percent → discount_pct
- gross_amount → gross_amount
- net_amount → net_amount

### 2. Update Distributor Sales Data

**Current Distributor Schema:**
- sale_date, store_id, sku, channel, qty, unit_list_price, discount_rate, unit_net_price, gross_sales, discount_amount, net_sales, cogs, orders, customers

**New Manufacturer Schema:**
- Use sell-through data for distributor sales
- sale_date, wholesaler_license, retailer_license, retailer_name, retailer_county, sku, wholesale_price, retail_price, quantity_packs, gross_amount

**Mapping:**
- sale_date → sale_date
- retailer_license → store_code (use retailer license as location key)
- sku → sku
- quantity_packs → qty
- retail_price → unit_list_price
- gross_amount → gross_sales
- Calculate discount_rate from wholesale_price vs retail_price

### 3. Update Direct-to-Retailer Data

**New Direct Sales Schema:**
- sale_date, order_id, retailer_license, retailer_name, retailer_county, account_type, sku, sku_name, category, pack_size, unit_price, quantity_packs, total_units, gross_amount, discount_percent, discount_amount, net_amount

**Mapping:**
- Use as separate channel "Direct" in the unified sales fact
- retailer_license → store_code
- Similar mapping to B2B orders

### 4. Update Location Dimension

**Current dim_location:**
- 2,345 synthetic locations

**New dim_location:**
- 258 wholesalers (for B2B orders)
- 795 retailers (for sell-through and direct sales)
- Total: 1,053 real business entities from Oregon cannabis licenses

**Fields:**
- location_key (license number)
- location_name (business name)
- location_type (wholesaler/retailer)
- county
- state (OR)
- preferred_channel (based on location type)

### 5. Update Product Dimension

**Current dim_product:**
- Already uses Althea product names
- 15 products with various flavors and potencies

**New dim_product:**
- 12 Althea SKUs from manufacturer data
- Keep existing product catalog structure
- Update to match manufacturer SKU format (ALT-XXX-XXX)

## Implementation Steps

### Phase 1: Data Generation Script Updates

1. **Create new data generation script** that:
   - Loads Althea manufacturer data from `data/reference/althea_manufacturer/`
   - Generates dimension tables (dim_location, dim_product, dim_channel)
   - Generates fact tables using manufacturer data
   - Maintains existing data quality issues (duplicates, missing keys, etc.)

2. **Update staging data structure**:
   - Replace POS transaction extracts with B2B order extracts
   - Update distributor sales extracts with sell-through data
   - Add direct-to-retailer extracts
   - Update inventory extracts with manufacturer inventory snapshots

### Phase 2: SQL View Updates

1. **Update staging views**:
   - stg_pos_transactions → stg_b2b_orders (rename and update schema)
   - stg_sales_distributor → update to use sell-through data
   - Add stg_direct_sales for direct-to-retailer data
   - Update stg_inventory_erp for manufacturer inventory

2. **Update integration views**:
   - int_sales_distributor → use sell-through data
   - int_sales_pos → use B2B order data
   - Add int_sales_direct for direct sales

3. **Update mart views**:
   - mart_fact_sales_daily → include manufacturer channels
   - mart_fact_sales_pos_daily → rename to mart_fact_sales_b2b_daily
   - mart_fact_sales_distributor_daily → use sell-through data
   - Add mart_fact_sales_direct_daily

### Phase 3: Documentation Updates

1. **Update README.md**:
   - Change business scenario from retail POS to manufacturer model
   - Update source systems description
   - Update data flow diagram

2. **Update executive documentation**:
   - executive_walkthrough.md
   - executive_narrative.md
   - metric_dictionary.md

3. **Create new documentation**:
   - manufacturer_model_overview.md
   - data_source_mapping.md

### Phase 4: Testing

1. **Data validation**:
   - Verify row counts match expected
   - Check referential integrity
   - Validate KPI calculations

2. **Pipeline testing**:
   - Run full data generation
   - Run SQL pipeline
   - Run QA checks
   - Verify reconciliation

## Benefits of Manufacturer Model

1. **More realistic for cannabis CPG**: Althea is a manufacturer, not a retailer
2. **Real business entities**: Uses actual Oregon cannabis license data
3. **Better geographic coverage**: All Oregon counties represented
4. **More accurate Tableau mapping**: Real business locations for map visualizations
5. **Authentic business model**: B2B wholesale + direct-to-retailer vs retail POS

## Risks and Considerations

1. **Schema changes**: Significant changes to staging and mart views
2. **Data volume**: Manufacturer data has more records (620K B2B orders vs current synthetic data)
3. **Channel complexity**: Need to handle B2B, distributor, and direct channels properly
4. **Location hierarchy**: Need to map wholesalers vs retailers correctly
5. **Reconciliation logic**: Finance reconciliation may need updates for manufacturer model

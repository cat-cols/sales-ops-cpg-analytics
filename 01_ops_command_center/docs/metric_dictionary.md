# Metrics Dictionary
**Project:** 01_ops_command_center
**Domain:** Sales / Ops / Labor / Finance (Synthetic Business Analyst Portfolio Project)
**Owner:** Brandon Hardison
**Status:** Draft v1 (source-of-truth definitions for modeled and reporting metrics)

---

## Purpose

This document defines the official business meaning and formulas for key metrics used in the Althea Business Analyst project.

It is the **source of truth** for:
- SQL transformations
- Python data generation logic
- QA/QC checks
- Power BI measures and visuals

This helps keep the same metric definitions consistent across the repo (so we don’t accidentally create three different versions of “net sales” and call it alignment).

---

## Metric Grains

Before defining metrics, here are the main grains (levels of detail) in this project:

### `fact_sales` grain
One row per:
- `date_key`
- `product_key` (Althea SKU)
- `location_key` (Oregon business license: wholesaler or retailer)
- `channel_key` (B2B, Direct, or Sell-through)
- `sales_source` (b2b, direct, or sell_through)

This is a **daily product-location-channel sales fact row** from manufacturer model data.

### `fact_inventory` grain
One row per:
- `date_key`
- `product_key` (Althea SKU)
- `location_key` (ALTHEA_WAREHOUSE)

### `fact_labor` grain
One row per:
- `date_key`
- `location_key`
- `employee_group_key`

### Data Sources
- **B2B Orders**: Manufacturer to wholesalers (258 Oregon wholesalers)
- **Direct Sales**: Manufacturer to retailers (795 Oregon retailers)
- **Sell-through**: Wholesalers to retailers (market visibility)
- **Business Entities**: Real Oregon cannabis business licenses

---

## Pricing Logic Notes (Important)

In `generate_fact_sales`, pricing currently includes:
1. Product base list price (`dim_product.base_list_price`)
2. Small random variation (price noise)
3. Channel price factor (Retail / Wholesale / Distributor)
4. Discount rate

### Channel price factors
- Retail = `1.00`
- Wholesale = `0.88`
- Distributor = `0.82`

This means a row’s **effective unit list price** may be lower than the product’s base list price due to channel pricing.

---

## Sales Metrics (`fact_sales`)

### 1) `units_sold`
- **Definition:** Number of units (packs) sold for the row grain (daily x product x location x channel).
- **Type:** Integer
- **Unit:** Count (packs, not individual gummies)
- **Grain:** `fact_sales`
- **Source inputs:** Althea manufacturer data (B2B orders, Direct sales, Sell-through)
- **Formula:** `quantity_packs` from source data
- **Notes:** Measured in packs per manufacturer data model. Foundation for most revenue metrics.
- **Manufacturer context:** Different by channel:
  - B2B: Packs shipped to wholesalers
  - Direct: Packs shipped to retailers
  - Sell-through: Packs sold by wholesalers to retailers

---

### 2) `unit_list_price`
- **Definition:** Pre-discount selling price per pack for the row.
- **Type:** Decimal
- **Unit:** USD per pack
- **Grain:** `fact_sales`
- **Source inputs:** Althea SKU catalog, channel-specific pricing
- **Formula (row-level):**
  - B2B: `unit_price` from manufacturer data
  - Direct: `unit_price` from manufacturer data
  - Sell-through: `retail_price` (wholesale markup applied)
- **Notes:**
  - Represents the list price before any discounts
  - Varies by channel due to manufacturer vs retail pricing

---

### 3) `discount_rate` *(recommended new column)*
- **Definition:** Discount applied to the row’s effective unit list price.
- **Type:** Decimal
- **Unit:** Proportion (0 to 1)
- **Grain:** `fact_sales`
- **Source inputs:** discount generation logic
- **Formula (row-level):**
  - Generated from normal distribution and clipped:
  - `discount_rate = clip(normal(0.08 + promo_discount_extra, 0.035), 0, 0.35)`
- **Notes:**
  - Promo periods increase average discount.
  - Store as decimal (e.g., `0.12`), not percent string.

---

### 4) `unit_net_price` *(recommended new column)*
- **Definition:** Effective price per unit after discount.
- **Type:** Decimal
- **Unit:** USD per unit
- **Grain:** `fact_sales`
- **Source inputs:** `unit_list_price`, `discount_rate`
- **Formula (row-level):**
  - `unit_net_price = unit_list_price * (1 - discount_rate)`
- **Notes:**
  - This is the cleanest “unit economics” metric for downstream analysis.

---

### 5) `gross_sales_amount`
- **Definition:** Total sales before discount for the row.
- **Type:** Decimal
- **Unit:** USD
- **Grain:** `fact_sales`
- **Source inputs:** `units_sold`, `unit_list_price`
- **Formula (row-level):**
  - `gross_sales_amount = quantity_packs * unit_list_price`
- **Manufacturer context:**
  - B2B/Direct: Manufacturer gross revenue
  - Sell-through: Retail gross revenue (wholesale perspective)

---

### 6) `discount_amount`
- **Definition:** Total discount dollars applied to the row.
- **Type:** Decimal
- **Unit:** USD
- **Grain:** `fact_sales`
- **Source inputs:** `gross_sales_amount`, `net_sales_amount`
- **Formula (row-level):**
  - `discount_amount = gross_sales_amount - net_sales_amount`
- **Manufacturer context:**
  - B2B/Direct: Manufacturer discount dollars
  - Sell-through: Wholesale-to-retailer markup dollars
- **Notes:**
  - Must be `>= 0`
  - QA rule: `discount_amount <= gross_sales_amount`

---

### 7) `net_sales_amount`
- **Definition:** Total sales after discount for the row.
- **Type:** Decimal
- **Unit:** USD
- **Grain:** `fact_sales`
- **Source inputs:** `units_sold`, `unit_net_price`
- **Formula (row-level):**
  - B2B/Direct: `quantity_packs * unit_price * (1 - discount_percent)`
  - Sell-through: `quantity_packs * wholesale_price`
- **Equivalent formula:**
  - `net_sales_amount = gross_sales_amount * (1 - discount_rate)`
- **Manufacturer context:**
  - B2B/Direct: Manufacturer net revenue (recognized revenue)
  - Sell-through: Wholesale revenue (not manufacturer revenue)
- **Notes:**
  - This is the primary revenue metric for most reporting
  - For manufacturer total revenue, sum only B2B + Direct channels

---

### 8) `cogs_amount`
- **Definition:** Cost of goods sold associated with the row’s net sales.
- **Type:** Decimal
- **Unit:** USD
- **Grain:** `fact_sales`
- **Source inputs:** `net_sales_amount`, product COGS ratio, COGS noise
- **Formula (row-level):**
  - `cogs_ratio_effective = clip(base_cogs_ratio + noise, 0.25, 0.75)`
  - `cogs_amount = net_sales_amount * cogs_ratio_effective`
- **Notes:**
  - COGS is modeled off **net sales**, not gross sales.

---

### 9) `order_count`
- **Definition:** Number of orders represented by the row.
- **Type:** Integer
- **Unit:** Count
- **Grain:** `fact_sales`
- **Source inputs:** B2B/Direct order data
- **Formula (row-level):**
  - B2B/Direct: Count of distinct `order_id` from manufacturer data
  - Sell-through: Set to 1 (transaction-level data)
- **Manufacturer context:**
  - B2B/Direct: Actual purchase orders from wholesalers/retailers
  - Sell-through: Individual retail transactions (no order grouping)
- **Notes:**
  - For manufacturer KPIs, use B2B + Direct channels only

---

### 10) `customer_count`
- **Definition:** Number of business entity customers represented by the row.
- **Type:** Integer
- **Unit:** Count
- **Grain:** `fact_sales`
- **Source inputs:** Business entity licenses
- **Formula (row-level):**
  - B2B/Direct: Count of distinct business licenses (wholesalers/retailers)
  - Sell-through: Count of distinct retailer licenses
- **Manufacturer context:**
  - B2B: Wholesaler count (B2B customers)
  - Direct: Retailer count (direct customers)
  - Sell-through: Retailer count (end-market visibility)
- **Notes:**
  - Business-to-business customers, not end consumers
  - Based on Oregon cannabis business licenses

---

## Suggested Derived Sales KPIs (Reporting Layer)

These can be calculated in SQL or Tableau (not necessarily stored in `fact_sales`).

### Manufacturer-Specific KPIs

### Total Manufacturer Revenue
- **Definition:** Combined B2B + Direct revenue (excludes sell-through)
- **Formula:**
  - `SUM(net_sales_amount) WHERE sales_source IN ('b2b', 'direct')`

### B2B Sales
- **Definition:** Manufacturer to wholesaler sales
- **Formula:**
  - `SUM(net_sales_amount) WHERE sales_source = 'b2b'`

### Direct Sales
- **Definition:** Manufacturer to retailer sales
- **Formula:**
  - `SUM(net_sales_amount) WHERE sales_source = 'direct'`

### Sell-through
- **Definition:** Wholesaler to retailer sales (market intelligence)
- **Formula:**
  - `SUM(net_sales_amount) WHERE sales_source = 'sell_through'`

### Distribution Coverage
- **Definition:** Percentage of business entities with active sales
- **Formula:**
  - `COUNT(DISTINCT location_key) / total_locations * 100`

### Channel Mix
- **Definition:** Revenue contribution by channel
- **Formula:**
  - `SUM(net_sales_amount) BY sales_source / total_manufacturer_revenue`

### Standard KPIs

### Average Selling Price (ASP)
- **Definition:** Average net revenue per pack
- **Formula:**
  - `ASP = SUM(net_sales_amount) / NULLIF(SUM(units_sold), 0)`

### Average Discount Rate (weighted)
- **Definition:** Weighted discount rate based on gross sales
- **Formula:**
  - `weighted_discount_rate = SUM(discount_amount) / NULLIF(SUM(gross_sales_amount), 0)`

### Gross Margin Dollars
- **Definition:** Net sales minus COGS
- **Formula:**
  - `gross_margin_amount = SUM(net_sales_amount) - SUM(cogs_amount)`

### Gross Margin %
- **Definition:** Gross margin as a % of net sales
- **Formula:**
  - `gross_margin_pct = (SUM(net_sales_amount) - SUM(cogs_amount)) / NULLIF(SUM(net_sales_amount), 0)`

### Revenue per Order
- **Formula:**
  - `SUM(net_sales_amount) / NULLIF(SUM(order_count), 0)`

### Units per Order
- **Formula:**
  - `SUM(units_sold) / NULLIF(SUM(order_count), 0)`

---

## Inventory Metrics (`fact_inventory`)

### `on_hand_units`
- **Definition:** Ending on-hand inventory packs at Althea warehouse.
- **Unit:** Count (packs)
- **Formula basis:** Manufacturer inventory simulation
- **Manufacturer context:** Single warehouse location (ALTHEA_WAREHOUSE)

### `received_units`
- **Definition:** Units produced/received into inventory on the day.
- **Unit:** Count (packs)
- **Manufacturer context:** Production output at manufacturer facility

### `shipped_units`
- **Definition:** Units shipped out on the day (B2B + Direct).
- **Unit:** Count (packs)
- **Manufacturer context:** Total manufacturer shipments to customers

### Suggested derived inventory KPIs
- **Days of Supply**
  - `on_hand_units / avg_daily_shipment_rate`
- **Production Efficiency**
  - `received_units / production_capacity`
- **Inventory Turnover**
  - `SUM(shipped_units) / AVG(on_hand_units)`

---

## Labor Metrics (`fact_labor`)

### `labor_hours`
- **Definition:** Total regular labor hours worked.
- **Unit:** Hours

### `overtime_hours`
- **Definition:** Overtime hours worked.
- **Unit:** Hours

### `headcount`
- **Definition:** Active headcount for employee group at location/date.
- **Unit:** Count

### `hires`
- **Definition:** Hire events recorded for the row.
- **Unit:** Count (0/1)

### `terminations`
- **Definition:** Termination events recorded for the row.
- **Unit:** Count (0/1)

### `labor_cost_amount`
- **Definition:** Total labor cost (regular + overtime premium).
- **Unit:** USD
- **Formula basis:** `labor_hours * rate + overtime_hours * rate * 0.5`

### Suggested derived labor KPIs
- **Avg Hourly Labor Cost**
  - `SUM(labor_cost_amount) / NULLIF(SUM(labor_hours + overtime_hours), 0)`
- **Overtime Rate**
  - `SUM(overtime_hours) / NULLIF(SUM(labor_hours + overtime_hours), 0)`
- **Labor Cost % of Net Sales**
  - `SUM(labor_cost_amount) / NULLIF(SUM(net_sales_amount), 0)`
  *(join via date/location at reporting layer)*

---

## Finance Summary Metrics (`finance_actuals_summary.xlsx`)

These are monthly finance extract values (with intentional label variation/noise for QA/QC demo work).

### `Gross Sales`
- Monthly gross sales total (USD)

### `Net Sales`
- Monthly net sales total (USD)

### `COGS`
- Monthly cost of goods sold (USD)

### `Gross Margin`
- **Formula:**
  - `Gross Margin = Net Sales - COGS`

### `Labor Cost`
- Monthly labor cost total (USD)

---

## Recommended QA Rules (Metric Integrity Checks)

Use these in SQL validation or Python QA scripts:

### Sales QA
- `units_sold >= 1`
- `unit_list_price > 0`
- `0 <= discount_rate <= 0.50` (expanded for sell-through markup)
- `unit_net_price <= unit_list_price`
- `gross_sales_amount = units_sold * unit_list_price` (within rounding tolerance)
- `net_sales_amount = units_sold * unit_net_price` (within rounding tolerance)
- `discount_amount = gross_sales_amount - net_sales_amount` (within rounding tolerance)
- `cogs_amount <= net_sales_amount`
- `discount_amount >= 0`
- **Manufacturer-specific:**
  - B2B/Direct channels: `discount_rate <= 0.20`
  - Sell-through channel: `discount_rate >= 0.15` (wholesale markup)

### Inventory QA
- `on_hand_units >= 0`
- `received_units >= 0`
- `shipped_units >= 0`
- `on_hand_units = previous_on_hand + received_units - shipped_units` (inventory balance)

### Labor QA
- `labor_hours >= 0`
- `overtime_hours >= 0`
- `headcount >= 1`
- `labor_cost_amount >= 0`

---

## Implementation Guidance

### Where logic should live
- **Row-level generation logic:** Python (`scripts/generate_project1_manufacturer_data.py`)
- **Standardized metric definitions:** This file (`metric_dictionary.md`) + YAML (`metric_dictionary.yml`)
- **Aggregated/reporting logic:** SQL mart views / Tableau calculations
- **Validation logic:** SQL QA scripts or Python QA checks

### Data sources
- **Manufacturer data:** `data/reference/althea_manufacturer/`
- **Business entities:** Oregon cannabis business licenses (258 wholesalers, 795 retailers)
- **Product catalog:** 12 Althea SKUs with manufacturer pricing

### Naming conventions
Use clear suffixes:
- `_amount` for currency totals (USD)
- `_price` for per-unit prices (per pack)
- `_rate` for proportions (0–1)
- `_count` for counts
- `_pct` for presentation ratios (optional, often reporting-only)

---

## Change Log

### v2.0 (Manufacturer Model Update)
- Updated all metrics for manufacturer model (B2B + Direct + Sell-through)
- Replaced retail POS model with manufacturer business model
- Added manufacturer-specific metrics (B2B sales, Direct sales, Sell-through)
- Updated pricing logic for manufacturer vs wholesale vs retail channels
- Added Oregon business license context (1,053 real business entities)
- Updated grain definitions for manufacturer data structure
- Added manufacturer-specific QA rules
- Created companion YAML file for machine-readable definitions

### v1 (Draft)
- Established canonical definitions for retail POS model
- Added inventory and labor metric definitions
- Added QA rule suggestions

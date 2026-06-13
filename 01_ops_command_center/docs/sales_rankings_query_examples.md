# Sales Rankings Query Examples

**View:** `mart.vw_sales_rankings`  
**Purpose:** SKU-level and location-level sales performance with multiple time granularities (daily/weekly/monthly/annual) and case-level metrics  
**Use Case:** Purchasing behavior analysis and inventory preparation for future events

---

## Data Levels

The view provides 8 data levels:
- **DAILY_LOCATION:** Location aggregates by day
- **WEEKLY_LOCATION:** Location aggregates by week  
- **MONTHLY_LOCATION:** Location aggregates by month
- **ANNUAL_LOCATION:** Location aggregates by year
- **DAILY_SKU:** SKU-level data by day
- **WEEKLY_SKU:** SKU-level data by week
- **MONTHLY_SKU:** SKU-level data by month
- **ANNUAL_SKU:** SKU-level data by year

---

## Daily Case Purchases by SKU

**Use Case:** Analyze daily purchasing patterns for inventory planning

```sql
SELECT 
    location_name,
    sale_date,
    sku,
    product_name,
    adjusted_cases_sold AS daily_cases,
    adjusted_sku_units AS daily_units,
    adjusted_sku_sales AS daily_sales,
    location_sku_rank
FROM mart.vw_sales_rankings
WHERE data_level = 'DAILY_SKU'
  AND product_name ILIKE '%gummy%'
ORDER BY sale_date DESC, adjusted_cases_sold DESC;
```

---

## Weekly Case Purchases for Inventory Planning

**Use Case:** Weekly purchasing trends for inventory preparation

```sql
SELECT 
    location_name,
    sale_week,
    sku,
    product_name,
    adjusted_cases_sold AS weekly_cases,
    adjusted_sku_units AS weekly_units,
    adjusted_sku_sales AS weekly_sales,
    location_sku_rank
FROM mart.vw_sales_rankings
WHERE data_level = 'WEEKLY_SKU'
  AND sale_week >= '2024-01-01'
ORDER BY location_name, sale_week, weekly_cases DESC;
```

---

## Monthly Case Trends for Seasonal Planning

**Use Case:** Monthly seasonal patterns for inventory strategy

```sql
SELECT 
    location_name,
    sale_month,
    sku,
    product_name,
    adjusted_cases_sold AS monthly_cases,
    adjusted_sku_units AS monthly_units,
    adjusted_sku_sales AS monthly_sales,
    location_sku_rank,
    county_sku_rank
FROM mart.vw_sales_rankings
WHERE data_level = 'MONTHLY_SKU'
ORDER BY location_name, sale_month, monthly_cases DESC;
```

---

## Annual Case Totals for Long-term Strategy

**Use Case:** Yearly totals for long-term inventory planning

```sql
SELECT 
    location_name,
    sku,
    product_name,
    sale_year,
    adjusted_cases_sold AS annual_cases,
    annual_sku_units AS annual_units,
    annual_sku_sales AS annual_sales,
    annual_location_sku_rank,
    annual_county_sku_rank
FROM mart.vw_sales_rankings
WHERE data_level = 'ANNUAL_SKU'
ORDER BY location_name, annual_cases DESC;
```

---

## Specific Dispensary Annual Case Purchases

**Use Case:** How many cases of each SKU a specific dispensary purchased over a year

```sql
SELECT 
    location_name,
    sku,
    product_name,
    sale_year,
    adjusted_cases_sold AS annual_cases_purchased,
    annual_sku_sales AS annual_sales_amount,
    pack_size,
    annual_location_sku_rank
FROM mart.vw_sales_rankings
WHERE data_level = 'ANNUAL_SKU'
  AND location_name = 'Your Dispensary Name'
  AND product_name ILIKE '%gummy%'
ORDER BY annual_cases_purchased DESC;
```

---

## All Dispensaries Annual Case Purchases

**Use Case:** How many cases of each SKU every dispensary purchased over a year

```sql
SELECT 
    location_name,
    sku,
    product_name,
    sale_year,
    adjusted_cases_sold AS annual_cases_purchased,
    annual_sku_sales AS annual_sales_amount,
    annual_location_sku_rank
FROM mart.vw_sales_rankings
WHERE data_level = 'ANNUAL_SKU'
  AND product_name ILIKE '%gummy%'
ORDER BY location_name, annual_cases_purchased DESC;
```

---

## Location-Level Daily Performance

**Use Case:** Daily location performance metrics

```sql
SELECT 
    location_name,
    sale_date,
    total_cases AS daily_cases,
    total_units AS daily_units,
    total_sales AS daily_sales,
    gross_profit,
    gross_margin_pct,
    unique_skus_sold,
    county_rank,
    state_rank,
    performance_tier
FROM mart.vw_sales_rankings
WHERE data_level = 'DAILY_LOCATION'
ORDER BY sale_date DESC, total_sales DESC;
```

---

## Location-Level Monthly Performance

**Use Case:** Monthly location performance for ranking analysis

```sql
SELECT 
    location_name,
    sale_month,
    total_cases AS monthly_cases,
    total_sales AS monthly_sales,
    gross_profit,
    gross_margin_pct,
    unique_skus_sold,
    county_rank,
    state_rank,
    sales_decile,
    performance_tier,
    county_position
FROM mart.vw_sales_rankings
WHERE data_level = 'MONTHLY_LOCATION'
ORDER BY sale_month DESC, total_sales DESC;
```

---

## Top SKUs by Location (Monthly)

**Use Case:** Identify best-selling SKUs per location

```sql
SELECT 
    location_name,
    sale_month,
    sku,
    product_name,
    adjusted_cases_sold AS monthly_cases,
    adjusted_sku_sales AS monthly_sales,
    location_sku_rank,
    total_skus_location
FROM mart.vw_sales_rankings
WHERE data_level = 'MONTHLY_SKU'
  AND location_sku_rank <= 10
ORDER BY location_name, sale_month, location_sku_rank;
```

---

## Seasonal Pattern Analysis

**Use Case:** Analyze seasonal purchasing patterns for inventory planning

```sql
SELECT 
    EXTRACT(MONTH FROM sale_month) AS month_num,
    TO_CHAR(sale_month, 'Mon') AS month_name,
    sku,
    product_name,
    AVG(adjusted_cases_sold) AS avg_monthly_cases,
    AVG(adjusted_sku_sales) AS avg_monthly_sales,
    COUNT(DISTINCT location_name) AS num_locations
FROM mart.vw_sales_rankings
WHERE data_level = 'MONTHLY_SKU'
  AND product_name ILIKE '%gummy%'
GROUP BY EXTRACT(MONTH FROM sale_month), TO_CHAR(sale_month, 'Mon'), sku, product_name
ORDER BY month_num, avg_monthly_cases DESC;
```

---

## Week-over-Week Growth Analysis

**Use Case:** Track weekly growth trends for inventory planning

```sql
WITH weekly_data AS (
    SELECT 
        location_name,
        sku,
        product_name,
        sale_week,
        adjusted_cases_sold AS weekly_cases,
        LAG(adjusted_cases_sold) OVER (PARTITION BY location_name, sku ORDER BY sale_week) AS prev_week_cases
    FROM mart.vw_sales_rankings
    WHERE data_level = 'WEEKLY_SKU'
)
SELECT 
    location_name,
    sku,
    product_name,
    sale_week,
    weekly_cases,
    prev_week_cases,
    ROUND(((weekly_cases - prev_week_cases) / NULLIF(prev_week_cases, 0) * 100)::numeric, 2) AS wow_growth_pct
FROM weekly_data
WHERE prev_week_cases IS NOT NULL
ORDER BY location_name, sku, sale_week DESC;
```

---

## Inventory Preparation for Events

**Use Case:** Prepare inventory based on historical purchasing patterns before events

```sql
-- Example: Prepare inventory for 4th of July (July 1-7)
WITH event_period AS (
    SELECT 
        location_name,
        sku,
        product_name,
        AVG(adjusted_cases_sold) AS avg_daily_cases_during_event,
        STDDEV(adjusted_cases_sold) AS stddev_cases
    FROM mart.vw_sales_rankings
    WHERE data_level = 'DAILY_SKU'
      AND EXTRACT(MONTH FROM sale_date) = 7
      AND EXTRACT(DAY FROM sale_date) BETWEEN 1 AND 7
    GROUP BY location_name, sku, product_name
)
SELECT 
    location_name,
    sku,
    product_name,
    avg_daily_cases_during_event,
    stddev_cases,
    ROUND(avg_daily_cases_during_event + (stddev_cases * 1.5), 2) AS recommended_inventory_cases
FROM event_period
ORDER BY location_name, avg_daily_cases_during_event DESC;
```

---

## Key Fields Reference

**Time Granularity Fields:**
- `sale_date`: Date of sales (NULL for weekly/monthly/annual)
- `sale_week`: Week of sales (NULL for daily/monthly/annual)
- `sale_month`: Month of sales (NULL for daily/weekly/annual)
- `sale_year`: Year of sales

**SKU-Level Fields:**
- `sku`: SKU identifier
- `product_name`: Product name
- `pack_size`: Pack size (units per case)
- `adjusted_sku_units`: SKU units sold with variation applied
- `adjusted_sku_sales`: SKU net sales with variation applied
- `adjusted_cases_sold`: SKU cases sold (units/pack_size) with variation applied
- `location_sku_rank`: SKU rank within location/time period (1 = best)
- `county_sku_rank`: SKU rank within county/time period (1 = best)
- `total_skus_location`: Total SKUs per location for context

**Location-Level Fields:**
- `total_units`: Total units sold
- `total_sales`: Total net sales
- `total_cases`: Total cases sold
- `gross_profit`: Gross profit amount
- `gross_margin_pct`: Gross margin percentage
- `unique_skus_sold`: Number of unique SKUs sold
- `county_rank`: Rank within county (1 = best)
- `state_rank`: Rank within state (1 = best)
- `sales_decile`: Sales decile (1-10)
- `performance_tier`: Performance categorization (Top/Bottom/Average Performer)
- `county_position`: County position (County Leader/Top 3/Mid-Lower)

**Data Level Field:**
- `data_level`: Data granularity identifier (DAILY_LOCATION, WEEKLY_LOCATION, MONTHLY_LOCATION, ANNUAL_LOCATION, DAILY_SKU, WEEKLY_SKU, MONTHLY_SKU, ANNUAL_SKU)

---

## Notes

- **Case Calculation:** Cases = Units ÷ Pack Size (defaults to 12 units/case if pack_size is NULL)
- **Variation Patterns:** 
  - Daily: Day-of-week patterns (weekends +20%, Mon/Tue -10%) with ±15% random variation
  - Weekly: Less volatile variation (±5%)
  - Monthly: Seasonal patterns (summer +15%, holidays +25%, post-holiday -15%) with ±10% variation
  - Annual: Aggregated from monthly data
- **Rankings:** Rankings are calculated within each time period and geography (location/county/state)

---

## Production Implementation Patterns

In a real production setting, these queries would be used through several implementation patterns:

### Automated Dashboards (Tableau/Power BI)
- Connect directly to `mart.vw_sales_rankings` as a data source
- Create filters for `data_level` to switch between daily/weekly/monthly/annual views
- Use parameters for location selection, product categories, date ranges
- Set up automatic refresh schedules (daily for operational, weekly for tactical)

### Scheduled Reports
- Daily inventory alerts: Query `DAILY_SKU` for low-stock warnings
- Weekly purchasing summaries: Query `WEEKLY_SKU` for procurement teams
- Monthly performance reviews: Query `MONTHLY_LOCATION` for management meetings
- Annual strategic planning: Query `ANNUAL_SKU` for budget cycles

### Inventory Planning Systems
- Event preparation queries run 2-4 weeks before holidays/events
- Seasonal pattern analysis informs quarterly inventory allocation
- Week-over-week growth triggers automatic reorder points
- Case calculations directly feed into purchase order generation

### Operational Workflows
- Store managers use daily SKU rankings for shelf space allocation
- Regional managers use weekly location rankings for resource deployment
- Buyers use monthly seasonal patterns for supplier negotiations
- Finance uses annual aggregates for forecasting and budgeting

### Data Integration
- API endpoints expose filtered query results for mobile apps
- ETL jobs materialize frequently-used query patterns as tables
- Real-time alerts trigger on threshold breaches (stockouts, margin erosion)

### Key Production Considerations
- Query performance: The view is pre-calculated for Tableau optimization
- Data freshness: Daily loads for operational, weekly for tactical use
- Security: Row-level security by region/territory
- Monitoring: Track query performance and data quality over time

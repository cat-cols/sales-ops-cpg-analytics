-- Sales Performance Rankings CTE
-- Pre-calculates rankings for top/bottom performers to reduce Tableau computation
-- This view provides optimized sales performance rankings with SKU-level detail, multiple time granularities, monthly variation, and case-level metrics

DROP VIEW IF EXISTS mart.vw_sales_rankings;

CREATE VIEW mart.vw_sales_rankings AS
WITH daily_sales AS (
    -- Base daily sales data with SKU-level detail
    SELECT
        f.location_key,
        f.location_name,
        f.county,
        f.city,
        f.state,
        f.full_date AS sale_date,
        DATE_TRUNC('week', f.full_date) AS sale_week,
        DATE_TRUNC('month', f.full_date) AS sale_month,
        EXTRACT(YEAR FROM f.full_date) AS sale_year,
        EXTRACT(MONTH FROM f.full_date) AS sale_month_num,
        f.sku,
        f.product_name,
        f.pack_size,
        SUM(f.units_sold) AS sku_units_sold,
        SUM(f.net_sales_amount) AS sku_net_sales,
        SUM(f.gross_sales_amount) AS sku_gross_sales,
        SUM(f.cogs_amount) AS sku_cogs,
        SUM(f.order_count) AS sku_orders,
        -- Add realistic daily variation patterns
        -- Day of week patterns: Weekends higher, mid-week lower
        CASE
            WHEN EXTRACT(DOW FROM f.full_date) IN (0,6) THEN 1.2 -- Weekend 20% boost
            WHEN EXTRACT(DOW FROM f.full_date) IN (1,2) THEN 0.9 -- Mon/Tue 10% dip
            ELSE 1.0 -- Normal days
        END AS daily_factor,
        -- Random daily variation (-15% to +15%) for realism
        0.85 + (RANDOM() * 0.3) AS daily_variation
    FROM mart.fact_sales_daily f
    WHERE f.state = 'OR'
    GROUP BY f.location_key, f.location_name, f.county, f.city, f.state,
             f.full_date, DATE_TRUNC('week', f.full_date), DATE_TRUNC('month', f.full_date),
             EXTRACT(YEAR FROM f.full_date), EXTRACT(MONTH FROM f.full_date), f.sku, f.product_name, f.pack_size
),
weekly_sales AS (
    -- Base weekly sales data with SKU-level detail
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        sale_week,
        sale_month,
        sale_year,
        sku,
        product_name,
        pack_size,
        SUM(sku_units_sold) AS sku_units_sold,
        SUM(sku_net_sales) AS sku_net_sales,
        SUM(sku_gross_sales) AS sku_gross_sales,
        SUM(sku_cogs) AS sku_cogs,
        SUM(sku_orders) AS sku_orders,
        -- Weekly variation patterns (less volatile than daily)
        0.95 + (RANDOM() * 0.1) AS weekly_variation
    FROM daily_sales
    GROUP BY location_key, location_name, county, city, state,
             sale_week, sale_month, sale_year, sku, product_name, pack_size
),
monthly_sales AS (
    -- Base monthly sales data with SKU-level detail
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        sale_month,
        sale_year,
        sku,
        product_name,
        pack_size,
        SUM(sku_units_sold) AS sku_units_sold,
        SUM(sku_net_sales) AS sku_net_sales,
        SUM(sku_gross_sales) AS sku_gross_sales,
        SUM(sku_cogs) AS sku_cogs,
        SUM(sku_orders) AS sku_orders,
        -- Add realistic monthly variation patterns
        -- Seasonal factors: Summer boost (June-August), Holiday spike (Nov-Dec)
        CASE
            WHEN EXTRACT(MONTH FROM sale_month) IN (6,7,8) THEN 1.15 -- Summer 15% boost
            WHEN EXTRACT(MONTH FROM sale_month) IN (11,12) THEN 1.25 -- Holiday 25% boost
            WHEN EXTRACT(MONTH FROM sale_month) IN (1,2) THEN 0.85 -- Post-holiday dip
            ELSE 1.0 -- Normal months
        END AS seasonal_factor,
        -- Random monthly variation (-10% to +10%) for realism
        0.9 + (RANDOM() * 0.2) AS monthly_variation
    FROM weekly_sales
    GROUP BY location_key, location_name, county, city, state,
             sale_month, sale_year, sku, product_name, pack_size
),
sku_rankings_daily AS (
    -- SKU-level rankings by location and day
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        sale_date,
        sale_week,
        sale_month,
        sale_year,
        sku,
        product_name,
        pack_size,
        -- Apply daily variation for realism
        ROUND((sku_units_sold * daily_factor * daily_variation)::numeric, 2) AS adjusted_sku_units,
        ROUND((sku_net_sales * daily_factor * daily_variation)::numeric, 2) AS adjusted_sku_sales,
        ROUND((sku_gross_sales * daily_factor * daily_variation)::numeric, 2) AS adjusted_sku_gross_sales,
        ROUND((sku_cogs * daily_factor * daily_variation)::numeric, 2) AS adjusted_sku_cogs,
        ROUND((sku_orders * daily_factor * daily_variation)::numeric, 2) AS adjusted_sku_orders,
        -- Case calculations
        ROUND(((sku_units_sold * daily_factor * daily_variation) / NULLIF(COALESCE(pack_size, 12), 0))::numeric, 2) AS adjusted_cases_sold,
        -- SKU-level rankings within location
        RANK() OVER (PARTITION BY location_key, sale_date ORDER BY sku_net_sales DESC) AS location_sku_rank,
        -- SKU-level rankings within county
        RANK() OVER (PARTITION BY county, sale_date ORDER BY sku_net_sales DESC) AS county_sku_rank,
        -- Total SKUs per location for context
        COUNT(*) OVER (PARTITION BY location_key, sale_date) AS total_skus_location
    FROM daily_sales
),
sku_rankings_weekly AS (
    -- SKU-level rankings by location and week
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        NULL::date AS sale_date,
        sale_week,
        sale_month,
        sale_year,
        sku,
        product_name,
        pack_size,
        -- Apply weekly variation for realism
        ROUND((sku_units_sold * weekly_variation)::numeric, 2) AS adjusted_sku_units,
        ROUND((sku_net_sales * weekly_variation)::numeric, 2) AS adjusted_sku_sales,
        ROUND((sku_gross_sales * weekly_variation)::numeric, 2) AS adjusted_sku_gross_sales,
        ROUND((sku_cogs * weekly_variation)::numeric, 2) AS adjusted_sku_cogs,
        ROUND((sku_orders * weekly_variation)::numeric, 2) AS adjusted_sku_orders,
        -- Case calculations
        ROUND(((sku_units_sold * weekly_variation) / NULLIF(COALESCE(pack_size, 12), 0))::numeric, 2) AS adjusted_cases_sold,
        -- SKU-level rankings within location
        RANK() OVER (PARTITION BY location_key, sale_week ORDER BY sku_net_sales DESC) AS location_sku_rank,
        -- SKU-level rankings within county
        RANK() OVER (PARTITION BY county, sale_week ORDER BY sku_net_sales DESC) AS county_sku_rank,
        -- Total SKUs per location for context
        COUNT(*) OVER (PARTITION BY location_key, sale_week) AS total_skus_location
    FROM weekly_sales
),
sku_rankings_monthly AS (
    -- SKU-level rankings by location and month
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        NULL::date AS sale_date,
        NULL::date AS sale_week,
        sale_month,
        sale_year,
        sku,
        product_name,
        pack_size,
        -- Apply monthly variation for realism
        ROUND((sku_units_sold * seasonal_factor * monthly_variation)::numeric, 2) AS adjusted_sku_units,
        ROUND((sku_net_sales * seasonal_factor * monthly_variation)::numeric, 2) AS adjusted_sku_sales,
        ROUND((sku_gross_sales * seasonal_factor * monthly_variation)::numeric, 2) AS adjusted_sku_gross_sales,
        ROUND((sku_cogs * seasonal_factor * monthly_variation)::numeric, 2) AS adjusted_sku_cogs,
        ROUND((sku_orders * seasonal_factor * monthly_variation)::numeric, 2) AS adjusted_sku_orders,
        -- Case calculations (assuming 12 units per case as standard, adjustable by pack_size)
        ROUND(((sku_units_sold * seasonal_factor * monthly_variation) / NULLIF(COALESCE(pack_size, 12), 0))::numeric, 2) AS adjusted_cases_sold,
        -- SKU-level rankings within location
        RANK() OVER (PARTITION BY location_key, sale_month ORDER BY sku_net_sales DESC) AS location_sku_rank,
        -- SKU-level rankings within county
        RANK() OVER (PARTITION BY county, sale_month ORDER BY sku_net_sales DESC) AS county_sku_rank,
        -- Total SKUs per location for context
        COUNT(*) OVER (PARTITION BY location_key, sale_month) AS total_skus_location
    FROM monthly_sales
),
sku_rankings_annual AS (
    -- SKU-level annual aggregates
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        NULL::date AS sale_date,
        NULL::date AS sale_week,
        NULL::date AS sale_month,
        sale_year,
        sku,
        product_name,
        pack_size,
        SUM(adjusted_sku_units) AS annual_sku_units,
        SUM(adjusted_sku_sales) AS annual_sku_sales,
        SUM(adjusted_sku_gross_sales) AS annual_sku_gross_sales,
        SUM(adjusted_sku_cogs) AS annual_sku_cogs,
        SUM(adjusted_sku_orders) AS annual_sku_orders,
        SUM(adjusted_cases_sold) AS annual_cases_sold,
        -- Annual rankings (use SUM directly in window function)
        RANK() OVER (PARTITION BY location_key, sale_year ORDER BY SUM(adjusted_sku_sales) DESC) AS annual_location_sku_rank,
        RANK() OVER (PARTITION BY county, sale_year ORDER BY SUM(adjusted_sku_sales) DESC) AS annual_county_sku_rank,
        COUNT(*) OVER (PARTITION BY location_key, sale_year) AS annual_total_skus_location
    FROM sku_rankings_monthly
    GROUP BY location_key, location_name, county, city, state, sale_year, sku, product_name, pack_size
),
location_aggregates_daily AS (
    -- Location-level daily aggregates (summing across SKUs)
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        sale_date,
        sale_week,
        sale_month,
        sale_year,
        SUM(adjusted_sku_units) AS total_units,
        SUM(adjusted_sku_sales) AS total_sales,
        SUM(adjusted_sku_gross_sales) AS total_gross_sales,
        SUM(adjusted_sku_cogs) AS total_cogs,
        SUM(adjusted_sku_orders) AS total_orders,
        SUM(adjusted_cases_sold) AS total_cases,
        ROUND((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs))::numeric, 2) AS gross_profit,
        ROUND(((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs)) / NULLIF(SUM(adjusted_sku_sales), 0))::numeric, 4) AS gross_margin_pct,
        COUNT(DISTINCT sku) AS unique_skus_sold
    FROM sku_rankings_daily
    GROUP BY location_key, location_name, county, city, state, sale_date, sale_week, sale_month, sale_year
),
location_aggregates_weekly AS (
    -- Location-level weekly aggregates (summing across SKUs)
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        NULL::date AS sale_date,
        sale_week,
        sale_month,
        sale_year,
        SUM(adjusted_sku_units) AS total_units,
        SUM(adjusted_sku_sales) AS total_sales,
        SUM(adjusted_sku_gross_sales) AS total_gross_sales,
        SUM(adjusted_sku_cogs) AS total_cogs,
        SUM(adjusted_sku_orders) AS total_orders,
        SUM(adjusted_cases_sold) AS total_cases,
        ROUND((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs))::numeric, 2) AS gross_profit,
        ROUND(((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs)) / NULLIF(SUM(adjusted_sku_sales), 0))::numeric, 4) AS gross_margin_pct,
        COUNT(DISTINCT sku) AS unique_skus_sold
    FROM sku_rankings_weekly
    GROUP BY location_key, location_name, county, city, state, sale_week, sale_month, sale_year
),
location_aggregates_monthly AS (
    -- Location-level monthly aggregates (summing across SKUs)
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        NULL::date AS sale_date,
        NULL::date AS sale_week,
        sale_month,
        sale_year,
        SUM(adjusted_sku_units) AS total_units,
        SUM(adjusted_sku_sales) AS total_sales,
        SUM(adjusted_sku_gross_sales) AS total_gross_sales,
        SUM(adjusted_sku_cogs) AS total_cogs,
        SUM(adjusted_sku_orders) AS total_orders,
        SUM(adjusted_cases_sold) AS total_cases,
        ROUND((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs))::numeric, 2) AS gross_profit,
        ROUND(((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs)) / NULLIF(SUM(adjusted_sku_sales), 0))::numeric, 4) AS gross_margin_pct,
        COUNT(DISTINCT sku) AS unique_skus_sold
    FROM sku_rankings_monthly
    GROUP BY location_key, location_name, county, city, state, sale_month, sale_year
),
location_aggregates_annual AS (
    -- Location-level annual aggregates
    SELECT
        location_key,
        location_name,
        county,
        city,
        state,
        NULL::date AS sale_date,
        NULL::date AS sale_week,
        NULL::date AS sale_month,
        sale_year,
        SUM(adjusted_sku_units) AS total_units,
        SUM(adjusted_sku_sales) AS total_sales,
        SUM(adjusted_sku_gross_sales) AS total_gross_sales,
        SUM(adjusted_sku_cogs) AS total_cogs,
        SUM(adjusted_sku_orders) AS total_orders,
        SUM(adjusted_cases_sold) AS total_cases,
        ROUND((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs))::numeric, 2) AS gross_profit,
        ROUND(((SUM(adjusted_sku_sales) - SUM(adjusted_sku_cogs)) / NULLIF(SUM(adjusted_sku_sales), 0))::numeric, 4) AS gross_margin_pct,
        COUNT(DISTINCT sku) AS unique_skus_sold
    FROM sku_rankings_monthly
    GROUP BY location_key, location_name, county, city, state, sale_year
),
location_rankings_daily AS (
    -- Location-level daily rankings
    SELECT
        l.*,
        RANK() OVER (PARTITION BY county, sale_date ORDER BY total_sales DESC) AS county_rank,
        RANK() OVER (PARTITION BY sale_date ORDER BY total_sales DESC) AS state_rank,
        PERCENT_RANK() OVER (PARTITION BY sale_date ORDER BY total_sales) AS sales_percentile,
        NTILE(10) OVER (PARTITION BY sale_date ORDER BY total_sales DESC) AS sales_decile,
        COUNT(*) OVER (PARTITION BY sale_date) AS total_locations
    FROM location_aggregates_daily l
),
location_rankings_weekly AS (
    -- Location-level weekly rankings
    SELECT
        l.*,
        RANK() OVER (PARTITION BY county, sale_week ORDER BY total_sales DESC) AS county_rank,
        RANK() OVER (PARTITION BY sale_week ORDER BY total_sales DESC) AS state_rank,
        PERCENT_RANK() OVER (PARTITION BY sale_week ORDER BY total_sales) AS sales_percentile,
        NTILE(10) OVER (PARTITION BY sale_week ORDER BY total_sales DESC) AS sales_decile,
        COUNT(*) OVER (PARTITION BY sale_week) AS total_locations
    FROM location_aggregates_weekly l
),
location_rankings_monthly AS (
    -- Location-level monthly rankings
    SELECT
        l.*,
        RANK() OVER (PARTITION BY county, sale_month ORDER BY total_sales DESC) AS county_rank,
        RANK() OVER (PARTITION BY sale_month ORDER BY total_sales DESC) AS state_rank,
        PERCENT_RANK() OVER (PARTITION BY sale_month ORDER BY total_sales) AS sales_percentile,
        NTILE(10) OVER (PARTITION BY sale_month ORDER BY total_sales DESC) AS sales_decile,
        COUNT(*) OVER (PARTITION BY sale_month) AS total_locations
    FROM location_aggregates_monthly l
),
location_rankings_annual AS (
    -- Location-level annual rankings
    SELECT
        l.*,
        RANK() OVER (PARTITION BY county, sale_year ORDER BY total_sales DESC) AS county_rank,
        RANK() OVER (PARTITION BY sale_year ORDER BY total_sales DESC) AS state_rank,
        PERCENT_RANK() OVER (PARTITION BY sale_year ORDER BY total_sales) AS sales_percentile,
        NTILE(10) OVER (PARTITION BY sale_year ORDER BY total_sales DESC) AS sales_decile,
        COUNT(*) OVER (PARTITION BY sale_year) AS total_locations
    FROM location_aggregates_annual l
)
-- Final combined view with daily, weekly, monthly, annual, SKU-level and location-level data
SELECT
    -- Location-level daily data
    lr.location_key,
    lr.location_name,
    lr.county,
    lr.city,
    lr.state,
    lr.sale_date,
    lr.sale_week,
    lr.sale_month,
    lr.sale_year,
    lr.total_sales,
    lr.total_gross_sales,
    lr.total_units,
    lr.total_orders,
    lr.total_cogs,
    lr.total_cases,
    lr.gross_profit,
    lr.gross_margin_pct,
    lr.unique_skus_sold,
    lr.county_rank,
    lr.state_rank,
    lr.sales_percentile,
    lr.sales_decile,
    lr.total_locations,
    ROUND((lr.sales_percentile * 100)::numeric, 2) AS sales_percentile_pct,
    CASE
        WHEN lr.sales_decile <= 3 THEN 'Top Performer'
        WHEN lr.sales_decile >= 8 THEN 'Bottom Performer'
        ELSE 'Average Performer'
    END AS performance_tier,
    CASE
        WHEN lr.county_rank = 1 THEN 'County Leader'
        WHEN lr.county_rank <= 3 THEN 'Top 3 in County'
        ELSE 'Mid/Lower in County'
    END AS county_position,
    -- SKU-level data (NULL for location-level rows)
    NULL::text AS sku,
    NULL::text AS product_name,
    NULL::integer AS pack_size,
    NULL::numeric AS adjusted_sku_units,
    NULL::numeric AS adjusted_sku_sales,
    NULL::numeric AS adjusted_cases_sold,
    NULL::integer AS location_sku_rank,
    NULL::integer AS county_sku_rank,
    NULL::integer AS total_skus_location,
    'DAILY_LOCATION' AS data_level
FROM location_rankings_daily lr

UNION ALL

SELECT
    -- Location-level weekly data
    lr.location_key,
    lr.location_name,
    lr.county,
    lr.city,
    lr.state,
    lr.sale_date,
    lr.sale_week,
    lr.sale_month,
    lr.sale_year,
    lr.total_sales,
    lr.total_gross_sales,
    lr.total_units,
    lr.total_orders,
    lr.total_cogs,
    lr.total_cases,
    lr.gross_profit,
    lr.gross_margin_pct,
    lr.unique_skus_sold,
    lr.county_rank,
    lr.state_rank,
    lr.sales_percentile,
    lr.sales_decile,
    lr.total_locations,
    ROUND((lr.sales_percentile * 100)::numeric, 2) AS sales_percentile_pct,
    CASE
        WHEN lr.sales_decile <= 3 THEN 'Top Performer'
        WHEN lr.sales_decile >= 8 THEN 'Bottom Performer'
        ELSE 'Average Performer'
    END AS performance_tier,
    CASE
        WHEN lr.county_rank = 1 THEN 'County Leader'
        WHEN lr.county_rank <= 3 THEN 'Top 3 in County'
        ELSE 'Mid/Lower in County'
    END AS county_position,
    -- SKU-level data (NULL for location-level rows)
    NULL::text AS sku,
    NULL::text AS product_name,
    NULL::integer AS pack_size,
    NULL::numeric AS adjusted_sku_units,
    NULL::numeric AS adjusted_sku_sales,
    NULL::numeric AS adjusted_cases_sold,
    NULL::integer AS location_sku_rank,
    NULL::integer AS county_sku_rank,
    NULL::integer AS total_skus_location,
    'WEEKLY_LOCATION' AS data_level
FROM location_rankings_weekly lr

UNION ALL

SELECT
    -- Location-level monthly data
    lr.location_key,
    lr.location_name,
    lr.county,
    lr.city,
    lr.state,
    lr.sale_date,
    lr.sale_week,
    lr.sale_month,
    lr.sale_year,
    lr.total_sales,
    lr.total_gross_sales,
    lr.total_units,
    lr.total_orders,
    lr.total_cogs,
    lr.total_cases,
    lr.gross_profit,
    lr.gross_margin_pct,
    lr.unique_skus_sold,
    lr.county_rank,
    lr.state_rank,
    lr.sales_percentile,
    lr.sales_decile,
    lr.total_locations,
    ROUND((lr.sales_percentile * 100)::numeric, 2) AS sales_percentile_pct,
    CASE
        WHEN lr.sales_decile <= 3 THEN 'Top Performer'
        WHEN lr.sales_decile >= 8 THEN 'Bottom Performer'
        ELSE 'Average Performer'
    END AS performance_tier,
    CASE
        WHEN lr.county_rank = 1 THEN 'County Leader'
        WHEN lr.county_rank <= 3 THEN 'Top 3 in County'
        ELSE 'Mid/Lower in County'
    END AS county_position,
    -- SKU-level data (NULL for location-level rows)
    NULL::text AS sku,
    NULL::text AS product_name,
    NULL::integer AS pack_size,
    NULL::numeric AS adjusted_sku_units,
    NULL::numeric AS adjusted_sku_sales,
    NULL::numeric AS adjusted_cases_sold,
    NULL::integer AS location_sku_rank,
    NULL::integer AS county_sku_rank,
    NULL::integer AS total_skus_location,
    'MONTHLY_LOCATION' AS data_level
FROM location_rankings_monthly lr

UNION ALL

SELECT
    -- Location-level annual data
    lr.location_key,
    lr.location_name,
    lr.county,
    lr.city,
    lr.state,
    lr.sale_date,
    lr.sale_week,
    lr.sale_month,
    lr.sale_year,
    lr.total_sales,
    lr.total_gross_sales,
    lr.total_units,
    lr.total_orders,
    lr.total_cogs,
    lr.total_cases,
    lr.gross_profit,
    lr.gross_margin_pct,
    lr.unique_skus_sold,
    lr.county_rank,
    lr.state_rank,
    lr.sales_percentile,
    lr.sales_decile,
    lr.total_locations,
    ROUND((lr.sales_percentile * 100)::numeric, 2) AS sales_percentile_pct,
    CASE
        WHEN lr.sales_decile <= 3 THEN 'Top Performer'
        WHEN lr.sales_decile >= 8 THEN 'Bottom Performer'
        ELSE 'Average Performer'
    END AS performance_tier,
    CASE
        WHEN lr.county_rank = 1 THEN 'County Leader'
        WHEN lr.county_rank <= 3 THEN 'Top 3 in County'
        ELSE 'Mid/Lower in County'
    END AS county_position,
    -- SKU-level data (NULL for location-level rows)
    NULL::text AS sku,
    NULL::text AS product_name,
    NULL::integer AS pack_size,
    NULL::numeric AS adjusted_sku_units,
    NULL::numeric AS adjusted_sku_sales,
    NULL::numeric AS adjusted_cases_sold,
    NULL::integer AS location_sku_rank,
    NULL::integer AS county_sku_rank,
    NULL::integer AS total_skus_location,
    'ANNUAL_LOCATION' AS data_level
FROM location_rankings_annual lr

UNION ALL

SELECT
    -- SKU-level daily data
    sr.location_key,
    sr.location_name,
    sr.county,
    sr.city,
    sr.state,
    sr.sale_date,
    sr.sale_week,
    sr.sale_month,
    sr.sale_year,
    NULL::numeric AS total_sales,
    NULL::numeric AS total_gross_sales,
    NULL::numeric AS total_units,
    NULL::numeric AS total_orders,
    NULL::numeric AS total_cogs,
    NULL::numeric AS total_cases,
    NULL::numeric AS gross_profit,
    NULL::numeric AS gross_margin_pct,
    NULL::integer AS unique_skus_sold,
    NULL::integer AS county_rank,
    NULL::integer AS state_rank,
    NULL::numeric AS sales_percentile,
    NULL::integer AS sales_decile,
    NULL::integer AS total_locations,
    NULL::numeric AS sales_percentile_pct,
    NULL::text AS performance_tier,
    NULL::text AS county_position,
    -- SKU-specific fields
    sr.sku,
    sr.product_name,
    sr.pack_size,
    sr.adjusted_sku_units,
    sr.adjusted_sku_sales,
    sr.adjusted_cases_sold,
    sr.location_sku_rank,
    sr.county_sku_rank,
    sr.total_skus_location,
    'DAILY_SKU' AS data_level
FROM sku_rankings_daily sr

UNION ALL

SELECT
    -- SKU-level weekly data
    sr.location_key,
    sr.location_name,
    sr.county,
    sr.city,
    sr.state,
    sr.sale_date,
    sr.sale_week,
    sr.sale_month,
    sr.sale_year,
    NULL::numeric AS total_sales,
    NULL::numeric AS total_gross_sales,
    NULL::numeric AS total_units,
    NULL::numeric AS total_orders,
    NULL::numeric AS total_cogs,
    NULL::numeric AS total_cases,
    NULL::numeric AS gross_profit,
    NULL::numeric AS gross_margin_pct,
    NULL::integer AS unique_skus_sold,
    NULL::integer AS county_rank,
    NULL::integer AS state_rank,
    NULL::numeric AS sales_percentile,
    NULL::integer AS sales_decile,
    NULL::integer AS total_locations,
    NULL::numeric AS sales_percentile_pct,
    NULL::text AS performance_tier,
    NULL::text AS county_position,
    -- SKU-specific fields
    sr.sku,
    sr.product_name,
    sr.pack_size,
    sr.adjusted_sku_units,
    sr.adjusted_sku_sales,
    sr.adjusted_cases_sold,
    sr.location_sku_rank,
    sr.county_sku_rank,
    sr.total_skus_location,
    'WEEKLY_SKU' AS data_level
FROM sku_rankings_weekly sr

UNION ALL

SELECT
    -- SKU-level monthly data
    sr.location_key,
    sr.location_name,
    sr.county,
    sr.city,
    sr.state,
    sr.sale_date,
    sr.sale_week,
    sr.sale_month,
    sr.sale_year,
    NULL::numeric AS total_sales,
    NULL::numeric AS total_gross_sales,
    NULL::numeric AS total_units,
    NULL::numeric AS total_orders,
    NULL::numeric AS total_cogs,
    NULL::numeric AS total_cases,
    NULL::numeric AS gross_profit,
    NULL::numeric AS gross_margin_pct,
    NULL::integer AS unique_skus_sold,
    NULL::integer AS county_rank,
    NULL::integer AS state_rank,
    NULL::numeric AS sales_percentile,
    NULL::integer AS sales_decile,
    NULL::integer AS total_locations,
    NULL::numeric AS sales_percentile_pct,
    NULL::text AS performance_tier,
    NULL::text AS county_position,
    -- SKU-specific fields
    sr.sku,
    sr.product_name,
    sr.pack_size,
    sr.adjusted_sku_units,
    sr.adjusted_sku_sales,
    sr.adjusted_cases_sold,
    sr.location_sku_rank,
    sr.county_sku_rank,
    sr.total_skus_location,
    'MONTHLY_SKU' AS data_level
FROM sku_rankings_monthly sr

UNION ALL

SELECT
    -- SKU-level annual data
    sr.location_key,
    sr.location_name,
    sr.county,
    sr.city,
    sr.state,
    sr.sale_date,
    sr.sale_week,
    sr.sale_month,
    sr.sale_year,
    NULL::numeric AS total_sales,
    NULL::numeric AS total_gross_sales,
    NULL::numeric AS total_units,
    NULL::numeric AS total_orders,
    NULL::numeric AS total_cogs,
    NULL::numeric AS total_cases,
    NULL::numeric AS gross_profit,
    NULL::numeric AS gross_margin_pct,
    NULL::integer AS unique_skus_sold,
    NULL::integer AS county_rank,
    NULL::integer AS state_rank,
    NULL::numeric AS sales_percentile,
    NULL::integer AS sales_decile,
    NULL::integer AS total_locations,
    NULL::numeric AS sales_percentile_pct,
    NULL::text AS performance_tier,
    NULL::text AS county_position,
    -- SKU-specific fields
    sr.sku,
    sr.product_name,
    sr.pack_size,
    sr.annual_sku_units AS adjusted_sku_units,
    sr.annual_sku_sales AS adjusted_sku_sales,
    sr.annual_cases_sold AS adjusted_cases_sold,
    sr.annual_location_sku_rank AS location_sku_rank,
    sr.annual_county_sku_rank AS county_sku_rank,
    sr.annual_total_skus_location AS total_skus_location,
    'ANNUAL_SKU' AS data_level
FROM sku_rankings_annual sr;

-- Add comments
COMMENT ON VIEW mart.vw_sales_rankings IS 'Pre-calculated sales performance rankings with SKU-level detail, multiple time granularities (daily/weekly/monthly/annual), variation patterns, and case-level metrics for optimized Tableau performance';
COMMENT ON COLUMN mart.vw_sales_rankings.sale_date IS 'Date of sales (NULL for weekly/monthly/annual data)';
COMMENT ON COLUMN mart.vw_sales_rankings.sale_week IS 'Week of sales (NULL for daily/monthly/annual data)';
COMMENT ON COLUMN mart.vw_sales_rankings.sale_month IS 'Month of sales (NULL for daily/weekly/annual data)';
COMMENT ON COLUMN mart.vw_sales_rankings.sale_year IS 'Year of sales';
COMMENT ON COLUMN mart.vw_sales_rankings.total_cases IS 'Total cases sold (location-level)';
COMMENT ON COLUMN mart.vw_sales_rankings.sku IS 'SKU identifier (NULL for location-level rows)';
COMMENT ON COLUMN mart.vw_sales_rankings.product_name IS 'Product name (NULL for location-level rows)';
COMMENT ON COLUMN mart.vw_sales_rankings.pack_size IS 'Pack size (units per case)';
COMMENT ON COLUMN mart.vw_sales_rankings.adjusted_sku_units IS 'SKU units sold with variation applied (daily/weekly/monthly) or annual total';
COMMENT ON COLUMN mart.vw_sales_rankings.adjusted_sku_sales IS 'SKU net sales with variation applied (daily/weekly/monthly) or annual total';
COMMENT ON COLUMN mart.vw_sales_rankings.adjusted_cases_sold IS 'SKU cases sold (units/pack_size) with variation applied (daily/weekly/monthly) or annual total';
COMMENT ON COLUMN mart.vw_sales_rankings.location_sku_rank IS 'SKU rank within location/time period (1 = best)';
COMMENT ON COLUMN mart.vw_sales_rankings.county_sku_rank IS 'SKU rank within county/time period (1 = best)';
COMMENT ON COLUMN mart.vw_sales_rankings.data_level IS 'Data granularity: DAILY_LOCATION, WEEKLY_LOCATION, MONTHLY_LOCATION, ANNUAL_LOCATION, DAILY_SKU, WEEKLY_SKU, MONTHLY_SKU, ANNUAL_SKU';
COMMENT ON COLUMN mart.vw_sales_rankings.unique_skus_sold IS 'Number of unique SKUs sold by location/time period';

-- Create sales by region heatmap view
-- This view joins sales data with OLCC retailer geographic data for heatmap visualization

DROP VIEW IF EXISTS mart.vw_sales_by_region_heatmap;

CREATE VIEW mart.vw_sales_by_region_heatmap AS
SELECT 
    -- Geographic information
    l.county,
    l.city,
    l.state,
    l.latitude,
    l.longitude,
    l.location_name as retailer_name,
    
    -- Geographic region classification
    CASE 
        WHEN l.latitude > 45.5 AND l.longitude < -122.5 THEN 'Portland Metro'
        WHEN l.latitude > 44 AND l.latitude < 45 AND l.longitude < -123 THEN 'Willamette Valley'
        WHEN l.latitude < 43 AND l.longitude > -123 THEN 'Southern Oregon'
        WHEN l.latitude > 45 AND l.longitude > -121 THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END AS geographic_region,
    
    -- Sales metrics
    SUM(f.units_sold) AS total_units_sold,
    SUM(f.gross_sales_amount) AS total_gross_sales,
    SUM(f.net_sales_amount) AS total_net_sales,
    SUM(f.cogs_amount) AS total_cogs,
    SUM(f.order_count) AS total_orders,
    SUM(f.customer_count) AS total_customers,
    
    -- Calculated metrics
    ROUND(SUM(f.net_sales_amount)::numeric, 2) AS sales_amount,
    ROUND((SUM(f.net_sales_amount) - SUM(f.cogs_amount))::numeric, 2) AS gross_profit,
    ROUND(((SUM(f.net_sales_amount) - SUM(f.cogs_amount)) / NULLIF(SUM(f.net_sales_amount), 0))::numeric, 4) AS gross_margin_pct,
    
    -- Date information
    MIN(d.full_date) AS first_sale_date,
    MAX(d.full_date) AS last_sale_date,
    COUNT(DISTINCT f.date_key) AS days_with_sales
    
FROM raw.fact_sales f
JOIN raw.dim_location l ON f.location_key = l.location_key
JOIN raw.dim_date d ON f.date_key = d.date_key
WHERE l.state = 'OR'  -- Oregon only
GROUP BY 
    l.county,
    l.city,
    l.state,
    l.latitude,
    l.longitude,
    l.location_name,
    CASE 
        WHEN l.latitude > 45.5 AND l.longitude < -122.5 THEN 'Portland Metro'
        WHEN l.latitude > 44 AND l.latitude < 45 AND l.longitude < -123 THEN 'Willamette Valley'
        WHEN l.latitude < 43 AND l.longitude > -123 THEN 'Southern Oregon'
        WHEN l.latitude > 45 AND l.longitude > -121 THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END;

-- Add comments
COMMENT ON VIEW mart.vw_sales_by_region_heatmap IS 'Sales data joined with geographic information for heatmap visualization';
COMMENT ON COLUMN mart.vw_sales_by_region_heatmap.geographic_region IS 'Geographic region classification for Oregon';
COMMENT ON COLUMN mart.vw_sales_by_region_heatmap.sales_amount IS 'Total net sales amount for the location';
COMMENT ON COLUMN mart.vw_sales_by_region_heatmap.gross_profit IS 'Gross profit (sales - COGS)';
COMMENT ON COLUMN mart.vw_sales_by_region_heatmap.gross_margin_pct IS 'Gross margin percentage';

-- Create county-level sales aggregation for filled map
DROP VIEW IF EXISTS mart.vw_sales_by_county_heatmap;

CREATE VIEW mart.vw_sales_by_county_heatmap AS
SELECT 
    l.county,
    l.state,
    
    -- Sales metrics aggregated by county
    SUM(f.units_sold) AS total_units_sold,
    SUM(f.gross_sales_amount) AS total_gross_sales,
    SUM(f.net_sales_amount) AS total_net_sales,
    SUM(f.cogs_amount) AS total_cogs,
    SUM(f.order_count) AS total_orders,
    COUNT(DISTINCT f.location_key) AS retailer_count,
    
    -- Calculated metrics
    ROUND(SUM(f.net_sales_amount)::numeric, 2) AS sales_amount,
    ROUND((SUM(f.net_sales_amount) / COUNT(DISTINCT f.location_key))::numeric, 2) AS avg_sales_per_retailer,
    ROUND(((SUM(f.net_sales_amount) - SUM(f.cogs_amount)) / NULLIF(SUM(f.net_sales_amount), 0))::numeric, 4) AS gross_margin_pct,
    
    -- Geographic region classification
    CASE 
        WHEN l.county IN ('Multnomah', 'Washington', 'Clackamas', 'Clark', 'Yamhill', 'Columbia') THEN 'Portland Metro'
        WHEN l.county IN ('Marion', 'Polk', 'Linn', 'Benton', 'Lane') THEN 'Willamette Valley'
        WHEN l.county IN ('Jackson', 'Josephine', 'Douglas', 'Coos', 'Curry') THEN 'Southern Oregon'
        WHEN l.county IN ('Deschutes', 'Jefferson', 'Crook', 'Klamath', 'Lake', 'Harney', 'Malheur', 'Baker', 'Union', 'Wallowa', 'Umatilla', 'Morrow', 'Grant', 'Wheeler') THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END AS geographic_region
    
FROM raw.fact_sales f
JOIN raw.dim_location l ON f.location_key = l.location_key
WHERE l.state = 'OR'  -- Oregon only
GROUP BY 
    l.county,
    l.state,
    CASE 
        WHEN l.county IN ('Multnomah', 'Washington', 'Clackamas', 'Clark', 'Yamhill', 'Columbia') THEN 'Portland Metro'
        WHEN l.county IN ('Marion', 'Polk', 'Linn', 'Benton', 'Lane') THEN 'Willamette Valley'
        WHEN l.county IN ('Jackson', 'Josephine', 'Douglas', 'Coos', 'Curry') THEN 'Southern Oregon'
        WHEN l.county IN ('Deschutes', 'Jefferson', 'Crook', 'Klamath', 'Lake', 'Harney', 'Malheur', 'Baker', 'Union', 'Wallowa', 'Umatilla', 'Morrow', 'Grant', 'Wheeler') THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END;

COMMENT ON VIEW mart.vw_sales_by_county_heatmap IS 'County-level sales aggregation for filled map heatmap visualization';
COMMENT ON COLUMN mart.vw_sales_by_county_heatmap.avg_sales_per_retailer IS 'Average sales per retailer in the county';

-- Market Analysis CTE
-- Pre-calculates market share and competitive metrics for strategic analysis
-- This view provides optimized market analysis for competitive intelligence dashboards

DROP VIEW IF EXISTS mart.vw_market_analysis;

CREATE VIEW mart.vw_market_analysis AS
WITH market_analysis AS (
    SELECT 
        l.county,
        CASE 
            WHEN l.latitude > 45.5 AND l.longitude < -122.5 THEN 'Portland Metro'
            WHEN l.latitude > 44 AND l.latitude < 45 AND l.longitude < -123 THEN 'Willamette Valley'
            WHEN l.latitude < 43 AND l.longitude > -123 THEN 'Southern Oregon'
            WHEN l.latitude > 45 AND l.longitude > -121 THEN 'Eastern Oregon'
            ELSE 'Other Region'
        END AS geographic_region,
        SUM(f.net_sales_amount) AS county_sales,
        SUM(f.gross_sales_amount) AS county_gross_sales,
        SUM(f.units_sold) AS county_units,
        COUNT(DISTINCT f.location_key) AS retailer_count,
        COUNT(DISTINCT f.location_key) AS active_retailers
    FROM raw.fact_sales f
    JOIN raw.dim_location l ON f.location_key = l.location_key
    WHERE l.state = 'OR'
    GROUP BY l.county, 
        CASE 
            WHEN l.latitude > 45.5 AND l.longitude < -122.5 THEN 'Portland Metro'
            WHEN l.latitude > 44 AND l.latitude < 45 AND l.longitude < -123 THEN 'Willamette Valley'
            WHEN l.latitude < 43 AND l.longitude > -123 THEN 'Southern Oregon'
            WHEN l.latitude > 45 AND l.longitude > -121 THEN 'Eastern Oregon'
            ELSE 'Other Region'
        END,
        l.latitude,
        l.longitude
)
SELECT 
    county,
    geographic_region,
    county_sales,
    county_gross_sales,
    county_units,
    retailer_count,
    active_retailers,
    -- Performance metrics
    ROUND((county_sales::numeric / NULLIF(retailer_count::numeric, 0)), 2) AS avg_sales_per_retailer,
    ROUND((county_units::numeric / NULLIF(retailer_count::numeric, 0)), 2) AS avg_units_per_retailer,
    -- Market position
    RANK() OVER (ORDER BY county_sales DESC) AS sales_rank,
    RANK() OVER (ORDER BY retailer_count DESC) AS retailer_rank,
    RANK() OVER (ORDER BY (county_sales::numeric / NULLIF(retailer_count::numeric, 0)) DESC) AS efficiency_rank,
    -- Market classification
    CASE 
        WHEN county_sales > (SELECT AVG(county_sales) FROM market_analysis) * 2 THEN 'Market Leader'
        WHEN county_sales > (SELECT AVG(county_sales) FROM market_analysis) * 1.5 THEN 'Major Market'
        WHEN county_sales > (SELECT AVG(county_sales) FROM market_analysis) THEN 'Significant Market'
        ELSE 'Emerging Market'
    END AS market_classification,
    CASE 
        WHEN (county_sales::numeric / NULLIF(retailer_count::numeric, 0)) > (SELECT AVG(county_sales::numeric / NULLIF(retailer_count::numeric, 0)) FROM market_analysis) * 1.5 THEN 'High Efficiency'
        WHEN (county_sales::numeric / NULLIF(retailer_count::numeric, 0)) > (SELECT AVG(county_sales::numeric / NULLIF(retailer_count::numeric, 0)) FROM market_analysis) * 1.2 THEN 'Above Average'
        WHEN (county_sales::numeric / NULLIF(retailer_count::numeric, 0)) < (SELECT AVG(county_sales::numeric / NULLIF(retailer_count::numeric, 0)) FROM market_analysis) * 0.8 THEN 'Low Efficiency'
        ELSE 'Average Efficiency'
    END AS efficiency_classification
FROM market_analysis;

-- Add comments
COMMENT ON VIEW mart.vw_market_analysis IS 'Pre-calculated market share and competitive metrics for optimized strategic analysis';
COMMENT ON COLUMN mart.vw_market_analysis.avg_sales_per_retailer IS 'Average sales per retailer in county';
COMMENT ON COLUMN mart.vw_market_analysis.sales_rank IS 'Rank within state by sales (1 = best)';
COMMENT ON COLUMN mart.vw_market_analysis.market_classification IS 'Market position classification';

-- Sales Performance Rankings CTE
-- Pre-calculates rankings for top/bottom performers to reduce Tableau computation
-- This view provides optimized sales performance rankings for dashboards

DROP VIEW IF EXISTS mart.vw_sales_rankings;

CREATE VIEW mart.vw_sales_rankings AS
WITH sales_rankings AS (
    SELECT 
        f.location_key,
        l.location_name,
        l.county,
        l.city,
        l.state,
        SUM(f.net_sales_amount) AS total_sales,
        SUM(f.gross_sales_amount) AS total_gross_sales,
        SUM(f.units_sold) AS total_units,
        SUM(f.order_count) AS total_orders,
        SUM(f.cogs_amount) AS total_cogs,
        ROUND((SUM(f.net_sales_amount) - SUM(f.cogs_amount))::numeric, 2) AS gross_profit,
        ROUND(((SUM(f.net_sales_amount) - SUM(f.cogs_amount)) / NULLIF(SUM(f.net_sales_amount), 0))::numeric, 4) AS gross_margin_pct,
        RANK() OVER (PARTITION BY l.county ORDER BY SUM(f.net_sales_amount) DESC) AS county_rank,
        RANK() OVER (ORDER BY SUM(f.net_sales_amount) DESC) AS state_rank,
        PERCENT_RANK() OVER (ORDER BY SUM(f.net_sales_amount)) AS sales_percentile,
        NTILE(10) OVER (ORDER BY SUM(f.net_sales_amount) DESC) AS sales_decile,
        COUNT(*) OVER () AS total_locations
    FROM raw.fact_sales f
    JOIN raw.dim_location l ON f.location_key = l.location_key
    WHERE l.state = 'OR'
    GROUP BY f.location_key, l.location_name, l.county, l.city, l.state
)
SELECT 
    location_key,
    location_name,
    county,
    city,
    state,
    total_sales,
    total_gross_sales,
    total_units,
    total_orders,
    total_cogs,
    gross_profit,
    gross_margin_pct,
    county_rank,
    state_rank,
    sales_percentile,
    sales_decile,
    total_locations,
    ROUND((sales_percentile * 100)::numeric, 2) AS sales_percentile_pct,
    CASE 
        WHEN sales_decile <= 3 THEN 'Top Performer'
        WHEN sales_decile >= 8 THEN 'Bottom Performer'
        ELSE 'Average Performer'
    END AS performance_tier,
    CASE 
        WHEN county_rank = 1 THEN 'County Leader'
        WHEN county_rank <= 3 THEN 'Top 3 in County'
        ELSE 'Mid/Lower in County'
    END AS county_position
FROM sales_rankings;

-- Add comments
COMMENT ON VIEW mart.vw_sales_rankings IS 'Pre-calculated sales performance rankings for optimized Tableau performance';
COMMENT ON COLUMN mart.vw_sales_rankings.county_rank IS 'Rank within county (1 = best)';
COMMENT ON COLUMN mart.vw_sales_rankings.state_rank IS 'Rank within state (1 = best)';
COMMENT ON COLUMN mart.vw_sales_rankings.sales_percentile IS 'Percentile ranking (0-1)';
COMMENT ON COLUMN mart.vw_sales_rankings.performance_tier IS 'Performance categorization';

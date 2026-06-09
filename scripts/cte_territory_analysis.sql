-- Territory Analysis CTE
-- Pre-calculates territory metrics for territory planning dashboard
-- This view provides optimized territory analysis for sales optimization dashboards

DROP VIEW IF EXISTS mart.vw_territory_analysis;

CREATE VIEW mart.vw_territory_analysis AS
WITH territory_analysis AS (
    SELECT
        mi.geographic_region,
        mi.county,
        COUNT(DISTINCT mi.license_number) AS retailer_count,
        COUNT(CASE WHEN mi.is_active_retailer = true THEN 1 END) AS active_retailer_count,
        SUM(f.net_sales_amount) AS total_sales,
        SUM(f.gross_sales_amount) AS total_gross_sales,
        SUM(f.units_sold) AS total_units,
        SUM(f.order_count) AS total_orders,
        AVG(f.net_sales_amount) AS avg_sales_per_retailer,
        COUNT(CASE WHEN mi.market_competition_level = 'High Competition' THEN 1 END) AS high_competition_count,
        COUNT(CASE WHEN mi.market_competition_level = 'Medium Competition' THEN 1 END) AS medium_competition_count,
        COUNT(CASE WHEN mi.market_competition_level = 'Low Competition' THEN 1 END) AS low_competition_count,
        AVG(mi.distance_from_portland_miles) AS avg_distance_from_portland,
        MIN(mi.distance_from_portland_miles) AS min_distance_from_portland,
        MAX(mi.distance_from_portland_miles) AS max_distance_from_portland
    FROM mart.vw_market_intelligence mi
    LEFT JOIN raw.fact_sales f ON mi.license_number = f.location_key::text
    GROUP BY mi.geographic_region, mi.county
)
SELECT
    geographic_region,
    county,
    retailer_count,
    active_retailer_count,
    total_sales,
    total_gross_sales,
    total_units,
    total_orders,
    ROUND(avg_sales_per_retailer::numeric, 2) AS avg_sales_per_retailer,
    high_competition_count,
    medium_competition_count,
    low_competition_count,
    ROUND(avg_distance_from_portland::numeric, 2) AS avg_distance_from_portland,
    ROUND(min_distance_from_portland::numeric, 2) AS min_distance_from_portland,
    ROUND(max_distance_from_portland::numeric, 2) AS max_distance_from_portland,
    -- Territory metrics
    ROUND((active_retailer_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100, 2) AS activity_rate_pct,
    -- Competition intensity
    ROUND((high_competition_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100, 2) AS high_competition_pct,
    ROUND((low_competition_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100, 2) AS low_competition_pct,
    -- Territory classification
    CASE 
        WHEN low_competition_count > (retailer_count * 0.5) AND avg_distance_from_portland < 100 THEN 'High Priority Territory'
        WHEN low_competition_count > (retailer_count * 0.3) AND avg_distance_from_portland < 150 THEN 'Medium Priority Territory'
        WHEN high_competition_count > (retailer_count * 0.5) THEN 'Saturated Territory'
        WHEN avg_distance_from_portland > 200 THEN 'Remote Territory'
        ELSE 'Standard Territory'
    END AS territory_priority,
    -- Market opportunity score
    ROUND((
        (CASE WHEN (low_competition_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100 > 50 THEN 3 WHEN (low_competition_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100 > 30 THEN 2 ELSE 1 END) * 0.4 +
        (CASE WHEN avg_distance_from_portland < 100 THEN 3 WHEN avg_distance_from_portland < 150 THEN 2 ELSE 1 END) * 0.3 +
        (CASE WHEN avg_sales_per_retailer > 10000 THEN 3 WHEN avg_sales_per_retailer > 5000 THEN 2 ELSE 1 END) * 0.3
    )::numeric, 2) AS opportunity_score,
    -- Territory rank within region
    RANK() OVER (PARTITION BY geographic_region ORDER BY opportunity_score DESC) AS regional_opportunity_rank
FROM territory_analysis;

-- Add comments
COMMENT ON VIEW mart.vw_territory_analysis IS 'Pre-calculated territory metrics for optimized territory planning dashboards';
COMMENT ON COLUMN mart.vw_territory_analysis.territory_priority IS 'Territory classification based on competition and location';
COMMENT ON COLUMN mart.vw_territory_analysis.opportunity_score IS 'Composite opportunity score (1-3 scale)';
COMMENT ON COLUMN mart.vw_territory_analysis.regional_opportunity_rank IS 'Rank within region by opportunity score (1 = best)';

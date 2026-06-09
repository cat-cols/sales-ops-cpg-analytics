-- Geographic Aggregation CTE
-- Pre-calculates county/region aggregations to reduce Tableau computation
-- This view provides optimized geographic aggregations for market intelligence dashboards

DROP VIEW IF EXISTS mart.vw_geo_aggregations;

CREATE VIEW mart.vw_geo_aggregations AS
WITH geo_aggregations AS (
    SELECT 
        county,
        CASE 
            WHEN latitude > 45.5 AND longitude < -122.5 THEN 'Portland Metro'
            WHEN latitude > 44 AND latitude < 45 AND longitude < -123 THEN 'Willamette Valley'
            WHEN latitude < 43 AND longitude > -123 THEN 'Southern Oregon'
            WHEN latitude > 45 AND longitude > -121 THEN 'Eastern Oregon'
            ELSE 'Other Region'
        END AS geographic_region,
        COUNT(*) AS retailer_count,
        COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) AS active_count,
        COUNT(CASE WHEN license_type LIKE '%RECREATIONAL%' THEN 1 END) AS recreational_count,
        COUNT(CASE WHEN license_type LIKE '%MEDICAL%' THEN 1 END) AS medical_count,
        COUNT(DISTINCT city) AS city_count,
        ROUND(AVG(latitude)::numeric, 6) AS avg_latitude,
        ROUND(AVG(longitude)::numeric, 6) AS avg_longitude,
        ROUND(AVG(
            SQRT(POW(latitude - 45.5152, 2) + POW(longitude - (-122.6784), 2)) * 69
        )::numeric, 2) AS avg_distance_from_portland
    FROM raw.olcc_retailers
    GROUP BY county, 
        CASE 
            WHEN latitude > 45.5 AND longitude < -122.5 THEN 'Portland Metro'
            WHEN latitude > 44 AND latitude < 45 AND longitude < -123 THEN 'Willamette Valley'
            WHEN latitude < 43 AND longitude > -123 THEN 'Southern Oregon'
            WHEN latitude > 45 AND longitude > -121 THEN 'Eastern Oregon'
            ELSE 'Other Region'
        END
)
SELECT 
    county,
    geographic_region,
    retailer_count,
    active_count,
    recreational_count,
    medical_count,
    city_count,
    avg_latitude,
    avg_longitude,
    avg_distance_from_portland,
    ROUND((active_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100, 2) AS active_percentage,
    ROUND((recreational_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100, 2) AS recreational_percentage,
    ROUND((medical_count::numeric / NULLIF(retailer_count::numeric, 0)) * 100, 2) AS medical_percentage
FROM geo_aggregations;

-- Add comments
COMMENT ON VIEW mart.vw_geo_aggregations IS 'Pre-calculated geographic aggregations for optimized Tableau performance';
COMMENT ON COLUMN mart.vw_geo_aggregations.geographic_region IS 'Geographic region classification for Oregon';
COMMENT ON COLUMN mart.vw_geo_aggregations.active_percentage IS 'Percentage of active retailers in county';
COMMENT ON COLUMN mart.vw_geo_aggregations.avg_distance_from_portland IS 'Average distance from Portland in miles';

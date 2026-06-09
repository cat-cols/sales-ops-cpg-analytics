-- Create integrated market intelligence view
-- This view combines OLCC retailer data with manufacturer data for comprehensive market analysis

DROP VIEW IF EXISTS mart.vw_market_intelligence;

CREATE VIEW mart.vw_market_intelligence AS
SELECT
    -- OLCC Retailer Information
    r.license_number,
    r.business_name AS retailer_name,
    r.license_type,
    r.status AS retailer_status,
    r.county,
    r.city,
    r.state,
    r.zip_code,
    r.street_address,
    r.latitude,
    r.longitude,
    
    -- Create full address
    CONCAT(
        COALESCE(r.street_address, ''), 
        CASE WHEN r.street_address IS NOT NULL AND r.city IS NOT NULL THEN ', ' ELSE '' END,
        COALESCE(r.city, ''),
        CASE WHEN r.city IS NOT NULL AND r.state IS NOT NULL THEN ', ' ELSE '' END,
        COALESCE(r.state, ''),
        CASE WHEN r.state IS NOT NULL AND r.zip_code IS NOT NULL THEN ' ' ELSE '' END,
        COALESCE(r.zip_code, '')
    ) AS full_address,
    
    -- Retailer Classification
    CASE 
        WHEN r.license_type LIKE '%RECREATIONAL%' THEN 'Recreational'
        WHEN r.license_type LIKE '%MEDICAL%' THEN 'Medical'
        ELSE 'Other'
    END AS retailer_category,
    
    CASE 
        WHEN r.status = 'ACTIVE' THEN true 
        ELSE false 
    END AS is_active_retailer,
    
    -- Geographic Analysis
    r.city AS city_name,
    r.county AS county_name,
    r.state AS state_name,
    
    -- Market Density Metrics (calculated at county level)
    (
        SELECT COUNT(*) 
        FROM raw.olcc_retailers r2 
        WHERE r2.county = r.county 
        AND r2.status = 'ACTIVE'
    ) AS active_retailers_in_county,
    
    (
        SELECT COUNT(*) 
        FROM raw.olcc_retailers r3 
        WHERE r3.city = r.city 
        AND r3.status = 'ACTIVE'
    ) AS active_retailers_in_city,
    
    -- Market Opportunity Score (placeholder - can be enhanced with population data)
    CASE 
        WHEN (
            SELECT COUNT(*) 
            FROM raw.olcc_retailers r4 
            WHERE r4.county = r.county 
            AND r4.status = 'ACTIVE'
        ) > 50 THEN 'High Competition'
        WHEN (
            SELECT COUNT(*) 
            FROM raw.olcc_retailers r5 
            WHERE r5.county = r.county 
            AND r5.status = 'ACTIVE'
        ) > 20 THEN 'Medium Competition'
        ELSE 'Low Competition'
    END AS market_competition_level,
    
    -- Geographic Clusters (simplified - can be enhanced with clustering algorithms)
    CASE 
        WHEN r.latitude > 45.5 AND r.longitude < -122.5 THEN 'Portland Metro'
        WHEN r.latitude > 44 AND r.latitude < 45 AND r.longitude < -123 THEN 'Willamette Valley'
        WHEN r.latitude < 43 AND r.longitude > -123 THEN 'Southern Oregon'
        WHEN r.latitude > 45 AND r.longitude > -121 THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END AS geographic_region,
    
    -- Distance from Portland (simplified calculation)
    ROUND(
        SQRT(
            POW(r.latitude - 45.5152, 2) + 
            POW(r.longitude - (-122.6784), 2)
        ) * 69, 2
    ) AS distance_from_portland_miles,
    
    -- Data freshness
    r.loaded_at AS retailer_data_loaded_at,
    NOW() AS analysis_timestamp
    
FROM raw.olcc_retailers r
WHERE r.license_number IS NOT NULL;

-- Add comments
COMMENT ON VIEW mart.vw_market_intelligence IS 'Integrated market intelligence view combining OLCC retailer data with geographic and competitive analysis';
COMMENT ON COLUMN mart.vw_market_intelligence.market_competition_level IS 'Market competition level based on retailer density';
COMMENT ON COLUMN mart.vw_market_intelligence.geographic_region IS 'Geographic region classification for strategic analysis';
COMMENT ON COLUMN mart.vw_market_intelligence.distance_from_portland_miles IS 'Distance from Portland in miles (simplified calculation)';

-- Create county-level market summary view
DROP VIEW IF EXISTS mart.vw_county_market_summary;

CREATE VIEW mart.vw_county_market_summary AS
SELECT 
    county_name,
    state_name,
    COUNT(*) AS total_retailers,
    COUNT(CASE WHEN is_active_retailer = true THEN 1 END) AS active_retailers,
    COUNT(CASE WHEN retailer_category = 'Recreational' THEN 1 END) AS recreational_retailers,
    COUNT(CASE WHEN retailer_category = 'Medical' THEN 1 END) AS medical_retailers,
    COUNT(DISTINCT city_name) AS cities_served,
    ROUND(AVG(latitude)::numeric, 6) AS avg_latitude,
    ROUND(AVG(longitude)::numeric, 6) AS avg_longitude,
    market_competition_level,
    geographic_region,
    COUNT(CASE WHEN market_competition_level = 'High Competition' THEN 1 END) AS high_competition_counties
FROM mart.vw_market_intelligence
GROUP BY county_name, state_name, market_competition_level, geographic_region
ORDER BY active_retailers DESC;

COMMENT ON VIEW mart.vw_county_market_summary IS 'County-level market summary for strategic planning';

-- Create city-level market summary view
DROP VIEW IF EXISTS mart.vw_city_market_summary;

CREATE VIEW mart.vw_city_market_summary AS
SELECT 
    city_name,
    county_name,
    state_name,
    COUNT(*) AS total_retailers,
    COUNT(CASE WHEN is_active_retailer = true THEN 1 END) AS active_retailers,
    COUNT(CASE WHEN retailer_category = 'Recreational' THEN 1 END) AS recreational_retailers,
    COUNT(CASE WHEN retailer_category = 'Medical' THEN 1 END) AS medical_retailers,
    ROUND(AVG(latitude)::numeric, 6) AS avg_latitude,
    ROUND(AVG(longitude)::numeric, 6) AS avg_longitude,
    market_competition_level,
    geographic_region,
    ROUND(AVG(distance_from_portland_miles)::numeric, 2) AS avg_distance_from_portland
FROM mart.vw_market_intelligence
GROUP BY city_name, county_name, state_name, market_competition_level, geographic_region
ORDER BY active_retailers DESC;

COMMENT ON VIEW mart.vw_city_market_summary IS 'City-level market summary for tactical planning';

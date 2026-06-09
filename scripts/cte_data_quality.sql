-- Data Quality CTE
-- Pre-calculates data quality metrics for dashboard trust indicators
-- This view provides optimized data quality checks for data governance dashboards

DROP VIEW IF EXISTS mart.vw_data_quality;

CREATE VIEW mart.vw_data_quality AS
WITH data_quality AS (
    -- OLCC Retailers data quality
    SELECT 
        'olcc_retailers' AS table_name,
        'Retailer License Data' AS data_domain,
        COUNT(*) AS total_records,
        COUNT(CASE WHEN latitude IS NULL THEN 1 END) AS missing_latitude,
        COUNT(CASE WHEN longitude IS NULL THEN 1 END) AS missing_longitude,
        COUNT(CASE WHEN city IS NULL OR city = '' THEN 1 END) AS missing_city,
        COUNT(CASE WHEN county IS NULL OR county = '' THEN 1 END) AS missing_county,
        COUNT(CASE WHEN zip_code IS NULL OR zip_code = '' THEN 1 END) AS missing_zip,
        COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) AS active_records,
        COUNT(CASE WHEN license_number IS NULL OR license_number = '' THEN 1 END) AS missing_keys,
        COUNT(DISTINCT license_number) AS unique_keys,
        COUNT(*) - COUNT(DISTINCT license_number) AS duplicate_keys,
        ROUND((COUNT(CASE WHEN latitude IS NOT NULL AND longitude IS NOT NULL THEN 1 END)::numeric / NULLIF(COUNT(*)::numeric, 0)) * 100, 2) AS geocoding_completeness_pct,
        ROUND((COUNT(CASE WHEN city IS NOT NULL AND city != '' THEN 1 END)::numeric / NULLIF(COUNT(*)::numeric, 0)) * 100, 2) AS city_completeness_pct,
        NOW() AS check_timestamp
    FROM raw.olcc_retailers
    
    UNION ALL
    
    -- Fact Sales data quality
    SELECT 
        'fact_sales' AS table_name,
        'Sales Transaction Data' AS data_domain,
        COUNT(*) AS total_records,
        0 AS missing_latitude,
        0 AS missing_longitude,
        0 AS missing_city,
        0 AS missing_county,
        0 AS missing_zip,
        COUNT(*) AS active_records,
        COUNT(CASE WHEN location_key IS NULL OR location_key = '' THEN 1 END) AS missing_keys,
        COUNT(DISTINCT CONCAT(date_key, '-', location_key, '-', product_key)) AS unique_keys,
        COUNT(*) - COUNT(DISTINCT CONCAT(date_key, '-', location_key, '-', product_key)) AS duplicate_keys,
        100.00 AS geocoding_completeness_pct,
        100.00 AS city_completeness_pct,
        NOW() AS check_timestamp
    FROM raw.fact_sales
    
    UNION ALL
    
    -- Dim Location data quality
    SELECT 
        'dim_location' AS table_name,
        'Location Reference Data' AS data_domain,
        COUNT(*) AS total_records,
        COUNT(CASE WHEN latitude IS NULL THEN 1 END) AS missing_latitude,
        COUNT(CASE WHEN longitude IS NULL THEN 1 END) AS missing_longitude,
        COUNT(CASE WHEN city IS NULL OR city = '' THEN 1 END) AS missing_city,
        COUNT(CASE WHEN county IS NULL OR county = '' THEN 1 END) AS missing_county,
        COUNT(CASE WHEN zip_code IS NULL OR zip_code = '' THEN 1 END) AS missing_zip,
        COUNT(*) AS active_records,
        COUNT(CASE WHEN location_key IS NULL OR location_key = '' THEN 1 END) AS missing_keys,
        COUNT(DISTINCT location_key) AS unique_keys,
        COUNT(*) - COUNT(DISTINCT location_key) AS duplicate_keys,
        ROUND((COUNT(CASE WHEN latitude IS NOT NULL AND longitude IS NOT NULL THEN 1 END)::numeric / NULLIF(COUNT(*)::numeric, 0)) * 100, 2) AS geocoding_completeness_pct,
        ROUND((COUNT(CASE WHEN city IS NOT NULL AND city != '' THEN 1 END)::numeric / NULLIF(COUNT(*)::numeric, 0)) * 100, 2) AS city_completeness_pct,
        NOW() AS check_timestamp
    FROM raw.dim_location
)
SELECT 
    table_name,
    data_domain,
    total_records,
    missing_latitude,
    missing_longitude,
    missing_city,
    missing_county,
    missing_zip,
    active_records,
    missing_keys,
    unique_keys,
    duplicate_keys,
    geocoding_completeness_pct,
    city_completeness_pct,
    check_timestamp,
    -- Overall quality score
    ROUND((
        (geocoding_completeness_pct * 0.3) +
        (city_completeness_pct * 0.3) +
        ((unique_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 * 0.2) +
        (CASE WHEN duplicate_keys = 0 THEN 100 ELSE 100 - (duplicate_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 END * 0.2)
    )::numeric, 2) AS overall_quality_score,
    -- Quality status
    CASE 
        WHEN (
            (geocoding_completeness_pct * 0.3) +
            (city_completeness_pct * 0.3) +
            ((unique_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 * 0.2) +
            (CASE WHEN duplicate_keys = 0 THEN 100 ELSE 100 - (duplicate_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 END * 0.2)
        ) >= 95 THEN 'EXCELLENT'
        WHEN (
            (geocoding_completeness_pct * 0.3) +
            (city_completeness_pct * 0.3) +
            ((unique_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 * 0.2) +
            (CASE WHEN duplicate_keys = 0 THEN 100 ELSE 100 - (duplicate_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 END * 0.2)
        ) >= 80 THEN 'GOOD'
        WHEN (
            (geocoding_completeness_pct * 0.3) +
            (city_completeness_pct * 0.3) +
            ((unique_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 * 0.2) +
            (CASE WHEN duplicate_keys = 0 THEN 100 ELSE 100 - (duplicate_keys::numeric / NULLIF(total_records::numeric, 0)) * 100 END * 0.2)
        ) >= 70 THEN 'FAIR'
        ELSE 'POOR'
    END AS quality_status,
    -- Issues requiring attention
    CASE 
        WHEN missing_latitude > 0 OR missing_longitude > 0 THEN 'Missing geocoding data'
        WHEN missing_city > 0 OR missing_county > 0 THEN 'Missing location data'
        WHEN duplicate_keys > 0 THEN 'Duplicate key issues'
        WHEN missing_keys > 0 THEN 'Missing key values'
        ELSE 'No critical issues'
    END AS attention_required
FROM data_quality;

-- Add comments
COMMENT ON VIEW mart.vw_data_quality IS 'Pre-calculated data quality metrics for optimized dashboard trust indicators';
COMMENT ON COLUMN mart.vw_data_quality.overall_quality_score IS 'Overall data quality score (0-100)';
COMMENT ON COLUMN mart.vw_data_quality.quality_status IS 'Quality status classification';
COMMENT ON COLUMN mart.vw_data_quality.attention_required IS 'Issues requiring attention';

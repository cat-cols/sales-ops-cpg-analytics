-- Create OLCC retailers mart view for analysis
-- This view provides a clean, analysis-ready view of OLCC retailer data

DROP VIEW IF EXISTS mart.vw_olcc_retailers;

CREATE VIEW mart.vw_olcc_retailers AS
SELECT 
    license_number,
    business_name,
    business_licenses,
    license_type,
    status,
    expiration_date,
    sos_registration_number,
    county,
    tier,
    canopy_type,
    endorsement,
    street_address,
    city,
    state,
    zip_code,
    -- Create a full address field for mapping
    CONCAT(
        COALESCE(street_address, ''), 
        CASE WHEN street_address IS NOT NULL AND city IS NOT NULL THEN ', ' ELSE '' END,
        COALESCE(city, ''),
        CASE WHEN city IS NOT NULL AND state IS NOT NULL THEN ', ' ELSE '' END,
        COALESCE(state, ''),
        CASE WHEN state IS NOT NULL AND zip_code IS NOT NULL THEN ' ' ELSE '' END,
        COALESCE(zip_code, '')
    ) AS full_address,
    -- Add computed fields for analysis
    CASE 
        WHEN status = 'ACTIVE' THEN true 
        ELSE false 
    END AS is_active,
    CASE 
        WHEN license_type LIKE '%RECREATIONAL%' THEN 'Recreational'
        WHEN license_type LIKE '%MEDICAL%' THEN 'Medical'
        ELSE 'Other'
    END AS license_category,
    -- Geographic hierarchy
    city AS city_name,
    county AS county_name,
    state AS state_name,
    loaded_at
FROM raw.olcc_retailers
WHERE license_number IS NOT NULL;

-- Add comments
COMMENT ON VIEW mart.vw_olcc_retailers IS 'Analysis-ready view of OLCC retailer data with computed fields for Tableau';
COMMENT ON COLUMN mart.vw_olcc_retailers.full_address IS 'Concatenated full address for mapping';
COMMENT ON COLUMN mart.vw_olcc_retailers.is_active IS 'Boolean flag for active licenses';
COMMENT ON COLUMN mart.vw_olcc_retailers.license_category IS 'Simplified license category (Recreational/Medical/Other)';

-- Create summary view for quick analytics
DROP VIEW IF EXISTS mart.vw_olcc_retailers_summary;

CREATE VIEW mart.vw_olcc_retailers_summary AS
SELECT 
    city,
    county,
    license_type,
    status,
    COUNT(*) AS retailer_count,
    COUNT(DISTINCT license_number) AS unique_licenses,
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) AS active_count
FROM raw.olcc_retailers
WHERE city IS NOT NULL
GROUP BY city, county, license_type, status
ORDER BY county, city, retailer_count DESC;

COMMENT ON VIEW mart.vw_olcc_retailers_summary IS 'Summary view of OLCC retailers by city, county, and license type';

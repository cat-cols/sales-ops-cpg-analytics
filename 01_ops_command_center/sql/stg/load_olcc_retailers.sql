-- Load OLCC retailer data from CSV into PostgreSQL
-- This script loads the cleaned OLCC retailer data into the raw.olcc_retailers table

-- First, clear existing data (optional - remove if you want to append)
TRUNCATE TABLE raw.olcc_retailers;

-- Load data from CSV
COPY raw.olcc_retailers (
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
    raw_physical_address,
    street_address,
    city,
    state,
    zip_code
)
FROM '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/olcc_retailer_cleaned.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';

-- Verify the load
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT city) as unique_cities,
    COUNT(DISTINCT county) as unique_counties,
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as active_licenses,
    COUNT(CASE WHEN license_type = 'RECREATIONAL RETAILER' THEN 1 END) as recreational_retailers
FROM raw.olcc_retailers;

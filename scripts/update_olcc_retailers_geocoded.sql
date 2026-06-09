-- Update OLCC retailers table with geocoded coordinates
-- This script updates the latitude and longitude columns with geocoded data

-- First, clear existing data (optional - remove if you want to append)
TRUNCATE TABLE raw.olcc_retailers;

-- Load geocoded data from CSV
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
    zip_code,
    latitude,
    longitude
)
FROM '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/olcc_retailer_geocoded.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';

-- Verify the geocoding
SELECT 
    COUNT(*) as total_records,
    COUNT(latitude) as geocoded_records,
    COUNT(longitude) as geocoded_longitudes,
    ROUND(AVG(latitude)::numeric, 6) as avg_latitude,
    ROUND(AVG(longitude)::numeric, 6) as avg_longitude
FROM raw.olcc_retailers;

-- Show sample of geocoded data
SELECT 
    business_name,
    city,
    state,
    latitude,
    longitude
FROM raw.olcc_retailers
WHERE latitude IS NOT NULL
LIMIT 10;

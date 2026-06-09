-- SQL approach to parse physical addresses into components
-- This script demonstrates how to parse addresses using PostgreSQL string functions

-- Key SQL functions used:

-- REGEXP_MATCHES: Extract patterns like ZIP codes (\d{5}(-\d{4})?)
-- SUBSTRING: Extract portions of strings
-- POSITION: Find location of specific text (like " OR")
-- SPLIT_PART: Split string by delimiter and get specific part
-- TRIM: Remove whitespace
-- CASE: Conditional logic for edge cases
-- SQL approach advantages:

-- Runs directly in PostgreSQL
-- No external dependencies
-- Can be integrated into database workflows
-- Easier to debug and modify for specific patterns
-- Steps in the SQL script:

-- Create table and load CSV
-- Add new columns (street_address, city, state, zip_code)
-- Parse ZIP code using regex
-- Extract state abbreviation (OR)
-- Parse city from remaining address
-- Extract street address
-- Handle "Exempt from Public Disclosure" cases
-- Verify and export results


-- Step 1: Create a table from the CSV
CREATE TABLE IF NOT EXISTS temp_recreational_retailer (
    license_number VARCHAR(50),
    business_name VARCHAR(200),
    license_group VARCHAR(100),
    business_licenses VARCHAR(200),
    license_type VARCHAR(100),
    physical_address VARCHAR(500),
    county VARCHAR(50),
    expiration_date DATE,
    tier VARCHAR(20),
    canopy_type VARCHAR(50),
    indoor_canopy_sqft VARCHAR(20),
    outdoor_canopy_sqft VARCHAR(20),
    endorsement VARCHAR(500),
    sos_registration_number VARCHAR(50)
);

-- Load the CSV data
\COPY temp_recreational_retailer FROM '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer.csv' CSV HEADER

-- Step 2: Add the new columns
ALTER TABLE temp_recreational_retailer
ADD COLUMN street_address VARCHAR(300),
ADD COLUMN city VARCHAR(100),
ADD COLUMN state VARCHAR(10),
ADD COLUMN zip_code VARCHAR(10);

-- Step 3: Parse addresses using SQL string functions
UPDATE temp_recreational_retailer
SET 
    -- Extract ZIP code (5 digits or 5-4 format)
    zip_code = CASE 
        WHEN physical_address ~ '\d{5}(-\d{4})?' 
        THEN SUBSTRING(physical_address FROM '\d{5}(-\d{4})?')
        ELSE NULL 
    END,
    -- Extract state (OR for Oregon)
    state = CASE 
        WHEN physical_address ~ '\bOR\b' 
        THEN 'OR'
        ELSE NULL 
    END,
    -- Remove ZIP and state from address for city/street parsing
    city = CASE 
        WHEN physical_address ~ '\bOR\b' AND physical_address ~ '\d{5}(-\d{4})?'
        THEN TRIM(SUBSTRING(
            REGEXP_REPLACE(physical_address, '\d{5}(-\d{4})?', ''),
            '\bOR\b',
            ''
        ))
        ELSE NULL 
    END;

-- Step 4: Parse city from the remaining address
-- City is typically the last word before state
UPDATE temp_recreational_retailer
SET city = CASE 
    WHEN city IS NOT NULL AND city != ''
    THEN SPLIT_PART(TRIM(city), ' ', array_length(string_to_array(TRIM(city), ' '), 1))
    ELSE NULL 
END;

-- Step 5: Parse street address (everything before city)
UPDATE temp_recreational_retailer
SET street_address = CASE 
    WHEN city IS NOT NULL AND city != ''
    THEN TRIM(SUBSTRING(
        city, 
        1, 
        LENGTH(city) - LENGTH(SPLIT_PART(TRIM(city), ' ', array_length(string_to_array(TRIM(city), ' '), 1))) - 1
    ))
    ELSE city
END;

-- Alternative approach using regex for more robust parsing
UPDATE temp_recreational_retailer
SET 
    zip_code = CASE 
        WHEN physical_address ~ '\d{5}(-\d{4})?' 
        THEN (REGEXP_MATCHES(physical_address, '\d{5}(-\d{4})?'))[1]
        ELSE NULL 
    END,
    state = CASE 
        WHEN physical_address ~ '\bOR\b' 
        THEN 'OR'
        ELSE NULL 
    END,
    city = CASE 
        WHEN physical_address ~ '\bOR\b' 
        THEN TRIM(SUBSTRING(
            physical_address, 
            0, 
            POSITION(' OR' IN physical_address)
        ))
        ELSE NULL 
    END;

-- Handle "Exempt from Public Disclosure" cases
UPDATE temp_recreational_retailer
SET 
    street_address = NULL,
    city = NULL,
    state = NULL,
    zip_code = NULL
WHERE physical_address = 'Exempt from Public Disclosure';

-- Step 6: Verify the parsing
SELECT 
    physical_address,
    street_address,
    city,
    state,
    zip_code
FROM temp_recreational_retailer
WHERE physical_address != 'Exempt from Public Disclosure'
LIMIT 10;

-- Step 7: Export the parsed data
\COPY (SELECT * FROM temp_recreational_retailer) TO '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer_sql_parsed.csv' CSV HEADER

-- Clean up when done
-- DROP TABLE temp_recreational_retailer;

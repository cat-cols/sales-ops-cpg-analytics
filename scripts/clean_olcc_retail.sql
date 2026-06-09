-- SQL script to clean and parse OLCC retailer data
-- This script handles data cleaning, column renaming, and address parsing with validation

-- Clean up from previous runs
DROP TABLE IF EXISTS temp_olcc_retailer;

-- Step 1: Create table from raw CSV
CREATE TABLE IF NOT EXISTS temp_olcc_retailer (
    "License Number" VARCHAR(50),
    "Business Name" VARCHAR(200),
    "Business Licenses" VARCHAR(200),
    "License Type" VARCHAR(100),
    "Status" VARCHAR(50),
    "Expiration Date" VARCHAR(20),
    "SOS Registration Number" VARCHAR(50),
    "PhysicalAddress" VARCHAR(500),
    "County" VARCHAR(50),
    "Tier" VARCHAR(20),
    "Canopy Type" VARCHAR(50),
    "Endorsement" VARCHAR(500)
);

-- Load the CSV data (tab-delimited, UTF-8 converted file)
\COPY temp_olcc_retailer FROM '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/raw/olcc_retail_utf8.csv' DELIMITER E'\t' CSV HEADER

-- Step 2: Remove blank rows (rows where all key fields are NULL or empty)
DELETE FROM temp_olcc_retailer
WHERE
    "License Number" IS NULL OR TRIM("License Number") = ''
    AND "Business Name" IS NULL OR TRIM("Business Name") = ''
    AND "PhysicalAddress" IS NULL OR TRIM("PhysicalAddress") = '';

-- Step 3: Add new columns for parsed address components
ALTER TABLE temp_olcc_retailer
ADD COLUMN raw_physical_address VARCHAR(500),
ADD COLUMN street_address VARCHAR(300),
ADD COLUMN city VARCHAR(100),
ADD COLUMN state VARCHAR(10),
ADD COLUMN zip_code VARCHAR(10);

-- Step 4: Rename PhysicalAddress to raw_physical_address
UPDATE temp_olcc_retailer
SET raw_physical_address = "PhysicalAddress";

-- Step 5: Parse addresses with validation rules
UPDATE temp_olcc_retailer
SET
    -- Extract ZIP code: must be only digits (5 digits or 5-4 format)
    zip_code = CASE
        WHEN "PhysicalAddress" ~ '^\d{5}(-\d{4})?$' 
        THEN SUBSTRING("PhysicalAddress" FROM '^\d{5}(-\d{4})?$')
        WHEN "PhysicalAddress" ~ '\d{5}(-\d{4})?$' 
        THEN (REGEXP_MATCHES("PhysicalAddress", '\d{5}(-\d{4})?$'))[1]
        ELSE NULL
    END,
    -- Extract state: must be 2-letter abbreviation (OR for Oregon)
    state = CASE 
        WHEN "PhysicalAddress" ~ '\b[A-Z]{2}\b' 
        THEN UPPER((REGEXP_MATCHES("PhysicalAddress", '\b[A-Z]{2}\b'))[1])
        ELSE NULL 
    END;

-- Step 6: Parse city with validation - must NOT contain numbers or ZIP codes
UPDATE temp_olcc_retailer
SET city = CASE 
    WHEN "PhysicalAddress" IS NOT NULL 
        AND "PhysicalAddress" != 'Exempt from Public Disclosure'
        AND "PhysicalAddress" != ''
    THEN 
        -- Remove ZIP code and state from address first
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE("PhysicalAddress", '\d{5}(-\d{4})?', ''),
                '\b[A-Z]{2}\b',
                ''
            )
        )
    ELSE NULL 
END;

-- Step 7: Extract city name (last word before state, must not contain numbers)
UPDATE temp_olcc_retailer
SET city = CASE 
    WHEN city IS NOT NULL AND city != ''
    THEN 
        -- Get last word and ensure it doesn't contain numbers
        CASE 
            WHEN SPLIT_PART(TRIM(city), ' ', array_length(string_to_array(TRIM(city), ' '), 1)) !~ '\d'
            THEN SPLIT_PART(TRIM(city), ' ', array_length(string_to_array(TRIM(city), ' '), 1))
            ELSE NULL 
        END
    ELSE NULL 
END;

-- Step 8: Parse street address (everything before city)
UPDATE temp_olcc_retailer
SET street_address = CASE 
    WHEN city IS NOT NULL AND city != '' AND "PhysicalAddress" IS NOT NULL
    THEN 
        -- Remove city, state, and ZIP from original address
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE("PhysicalAddress", city, ''),
                    '\b[A-Z]{2}\b',
                    ''
                ),
                '\d{5}(-\d{4})?',
                ''
            )
        )
    ELSE NULL 
END;

-- Step 9: Additional validation - ensure city doesn't contain ZIP codes
UPDATE temp_olcc_retailer
SET city = CASE 
    WHEN city ~ '\d{5}' 
    THEN NULL  -- Invalid city if it contains ZIP code pattern
    ELSE city 
END;

-- Step 10: Additional validation - ensure ZIP code doesn't contain letters
UPDATE temp_olcc_retailer
SET zip_code = CASE 
    WHEN zip_code ~ '[A-Za-z]' 
    THEN NULL  -- Invalid ZIP if it contains letters
    ELSE zip_code 
END;

-- Step 11: Handle "Exempt from Public Disclosure" cases
UPDATE temp_olcc_retailer
SET 
    street_address = NULL,
    city = NULL,
    state = NULL,
    zip_code = NULL
WHERE "PhysicalAddress" = 'Exempt from Public Disclosure' OR "PhysicalAddress" IS NULL;

-- Step 12: Drop the old PhysicalAddress column
ALTER TABLE temp_olcc_retailer DROP COLUMN "PhysicalAddress";

-- Step 13: Verify the cleaning and parsing
SELECT 
    "License Number",
    "Business Name",
    raw_physical_address,
    street_address,
    city,
    state,
    zip_code,
    CASE 
        WHEN city ~ '\d' THEN 'INVALID: City contains numbers'
        WHEN city ~ '\d{5}' THEN 'INVALID: City contains ZIP pattern'
        WHEN zip_code ~ '[A-Za-z]' THEN 'INVALID: ZIP contains letters'
        ELSE 'VALID'
    END as validation_status
FROM temp_olcc_retailer
WHERE raw_physical_address IS NOT NULL 
    AND raw_physical_address != 'Exempt from Public Disclosure'
LIMIT 20;

-- Step 14: Export cleaned data
\COPY (SELECT * FROM temp_olcc_retailer) TO '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/olcc_retailer_cleaned.csv' CSV HEADER

-- Step 15: Summary statistics
SELECT 
    COUNT(*) as total_records,
    COUNT(CASE WHEN raw_physical_address IS NOT NULL AND raw_physical_address != '' THEN 1 END) as records_with_addresses,
    COUNT(CASE WHEN city IS NOT NULL AND city != '' THEN 1 END) as records_with_cities,
    COUNT(CASE WHEN zip_code IS NOT NULL AND zip_code != '' THEN 1 END) as records_with_zip_codes,
    COUNT(CASE WHEN raw_physical_address = 'Exempt from Public Disclosure' THEN 1 END) as exempt_records
FROM temp_olcc_retailer;

-- Clean up when done
-- DROP TABLE temp_olcc_retailer;

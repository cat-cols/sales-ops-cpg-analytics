-- Create OLCC retailers table in PostgreSQL
-- This table stores Oregon Liquor Control Commission (OLCC) retailer license data

DROP TABLE IF EXISTS raw.olcc_retailers;

CREATE TABLE raw.olcc_retailers (
    license_number VARCHAR(20) PRIMARY KEY,
    business_name VARCHAR(255),
    business_licenses VARCHAR(255),
    license_type VARCHAR(100),
    status VARCHAR(50),
    expiration_date VARCHAR(20),
    sos_registration_number VARCHAR(50),
    county VARCHAR(100),
    tier VARCHAR(50),
    canopy_type VARCHAR(100),
    endorsement TEXT,
    raw_physical_address TEXT,
    street_address VARCHAR(255),
    city VARCHAR(100),
    state CHAR(2),
    zip_code VARCHAR(10),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common query patterns
CREATE INDEX idx_olcc_retailers_city ON raw.olcc_retailers(city);
CREATE INDEX idx_olcc_retailers_county ON raw.olcc_retailers(county);
CREATE INDEX idx_olcc_retailers_status ON raw.olcc_retailers(status);
CREATE INDEX idx_olcc_retailers_license_type ON raw.olcc_retailers(license_type);

-- Add comments
COMMENT ON TABLE raw.olcc_retailers IS 'Oregon OLCC retailer license data with parsed addresses';
COMMENT ON COLUMN raw.olcc_retailers.license_number IS 'OLCC license number';
COMMENT ON COLUMN raw.olcc_retailers.business_name IS 'Business name of the retailer';
COMMENT ON COLUMN raw.olcc_retailers.license_type IS 'Type of license (e.g., RECREATIONAL RETAILER)';
COMMENT ON COLUMN raw.olcc_retailers.status IS 'License status (e.g., ACTIVE, PENDING)';
COMMENT ON COLUMN raw.olcc_retailers.street_address IS 'Parsed street address';
COMMENT ON COLUMN raw.olcc_retailers.city IS 'Parsed city name (UPPERCASE)';
COMMENT ON COLUMN raw.olcc_retailers.state IS 'State abbreviation (OR)';
COMMENT ON COLUMN raw.olcc_retailers.zip_code IS 'ZIP code';
COMMENT ON COLUMN raw.olcc_retailers.latitude IS 'Geographic latitude (for mapping)';
COMMENT ON COLUMN raw.olcc_retailers.longitude IS 'Geographic longitude (for mapping)';

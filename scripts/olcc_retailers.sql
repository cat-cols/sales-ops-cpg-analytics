CREATE TABLE raw.olcc_retailers (
    license_number VARCHAR(20) PRIMARY KEY,
    business_name VARCHAR(255),
    business_type VARCHAR(100),
    status VARCHAR(50),
    county VARCHAR(100),
    street_address VARCHAR(255),
    city VARCHAR(100),
    state CHAR(2),
    zip_code VARCHAR(10),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    raw_physical_address TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
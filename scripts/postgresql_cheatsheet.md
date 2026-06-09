# PostgreSQL Cheatsheet - Althea Ops Command Center

## Database Connection

### Connect to Database
```bash
psql -d althea_ops
```

### Connect with Specific User
```bash
psql -d althea_ops -U username
```

### Connect to Different Host
```bash
psql -h localhost -p 5432 -d althea_ops -U username
```

---

## Schema and Table Management

### List All Tables
```bash
psql -d althea_ops -c "\dt"
```

### List Tables in Specific Schema
```bash
psql -d althea_ops -c "\dt raw.*"
psql -d althea_ops -c "\dt mart.*"
psql -d althea_ops -c "\dt public.*"
```

### List All Views
```bash
psql -d althea_ops -c "\dv"
```

### Describe Table Structure
```bash
psql -d althea_ops -c "\d raw.fact_sales"
psql -d althea_ops -c "\d raw.dim_location"
psql -d althea_ops -c "\d raw.olcc_retailers"
```

### List All Schemas
```bash
psql -d althea_ops -c "\dn"
```

---

## Data Inspection

### Sample Data from Table
```bash
psql -d althea_ops -c "SELECT * FROM raw.olcc_retailers LIMIT 5;"
```

### Count Records
```bash
psql -d althea_ops -c "SELECT COUNT(*) FROM raw.olcc_retailers;"
```

### Check for Null Values
```bash
psql -d althea_ops -c "SELECT COUNT(*) FROM raw.olcc_retailers WHERE latitude IS NULL;"
```

### Unique Values
```bash
psql -d althea_ops -c "SELECT COUNT(DISTINCT city) FROM raw.olcc_retailers;"
psql -d althea_ops -c "SELECT COUNT(DISTINCT county) FROM raw.olcc_retailers;"
```

---

## OLCC Retailer Data Queries

### Basic Retailer Information
```sql
SELECT 
    license_number,
    business_name,
    city,
    county,
    state,
    status,
    license_type
FROM raw.olcc_retailers
LIMIT 10;
```

### Retailers by County
```sql
SELECT 
    county,
    COUNT(*) as retailer_count,
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as active_count
FROM raw.olcc_retailers
GROUP BY county
ORDER BY retailer_count DESC;
```

### Geocoding Verification
```sql
SELECT 
    COUNT(*) as total_retailers,
    COUNT(latitude) as geocoded_count,
    COUNT(longitude) as longitude_count,
    ROUND(AVG(latitude)::numeric, 6) as avg_latitude,
    ROUND(AVG(longitude)::numeric, 6) as avg_longitude
FROM raw.olcc_retailers;
```

### Geographic Region Distribution
```sql
SELECT 
    CASE 
        WHEN latitude > 45.5 AND longitude < -122.5 THEN 'Portland Metro'
        WHEN latitude > 44 AND latitude < 45 AND longitude < -123 THEN 'Willamette Valley'
        WHEN latitude < 43 AND longitude > -123 THEN 'Southern Oregon'
        WHEN latitude > 45 AND longitude > -121 THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END as geographic_region,
    COUNT(*) as retailer_count
FROM raw.olcc_retailers
GROUP BY geographic_region
ORDER BY retailer_count DESC;
```

---

## Sales Data Queries

### Sales by Location
```sql
SELECT 
    l.location_name,
    l.county,
    l.city,
    SUM(f.net_sales_amount) as total_sales,
    SUM(f.units_sold) as total_units
FROM raw.fact_sales f
JOIN raw.dim_location l ON f.location_key = l.location_key
WHERE l.state = 'OR'
GROUP BY l.location_name, l.county, l.city
ORDER BY total_sales DESC;
```

### Sales by County
```sql
SELECT 
    l.county,
    COUNT(DISTINCT f.location_key) as retailer_count,
    SUM(f.net_sales_amount) as total_sales,
    SUM(f.units_sold) as total_units,
    ROUND(AVG(f.net_sales_amount)::numeric, 2) as avg_sales_per_retailer
FROM raw.fact_sales f
JOIN raw.dim_location l ON f.location_key = l.location_key
WHERE l.state = 'OR'
GROUP BY l.county
ORDER BY total_sales DESC;
```

### Sales by Geographic Region
```sql
SELECT 
    CASE 
        WHEN l.latitude > 45.5 AND l.longitude < -122.5 THEN 'Portland Metro'
        WHEN l.latitude > 44 AND l.latitude < 45 AND l.longitude < -123 THEN 'Willamette Valley'
        WHEN l.latitude < 43 AND l.longitude > -123 THEN 'Southern Oregon'
        WHEN l.latitude > 45 AND l.longitude > -121 THEN 'Eastern Oregon'
        ELSE 'Other Region'
    END as geographic_region,
    SUM(f.net_sales_amount) as total_sales,
    SUM(f.units_sold) as total_units,
    COUNT(DISTINCT f.location_key) as retailer_count
FROM raw.fact_sales f
JOIN raw.dim_location l ON f.location_key = l.location_key
WHERE l.state = 'OR'
GROUP BY geographic_region
ORDER BY total_sales DESC;
```

---

## View Management

### Create View from SQL File
```bash
psql -d althea_ops -f scripts/create_olcc_retailers_mart_view.sql
psql -d althea_ops -f scripts/create_market_intelligence_view.sql
psql -d althea_ops -f scripts/create_sales_heatmap_view.sql
```

### Drop View
```sql
DROP VIEW IF EXISTS mart.vw_market_intelligence;
DROP VIEW IF EXISTS mart.vw_sales_by_county_heatmap;
```

### Recreate View
```sql
CREATE OR REPLACE VIEW mart.vw_market_intelligence AS
-- your view definition here
```

---

## Data Loading

### Load CSV Data
```bash
psql -d althea_ops -f scripts/load_olcc_retailers.sql
```

### COPY Command Example
```sql
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
FROM '/path/to/olcc_retailer_geocoded.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';
```

### Truncate Table Before Loading
```sql
TRUNCATE TABLE raw.olcc_retailers;
```

---

## User Management

### List Users
```bash
psql -d postgres -c "\du"
```

### Create User
```sql
CREATE USER tableau_user WITH PASSWORD 'your_password';
```

### Grant Privileges
```sql
GRANT CONNECT ON DATABASE althea_ops TO tableau_user;
GRANT USAGE ON SCHEMA public, raw, mart TO tableau_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO tableau_user;
GRANT SELECT ON ALL TABLES IN SCHEMA raw TO tableau_user;
GRANT SELECT ON ALL TABLES IN SCHEMA mart TO tableau_user;
```

---

## Performance and Maintenance

### Analyze Table Performance
```sql
ANALYZE raw.olcc_retailers;
ANALYZE raw.fact_sales;
```

### Vacuum Table
```sql
VACUUM ANALYZE raw.olcc_retailers;
```

### Check Table Size
```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname IN ('raw', 'mart', 'public')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Common Issues and Solutions

### View Does Not Exist Error
```bash
# Check if view exists
psql -d althea_ops -c "\dv mart.vw_market_intelligence"

# Recreate view if needed
psql -d althea_ops -f scripts/create_market_intelligence_view.sql
```

### Permission Denied
```sql
# Grant proper permissions
GRANT ALL PRIVILEGES ON DATABASE althea_ops TO your_user;
GRANT ALL PRIVILEGES ON SCHEMA raw TO your_user;
GRANT ALL PRIVILEGES ON SCHEMA mart TO your_user;
```

### Connection Issues
```bash
# Check if PostgreSQL is running
brew services list | grep postgresql

# Start PostgreSQL
brew services start postgresql

# Check connection
psql -d althea_ops -c "SELECT version();"
```

---

## Project-Specific Commands

### OLCC Retailer Data Pipeline
```bash
# 1. Clean and parse OLCC data
python3 scripts/clean_olcc_retail.py

# 2. Geocode addresses
python3 scripts/geocode_olcc_retailers.py

# 3. Create table
psql -d althea_ops -f scripts/create_olcc_retailers_table.sql

# 4. Load data
psql -d althea_ops -f scripts/load_olcc_retailers.sql

# 5. Update with geocoded data
psql -d althea_ops -f scripts/update_olcc_retailers_geocoded.sql

# 6. Create views
psql -d althea_ops -f scripts/create_olcc_retailers_mart_view.sql
psql -d althea_ops -f scripts/create_market_intelligence_view.sql
psql -d althea_ops -f scripts/create_sales_heatmap_view.sql
```

### Manufacturer Data Pipeline
```bash
# Generate manufacturer data
python3 01_ops_command_center/scripts/generate_project1_manufacturer_data.py

# Load manufacturer data (if using separate loading scripts)
# psql -d althea_ops -f scripts/load_manufacturer_data.sql
```

---

## Tableau Integration

### Verify Views for Tableau
```bash
# List all mart views
psql -d althea_ops -c "\dv mart.*"

# Test view data
psql -d althea_ops -c "SELECT * FROM mart.vw_market_intelligence LIMIT 5;"
psql -d althea_ops -c "SELECT * FROM mart.vw_sales_by_county_heatmap LIMIT 5;"
```

### Check View Performance
```sql
EXPLAIN ANALYZE SELECT * FROM mart.vw_market_intelligence;
EXPLAIN ANALYZE SELECT * FROM mart.vw_sales_by_county_heatmap;
```

---

## Backup and Export

### Export Table to CSV
```sql
COPY raw.olcc_retailers TO '/tmp/olcc_retailers_backup.csv' DELIMITER ',' CSV HEADER;
```

### Export Query Results
```sql
COPY (
    SELECT county, COUNT(*) as retailer_count 
    FROM raw.olcc_retailers 
    GROUP BY county
) TO '/tmp/county_retailers.csv' DELIMITER ',' CSV HEADER;
```

### Backup Database
```bash
pg_dump althea_ops > althea_ops_backup.sql
```

### Restore Database
```bash
psql -d althea_ops < althea_ops_backup.sql
```

---

## Useful System Queries

### Database Size
```sql
SELECT pg_size_pretty(pg_database_size('althea_ops'));
```

### Active Connections
```sql
SELECT count(*) FROM pg_stat_activity WHERE datname = 'althea_ops';
```

### Lock Status
```sql
SELECT * FROM pg_locks WHERE relation IN (
    SELECT oid FROM pg_class WHERE relname LIKE 'olcc_retailers'
);
```

### Recent Queries
```sql
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
WHERE query LIKE '%olcc_retailers%' 
ORDER BY total_time DESC 
LIMIT 10;
```

---

## Quick Reference

### Common PSQL Commands
- `\q` - Quit psql
- `\l` - List databases
- `\c database_name` - Connect to database
- `\dt` - List tables
- `\dv` - List views
- `\d table_name` - Describe table
- `\du` - List users
- `\dn` - List schemas
- `\h` - Help on SQL commands
- `\?` - Help on psql commands

### Common SQL Patterns
```sql
-- Basic SELECT
SELECT * FROM table_name LIMIT 10;

-- COUNT
SELECT COUNT(*) FROM table_name;

-- DISTINCT
SELECT COUNT(DISTINCT column_name) FROM table_name;

-- GROUP BY
SELECT column_name, COUNT(*) FROM table_name GROUP BY column_name;

-- ORDER BY
SELECT * FROM table_name ORDER BY column_name DESC;

-- JOIN
SELECT * FROM table1 JOIN table2 ON table1.id = table2.id;

-- CASE statement
SELECT 
    CASE 
        WHEN condition THEN value1
        WHEN condition THEN value2
        ELSE default_value
    END as new_column
FROM table_name;
```

---

*This cheatsheet is specific to the Althea Ops Command Center project and focuses on the OLCC retailer data integration and sales analysis work.*

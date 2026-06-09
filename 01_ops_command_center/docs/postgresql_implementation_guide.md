# PostgreSQL Implementation Guide - Project 1

## Overview
This guide walks through implementing Project 1 using PostgreSQL instead of CSV files. This demonstrates data engineering capabilities in addition to business analyst skills.

## Prerequisites
- PostgreSQL installed (version 13+ recommended)
- Python 3 with psycopg2 library
- Power BI Desktop with PostgreSQL connector
- Existing CSV sample data from `data/sample/`

## Step 1: Set Up PostgreSQL

### 1.1 Install PostgreSQL
```bash
# macOS (Homebrew)
brew install postgresql@14
brew services start postgresql@14

# Verify installation
psql --version
```

### 1.2 Create Database
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE althea_ops;

# Create user (optional, for security)
CREATE USER althea_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE althea_ops TO althea_user;

# Exit
\q
```

### 1.3 Install Python Dependencies
```bash
pip install psycopg2-binary pandas
```

## Step 2: Create Database Schemas

### 2.1 Execute Schema Creation Script
```bash
cd /Users/b/DATA/PROJECTS/cannalytics-sales-ops-cpg/01_ops_command_center
psql -U postgres -d althea_ops -f sql/stg/00_create_schemas.sql
```

### 2.2 Verify Schemas
```sql
-- Connect to database
psql -U postgres -d althea_ops

-- List schemas
\dn

-- Expected output:
-- raw
-- stg
-- int
-- mart
```

## Step 3: Load CSV Data into Database

### 3.1 Create Python Loading Script
Create `scripts/load_csv_to_postgres.py`:

```python
#!/usr/bin/env python3
import psycopg2
import pandas as pd
from pathlib import Path

# Database connection
conn = psycopg2.connect(
    host="localhost",
    database="althea_ops",
    user="postgres",
    password="your_password"
)
conn.autocommit = True
cursor = conn.cursor()

# Data directory
data_dir = Path("data/sample")

# Load dimension tables first
dimension_files = {
    "dim_date_sample.csv": "raw.dim_date",
    "dim_product_sample.csv": "raw.dim_product",
    "dim_location_sample.csv": "raw.dim_location",
    "dim_channel_sample.csv": "raw.dim_channel",
    "dim_employee_group_sample.csv": "raw.dim_employee_group",
}

# Load fact tables
fact_files = {
    "sales_sample.csv": "raw.fact_sales",
    "inventory_sample.csv": "raw.fact_inventory",
    "labor_sample.csv": "raw.fact_labor",
    "finance_sample.csv": "raw.fact_finance",
}

def load_csv_to_table(csv_file, table_name):
    """Load CSV file into PostgreSQL table"""
    csv_path = data_dir / csv_file
    df = pd.read_csv(csv_path)
    
    # Create table if not exists
    cursor.execute(f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            {', '.join([f'{col} TEXT' for col in df.columns])}
        )
    """)
    
    # Clear existing data
    cursor.execute(f"TRUNCATE TABLE {table_name}")
    
    # Insert data
    for _, row in df.iterrows():
        columns = ', '.join(df.columns)
        values = ', '.join([f"'{val}'" if pd.notna(val) else 'NULL' for val in row])
        cursor.execute(f"INSERT INTO {table_name} ({columns}) VALUES ({values})")
    
    print(f"Loaded {len(df)} rows into {table_name}")

# Load dimensions
for csv_file, table_name in dimension_files.items():
    load_csv_to_table(csv_file, table_name)

# Load facts
for csv_file, table_name in fact_files.items():
    load_csv_to_table(csv_file, table_name)

cursor.close()
conn.close()
print("Data loading complete!")
```

### 3.2 Execute Loading Script
```bash
python3 scripts/load_csv_to_postgres.py
```

### 3.3 Verify Data Loading
```sql
-- Connect to database
psql -U postgres -d althea_ops

-- Check row counts
SELECT 'dim_date' as table_name, COUNT(*) as row_count FROM raw.dim_date
UNION ALL
SELECT 'dim_product', COUNT(*) FROM raw.dim_product
UNION ALL
SELECT 'dim_location', COUNT(*) FROM raw.dim_location
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM raw.fact_sales
UNION ALL
SELECT 'fact_inventory', COUNT(*) FROM raw.fact_inventory
UNION ALL
SELECT 'fact_labor', COUNT(*) FROM raw.fact_labor;
```

## Step 4: Execute Staging Layer

### 4.1 Build Staging Views
```bash
psql -U postgres -d althea_ops -f sql/stg/_build_stg.sql
```

### 4.2 Verify Staging Views
```sql
-- Check staging views
SELECT viewname FROM pg_views WHERE schemaname = 'stg';

-- Sample query
SELECT * FROM stg.stg_dispensary_master LIMIT 5;
```

## Step 5: Execute Integration Layer

### 5.1 Build Integration Tables
```bash
psql -U postgres -d althea_ops -f sql/int/_build_int.sql
```

### 5.2 Verify Integration Tables
```sql
-- Check integration tables
SELECT tablename FROM pg_tables WHERE schemaname = 'int';

-- Sample query
SELECT * FROM int.int_dispensary_latest LIMIT 5;
```

## Step 6: Execute Mart Layer

### 6.1 Build Mart Tables
```bash
psql -U postgres -d althea_ops -f sql/mart/_build_mart.sql
```

### 6.2 Verify Mart Tables
```sql
-- Check mart tables
SELECT tablename FROM pg_tables WHERE schemaname = 'mart';

-- Sample query
SELECT * FROM mart.fact_sales_conformed LIMIT 5;
```

## Step 7: Connect Power BI to PostgreSQL

### 7.1 Install PostgreSQL Connector
- In Power BI Desktop: Get Data → Database → PostgreSQL
- Install PostgreSQL connector if prompted

### 7.2 Configure Connection
```
Server: localhost
Database: althea_ops
User name: postgres
Password: your_password
```

### 7.3 Load Tables
Load these tables into Power BI:
- `mart.fact_sales_conformed`
- `mart.fact_inventory_conformed`
- `mart.fact_labor_conformed`
- `int.dim_date`
- `int.dim_product`
- `int.dim_location`
- `int.dim_channel`

### 7.4 Build Relationships
Same as CSV approach:
- `int.dim_date[full_date]` → `mart.fact_sales_conformed[transaction_date]`
- `int.dim_product[product_sku]` → `mart.fact_sales_conformed[product_sku]`
- `int.dim_location[state_code]` → `mart.fact_sales_conformed[state_code]`
- `int.dim_channel[channel]` → `mart.fact_sales_conformed[channel]`

### 7.5 Create DAX Measures
Same measures as CSV approach - just pointing to database tables instead of CSV files.

## Step 8: Update Documentation

### 8.1 Update Pipeline Visualization
Update `docs/diagrams/data_pipeline_visualization.md` to reflect PostgreSQL approach:

**Change:**
- Data Generation → PostgreSQL Tables (instead of CSV files)
- Standardization → Staging Views (SQL-based)
- Semantic Model → Database Tables (instead of CSV import)

### 8.2 Update README
Add PostgreSQL setup instructions to project README.

## Step 9: Validation

### 9.1 Run QA Checks
```bash
psql -U postgres -d althea_ops -f sql/_qa/int/qa_int.sql
```

### 9.2 Verify Data Consistency
```sql
-- Compare database counts with CSV counts
SELECT 'Database' as source, COUNT(*) as count FROM mart.fact_sales_conformed
UNION ALL
SELECT 'CSV' as source, COUNT(*) as count FROM (
    SELECT * FROM csv_data -- adjust as needed
) csv;
```

## Troubleshooting

### Connection Issues
```bash
# Check PostgreSQL is running
brew services list

# Restart PostgreSQL if needed
brew services restart postgresql@14

# Check connection
psql -U postgres -d althea_ops
```

### Permission Issues
```sql
-- Grant permissions if needed
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA raw TO althea_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA stg TO althea_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA int TO althea_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA mart TO althea_user;
```

### Data Type Issues
- PostgreSQL may have different data types than CSV
- Adjust column types in CREATE TABLE statements
- Use TEXT for simplicity, convert to specific types as needed

## Portfolio Value

This PostgreSQL implementation demonstrates:
- Data engineering skills (ETL/ELT)
- Database design and optimization
- SQL development (staging/integration/mart patterns)
- Database connectivity (Power BI to PostgreSQL)
- End-to-end data pipeline implementation

**Interview talking points:**
- "I implemented a full data warehouse with staging, integration, and mart layers"
- "Used PostgreSQL for the data layer, which maps to Snowflake/BigQuery in production"
- "Built reusable SQL patterns for data transformation"
- "Connected Power BI directly to the database for real-time analytics"

## Next Steps

1. Complete PostgreSQL setup
2. Load all data successfully
3. Execute all SQL layers (staging/integration/mart)
4. Connect Power BI to PostgreSQL
5. Validate data consistency
6. Update documentation
7. Test Power BI report with database connection

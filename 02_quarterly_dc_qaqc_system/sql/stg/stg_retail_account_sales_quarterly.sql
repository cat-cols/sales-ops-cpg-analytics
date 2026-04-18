-- sql/stg/stg_retail_account_sales_quarterly.sql
-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: standardize retail quarterly sales submissions into a typed staging view

create schema if not exists stg;

create or replace view stg.stg_retail_account_sales_quarterly as
select
    nullif(trim(quarter_id), '') as quarter_id,
    cast(nullif(trim(week_end_date), '') as date) as week_end_date,
    nullif(trim(dispensary_account_id), '') as dispensary_account_id,
    nullif(trim(sku_id), '') as sku_id,
    cast(units_sold as integer) as units_sold,
    cast(gross_sales as numeric(18,2)) as gross_sales,
    cast(discount_amount as numeric(18,2)) as discount_amount,
    cast(net_sales as numeric(18,2)) as net_sales
from raw.retail_account_sales_quarterly_extract;

-- RUN IT:
-- psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 02_quarterly_dc_qaqc_system/sql/stg/stg_retail_account_sales_quarterly.sql

-- TEST IT:
-- psql "$P1_PG_OPS" -c "select * from stg.stg_retail_account_sales_quarterly limit 20;"

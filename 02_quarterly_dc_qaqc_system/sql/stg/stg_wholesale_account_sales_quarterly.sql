-- sql/stg/stg_wholesale_account_sales_quarterly.sql
-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: standardize wholesale quarterly sales submissions into a typed staging view

create schema if not exists stg;

create or replace view stg.stg_wholesale_account_sales_quarterly as
select
    nullif(trim(quarter_id), '') as quarter_id,
    cast(nullif(trim(week_end_date), '') as date) as week_end_date,
    nullif(trim(wholesale_account_id), '') as wholesale_account_id,
    nullif(trim(sku_id), '') as sku_id,
    cast(cases_sold as integer) as cases_sold,
    cast(gross_sales as numeric(18,2)) as gross_sales,
    cast(net_sales as numeric(18,2)) as net_sales
from raw.wholesale_account_sales_quarterly_extract;

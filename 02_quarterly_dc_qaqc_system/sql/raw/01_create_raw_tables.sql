-- sql/raw/01_create_raw_tables.sql
-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: create raw landing tables for quarterly source submissions

create schema if not exists raw;

create table if not exists raw.retail_account_sales_quarterly_extract (
    quarter_id text,
    week_end_date text,
    dispensary_account_id text,
    sku_id text,
    units_sold text,
    gross_sales text,
    discount_amount text,
    net_sales text,
    source_file_name text,
    load_ts timestamp not null default current_timestamp
);

create table if not exists raw.wholesale_account_sales_quarterly_extract (
    quarter_id text,
    week_end_date text,
    wholesale_account_id text,
    sku_id text,
    cases_sold text,
    gross_sales text,
    net_sales text,
    source_file_name text,
    load_ts timestamp not null default current_timestamp
);

create table if not exists raw.finance_quarterly_actuals (
    quarter_id text,
    account_code text,
    department_code text,
    actual_amount text,
    reporting_category text,
    source_file_name text,
    load_ts timestamp not null default current_timestamp
);

create table if not exists raw.inventory_quarterly_extract (
    quarter_id text,
    week_end_date text,
    warehouse_id text,
    sku_id text,
    on_hand_units text,
    available_units text,
    inventory_value text,
    source_file_name text,
    load_ts timestamp not null default current_timestamp
);

create table if not exists raw.trade_adjustments_extract (
    quarter_id text,
    adjustment_id text,
    account_id text,
    adjustment_type text,
    adjustment_amount text,
    adjustment_date text,
    reason_code text,
    source_file_name text,
    load_ts timestamp not null default current_timestamp
);
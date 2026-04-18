-- sql/stg/stg_inventory_quarterly.sql
-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: standardize quarterly inventory submissions into a typed staging view

create schema if not exists stg;

create or replace view stg.stg_inventory_quarterly as
select
    nullif(trim(quarter_id), '') as quarter_id,
    cast(nullif(trim(week_end_date), '') as date) as week_end_date,
    nullif(trim(warehouse_id), '') as warehouse_id,
    nullif(trim(sku_id), '') as sku_id,
    cast(on_hand_units as integer) as on_hand_units,
    cast(available_units as integer) as available_units,
    cast(inventory_value as numeric(18,2)) as inventory_value
from raw.inventory_quarterly_extract;
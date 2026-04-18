-- sql/stg/stg_trade_adjustments.sql
-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: standardize quarterly trade adjustments into a typed staging view

create schema if not exists stg;

create or replace view stg.stg_trade_adjustments as
select
    nullif(trim(quarter_id), '') as quarter_id,
    nullif(trim(adjustment_id), '') as adjustment_id,
    nullif(trim(account_id), '') as account_id,
    nullif(trim(adjustment_type), '') as adjustment_type,
    cast(adjustment_amount as numeric(18,2)) as adjustment_amount,
    cast(nullif(trim(adjustment_date), '') as date) as adjustment_date,
    nullif(trim(reason_code), '') as reason_code
from raw.trade_adjustments_extract;
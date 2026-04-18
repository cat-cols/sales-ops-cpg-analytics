-- sql/stg/stg_finance_quarterly_actuals.sql
-- Project 2: Quarterly Data Collection + QA/QC System
-- Purpose: standardize quarterly finance actuals into a typed staging view

create schema if not exists stg;

create or replace view stg.stg_finance_quarterly_actuals as
select
    nullif(trim(quarter_id), '') as quarter_id,
    nullif(trim(account_code), '') as account_code,
    nullif(trim(department_code), '') as department_code,
    cast(actual_amount as numeric(18,2)) as actual_amount,
    nullif(trim(reporting_category), '') as reporting_category
from raw.finance_quarterly_actuals;
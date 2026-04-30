create or replace view stg.stg_ghg_electricity_bills as
with source as (
    select
        row_number() over () as raw_row_id,
        *
    from raw.ghg_electricity_bills_monthly
),

cleaned as (
    select
        raw_row_id,

        case
            when trim(bill_month) ~ '^\d{4}-\d{2}-\d{2}$'
                then trim(bill_month)::date
            when trim(bill_month) ~ '^[A-Za-z]{3}-\d{4}$'
                then to_date(trim(bill_month), 'Mon-YYYY')
            when trim(bill_month) ~ '^\d{1,2}/\d{1,2}/\d{4}$'
                then to_date(trim(bill_month), 'MM/DD/YYYY')
            else null
        end as activity_month,

        upper(nullif(trim(facility_id), '')) as facility_id,
        trim(facility_name) as facility_name,
        trim(utility_provider) as utility_provider,
        upper(nullif(trim(meter_number), '')) as meter_number,

        case
            when trim(usage_amount) ~ '^-?\d+(\.\d+)?$'
                then trim(usage_amount)::numeric(18, 4)
            else null
        end as activity_amount,

        case
            when lower(trim(usage_unit)) in ('kwh', 'kw hrs', 'kwhrs', 'kilowatt hour', 'kilowatt hours')
                then 'kwh'
            else lower(trim(usage_unit))
        end as activity_unit,

        case
            when trim(invoice_amount_usd) ~ '^-?\d+(\.\d+)?$'
                then trim(invoice_amount_usd)::numeric(18, 2)
            else null
        end as invoice_amount_usd,

        upper(nullif(trim(invoice_number), '')) as invoice_number,

        'Scope 2' as scope,
        'electricity_kwh' as factor_type,
        'electricity_bills' as source_system

    from source
)

select
    *,
    activity_amount < 0 as has_negative_activity,
    facility_id is null as has_missing_facility_id,
    activity_month is null as has_invalid_activity_month
from cleaned;
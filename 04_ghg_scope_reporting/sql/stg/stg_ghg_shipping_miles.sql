create or replace view stg.stg_ghg_shipping_miles as
with source as (
    select
        row_number() over () as raw_row_id,
        *
    from raw.ghg_shipping_miles_logistics
),

cleaned as (
    select
        raw_row_id,

        upper(nullif(trim(shipment_id), '')) as shipment_id,

        case
            when trim(shipment_date) ~ '^\d{4}-\d{2}-\d{2}$'
                then trim(shipment_date)::date
            when trim(shipment_date) ~ '^\d{1,2}/\d{1,2}/\d{4}$'
                then to_date(trim(shipment_date), 'MM/DD/YYYY')
            else null
        end as shipment_date,

        date_trunc(
            'month',
            case
                when trim(shipment_date) ~ '^\d{4}-\d{2}-\d{2}$'
                    then trim(shipment_date)::date
                when trim(shipment_date) ~ '^\d{1,2}/\d{1,2}/\d{4}$'
                    then to_date(trim(shipment_date), 'MM/DD/YYYY')
                else null
            end
        )::date as activity_month,

        upper(nullif(trim(origin_facility_id), '')) as facility_id,
        upper(nullif(trim(destination_state), '')) as destination_state,
        upper(nullif(trim(product_line_id), '')) as product_line_id,

        case
            when lower(trim(shipping_mode)) = 'truck'
                then 'truck'
            when lower(trim(shipping_mode)) = 'air'
                then 'air'
            else lower(trim(shipping_mode))
        end as shipping_mode,

        trim(carrier) as carrier,

        case
            when trim(distance_miles) ~ '^-?\d+(\.\d+)?$'
                then trim(distance_miles)::numeric(18, 4)
            else null
        end as distance_miles,

        case
            when trim(shipment_weight_lb) ~ '^-?\d+(\.\d+)?$'
                then trim(shipment_weight_lb)::numeric(18, 4)
            else null
        end as shipment_weight_lb,

        case
            when trim(ton_miles) ~ '^-?\d+(\.\d+)?$'
                then trim(ton_miles)::numeric(18, 4)
            else null
        end as activity_amount,

        'ton_mile' as activity_unit,

        case
            when trim(freight_cost_usd) ~ '^-?\d+(\.\d+)?$'
                then trim(freight_cost_usd)::numeric(18, 2)
            else null
        end as freight_cost_usd,

        'Scope 3' as scope,

        case
            when lower(trim(shipping_mode)) = 'truck'
                then 'freight_truck_ton_mile'
            when lower(trim(shipping_mode)) = 'air'
                then 'freight_air_ton_mile'
            else null
        end as factor_type,

        'shipping_miles' as source_system

    from source
)

select
    *,
    activity_amount < 0 as has_negative_activity,
    facility_id is null as has_missing_facility_id,
    product_line_id is null as has_missing_product_line_id,
    shipment_date is null as has_invalid_shipment_date,
    factor_type is null as has_unknown_shipping_mode
from cleaned;
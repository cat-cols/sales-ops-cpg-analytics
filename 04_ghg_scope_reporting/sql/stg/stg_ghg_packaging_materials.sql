create or replace view stg.stg_ghg_packaging_materials as
with source as (
    select
        row_number() over () as raw_row_id,
        *
    from raw.ghg_packaging_materials_procurement
),

cleaned as (
    select
        raw_row_id,

        case
            when trim(invoice_month) ~ '^\d{4}-\d{2}-\d{2}$'
                then trim(invoice_month)::date
            when trim(invoice_month) ~ '^[A-Za-z]{3}-\d{4}$'
                then to_date(trim(invoice_month), 'Mon-YYYY')
            when trim(invoice_month) ~ '^\d{1,2}/\d{1,2}/\d{4}$'
                then to_date(trim(invoice_month), 'MM/DD/YYYY')
            else null
        end as activity_month,

        upper(nullif(trim(facility_id), '')) as facility_id,
        upper(nullif(trim(product_line_id), '')) as product_line_id,

        case
            when lower(trim(material_type)) = 'paper'
                then 'paper'
            when lower(trim(material_type)) = 'plastic'
                then 'plastic'
            when lower(trim(material_type)) = 'glass'
                then 'glass'
            else lower(trim(material_type))
        end as material_type,

        trim(supplier_name) as supplier_name,

        case
            when trim(units_purchased) ~ '^-?\d+(\.\d+)?$'
                then trim(units_purchased)::numeric(18, 4)
            else null
        end as units_purchased,

        case
            when trim(material_weight_kg) ~ '^-?\d+(\.\d+)?$'
                then trim(material_weight_kg)::numeric(18, 4)
            else null
        end as activity_amount,

        'kg' as activity_unit,

        upper(nullif(trim(invoice_number), '')) as invoice_number,

        case
            when trim(cost_usd) ~ '^-?\d+(\.\d+)?$'
                then trim(cost_usd)::numeric(18, 2)
            else null
        end as cost_usd,

        'Scope 3' as scope,

        case
            when lower(trim(material_type)) = 'paper'
                then 'packaging_paper_kg'
            when lower(trim(material_type)) = 'plastic'
                then 'packaging_plastic_kg'
            when lower(trim(material_type)) = 'glass'
                then 'packaging_glass_kg'
            else null
        end as factor_type,

        'packaging_materials' as source_system

    from source
)

select
    *,
    activity_amount < 0 as has_negative_activity,
    facility_id is null as has_missing_facility_id,
    product_line_id is null as has_missing_product_line_id,
    activity_month is null as has_invalid_activity_month,
    factor_type is null as has_unknown_material_type
from cleaned;
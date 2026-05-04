create or replace view int.int_ghg_activity_all as

select
    md5(concat_ws('|', source_system, raw_row_id::text, activity_month::text, facility_id, factor_type)) as activity_id,
    source_system,
    raw_row_id::text as source_record_id,
    activity_month,
    scope,
    facility_id,
    null::text as product_line_id,
    'electricity' as activity_category,
    factor_type,
    activity_amount,
    activity_unit,
    invoice_amount_usd as cost_usd,
    invoice_number as evidence_reference,
    has_negative_activity,
    has_missing_facility_id,
    false as has_missing_product_line_id,
    has_invalid_activity_month,
    false as has_unknown_activity_type
from stg.stg_ghg_electricity_bills

union all

select
    md5(concat_ws('|', source_system, raw_row_id::text, activity_month::text, facility_id, factor_type)) as activity_id,
    source_system,
    raw_row_id::text as source_record_id,
    activity_month,
    scope,
    facility_id,
    null::text as product_line_id,
    fuel_type as activity_category,
    factor_type,
    activity_amount,
    activity_unit,
    cost_usd,
    invoice_number as evidence_reference,
    has_negative_activity,
    has_missing_facility_id,
    false as has_missing_product_line_id,
    has_invalid_activity_month,
    has_unknown_fuel_type as has_unknown_activity_type
from stg.stg_ghg_fuel_usage

union all

select
    md5(concat_ws('|', source_system, raw_row_id::text, shipment_id, activity_month::text, facility_id, product_line_id, factor_type)) as activity_id,
    source_system,
    raw_row_id::text as source_record_id,
    activity_month,
    scope,
    facility_id,
    product_line_id,
    shipping_mode as activity_category,
    factor_type,
    activity_amount,
    activity_unit,
    freight_cost_usd as cost_usd,
    shipment_id as evidence_reference,
    has_negative_activity,
    has_missing_facility_id,
    has_missing_product_line_id,
    shipment_date is null as has_invalid_activity_month,
    has_unknown_shipping_mode as has_unknown_activity_type
from stg.stg_ghg_shipping_miles

union all

select
    md5(concat_ws('|', source_system, raw_row_id::text, activity_month::text, facility_id, product_line_id, factor_type, invoice_number)) as activity_id,
    source_system,
    raw_row_id::text as source_record_id,
    activity_month,
    scope,
    facility_id,
    product_line_id,
    material_type as activity_category,
    factor_type,
    activity_amount,
    activity_unit,
    cost_usd,
    invoice_number as evidence_reference,
    has_negative_activity,
    has_missing_facility_id,
    has_missing_product_line_id,
    has_invalid_activity_month,
    has_unknown_material_type as has_unknown_activity_type
from stg.stg_ghg_packaging_materials;
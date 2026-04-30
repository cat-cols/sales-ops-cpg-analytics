drop table if exists raw.ghg_facility_master cascade;
create table raw.ghg_facility_master (
    facility_id text,
    facility_name text,
    facility_type text,
    city text,
    state_province text,
    country text,
    grid_region text,
    active_flag text,
    opened_date text
);

drop table if exists raw.ghg_product_line_master cascade;
create table raw.ghg_product_line_master (
    product_line_id text,
    product_line_name text,
    product_family text,
    active_flag text
);

drop table if exists raw.ghg_electricity_bills_monthly cascade;
create table raw.ghg_electricity_bills_monthly (
    bill_month text,
    facility_id text,
    facility_name text,
    utility_provider text,
    meter_number text,
    usage_amount text,
    usage_unit text,
    invoice_amount_usd text,
    invoice_number text
);

drop table if exists raw.ghg_fuel_usage_facility cascade;
create table raw.ghg_fuel_usage_facility (
    activity_month text,
    facility_id text,
    fuel_type text,
    activity_amount text,
    activity_unit text,
    vendor_name text,
    invoice_number text,
    cost_usd text
);

drop table if exists raw.ghg_shipping_miles_logistics cascade;
create table raw.ghg_shipping_miles_logistics (
    shipment_id text,
    shipment_date text,
    origin_facility_id text,
    destination_state text,
    product_line_id text,
    shipping_mode text,
    carrier text,
    distance_miles text,
    shipment_weight_lb text,
    ton_miles text,
    freight_cost_usd text
);

drop table if exists raw.ghg_packaging_materials_procurement cascade;
create table raw.ghg_packaging_materials_procurement (
    invoice_month text,
    facility_id text,
    product_line_id text,
    material_type text,
    supplier_name text,
    units_purchased text,
    material_weight_kg text,
    invoice_number text,
    cost_usd text
);

drop table if exists raw.ghg_emission_factors_reference cascade;
create table raw.ghg_emission_factors_reference (
    factor_id text,
    scope text,
    factor_type text,
    region text,
    activity_unit text,
    factor_value_kg_co2e_per_unit text,
    source_authority text,
    effective_start text,
    effective_end text,
    version text,
    is_current text
);

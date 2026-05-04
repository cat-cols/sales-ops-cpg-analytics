select 'raw.ghg_facility_master' as table_name, count(*) as row_count from raw.ghg_facility_master
union all
select 'raw.ghg_product_line_master', count(*) from raw.ghg_product_line_master
union all
select 'raw.ghg_emission_factors_reference', count(*) from raw.ghg_emission_factors_reference
union all
select 'raw.ghg_electricity_bills_monthly', count(*) from raw.ghg_electricity_bills_monthly
union all
select 'raw.ghg_fuel_usage_facility', count(*) from raw.ghg_fuel_usage_facility
union all
select 'raw.ghg_shipping_miles_logistics', count(*) from raw.ghg_shipping_miles_logistics
union all
select 'raw.ghg_packaging_materials_procurement', count(*) from raw.ghg_packaging_materials_procurement
order by table_name;
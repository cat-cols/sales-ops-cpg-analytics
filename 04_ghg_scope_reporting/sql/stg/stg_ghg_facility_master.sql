create or replace view stg.stg_ghg_facility_master as
select
    upper(trim(facility_id)) as facility_id,
    trim(facility_name) as facility_name,
    lower(trim(facility_type)) as facility_type,
    trim(city) as city,
    upper(trim(state_province)) as state_province,
    upper(trim(country)) as country,
    upper(trim(grid_region)) as grid_region,
    case
        when upper(trim(active_flag)) in ('Y', 'YES', 'TRUE', '1') then true
        else false
    end as is_active,
    opened_date::date as opened_date
from raw.ghg_facility_master;
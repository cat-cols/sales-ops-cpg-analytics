create or replace view stg.stg_ghg_emission_factors as
select
    upper(trim(factor_id)) as factor_id,
    initcap(trim(scope)) as scope,
    lower(trim(factor_type)) as factor_type,
    upper(trim(region)) as region,
    lower(trim(activity_unit)) as activity_unit,
    factor_value_kg_co2e_per_unit::numeric(18, 6) as factor_value_kg_co2e_per_unit,
    trim(source_authority) as source_authority,
    effective_start::date as effective_start,
    effective_end::date as effective_end,
    trim(version) as factor_version,
    case
        when upper(trim(is_current)) in ('Y', 'YES', 'TRUE', '1') then true
        else false
    end as is_current
from raw.ghg_emission_factors_reference;
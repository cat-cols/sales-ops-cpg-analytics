create or replace view int.int_ghg_activity_with_factors as
select
    a.activity_id,
    a.source_system,
    a.source_record_id,
    a.activity_month,
    a.scope,
    a.facility_id,
    f.facility_name,
    f.facility_type,
    f.state_province,
    f.country,
    f.grid_region,
    a.product_line_id,
    p.product_line_name,
    p.product_family,
    a.activity_category,
    a.factor_type,
    a.activity_amount,
    a.activity_unit,
    a.cost_usd,
    a.evidence_reference,

    ef.factor_id,
    ef.factor_version,
    ef.source_authority,
    ef.factor_value_kg_co2e_per_unit,

    case
        when a.activity_amount is not null
         and ef.factor_value_kg_co2e_per_unit is not null
         and a.activity_amount >= 0
            then a.activity_amount * ef.factor_value_kg_co2e_per_unit
        else null
    end as kg_co2e,

    case
        when a.activity_amount is not null
         and ef.factor_value_kg_co2e_per_unit is not null
         and a.activity_amount >= 0
            then (a.activity_amount * ef.factor_value_kg_co2e_per_unit) / 1000.0
        else null
    end as metric_tons_co2e,

    a.has_negative_activity,
    a.has_missing_facility_id,
    a.has_missing_product_line_id,
    a.has_invalid_activity_month,
    a.has_unknown_activity_type,

    f.facility_id is null as has_missing_facility_join,
    p.product_line_id is null and a.product_line_id is not null as has_missing_product_line_join,
    ef.factor_id is null as has_missing_factor_join

from int.int_ghg_activity_all a

left join stg.stg_ghg_facility_master f
    on a.facility_id = f.facility_id

left join stg.stg_ghg_product_line_master p
    on a.product_line_id = p.product_line_id

left join stg.stg_ghg_emission_factors ef
    on a.factor_type = ef.factor_type
   and a.activity_unit = ef.activity_unit
   and a.activity_month between ef.effective_start and ef.effective_end
   and (
        case
            when a.scope = 'Scope 2' then f.grid_region
            else 'US'
        end
   ) = ef.region;
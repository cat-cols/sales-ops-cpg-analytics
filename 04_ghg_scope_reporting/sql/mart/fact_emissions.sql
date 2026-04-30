create or replace view mart.fact_emissions as
with base as (
    select
        activity_id,
        source_system,
        source_record_id,
        activity_month,
        scope,

        facility_id,
        facility_name,
        facility_type,
        state_province,
        country,
        grid_region,

        product_line_id,
        product_line_name,
        product_family,

        activity_category,
        factor_type,
        activity_amount,
        activity_unit,
        cost_usd,
        evidence_reference,

        factor_id,
        factor_version,
        source_authority,
        factor_value_kg_co2e_per_unit,

        kg_co2e,
        metric_tons_co2e,

        has_negative_activity,
        has_missing_facility_id,
        has_missing_product_line_id,
        has_invalid_activity_month,
        has_unknown_activity_type,
        has_missing_facility_join,
        has_missing_product_line_join,
        has_missing_factor_join,

        case
            when has_negative_activity
              or has_missing_facility_id
              or has_invalid_activity_month
              or has_unknown_activity_type
              or has_missing_facility_join
              or has_missing_factor_join
                then false
            else true
        end as is_reportable_emissions_row

    from int.int_ghg_activity_with_factors
)

select
    *,

    case
        when has_missing_factor_join then '❌ Missing factor join'
        when has_negative_activity then '⚠️ Negative activity'
        when has_missing_facility_id then '⚠️ Missing facility ID'
        when has_invalid_activity_month then '⚠️ Invalid activity month'
        when has_unknown_activity_type then '⚠️ Unknown activity type'
        when has_missing_facility_join then '⚠️ Missing facility join'
        when has_missing_product_line_join then '⚠️ Missing product line join'
        when is_reportable_emissions_row then '✅ Reportable'
        else '⚠️ Review'
    end as qa_status_label

from base;
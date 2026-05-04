create or replace view mart.kpi_emissions_intensity_monthly as
select
    activity_month,
    scope,
    facility_id,
    facility_name,
    facility_type,
    product_line_id,
    product_line_name,

    count(*) as activity_row_count,
    count(*) filter (where is_reportable_emissions_row) as reportable_row_count,

    round(sum(activity_amount) filter (where is_reportable_emissions_row), 4) as reportable_activity_amount,
    round(sum(kg_co2e) filter (where is_reportable_emissions_row), 4) as kg_co2e,
    round(sum(metric_tons_co2e) filter (where is_reportable_emissions_row), 4) as metric_tons_co2e,
    round(sum(cost_usd) filter (where is_reportable_emissions_row), 2) as cost_usd,

    case
        when sum(cost_usd) filter (where is_reportable_emissions_row) > 0
            then round(
                sum(metric_tons_co2e) filter (where is_reportable_emissions_row)
                / sum(cost_usd) filter (where is_reportable_emissions_row),
                8
            )
        else null
    end as metric_tons_co2e_per_usd

from mart.fact_emissions
group by
    activity_month,
    scope,
    facility_id,
    facility_name,
    facility_type,
    product_line_id,
    product_line_name;
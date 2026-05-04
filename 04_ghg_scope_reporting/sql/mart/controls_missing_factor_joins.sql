create or replace view mart.controls_missing_factor_joins as
select
    source_system,
    scope,
    factor_type,
    activity_unit,
    count(*) as missing_factor_row_count,
    min(activity_month) as first_activity_month,
    max(activity_month) as last_activity_month
from mart.fact_emissions
where has_missing_factor_join
group by
    source_system,
    scope,
    factor_type,
    activity_unit
order by missing_factor_row_count desc;
create or replace view mart.fact_variance_bridge_weekly as
select
    week_start_date,
    channel,
    plan_version,

    sum(forecast_net_sales) as forecast_net_sales,
    sum(volume_effect) as volume_effect,
    sum(price_effect) as price_effect,
    sum(mix_or_residual_effect) as mix_or_residual_effect,
    sum(actual_net_sales) as actual_net_sales,
    sum(total_sales_variance) as total_sales_variance,

    count(*) as row_count,
    count(actual_net_sales) as rows_with_actuals,
    count(*) - count(actual_net_sales) as rows_missing_actuals

from int.int_price_volume_mix_variance
where actual_net_sales is not null
group by
    week_start_date,
    channel,
    plan_version;

select count(*)
from mart.fact_variance_bridge_weekly;
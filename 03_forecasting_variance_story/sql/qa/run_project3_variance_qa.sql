\echo 'Project 3 variance QA checks'

\echo '1. Row count: int.int_price_volume_mix_variance'
select count(*) as row_count
from int.int_price_volume_mix_variance;

\echo '2. Bridge tie-out: int.int_price_volume_mix_variance'
select
    round(sum(total_sales_variance), 2) as total_sales_variance,
    round(sum(volume_effect + price_effect + mix_or_residual_effect), 2) as explained_variance,
    round(
        sum(total_sales_variance)
        - sum(volume_effect + price_effect + mix_or_residual_effect),
        2
    ) as tie_out_difference
from int.int_price_volume_mix_variance
where actual_net_sales is not null;

\echo '3. Bridge tie-out: mart.fact_variance_bridge_weekly'
select
    round(sum(total_sales_variance), 2) as total_sales_variance,
    round(sum(volume_effect + price_effect + mix_or_residual_effect), 2) as bridge_total,
    round(
        sum(total_sales_variance)
        - sum(volume_effect + price_effect + mix_or_residual_effect),
        2
    ) as tie_out_difference
from mart.fact_variance_bridge_weekly;

\echo '4. Missing actual rows by latest weeks'
select
    week_start_date,
    count(*) as total_rows,
    count(actual_net_sales) as rows_with_actuals,
    count(*) - count(actual_net_sales) as rows_missing_actuals
from mart.fact_forecast_vs_actual_weekly
group by 1
order by 1 desc
limit 5;

\echo '5. Variance by business event'
select
    business_event,
    count(*) as row_count,
    round(sum(total_sales_variance), 2) as total_sales_variance,
    round(sum(volume_effect), 2) as volume_effect,
    round(sum(price_effect), 2) as price_effect,
    round(sum(mix_or_residual_effect), 2) as mix_or_residual_effect
from int.int_price_volume_mix_variance
where actual_net_sales is not null
group by 1
order by total_sales_variance;

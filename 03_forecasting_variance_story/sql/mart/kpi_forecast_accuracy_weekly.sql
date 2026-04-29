create or replace view mart.kpi_forecast_accuracy_weekly as
select
    week_start_date,
    channel,
    plan_version,

    sum(forecast_net_sales) as forecast_net_sales,
    sum(actual_net_sales) as actual_net_sales,

    sum(actual_net_sales - forecast_net_sales) as forecast_bias_amount,

    sum(abs(actual_net_sales - forecast_net_sales)) as absolute_sales_error,

    case
        when sum(actual_net_sales) = 0 then null
        else sum(abs(actual_net_sales - forecast_net_sales)) / sum(actual_net_sales)
    end as wape,

    case
        when sum(forecast_net_sales) = 0 then null
        else sum(actual_net_sales - forecast_net_sales) / sum(forecast_net_sales)
    end as bias_pct,

    count(*) as row_count,
    count(actual_net_sales) as rows_with_actuals,
    count(*) - count(actual_net_sales) as rows_missing_actuals

from int.int_forecast_vs_actual_weekly
where actual_net_sales is not null
group by
    week_start_date,
    channel,
    plan_version;


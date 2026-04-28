create or replace view int.int_forecast_vs_actual_weekly as
select
    week_start_date,
    store_code,
    state,
    region,
    sku,
    product_name,
    product_family,
    channel,
    plan_version,

    forecast_units,
    actual_units,

    forecast_net_sales,
    actual_net_sales,

    forecast_unit_price,
    actual_unit_price,

    actual_units - forecast_units as unit_variance,

    actual_net_sales - forecast_net_sales as sales_variance,

    case
        when forecast_net_sales = 0 then null
        else (actual_net_sales - forecast_net_sales) / forecast_net_sales
    end as sales_variance_pct,

    abs(actual_net_sales - forecast_net_sales) as absolute_sales_error,

    case
        when actual_net_sales = 0 then null
        else abs(actual_net_sales - forecast_net_sales) / actual_net_sales
    end as absolute_percent_error,

    case
        when actual_net_sales is null then true
        else false
    end as is_missing_actual,

    is_partial_actual,

    case
        when actual_net_sales is null then 'partial_actual'
        when actual_net_sales > forecast_net_sales then 'above_forecast'
        when actual_net_sales < forecast_net_sales then 'below_forecast'
        else 'on_forecast'
    end as forecast_performance_status,

    promo_flag,
    stockout_flag,
    seasonality_label,
    business_event,

    loaded_at

from stg.stg_forecast_actuals_weekly;
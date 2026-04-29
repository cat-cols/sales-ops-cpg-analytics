create or replace view mart.fact_forecast_vs_actual_weekly as
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
    unit_variance,

    forecast_net_sales,
    actual_net_sales,
    sales_variance,
    sales_variance_pct,

    forecast_unit_price,
    actual_unit_price,

    absolute_sales_error,
    absolute_percent_error,

    forecast_performance_status,
    is_missing_actual,
    is_partial_actual,

    promo_flag,
    stockout_flag,
    seasonality_label,
    business_event,

    loaded_at

from int.int_forecast_vs_actual_weekly;


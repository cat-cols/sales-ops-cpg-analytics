create or replace view int.int_price_volume_mix_variance as
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

    sales_variance as total_sales_variance,

    unit_variance,

    case
        when actual_net_sales is null then null
        else (actual_units - forecast_units) * forecast_unit_price
    end as volume_effect,

    case
        when actual_net_sales is null then null
        else (actual_unit_price - forecast_unit_price) * actual_units
    end as price_effect,

    case
        when actual_net_sales is null then null
        else
            sales_variance
            - ((actual_units - forecast_units) * forecast_unit_price)
            - ((actual_unit_price - forecast_unit_price) * actual_units)
    end as mix_or_residual_effect,

    case
        when actual_net_sales is null then 'partial_actual'
        when stockout_flag = true then 'stockout'
        when promo_flag = true then 'promo'
        when actual_units > forecast_units and actual_unit_price >= forecast_unit_price then 'volume_up'
        when actual_units < forecast_units and actual_unit_price <= forecast_unit_price then 'volume_down'
        when actual_unit_price > forecast_unit_price then 'price_up'
        when actual_unit_price < forecast_unit_price then 'price_down'
        else 'base_business'
    end as primary_variance_driver,

    promo_flag,
    stockout_flag,
    is_partial_actual,
    seasonality_label,
    business_event,
    forecast_performance_status,

    loaded_at

from int.int_forecast_vs_actual_weekly;
-- 03_forecasting_variance_story/sql/raw/01_create_raw_tables.sql

drop table if exists raw.forecast_actuals_weekly cascade;

create table raw.forecast_actuals_weekly (
    week_start_date text,
    store_code text,
    state text,
    region text,
    sku text,
    product_name text,
    product_family text,
    channel text,

    forecast_units text,
    actual_units text,
    forecast_net_sales text,
    actual_net_sales text,
    forecast_unit_price text,
    actual_unit_price text,

    promo_flag text,
    stockout_flag text,
    is_partial_actual text,
    seasonality_label text,
    business_event text,
    plan_version text,

    loaded_at timestamp default current_timestamp
);
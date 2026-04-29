\pset pager off
\timing on

\echo ''
\echo '============================================================'
\echo 'PROJECT 3 PIPELINE START'
\echo 'Forecasting + Variance Story'
\echo '============================================================'
\echo ''

\echo 'Step 1: create schemas'
\ir 00_create_schemas.sql

\echo ''
\echo 'Step 2: create raw tables'
\ir raw/01_create_raw_tables.sql

\echo ''
\echo 'Step 3: load Project 3 source extract into raw table'
\copy raw.forecast_actuals_weekly(week_start_date, store_code, state, region, sku, product_name, product_family, channel, forecast_units, actual_units, forecast_net_sales, actual_net_sales, forecast_unit_price, actual_unit_price, promo_flag, stockout_flag, is_partial_actual, seasonality_label, business_event, plan_version) from '03_forecasting_variance_story/data/source_extracts/forecast_actuals_weekly.csv' with csv header

\echo ''
\echo 'Step 4: build staging view'
\ir stg/stg_forecast_actuals_weekly.sql

\echo ''
\echo 'Step 5: build forecast vs actual integration view'
\ir int/int_forecast_vs_actual_weekly.sql

\echo ''
\echo 'Step 6: build price / volume / mix variance view'
\ir int/int_price_volume_mix_variance.sql

\echo ''
\echo 'Step 7: build forecast vs actual mart'
\ir mart/fact_forecast_vs_actual_weekly.sql

\echo ''
\echo 'Step 8: build variance bridge mart'
\ir mart/fact_variance_bridge_weekly.sql

\echo ''
\echo 'Step 9: build forecast accuracy KPI mart'
\ir mart/kpi_forecast_accuracy_weekly.sql

\echo ''
\echo 'Step 10: run QA checks'
\ir qa/run_project3_variance_qa.sql

\echo ''
\echo '============================================================'
\echo 'PROJECT 3 PIPELINE COMPLETE'
\echo '============================================================'
\echo ''
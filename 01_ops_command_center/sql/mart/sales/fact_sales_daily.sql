-- mart/sales/fact_sales_daily.sql
-- Unified sales fact for manufacturer model consumption.
-- Grain: 1 row per sale_date + store_code + sku + channel + sales_source
--
-- This view unifies B2B, direct, and sell-through sales for the manufacturer model.
-- Replaces the distributor + POS union for the retail model.

create schema if not exists mart;

create or replace view mart.fact_sales_daily as
select
  sale_date,
  store_code,
  sku,
  channel,
  'b2b'::text as sales_source,

  product_name,
  qty,
  gross_sales,
  discount_amount,
  net_sales,
  cogs,
  orders,
  customers,
  unit_list_price_wavg,
  unit_net_price_wavg,
  discount_rate_implied,
  n_source_rows,
  n_dup_candidate_rows,
  max_ingested_at,
  max_drop_date
from mart.fact_sales_b2b_daily

union all

select
  sale_date,
  store_code,
  sku,
  channel,
  'direct'::text as sales_source,

  product_name,
  qty,
  gross_sales,
  discount_amount,
  net_sales,
  cogs,
  orders,
  customers,
  unit_list_price_wavg,
  unit_net_price_wavg,
  discount_rate_implied,
  n_source_rows,
  n_dup_candidate_rows,
  max_ingested_at,
  max_drop_date
from mart.fact_sales_direct_daily

union all

select
  sale_date,
  store_code,
  sku,
  channel,
  'sell_through'::text as sales_source,

  product_name,
  qty,
  gross_sales,
  discount_amount,
  net_sales,
  cogs,
  orders,
  customers,
  unit_list_price_wavg,
  unit_net_price_wavg,
  discount_rate_implied,
  n_source_rows,
  n_dup_candidate_rows,
  max_ingested_at,
  max_drop_date
from mart.fact_sales_sell_through_daily;
;

-- mart/sales/fact_sales_b2b_daily.sql
-- B2B sales fact (manufacturer to wholesalers)
-- Replaces fact_sales_pos_daily for manufacturer model
-- Grain: 1 row per sale_date + store_code + sku + channel
-- Source: int.int_b2b_dedup

create schema if not exists mart;

create or replace view mart.fact_sales_b2b_daily as
with base as (
  select
    sale_date,
    store_code,
    sku,
    channel,

    -- descriptive label (non-key)
    product_name,

    -- measures
    qty,
    gross_sales,
    discount_amount,
    net_sales,
    cogs,
    orders,
    customers,

    -- pricing inputs
    unit_list_price,
    unit_net_price,
    discount_rate,

    -- explainability inputs from INT
    coalesce(dup_group_size, 1) as dup_group_size,

    -- lineage inputs
    ingested_at,
    max_drop_date as drop_date
  from int.int_b2b_dedup
  where sale_date is not null
    and store_code is not null
    and sku is not null
    and channel is not null
),
agg as (
  select
    sale_date,
    store_code,
    sku,
    channel,

    -- descriptive label (use most recent product name)
    max(product_name) as product_name,

    -- measures (aggregated at grain)
    sum(qty) as qty,
    sum(gross_sales) as gross_sales,
    sum(discount_amount) as discount_amount,
    sum(net_sales) as net_sales,
    sum(cogs) as cogs,
    sum(orders) as orders,
    sum(customers) as customers,

    -- pricing (weighted averages)
    sum(gross_sales) / nullif(sum(qty), 0) as unit_list_price_wavg,
    sum(net_sales) / nullif(sum(qty), 0) as unit_net_price_wavg,
    sum(discount_amount) / nullif(sum(gross_sales), 0) as discount_rate_implied,

    -- explainability
    sum(coalesce(dup_group_size, 1)) as n_source_rows,
    sum(greatest(coalesce(dup_group_size, 1) - 1, 0)) as n_dup_candidate_rows,

    -- lineage
    max(ingested_at) as max_ingested_at,
    max(drop_date) as max_drop_date
  from base
  group by
    sale_date,
    store_code,
    sku,
    channel
)
select
  sale_date,
  store_code,
  sku,
  channel,
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
from agg;

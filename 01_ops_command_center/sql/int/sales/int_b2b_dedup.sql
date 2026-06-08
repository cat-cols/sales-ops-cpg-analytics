-- int/int_sales/int_b2b_dedup.sql
-- Deduplicate B2B orders (manufacturer to wholesalers)
-- Replaces int_pos_dedup for manufacturer model
-- Source: stg.stg_b2b_orders
-- Output: int.int_b2b_dedup

create schema if not exists int;

create or replace view int.int_b2b_dedup as
with ranked as (
  select
    b.*,
    row_number() over (
      partition by
        b.txn_id,
        b.sale_date,
        b.store_code_norm,
        b.sku_norm
      order by
        (b.store_code_norm is not null) desc,
        (b.sku_norm is not null) desc,
        (b.sale_date is not null) desc,
        b.ingested_at desc nulls last,
        b.drop_date desc nulls last,
        b.load_id desc nulls last
    ) as rn
  from stg.stg_b2b_orders b
  where b.txn_id is not null
),
dedup as (
  select *
  from ranked
  where rn = 1
),
daily as (
  select
    sale_date,
    store_code_norm as store_code,
    sku_norm as sku,
    channel,

    -- descriptive label
    sku_name as product_name,

    -- measures
    sum(qty) as qty,
    sum(gross_amount) as gross_sales,
    sum(discount_amount) as discount_amount,
    sum(net_amount) as net_sales,
    sum(net_amount * 0.42) as cogs,  -- Approximate COGS

    -- pricing
    avg(unit_price) as unit_list_price,
    avg(unit_price * (1 - discount_rate)) as unit_net_price,
    avg(discount_rate) as discount_rate,

    -- orders/customers
    count(distinct txn_id) as orders,
    count(distinct store_code_norm) as customers,

    -- dedup metadata
    count(*) as n_source_rows,
    count(*) over (partition by sale_date, store_code_norm, sku_norm, channel) as dup_group_size,

    -- lineage
    max(ingested_at) as max_ingested_at,
    max(drop_date) as max_drop_date
  from dedup
  where sale_date is not null
    and store_code_norm is not null
    and sku_norm is not null
    and channel is not null
  group by
    sale_date,
    store_code_norm,
    sku_norm,
    channel,
    sku_name
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
  unit_list_price,
  unit_net_price,
  discount_rate,
  n_source_rows,
  dup_group_size,
  max_ingested_at,
  max_drop_date
from daily;

-- int/int_sales/int_sell_through_dedup.sql
-- Deduplicate sell-through data (wholesaler to retailer)
-- New view for manufacturer model
-- Source: stg.stg_sell_through
-- Output: int.int_sell_through_dedup

create schema if not exists int;

create or replace view int.int_sell_through_dedup as
with ranked as (
  select
    s.*,
    row_number() over (
      partition by
        s.sale_date,
        s.store_code_norm,
        s.sku_norm,
        s.wholesaler_license
      order by
        (s.store_code_norm is not null) desc,
        (s.sku_norm is not null) desc,
        (s.sale_date is not null) desc,
        s.ingested_at desc nulls last,
        s.drop_date desc nulls last,
        s.load_id desc nulls last
    ) as rn
  from stg.stg_sell_through s
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
    sum(gross_sales) as gross_sales,
    sum(discount_amount) as discount_amount,
    sum(net_sales) as net_sales,
    sum(cogs) as cogs,

    -- pricing
    avg(unit_list_price) as unit_list_price,
    avg(unit_net_price) as unit_net_price,
    avg(discount_rate) as discount_rate,

    -- orders/customers
    sum(orders) as orders,
    sum(customers) as customers,

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

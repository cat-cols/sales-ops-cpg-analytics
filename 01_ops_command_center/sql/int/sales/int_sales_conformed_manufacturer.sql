-- 01_ops_command_center/sql/int/sales/int_sales_conformed_manufacturer.sql
-- Phase 3 conformance wrapper for sales - Manufacturer Model
-- Grain: 1 row per sale_date + store_code + sku + channel + sales_source
--
-- Purpose:
-- - Align B2B, direct, and sell-through sales to one shared business-key structure
-- - Enrich sales with conformed store/account context from INT truth tables
-- - Preserve lineage + explainability fields for downstream MART / QA use
--
-- Notes:
-- - This is an INT-layer bridge for the manufacturer model
-- - Replaces int_sales_conformed.sql for manufacturer model
-- - B2B sales: manufacturer to wholesalers
-- - Direct sales: manufacturer to retailers
-- - Sell-through: wholesalers to retailers

create schema if not exists int;

create or replace view int.int_sales_conformed_manufacturer as
with b2b as (
    select
        b.sale_date,
        b.store_code,
        b.sku,
        b.channel,
        'b2b'::text as sales_source,

        b.product_name,

        b.qty::numeric as qty,
        b.gross_sales::numeric as gross_sales,
        b.discount_amount::numeric as discount_amount,
        b.net_sales::numeric as net_sales,
        b.cogs::numeric as cogs,
        b.orders::bigint as orders,
        b.customers::bigint as customers,

        b.unit_list_price::numeric as unit_list_price,
        b.unit_net_price::numeric as unit_net_price,
        b.discount_rate::numeric as discount_rate,

        coalesce(b.dup_group_size, 1)::int as n_source_rows,
        greatest(coalesce(b.dup_group_size, 1) - 1, 0)::int as n_dup_candidate_rows,

        b.max_ingested_at as ingested_at,
        b.max_drop_date as drop_date
    from int.int_b2b_dedup b
    where b.sale_date is not null
      and b.store_code is not null
      and b.sku is not null
      and b.channel is not null
),

direct as (
    select
        d.sale_date,
        d.store_code,
        d.sku,
        d.channel,
        'direct'::text as sales_source,

        d.product_name,

        d.qty::numeric as qty,
        d.gross_sales::numeric as gross_sales,
        d.discount_amount::numeric as discount_amount,
        d.net_sales::numeric as net_sales,
        d.cogs::numeric as cogs,
        d.orders::bigint as orders,
        d.customers::bigint as customers,

        d.unit_list_price::numeric as unit_list_price,
        d.unit_net_price::numeric as unit_net_price,
        d.discount_rate::numeric as discount_rate,

        coalesce(d.dup_group_size, 1)::int as n_source_rows,
        greatest(coalesce(d.dup_group_size, 1) - 1, 0)::int as n_dup_candidate_rows,

        d.max_ingested_at as ingested_at,
        d.max_drop_date as drop_date
    from int.int_direct_dedup d
    where d.sale_date is not null
      and d.store_code is not null
      and d.sku is not null
      and d.channel is not null
),

sell_through as (
    select
        s.sale_date,
        s.store_code,
        s.sku,
        s.channel,
        'sell_through'::text as sales_source,

        s.product_name,

        s.qty::numeric as qty,
        s.gross_sales::numeric as gross_sales,
        s.discount_amount::numeric as discount_amount,
        s.net_sales::numeric as net_sales,
        s.cogs::numeric as cogs,
        s.orders::bigint as orders,
        s.customers::bigint as customers,

        s.unit_list_price::numeric as unit_list_price,
        s.unit_net_price::numeric as unit_net_price,
        s.discount_rate::numeric as discount_rate,

        coalesce(s.dup_group_size, 1)::int as n_source_rows,
        greatest(coalesce(s.dup_group_size, 1) - 1, 0)::int as n_dup_candidate_rows,

        s.max_ingested_at as ingested_at,
        s.max_drop_date as drop_date
    from int.int_sell_through_dedup s
    where s.sale_date is not null
      and s.store_code is not null
      and s.sku is not null
      and s.channel is not null
),

sales_union as (
    select * from b2b
    union all
    select * from direct
    union all
    select * from sell_through
),

product_ranked as (
    select
        d.sku,
        d.product_name,
        row_number() over (
            partition by d.sku
            order by
                d.sale_date desc nulls last,
                d.ingested_at desc nulls last,
                d.drop_date desc nulls last
        ) as rn
    from sales_union d
    where d.sku is not null
      and d.product_name is not null
),

product_lookup as (
    select
        sku,
        product_name
    from product_ranked
    where rn = 1
)

select
    -- conformed business keys
    u.sale_date,
    u.store_code,
    u.sku,
    u.channel,
    u.sales_source,

    -- descriptive attributes
    coalesce(u.product_name, pl.product_name) as product_name,

    -- conformance / QA helpers
    (coalesce(u.product_name, pl.product_name) is null) as is_missing_product_label,

    -- measures
    u.qty,
    u.gross_sales,
    u.discount_amount,
    u.net_sales,
    u.cogs,
    u.orders,
    u.customers,
    u.unit_list_price,
    u.unit_net_price,
    u.discount_rate,

    -- explainability
    u.n_source_rows,
    u.n_dup_candidate_rows,

    -- lineage
    u.ingested_at,
    u.drop_date

from sales_union u
left join product_lookup pl
  on pl.sku = u.sku;

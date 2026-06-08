-- sql/stg/stg_sell_through.sql
-- Sell-through data staging view (wholesaler to retailer)
-- Alternative to stg_sales_distributor for manufacturer model
-- Raw source: raw.sell_through_extract
-- Output: stg.stg_sell_through

create schema if not exists stg;

create or replace view stg.stg_sell_through as
with base as (
    select
        -- lineage
        load_id,
        source_system,
        cadence,
        drop_date,
        ingested_at,

        -- transaction identifiers / timestamps
        sale_date as txn_date,
        sale_date as sale_date,

        -- keys
        retailer_license as store_code_raw,
        trim(retailer_license) as store_code_norm,
        sku as sku_raw,
        trim(sku) as sku_norm,

        -- measures
        quantity_packs as qty_raw,
        quantity_packs as qty,
        retail_price as unit_list_price_raw,
        retail_price as unit_list_price,
        wholesale_price as unit_net_price_raw,
        wholesale_price as unit_net_price,
        discount_rate as discount_rate_raw,
        discount_rate,
        gross_amount as gross_amount_raw,
        gross_amount as gross_sales,
        discount_amount as discount_amount_raw,
        discount_amount,
        net_sales as net_amount_raw,
        net_sales,
        cogs as cogs_raw,
        cogs,

        -- additional fields
        wholesaler_license,
        wholesaler_name,
        retailer_name,
        retailer_county,
        sku_name,
        channel
    from raw.sell_through_extract
),
casted as (
    select
        load_id,
        source_system,
        cadence,
        drop_date,
        ingested_at,

        -- dates
        sale_date::date as sale_date,
        sale_date as sale_date_raw,

        -- keys
        store_code_norm,
        store_code_raw,
        sku_norm,
        sku_raw,

        -- measures (cast to appropriate types)
        qty::numeric as qty,
        qty_raw,
        unit_list_price::numeric as unit_list_price,
        unit_list_price_raw,
        unit_net_price::numeric as unit_net_price,
        unit_net_price_raw,
        discount_rate::numeric as discount_rate,
        discount_rate_raw,
        gross_sales::numeric as gross_sales,
        gross_amount_raw,
        discount_amount::numeric as discount_amount,
        discount_amount_raw,
        net_sales::numeric as net_sales,
        net_amount_raw,
        cogs::numeric as cogs,
        cogs_raw,

        -- additional fields
        wholesaler_license,
        wholesaler_name,
        retailer_name,
        retailer_county,
        sku_name,
        channel,

        -- Default orders/customers
        1 as orders,
        1 as customers
    from base
),
qa_flags as (
    select
        *,
        -- QA flags
        case
            when store_code_norm is null or store_code_norm = '' then 1
            else 0
        end as missing_store_flag,
        case
            when sku_norm is null or sku_norm = '' then 1
            else 0
        end as missing_sku_flag,
        case
            when qty is null or qty <= 0 then 1
            else 0
        end as invalid_qty_flag,
        case
            when unit_list_price is null or unit_list_price <= 0 then 1
            else 0
        end as invalid_price_flag,
        case
            when sale_date is null then 1
            else 0
        end as invalid_date_flag
    from casted
)
select
    load_id,
    source_system,
    cadence,
    drop_date,
    ingested_at,

    -- identifiers
    sale_date,
    sale_date_raw,

    -- keys
    store_code_norm,
    store_code_raw,
    sku_norm,
    sku_raw,

    -- measures
    qty,
    qty_raw,
    unit_list_price,
    unit_list_price_raw,
    unit_net_price,
    unit_net_price_raw,
    discount_rate,
    discount_rate_raw,
    gross_sales,
    gross_amount_raw,
    discount_amount,
    discount_amount_raw,
    net_sales,
    net_amount_raw,
    cogs,
    cogs_raw,

    -- additional fields
    wholesaler_license,
    wholesaler_name,
    retailer_name,
    retailer_county,
    sku_name,
    channel,

    -- orders/customers
    orders,
    customers,

    -- QA flags
    missing_store_flag,
    missing_sku_flag,
    invalid_qty_flag,
    invalid_price_flag,
    invalid_date_flag
from qa_flags;

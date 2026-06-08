-- sql/stg/stg_b2b_orders.sql
-- B2B orders staging view (manufacturer to wholesalers)
-- Replaces stg_pos_transactions for manufacturer model
-- Raw source: raw.b2b_orders_extract
-- Output: stg.stg_b2b_orders

create schema if not exists stg;

create or replace view stg.stg_b2b_orders as
with base as (
    select
        -- lineage
        load_id,
        source_system,
        cadence,
        drop_date,
        ingested_at,

        -- transaction identifiers / timestamps
        order_id as txn_id,
        sale_date as txn_date,
        sale_date as sale_date,

        -- keys
        store_code as store_code_raw,
        trim(store_code) as store_code_norm,
        sku as sku_raw,
        trim(sku) as sku_norm,

        -- measures
        quantity_packs as qty_raw,
        quantity_packs as qty,
        unit_price as unit_price_raw,
        unit_price,
        discount_rate as discount_rate_raw,
        discount_rate,
        gross_sales as gross_amount_raw,
        gross_sales as gross_amount,
        net_sales as net_amount_raw,
        net_sales as net_amount,

        -- additional fields from manufacturer data
        wholesaler_name,
        wholesaler_county,
        sku_name,
        category,
        pack_size,
        channel
    from raw.b2b_orders_extract
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
        unit_price::numeric as unit_price,
        unit_price_raw,
        discount_rate::numeric as discount_rate,
        discount_rate_raw,
        gross_amount::numeric as gross_amount,
        gross_amount_raw,
        net_amount::numeric as net_amount,
        net_amount_raw,

        -- additional fields
        wholesaler_name,
        wholesaler_county,
        sku_name,
        category,
        pack_size,
        channel
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
            when unit_price is null or unit_price <= 0 then 1
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
    txn_id,
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
    unit_price,
    unit_price_raw,
    discount_rate,
    discount_rate_raw,
    gross_amount,
    gross_amount_raw,
    net_amount,
    net_amount_raw,

    -- additional fields
    wholesaler_name,
    wholesaler_county,
    sku_name,
    category,
    pack_size,
    channel,

    -- QA flags
    missing_store_flag,
    missing_sku_flag,
    invalid_qty_flag,
    invalid_price_flag,
    invalid_date_flag
from qa_flags;

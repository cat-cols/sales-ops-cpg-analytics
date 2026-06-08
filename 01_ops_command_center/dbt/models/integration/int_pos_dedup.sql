-- Grain: `txn_id`
-- Rule: pick the "best" row per txn using:
-- * prefer parsed timestamp present
-- * prefer normalized keys present
-- * newest `ingested_at` then `drop_date`

with ranked as (
    select
        p.*,
        row_number() over (
            partition by p.txn_id
            order by
                (p.txn_ts_parsed is not null) desc,
                (p.store_code is not null) desc,
                (p.sku is not null) desc,
                p.ingested_at desc nulls last,
                p.drop_date desc nulls last,
                p.load_id desc nulls last
        ) as rn
    from {{ ref('stg_pos_transactions') }} p
    where p.txn_id is not null
)
select *
from ranked
where rn = 1

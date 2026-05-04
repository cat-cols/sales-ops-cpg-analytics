create or replace view stg.stg_ghg_product_line_master as
select
    upper(trim(product_line_id)) as product_line_id,
    trim(product_line_name) as product_line_name,
    lower(trim(product_family)) as product_family,
    case
        when upper(trim(active_flag)) in ('Y', 'YES', 'TRUE', '1') then true
        else false
    end as is_active
from raw.ghg_product_line_master;
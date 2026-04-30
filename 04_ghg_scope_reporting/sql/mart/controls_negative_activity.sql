create or replace view mart.controls_negative_activity as
select
    source_system,
    scope,
    activity_month,
    facility_id,
    product_line_id,
    activity_category,
    factor_type,
    activity_amount,
    activity_unit,
    evidence_reference
from mart.fact_emissions
where has_negative_activity
order by
    activity_month,
    source_system,
    facility_id;
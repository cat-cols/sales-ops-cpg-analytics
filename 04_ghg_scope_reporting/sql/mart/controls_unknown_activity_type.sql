create or replace view mart.controls_unknown_activity_type as
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
    evidence_reference,

    has_unknown_activity_type,
    has_missing_factor_join,
    qa_status_label

from mart.fact_emissions
where has_unknown_activity_type
order by
    activity_month,
    source_system,
    facility_id,
    activity_category;
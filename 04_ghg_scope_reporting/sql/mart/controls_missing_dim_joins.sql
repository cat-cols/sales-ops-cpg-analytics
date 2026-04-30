drop view if exists mart.controls_missing_dim_joins cascade;
create view mart.controls_missing_dim_joins as
select
    source_system,
    scope,
    activity_month,
    facility_id,
    product_line_id,
    evidence_reference,

    has_missing_facility_join,
    has_missing_product_line_join

from mart.fact_emissions
where has_missing_facility_join
   or has_missing_product_line_join
order by
    activity_month,
    source_system,
    facility_id,
    product_line_id;
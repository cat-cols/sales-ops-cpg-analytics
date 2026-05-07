-- ============================================================
-- Project 4 Traceability Sample Queries
-- GHG Scope Reporting + Audit-Ready Documentation
-- ============================================================
--
-- Purpose:
-- These queries demonstrate how reported emissions can be traced
-- from mart outputs back to source records, evidence references,
-- emission factor versions, and QA/reportability status.
--
-- Run after:
--   1. sql/00_run_project4_pipeline.sql
--   2. scripts/load_project4_raw_tables.py
--   3. sql/qa/_run_qa.sql
-- ============================================================

\pset pager off

\echo '============================================================'
\echo 'Traceability 1: Reportable emissions rows with source and factor evidence'
\echo '============================================================'

select
    activity_id,
    source_system,
    source_record_id,
    evidence_reference,
    activity_month,
    scope,
    facility_id,
    product_line_id,
    activity_category,
    activity_amount,
    activity_unit,
    factor_id,
    factor_version,
    source_authority,
    factor_value_kg_co2e_per_unit,
    metric_tons_co2e,
    is_reportable_emissions_row,
    qa_status_label
from mart.fact_emissions
where is_reportable_emissions_row
order by activity_month, source_system, facility_id
limit 25;


\echo '============================================================'
\echo 'Traceability 2: Non-reportable rows and exclusion reasons'
\echo '============================================================'

select
    activity_id,
    source_system,
    source_record_id,
    evidence_reference,
    activity_month,
    scope,
    facility_id,
    product_line_id,
    activity_category,
    activity_amount,
    activity_unit,
    factor_id,
    factor_version,
    metric_tons_co2e,
    qa_status_label,
    has_negative_activity,
    has_missing_facility_id,
    has_missing_product_line_id,
    has_invalid_activity_month,
    has_unknown_activity_type,
    has_missing_facility_join,
    has_missing_product_line_join,
    has_missing_factor_join
from mart.fact_emissions
where not is_reportable_emissions_row
order by activity_month, source_system, facility_id
limit 25;


\echo '============================================================'
\echo 'Traceability 3: Emissions summarized by factor version'
\echo '============================================================'

select
    scope,
    factor_type,
    activity_unit,
    grid_region,
    factor_id,
    factor_version,
    source_authority,
    count(*) as rows_using_factor,
    round(sum(metric_tons_co2e), 2) as metric_tons_co2e
from mart.fact_emissions
where is_reportable_emissions_row
group by
    scope,
    factor_type,
    activity_unit,
    grid_region,
    factor_id,
    factor_version,
    source_authority
order by
    scope,
    factor_type,
    grid_region,
    factor_version;


\echo '============================================================'
\echo 'Traceability 4: Summarized emissions: source system X activity category'
\echo '============================================================'

select
    source_system,
    scope,
    activity_category,
    activity_unit,
    count(*) as total_rows,
    count(*) filter (where is_reportable_emissions_row) as reportable_rows,
    count(*) filter (where not is_reportable_emissions_row) as non_reportable_rows,
    round(sum(metric_tons_co2e) filter (where is_reportable_emissions_row), 2) as reportable_metric_tons_co2e
from mart.fact_emissions
group by
    source_system,
    scope,
    activity_category,
    activity_unit
order by
    source_system,
    scope,
    activity_category,
    activity_unit;


\echo '============================================================'
\echo 'Traceability 5: Reportable activity row traced end-to-end'
\echo '============================================================'

with sample_activity as (
    select activity_id
    from mart.fact_emissions
    where is_reportable_emissions_row
    order by activity_month, source_system, facility_id
    limit 1
)

select
    fe.activity_id,
    fe.source_system,
    fe.source_record_id,
    fe.evidence_reference,
    fe.activity_month,
    fe.scope,
    fe.facility_id,
    fe.facility_name,
    fe.product_line_id,
    fe.product_line_name,
    fe.activity_category,
    fe.activity_amount,
    fe.activity_unit,
    fe.factor_type,
    fe.factor_id,
    fe.factor_version,
    fe.source_authority,
    fe.factor_value_kg_co2e_per_unit,
    fe.kg_co2e,
    fe.metric_tons_co2e,
    fe.is_reportable_emissions_row,
    fe.qa_status_label
from mart.fact_emissions fe
join sample_activity s
    on fe.activity_id = s.activity_id;


\echo '============================================================'
\echo 'Traceability 6: Unknown activity type exceptions'
\echo '============================================================'

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
from mart.controls_unknown_activity_type
order by
    activity_month,
    source_system,
    facility_id,
    activity_category;


\echo '============================================================'
\echo 'Traceability 7: Duplicate source record control'
\echo '============================================================'

select
    source_system,
    count(*) as duplicate_rows
from mart.controls_duplicate_source_records
group by source_system
order by source_system;


\echo '============================================================'
\echo 'Traceability queries complete'
\echo '============================================================'
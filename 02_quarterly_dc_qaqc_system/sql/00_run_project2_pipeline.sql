-- 02_quarterly_dc_qaqc_system/sql/00_run_project2_pipeline.sql
-- Quarterly Data Collection + QA/QC System

-- A. header / purpose
-- B. psql safety settings
-- C. announce run context
-- D. setup / seed / stage
-- E. run DQ checks
-- F. run reconciliation checks
-- G. build reporting views
-- H. final verification queries

--
-- Purpose:
-- Run the Project 2 quarterly pipeline in the correct order so that
-- staging, DQ checks, reconciliation, and reporting outputs stay in sync.
--
-- Intended order:
-- 1) setup / schema dependencies
-- 2) rule seed maintenance
-- 3) staging layer build
-- 4) first-pass DQ checks
-- 5) reconciliation checks
-- 6) reporting views
-- 7) final verification queries
--
-- Notes:
-- - This is a psql orchestration script.
-- - It assumes required source data has already been generated and loaded.
-- - It should fail immediately if any step errors.


---
---
---

-- 02_quarterly_dc_qaqc_system/sql/00_run_project2_pipeline.sql
-- Quarterly Data Collection + QA/QC System
--
-- A. header / purpose
-- B. psql safety settings
-- C. announce run context
-- D. setup / seed / stage
-- E. run DQ checks
-- F. run reconciliation checks
-- G. build reporting views
-- H. final verification queries

-- ============================================================
-- A. header / purpose
-- ============================================================
--
-- Purpose:
-- Run the Project 2 quarterly pipeline in the correct order so
-- staging, DQ checks, reconciliation, and reporting outputs
-- stay synchronized.
--
-- Intended order:
-- 1) setup / seed / stage
-- 2) run first-pass DQ checks
-- 3) run reconciliation checks
-- 4) build / refresh reporting views
-- 5) run final verification queries
--
-- Notes:
-- - This is a psql orchestration script.
-- - It assumes required source data has already been generated
--   and loaded into the appropriate raw/staging inputs.
-- - It should fail immediately if any step errors.
-- - Run from repo root, for example:
--
--   psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 \
--     -f 02_quarterly_dc_qaqc_system/sql/00_run_project2_pipeline.sql


-- ============================================================
-- B. psql safety settings
-- ============================================================
\set ON_ERROR_STOP on
\pset pager off
\timing on


-- ============================================================
-- C. announce run context
-- ============================================================
\echo ''
\echo '============================================================'
\echo 'PROJECT 2 PIPELINE START'
\echo 'Quarterly Data Collection + QA/QC System'
\echo '============================================================'


-- ============================================================
-- D. setup / seed / stage
-- ============================================================
\echo ''
\echo 'Step D1: seed / maintain DQ rules'
\i 02_quarterly_dc_qaqc_system/sql/dq/02_seed_dq_rules.sql

\echo ''
\echo 'Step D2: build / refresh staging layer'
\echo 'NOTE: replace or expand this section with your actual staging build files.'

-- If you later create a staging build runner, uncomment this:
-- \i 02_quarterly_dc_qaqc_system/sql/stg/_build_stg.sql

-- If you do not yet have a single staging build runner, you can include
-- individual staging files here one by one, for example:
-- \i 02_quarterly_dc_qaqc_system/sql/stg/stg_retail_account_sales_quarterly.sql
-- \i 02_quarterly_dc_qaqc_system/sql/stg/stg_wholesale_account_sales_quarterly.sql
-- \i 02_quarterly_dc_qaqc_system/sql/stg/stg_finance_quarterly_actuals.sql
-- \i 02_quarterly_dc_qaqc_system/sql/stg/stg_inventory_quarterly.sql
-- \i 02_quarterly_dc_qaqc_system/sql/stg/stg_trade_adjustments.sql


-- ============================================================
-- E. run DQ checks
-- ============================================================
\echo ''
\echo 'Step E1: run first-pass DQ checks'
\i 02_quarterly_dc_qaqc_system/sql/dq/03_run_first_pass_checks.sql


-- ============================================================
-- F. run reconciliation checks
-- ============================================================
\echo ''
\echo 'Step F1: run reconciliation checks'
\i 02_quarterly_dc_qaqc_system/sql/dq/04_run_reconciliation_checks.sql


-- ============================================================
-- G. build reporting views
-- ============================================================
\echo ''
\echo 'Step G1: build / refresh reporting views'
\echo 'NOTE: replace or expand this section with your actual reporting build files.'

-- If you later create a single reporting build runner, uncomment this:
-- \i 02_quarterly_dc_qaqc_system/sql/reporting/_build_reporting.sql

-- Otherwise include your view files individually:
-- \i 02_quarterly_dc_qaqc_system/sql/reporting/vw_dq_scorecard.sql
-- \i 02_quarterly_dc_qaqc_system/sql/reporting/vw_open_exceptions.sql
-- \i 02_quarterly_dc_qaqc_system/sql/reporting/vw_reconciliation_summary.sql
-- \i 02_quarterly_dc_qaqc_system/sql/reporting/certified_quarterly_reporting.sql

\echo ''
\echo 'Step G2: run reporting demo / sample output queries'
\i 02_quarterly_dc_qaqc_system/sql/reporting/00_run_reporting_views.sql


-- ============================================================
-- H. final verification queries
-- ============================================================
\echo ''
\echo 'Step H1: latest run log rows'

select
    run_id,
    quarter_id,
    run_by,
    source_batch_name,
    rules_version,
    run_status,
    run_ts
from dq.dq_run_log
order by run_id desc
limit 5;

\echo ''
\echo 'Step H2: latest DQ result rows'

select
    run_id,
    quarter_id,
    rule_id,
    target_table,
    checked_count,
    failed_count,
    failed_pct,
    status
from dq.dq_results_fact
where run_id = (select max(run_id) from dq.dq_run_log)
order by rule_id, target_table;

\echo ''
\echo 'Step H3: latest open exceptions'

select
    quarter_id,
    rule_name,
    severity,
    assigned_team,
    target_table,
    record_key,
    issue_value,
    issue_description
from reporting.vw_open_exceptions
order by assigned_team, rule_name, record_key;

\echo ''
\echo 'Step H4: reconciliation summary'

select
    quarter_id,
    recon_name,
    metric_name,
    left_value,
    right_value,
    variance_value,
    variance_pct,
    tolerance_pct,
    status
from reporting.vw_reconciliation_summary
order by quarter_id, recon_name;

\echo ''
\echo 'Step H5: certification output'

select *
from reporting.certified_quarterly_reporting
order by quarter_id;

\echo ''
\echo '============================================================'
\echo 'PROJECT 2 PIPELINE COMPLETE'
\echo '============================================================'


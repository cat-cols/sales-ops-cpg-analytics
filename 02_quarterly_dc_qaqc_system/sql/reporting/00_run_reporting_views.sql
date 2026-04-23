-- sql/reporting/00_run_reporting_views.sql
-- Purpose: run final reporting queries for Project 2 demo / review

select *
from reporting.vw_dq_scorecard
order by severity desc, rule_name;

select *
from reporting.vw_open_exceptions
order by assigned_team, severity desc, rule_name, record_key;

select *
from reporting.vw_reconciliation_summary
order by created_at desc;

select *
from reporting.certified_quarterly_reporting
order by quarter_id;
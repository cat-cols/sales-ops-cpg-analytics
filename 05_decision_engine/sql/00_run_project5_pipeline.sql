\pset pager off
\timing on

\echo ''
\echo '============================================================'
\echo 'DECISION ENGINE: PIPELINE START'
\echo '============================================================'

\echo ''
\echo 'Step 1: build decision mart layer'
\ir mart/_build_decision_mart.sql

\echo ''
\echo 'Step 2: run QA checks'
\ir _qa/_run_qa.sql

\echo ''
\echo '============================================================'
\echo 'DECISION ENGINE: PIPELINE COMPLETE'
\echo '============================================================'
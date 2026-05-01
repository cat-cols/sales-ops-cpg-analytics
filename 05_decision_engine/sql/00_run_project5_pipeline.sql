\pset pager off
\timing on

\echo ''
\echo '============================================================'
\echo 'PROJECT 5 PIPELINE START'
\echo 'Decision Engine'
\echo '============================================================'

\echo ''
\echo 'Step 1: build decision mart layer'
\ir mart/_build_decision_mart.sql

\echo ''
\echo '============================================================'
\echo 'DECISION ENGINE PIPELINE COMPLETE'
\echo '============================================================'
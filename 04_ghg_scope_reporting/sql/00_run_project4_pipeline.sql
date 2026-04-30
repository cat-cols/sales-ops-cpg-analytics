\pset pager off
\timing on

\echo '============================================================'
\echo 'PROJECT 4 PIPELINE START'
\echo 'GHG Scope Reporting + Audit-Ready Documentation'
\echo '============================================================'

\echo 'Step 1: create schemas'
\ir 00_create_schemas.sql

\echo 'Step 2: create raw landing tables'
\ir raw/01_create_raw_tables.sql

\echo 'Step 3: build staging views'
\ir stg/_build_stg.sql

\echo 'Step 4: build intermediate conformance views'
\ir int/_build_int.sql

\echo 'Step 5: build mart views'
\ir mart/_build_mart.sql

\echo '============================================================'
\echo 'GHG SCOPE REPORTING PIPELINE COMPLETE'
\echo '============================================================'
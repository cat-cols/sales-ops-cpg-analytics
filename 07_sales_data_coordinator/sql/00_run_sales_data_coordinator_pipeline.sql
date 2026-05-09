\echo '============================================================'
\echo 'Sales Data Coordinator — Order Lifecycle System'
\echo '============================================================'

\echo 'Creating schemas...'
\ir 00_create_schemas.sql

\echo 'Pipeline scaffold complete.'
\echo 'Next steps: raw tables, source extracts, staging views, QA checks, and marts.'
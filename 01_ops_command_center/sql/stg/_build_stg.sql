\pset pager off

\echo ''
\echo '=============================='
\echo ' BUILD: STG'
\echo '=============================='
\echo ''

\i 01_ops_command_center/sql/stg/00_create_schemas.sql

\echo ''
\echo '--- STG ---'

-- Manufacturer model staging views
\i 01_ops_command_center/sql/stg/stg_b2b_orders.sql
\i 01_ops_command_center/sql/stg/stg_direct_sales.sql
\i 01_ops_command_center/sql/stg/stg_sell_through.sql

-- Legacy staging views (updated for manufacturer model)
\i 01_ops_command_center/sql/stg/stg_account_status.sql
\i 01_ops_command_center/sql/stg/stg_dispensary_master.sql
\i 01_ops_command_center/sql/stg/stg_sku_distribution_status.sql
\i 01_ops_command_center/sql/stg/stg_sales_distributor.sql
\i 01_ops_command_center/sql/stg/stg_inventory_erp.sql
\i 01_ops_command_center/sql/stg/stg_wms_shipments.sql
\i 01_ops_command_center/sql/stg/stg_timeclock_punches.sql
\i 01_ops_command_center/sql/stg/stg_labor_payroll.sql
\i 01_ops_command_center/sql/stg/stg_finance_actuals.sql

-- Legacy POS view (kept for reference, not used in manufacturer model)
-- \i 01_ops_command_center/sql/stg/stg_pos_transactions.sql

\echo ''
\echo '✅ BUILD STG COMPLETE'
\echo ''
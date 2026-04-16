-- 02_quarterly_dc_qaqc_system/sql/00_create_schemas.sql

-- Create schemas for the quarterly DC QA/QC system
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dq;
CREATE SCHEMA IF NOT EXISTS reporting;

-- CREATE SCHEMA IF NOT EXISTS audit;

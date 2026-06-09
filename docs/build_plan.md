# Order of Operations

## Purpose
This document defines the recommended build sequence for Project 2 — Quarterly Data Collection + QA/QC System. The goal is to build the project in a logical order so that source intake, validation, reconciliation, and certified reporting all rest on a clear operational foundation.

## Build principles
- Build process controls before downstream reporting.
- Define source expectations before writing validation logic.
- Standardize raw submissions before running DQ rules.
- Store both summary-level and record-level QA results.
- Publish certified outputs only after validation and reconciliation checks are complete.

## Phase 1 — Project scaffold and source definition
**Objective:** establish scope, source expectations, and repo structure.

### Tasks
1. Finalize project scope and business problem statement.
2. Define in-scope sources and expected business grains.
3. Create the source register.
4. Create the repo folder structure for `docs/`, `sql/`, `data/`, and `powerbi/`.
5. Add the initial project README.

### Main outputs
- `README.md`
- `docs/in_scope_sources.md`
- `docs/source_register.md`

---

## Phase 2 — Schema and intake framework
**Objective:** create the database structure and submission-tracking process.

### Tasks
1. Create schemas:
   - `raw`
   - `ops`
   - `stg`
   - `dq`
   - `reporting`
2. Create the intake submission log table.
3. Seed the intake log with expected quarterly source submissions.
4. Define submission statuses and certification states.

### Main outputs
- `sql/00_create_schemas.sql`
- `sql/ops/01_create_intake_submission_log.sql`
- `sql/ops/02_seed_intake_submission_log.sql`

---

## Phase 3 — Raw source simulation
**Objective:** create realistic quarterly source files with intentional data quality problems.

### Tasks
1. Create sample quarterly source extracts.
2. Introduce realistic issues:
   - missing keys
   - duplicates
   - missing weeks
   - negative values
   - wrong template version
   - stale submissions
   - reconciliation mismatches
3. Store source files under `data/source_extracts/`.

### Main outputs
- `data/source_extracts/retail_account_sales_quarterly_extract.csv`
- `data/source_extracts/wholesale_account_sales_quarterly_extract.csv`
- `data/source_extracts/finance_quarterly_actuals.csv`
- `data/source_extracts/inventory_quarterly_extract.csv`
- `data/source_extracts/trade_adjustments_extract.csv`

---

## Phase 4 — Staging layer
**Objective:** standardize each source into typed, predictable structures.

### Tasks
1. Create raw load targets or assumptions for landed files.
2. Build staging views or tables for each source.
3. Standardize:
   - column names
   - data types
   - date fields
   - casing/whitespace
   - numeric fields
4. Preserve source traceability where useful.

### Main outputs
- `sql/stg/stg_retail_account_sales_quarterly.sql`
- `sql/stg/stg_wholesale_account_sales_quarterly.sql`
- `sql/stg/stg_finance_quarterly_actuals.sql`
- `sql/stg/stg_inventory_quarterly.sql`
- `sql/stg/stg_trade_adjustments.sql`

---

## Phase 5 — DQ framework tables
**Objective:** create the persistent structures used to store rule definitions and validation results.

### Tasks
1. Create the DQ rules table.
2. Create the DQ run log table.
3. Create the DQ results fact table.
4. Create the DQ exceptions detail table.
5. Create the reconciliation results table.
6. Add basic indexes and keys where appropriate.

### Main outputs
- `sql/dq/01_create_dq_tables.sql`

---

## Phase 6 — Seed the governed rule catalog
**Objective:** define the first production-style rule set for quarterly intake validation.

### Tasks
1. Seed completeness rules.
2. Seed uniqueness rules.
3. Seed validity rules.
4. Seed timeliness rules.
5. Seed reconciliation rules.
6. Document severity, threshold, logic, and owner team.

### Main outputs
- `sql/dq/02_seed_dq_rules.sql`
- `docs/dq_rules_catalog.md`

---

## Phase 7 — Validation logic and exception generation
**Objective:** run rules against staged data and persist both summary failures and record-level issues.

### Tasks
1. Write SQL checks for the first rule set.
2. Insert run metadata into `dq.dq_run_log`.
3. Insert summary results into `dq.dq_results_fact`.
4. Insert record-level failures into `dq.dq_exceptions_detail`.
5. Verify that each failed rule produces usable exception output.

### Main outputs
- `sql/dq/03_run_completeness_checks.sql`
- `sql/dq/04_run_uniqueness_checks.sql`
- `sql/dq/05_run_validity_checks.sql`
- `sql/dq/06_run_timeliness_checks.sql`

---

## Phase 8 — Reconciliation layer
**Objective:** compare related sources and quantify mismatches.

### Tasks
1. Define reconciliation logic for Sales vs Finance.
2. Define reconciliation logic for adjustments vs net revenue bridge.
3. Insert recon results into `dq.recon_results`.
4. Set pass/fail thresholds and tolerance logic.

### Main outputs
- `sql/recon/01_reconcile_sales_to_finance.sql`
- `sql/recon/02_reconcile_adjustments_to_finance.sql`
- `docs/reconciliation_guide.md`

---

## Phase 9 — Certified reporting layer
**Objective:** publish cleaned, approved outputs for business reporting.

### Tasks
1. Define the certified reporting dataset.
2. Exclude or flag non-certified records as needed.
3. Create scorecard-friendly reporting views.
4. Add status logic so stakeholders can distinguish certified vs uncertified data.

### Main outputs
- `sql/reporting/01_create_certified_quarterly_reporting.sql`
- `sql/reporting/02_create_vw_dq_scorecard.sql`
- `sql/reporting/03_create_vw_reconciliation_summary.sql`

---

## Phase 10 — Documentation and governance artifacts
**Objective:** make the project understandable and operationally credible.

### Tasks
1. Write the quarterly data collection playbook.
2. Document rule ownership and escalation flow.
3. Add release notes for rule changes and threshold changes.
4. Document known limitations and future improvements.

### Main outputs
- `docs/quarterly_data_collection_playbook.md`
- `docs/release_notes.md`

---

## Phase 11 — Power BI mockup and reporting layer
**Objective:** demonstrate how the QA/QC system would be consumed by stakeholders.

### Tasks
1. Mock the Data Quality Monitor page.
2. Mock the Exceptions dashboard.
3. Mock the Reconciliation summary page.
4. Add measure notes and page descriptions.

### Main outputs
- `powerbi/mockups/data_quality_monitor.md`
- `powerbi/mockups/exceptions_dashboard.md`
- `powerbi/mockups/reconciliation_summary.md`

---

## Recommended build sequence summary
1. Define source scope and source register.
2. Create schemas.
3. Create intake submission log and seed expected submissions.
4. Create sample messy source files.
5. Build staging layer.
6. Create DQ framework tables.
7. Seed the DQ rule catalog.
8. Implement validation and exception logging.
9. Build reconciliation logic.
10. Publish certified reporting outputs.
11. Finish governance docs and BI mockups.

## Milestone checkpoints

### Milestone 1 — Scaffold
- Scope defined
- Source register complete
- Schemas created
- Intake log created

### Milestone 2 — DQ framework
- DQ tables created
- Rule catalog seeded
- Sample source files loaded

### Milestone 3 — QA execution
- Rules run successfully
- Exceptions generated
- Recon logic working

### Milestone 4 — Reporting-ready
- Certified dataset published
- DQ scorecard available
- Documentation complete

## Notes
This project should remain distinct from Project 1. Project 2 is primarily about intake operations, validation, reconciliation, certification, and governance rather than a broad cross-functional KPI mart.
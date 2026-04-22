# Project 2 — Quarterly Data Collection + QA/QC System

## Project summary

Build a governed quarterly reporting intake process that receives departmental submissions, validates them against governed business rules, logs remediation-ready exceptions, reconciles operational totals to finance, and publishes reporting-ready QA/QC outputs for downstream reporting.

Unlike Project 1, which focuses on cross-functional KPI modeling and analytics consumption, Project 2 focuses on the operational discipline of collecting, standardizing, validating, reconciling, and certifying quarterly business data before it is trusted for reporting.

## What this project proves

* You can manage a structured quarterly data collection process across multiple business teams.
* You can land messy departmental submissions into raw tables and preserve source defects for downstream QA.
* You can standardize inconsistent submissions into typed staging views.
* You can formalize validation logic in a governed rules catalog.
* You can persist run metadata, rule-level scorecard results, detailed exceptions, and reconciliation outputs.
* You can create stakeholder-facing reporting views for scorecards, open exceptions, and reconciliations.
* You can support repeatable quarterly certification with documented remediation and release-note workflows.

## Business problem

Quarterly reporting often depends on files submitted by different teams using inconsistent templates, incomplete keys, inconsistent timing, and conflicting business logic. Common problems include missing required fields, duplicate business-grain rows, out-of-period dates, invalid quantities, unexplained revenue adjustments, and mismatches between operational reporting and finance actuals. These issues delay reporting cycles, increase manual cleanup, and reduce trust in the final numbers.

## Target outcome

Create a repeatable quarterly QA/QC workflow that:

1. tracks submissions and intake status,
2. lands raw source submissions without prematurely correcting source defects,
3. standardizes departmental extracts into typed staging views,
4. applies governed validation rules and logs failures,
5. produces an open exceptions queue for remediation,
6. reconciles operational sales totals to finance net revenue,
7. exposes reporting-ready summary views,
8. supports certification decisions for the reporting cycle.

## Current implementation status

Implemented in the current build:

* raw landing tables for all in-scope submissions,
* staging views for all in-scope submissions,
* governed DQ rules catalog and run metadata tables,
* first-pass completeness checks,
* first-pass uniqueness checks,
* first-pass validity checks,
* first-pass sales-to-finance reconciliation,
* reporting views for DQ scorecard, open exceptions, and reconciliation summary.

## In-scope sources

Simulated source submissions currently implemented:

* `retail_account_sales_quarterly_extract.csv`
* `wholesale_account_sales_quarterly_extract.csv`
* `finance_quarterly_actuals.csv`
* `inventory_quarterly_extract.csv`
* `trade_adjustments_extract.csv`

## Realistic issues simulated

* Missing required keys
* Duplicate business-grain rows
* Out-of-period dates
* Missing weeks inside the quarter
* Negative inventory quantities
* Missing adjustment reason codes
* Suspicious wholesale net-to-gross relationships
* Late or invalid submission scenarios via intake metadata
* Cross-source mismatch between operational sales and finance net revenue
* Blank required fields and source irregularities

## Implemented architecture

### Landing / intake

Store raw submissions and intake metadata.

**Core objects**

* `raw.retail_account_sales_quarterly_extract`
* `raw.wholesale_account_sales_quarterly_extract`
* `raw.finance_quarterly_actuals`
* `raw.inventory_quarterly_extract`
* `raw.trade_adjustments_extract`
* `ops.intake_submission_log`

### Standardization

Create typed, predictable staging views while preserving source defects needed for QA.

**Core objects**

* `stg.stg_retail_account_sales_quarterly`
* `stg.stg_wholesale_account_sales_quarterly`
* `stg.stg_finance_quarterly_actuals`
* `stg.stg_inventory_quarterly`
* `stg.stg_trade_adjustments`

### QA/QC framework

Persist rule definitions, run metadata, summary results, detailed exceptions, and reconciliation outputs.

**Core objects**

* `dq.dq_rules`
* `dq.dq_run_log`
* `dq.dq_results_fact`
* `dq.dq_exceptions_detail`
* `dq.recon_results`

### Reporting layer

Publish dashboard-friendly outputs for scorecards, remediation, and reconciliation review.

**Core objects**

* `reporting.vw_dq_scorecard`
* `reporting.vw_open_exceptions`
* `reporting.vw_reconciliation_summary`
* `reporting.certified_quarterly_reporting` *(planned)*

## Core table designs

### `ops.intake_submission_log`

Tracks file receipt, versioning, and intake status.

| Column              | Type      | Purpose                                                    |
| ------------------- | --------- | ---------------------------------------------------------- |
| `submission_id`     | bigint    | Unique intake record                                       |
| `quarter_id`        | text      | Reporting period identifier (e.g. `2026Q1`)                |
| `department_name`   | text      | Submitting team or domain                                  |
| `source_file_name`  | text      | Raw file name received                                     |
| `template_version`  | text      | Submitted template version                                 |
| `submitted_by`      | text      | File owner or sender                                       |
| `submitted_at`      | timestamp | Submission timestamp                                       |
| `expected_by`       | timestamp | Due date/time                                              |
| `received_flag`     | boolean   | Whether a submission was received                          |
| `schema_valid_flag` | boolean   | Whether required columns were present                      |
| `qa_status`         | text      | Intake status (`pending`, `failed`, `passed`, `certified`) |
| `certified_flag`    | boolean   | Whether source is approved for reporting                   |
| `notes`             | text      | Intake comments                                            |

### `dq.dq_rules`

Governed rules catalog.

| Column                 | Type         | Purpose                                                        |
| ---------------------- | ------------ | -------------------------------------------------------------- |
| `rule_id`              | bigint       | Unique rule key                                                |
| `rule_name`            | text         | Short business-friendly rule name                              |
| `rule_category`        | text         | Completeness, uniqueness, validity, timeliness, reconciliation |
| `target_table`         | text         | Table the rule runs against                                    |
| `target_column`        | text         | Primary or relevant columns under test                         |
| `severity`             | text         | `critical`, `high`, `medium`, `low`                            |
| `threshold_pct`        | numeric(8,4) | Failure tolerance                                              |
| `logic_description`    | text         | Plain-English rule description                                 |
| `business_rationale`   | text         | Why the rule matters                                           |
| `owner_team`           | text         | Responsible team                                               |
| `active_flag`          | boolean      | Whether rule is active                                         |
| `effective_start_date` | date         | Start date for rule version                                    |
| `effective_end_date`   | date         | End date for rule version                                      |

### `dq.dq_run_log`

Validation-run metadata.

| Column              | Type      | Purpose                          |
| ------------------- | --------- | -------------------------------- |
| `run_id`            | bigint    | Validation run identifier        |
| `quarter_id`        | text      | Quarter being processed          |
| `run_ts`            | timestamp | Execution timestamp              |
| `run_by`            | text      | User or process name             |
| `source_batch_name` | text      | Batch label for intake group     |
| `rules_version`     | text      | Rule-set version applied         |
| `run_status`        | text      | `started`, `completed`, `failed` |

### `dq.dq_results_fact`

Rule-level failure summary for scorecards.

| Column          | Type         | Purpose                   |
| --------------- | ------------ | ------------------------- |
| `run_id`        | bigint       | Validation run identifier |
| `quarter_id`    | text         | Quarter being processed   |
| `rule_id`       | bigint       | Rule executed             |
| `target_table`  | text         | Evaluated table           |
| `checked_count` | bigint       | Records evaluated         |
| `failed_count`  | bigint       | Records failing           |
| `failed_pct`    | numeric(8,4) | Percent failed            |
| `severity`      | text         | Rule severity             |
| `status`        | text         | `pass`, `warn`, `fail`    |
| `created_at`    | timestamp    | Insert timestamp          |

### `dq.dq_exceptions_detail`

Record-level issue queue for remediation.

| Column               | Type      | Purpose                                     |
| -------------------- | --------- | ------------------------------------------- |
| `run_id`             | bigint    | Validation run identifier                   |
| `quarter_id`         | text      | Quarter being processed                     |
| `rule_id`            | bigint    | Triggered rule                              |
| `target_table`       | text      | Source table                                |
| `record_key`         | text      | Business key or composite identifier        |
| `issue_value`        | text      | Problematic value                           |
| `issue_description`  | text      | Plain-English issue summary                 |
| `assigned_team`      | text      | Team to remediate                           |
| `remediation_status` | text      | `open`, `in_progress`, `resolved`, `waived` |
| `comment`            | text      | Notes                                       |
| `created_at`         | timestamp | Insert timestamp                            |
| `resolved_at`        | timestamp | Resolution timestamp                        |

### `dq.recon_results`

Cross-source tie-out summary.

| Column           | Type          | Purpose                     |
| ---------------- | ------------- | --------------------------- |
| `run_id`         | bigint        | Validation run identifier   |
| `quarter_id`     | text          | Quarter being processed     |
| `recon_name`     | text          | Name of reconciliation test |
| `left_source`    | text          | First source                |
| `right_source`   | text          | Second source               |
| `metric_name`    | text          | Metric being compared       |
| `left_value`     | numeric(18,2) | Left-side total             |
| `right_value`    | numeric(18,2) | Right-side total            |
| `variance_value` | numeric(18,2) | Difference                  |
| `variance_pct`   | numeric(8,4)  | Percent difference          |
| `tolerance_pct`  | numeric(8,4)  | Allowed threshold           |
| `status`         | text          | `pass`, `fail`, `warn`      |
| `created_at`     | timestamp     | Insert timestamp            |

## Current implemented rule families

### Completeness

* Required key present - retail sales
* Required key present - wholesale sales
* Required key present - inventory
* Weekly continuity by source - retail sales *(cataloged; execution expansion planned)*

### Uniqueness

* No duplicate business grain - retail sales
* No duplicate business grain - wholesale sales
* No duplicate business grain - inventory

### Validity

* Quarter dates within expected range - retail sales
* Quarter dates within expected range - trade adjustments
* No negative quantity - inventory
* Negative trade adjustments require valid reason code
* Margin percent within tolerance *(cataloged; execution expansion planned)*

### Timeliness

* Approved template version submitted *(cataloged; execution expansion planned)*
* Submission timeliness against due date *(cataloged; execution expansion planned)*

### Reconciliation

* Sales vs Finance reconciliation within tolerance

## Example business grains

* Retail sales: one row per `quarter_id + week_end_date + dispensary_account_id + sku_id`
* Wholesale sales: one row per `quarter_id + week_end_date + wholesale_account_id + sku_id`
* Finance: one row per `quarter_id + account_code + department_code`
* Inventory: one row per `quarter_id + week_end_date + warehouse_id + sku_id`
* Trade adjustments: one row per `quarter_id + adjustment_id`

## Operating workflow

1. Receive quarterly source submissions and log expected files.
2. Land source files into `raw` tables without prematurely correcting defects.
3. Standardize the landed data into typed `stg` views.
4. Run first-pass DQ checks via `sql/dq/03_run_first_pass_checks.sql`.
5. Run reconciliation checks via `sql/dq/04_run_reconciliation_checks.sql`.
6. Review `reporting.vw_dq_scorecard` for rule-level failures.
7. Review `reporting.vw_open_exceptions` for team-assigned remediation items.
8. Review `reporting.vw_reconciliation_summary` for quarter-level tie-outs.
9. Resolve, waive, or document exceptions as needed.
10. Publish certified reporting outputs once the quarter is approved.

## Reporting outputs

### `reporting.vw_dq_scorecard`

Latest-run rule summary for scorecards and monitoring.

### `reporting.vw_open_exceptions`

Latest-run unresolved issues for remediation workflow.

### `reporting.vw_reconciliation_summary`

Latest-run reconciliation output for finance tie-out review.

## Power BI page plan

### 1. Data Quality Monitor

* overall pass rate
* critical rule failures
* failed records by source
* failed records by severity
* certification status by department

### 2. Exceptions dashboard

* unresolved issues by rule
* unresolved issues by department
* aging buckets
* detailed exceptions table

### 3. Reconciliation summary

* Sales vs Finance comparisons
* tolerance bands
* quarter-over-quarter variance views
* unresolved recon failures

### 4. Release notes

* rules added
* thresholds changed
* known limitations
* quarter-specific decisions or waivers

## Documentation deliverables

* `README.md`
* `docs/quarterly_data_collection_playbook.md`
* `docs/dq_rules_catalog.md`
* `docs/reconciliation_guide.md`
* `docs/release_notes.md`

## Known limitations

* Source data is simulated for portfolio purposes.
* Current reporting views emphasize latest-run state rather than full run history.
* Rule coverage is first-pass and not yet exhaustive for all cataloged rules.
* Certification logic is partly procedural and not yet fully materialized as a dedicated reporting object.
* Rule catalog hygiene may still require cleanup where older manual inserts created duplicate rule rows.

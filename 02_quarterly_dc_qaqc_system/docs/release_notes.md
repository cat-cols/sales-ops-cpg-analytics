# Release Notes

## Purpose

This document records meaningful changes to the Quarterly Data Collection + QA/QC System as the project evolves from initial framework setup into a working governed validation and reconciliation workflow.

The goal of these notes is to make it easy to understand:
- what changed,
- why the change matters,
- what business capability was added,
- and what follow-up work remains.

---

## Versioning Approach

This project uses lightweight milestone-based versioning rather than formal software release packaging.

Each release note entry groups a meaningful project milestone, such as:
- framework setup,
- first-pass rule execution,
- reconciliation logic,
- reporting views,
- documentation and process guidance.

---

## Releases

### v0.1 — Initial framework setup
**Status:** Completed

**Summary**
Established the core Quarterly Data Collection + QA/QC System structure.

**Changes included**
- Created project schemas for `raw`, `ops`, `stg`, `dq`, and `reporting`.
- Added raw landing tables for in-scope quarterly source submissions.
- Added staging views for retail sales, wholesale sales, finance actuals, inventory, and trade adjustments.
- Created governed QA/QC framework tables:
  - `dq.dq_rules`
  - `dq.dq_run_log`
  - `dq.dq_results_fact`
  - `dq.dq_exceptions_detail`
  - `dq.recon_results`

**Business impact**
Established the structural foundation needed to standardize quarterly submissions and persist QA/QC results in a governed way.

---

### v0.2 — First-pass DQ execution
**Status:** Completed

**Summary**
Implemented the first working rule-execution workflow with persisted summary results and detailed remediation-ready exceptions.

**Changes included**
- Added first-pass completeness checks for:
  - retail sales
  - wholesale sales
  - inventory
- Added first-pass uniqueness checks for:
  - retail sales
  - wholesale sales
  - inventory
- Added first-pass validity checks for:
  - retail quarter dates
  - trade-adjustment quarter dates
  - negative inventory quantity
  - negative trade adjustments missing reason code
- Added run logging via `dq.dq_run_log`.
- Added rule-level scorecard output via `dq.dq_results_fact`.
- Added record-level exception tracking via `dq.dq_exceptions_detail`.

**Business impact**
The process can now detect and persist high-value data quality failures rather than relying on ad hoc manual review.

---

### v0.3 — Reconciliation and reporting views
**Status:** Completed

**Summary**
Added first-pass cross-source reconciliation and business-facing reporting outputs.

**Changes included**
- Added `sql/dq/04_run_reconciliation_checks.sql`.
- Implemented `Sales vs Finance reconciliation within tolerance`.
- Added reconciliation storage in `dq.recon_results`.
- Added reporting views:
  - `reporting.vw_dq_scorecard`
  - `reporting.vw_open_exceptions`
  - `reporting.vw_reconciliation_summary`

**Business impact**
The project now supports both rule-based QA review and quarter-level finance tie-out review through reporting-friendly outputs.

---

### v0.4 — Documentation package
**Status:** In progress

**Summary**
Documented the operating workflow, rules, and reconciliation logic to support reuse and stakeholder review.

**Changes included**
- Added or began adding:
  - `docs/quarterly_data_collection_playbook.md`
  - `docs/dq_rules_catalog.md`
  - `docs/reconciliation_guide.md`
  - `docs/release_notes.md`

**Business impact**
Improves operational clarity, handoff quality, and portfolio readability by turning the project into a documented process rather than only a technical build.

---

## Open Follow-Ups

The following items remain open or are candidates for near-term refinement:

- Expand execution coverage for cataloged-but-not-yet-fully-executed rules:
  - weekly continuity
  - template version checks
  - submission timeliness
  - wholesale margin / ratio tolerance
- Clean up duplicate rule history in `dq.dq_rules` where prior manual inserts created overlapping active rows.
- Add a dedicated certification-oriented reporting object, such as `reporting.certified_quarterly_reporting`.
- Expand reconciliation coverage beyond the first quarter-level sales-to-finance comparison.
- Add Power BI pages on top of the reporting views.

---

## Known Limitations

- Source data is simulated for portfolio purposes.
- Current reporting views emphasize latest-run state rather than full historical run trend analysis.
- Some cataloged rules exist before their full execution logic has been added.
- Certification logic is partially procedural and not yet fully materialized as a standalone reporting object.
- Reconciliation coverage is currently limited to the first-pass quarter-level sales-to-finance comparison.
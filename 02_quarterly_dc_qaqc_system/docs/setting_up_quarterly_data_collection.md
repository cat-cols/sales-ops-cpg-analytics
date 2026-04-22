## 1. Title and purpose

Open with:

* what the playbook is
* what process it governs

Example sections:

* `# Quarterly Data Collection Playbook`
* `## Purpose`

This should be short and plain-English.

## 2. Scope

Explain:

* which quarter-level process this covers
* which source submissions are included
* which outputs are produced

This is where you should use your **actual implemented source names**, not the older generic names from the earlier brief. Your canvas brief still lists older generic names like `sales_quarterly_extract.csv` and `customer_adjustments_extract.xlsx`, but your live implementation is more specific now, so the playbook should reflect the actual project objects and filenames.

## 3. Process overview

This should be a short numbered list of the end-to-end workflow.

Something like:

1. Receive quarterly source submissions
2. Log intake status
3. Load raw tables
4. Standardize into staging
5. Run DQ checks
6. Run reconciliation checks
7. Review open exceptions
8. Review reconciliation status
9. Publish reporting views
10. Certify or hold the quarter

This is the backbone of the playbook.

## 4. In-scope sources

List the actual sources and their business purpose.

For each one, include:

* source file name
* business owner
* grain
* primary business use

Keep this concise.

## 5. Data model / architecture overview

Describe the schemas and what each one does.

For example:

* `raw` = landed submissions
* `ops` = intake tracking
* `stg` = typed standardization layer
* `dq` = rule definitions, run metadata, results, exceptions, recon
* `reporting` = dashboard-friendly views

This section should help a reader orient themselves fast.

## 6. Step-by-step operating procedure

This is the most important section.

Give each step its own subsection.

For example:

### Step 1 — Receive and log submissions

Explain:

* expected source files
* intake log expectations
* due dates / template versions

### Step 2 — Load raw data

Explain:

* raw landing tables
* principle of “preserve what was submitted”

### Step 3 — Build staging

Explain:

* trim, null-normalize, cast
* preserve defects for DQ

### Step 4 — Run DQ checks

Explain:

* execute `03_run_first_pass_checks.sql`
* results go to `dq_results_fact`
* exceptions go to `dq_exceptions_detail`

### Step 5 — Run reconciliation

Explain:

* execute `04_run_reconciliation_checks.sql`
* results go to `dq.recon_results`

### Step 6 — Review reporting views

Explain:

* `reporting.vw_dq_scorecard`
* `reporting.vw_open_exceptions`
* `reporting.vw_reconciliation_summary`

### Step 7 — Decide certification status

Explain what conditions must be reviewed before certification.

This should be the heart of the file.

## 7. Rule families currently implemented

Summarize the categories now working:

* completeness
* uniqueness
* validity
* reconciliation

Do not dump every SQL detail here. Just explain what each family is meant to catch.

Your current brief already lists the general first rule set, but the playbook should focus on the rules you actually implemented, not just the earlier aspirational list. 

## 8. Exception management workflow

Explain:

* how open exceptions are reviewed
* who owns remediation
* what statuses mean
* when an issue can be waived vs resolved

This is a very business-analyst-friendly section.

## 9. Reconciliation workflow

Explain:

* what is being compared
* how operational sales are calculated
* how finance net revenue is calculated
* what tolerance means
* what pass/fail means

This can be a short version here, with deeper detail later in `docs/reconciliation_guide.md`.

## 10. Certification criteria

Define what “certified” means for the quarter.

Even if you do not yet automate it fully, document the intended rule.

Example:

* no unresolved critical completeness/uniqueness failures
* reconciliation reviewed
* known exceptions documented
* reporting views refreshed

This is where the playbook becomes operationally meaningful.

## 11. Known limitations

Include:

* sample data is simulated
* rule set is first-pass, not exhaustive
* latest-run reporting views emphasize current-state monitoring
* duplicate rule cleanup may still be needed in the catalog if applicable

This makes the project more credible.

## 12. Related files / objects

End with a short reference section:

* key SQL runner files
* key reporting views
* related docs

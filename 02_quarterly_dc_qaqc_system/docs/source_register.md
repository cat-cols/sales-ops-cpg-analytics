# Source Register

## Purpose
This register documents the primary quarterly source submissions used in the Project 2 QA/QC workflow. It defines the expected business grain, required keys, core measures, major data quality risks, and reconciliation targets for each source.

## Scope and assumptions
- These sources represent quarterly departmental submissions used for certified business reporting.
- The project is modeled around a Wyld-like B2B operating context, including dispensary account sales, wholesale sales, finance actuals, inventory, and trade adjustments.
- This register is used to define source expectations before staging, validation, reconciliation, and reporting certification.

## Source register

| Source file | Business owner | Cadence | Business grain | Required keys | Core measures | Main DQ risks | Main recon target |
|---|---|---|---|---|---|---|---|
| `retail_account_sales_quarterly_extract.csv` | Sales Operations | Quarterly | `quarter_id + week_end_date + dispensary_account_id + sku_id` | `quarter_id`, `week_end_date`, `dispensary_account_id`, `sku_id` | `units_sold`, `gross_sales`, `discount_amount`, `net_sales` | Missing account IDs, duplicate weekly lines, negative sales, missing weeks | Tie to finance revenue by quarter and sales channel |
| `wholesale_account_sales_quarterly_extract.csv` | Commercial / Wholesale | Quarterly | `quarter_id + week_end_date + wholesale_account_id + sku_id` | `quarter_id`, `week_end_date`, `wholesale_account_id`, `sku_id` | `cases_sold`, `gross_sales`, `net_sales` | Account mismatches, duplicate account-SKU rows, outlier pricing, missing weeks | Tie to finance wholesale revenue by quarter |
| `finance_quarterly_actuals.csv` | Finance | Quarterly | `quarter_id + account_code + department_code` | `quarter_id`, `account_code`, `department_code` | `actual_amount` | Missing account mappings, wrong sign conventions, stale versions | Reconcile against retail + wholesale sales totals and selected adjustments |
| `inventory_quarterly_extract.csv` | Supply Chain / Inventory Control | Quarterly | `quarter_id + week_end_date + warehouse_id + sku_id` | `quarter_id`, `week_end_date`, `warehouse_id`, `sku_id` | `on_hand_units`, `available_units`, `inventory_value` | Negative on-hand units, missing weeks, duplicate snapshots, blank SKU IDs | Support reasonability checks against sales movement and adjustment activity |
| `trade_adjustments_extract.csv` | Trade Marketing / Finance | Quarterly | `quarter_id + adjustment_id` | `quarter_id`, `adjustment_id` | `adjustment_amount` | Missing reason codes, duplicate adjustments, out-of-period dates | Reconcile net revenue bridge between operational sales and finance actuals |

## Usage notes
- The business grain defined here is the expected uniqueness grain for source-level QA checks.
- Required keys defined here are the basis for completeness and null-check validation rules.
- Main DQ risks inform the first-pass rule set in `dq.dq_rules`.
- Reconciliation targets define expected cross-source tie-outs used in `dq.recon_results`.
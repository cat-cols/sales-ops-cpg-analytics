# Reconciliation Log — Project 1

This log is the human-readable companion to the SQL QA suite, mart-layer reconciliation views, and control outputs for Project 1.

It documents which checks are expected to tie exactly, which checks are monitored for variance, and which warnings are acceptable within the current simulated-data design.

| Refresh Date | Domain | Check | Source Object | Compared Object | Tolerance | Current Status | Notes |
|---|---|---|---|---|---:|---|---|
| 2026-04-10 | Sales | Distributor net sales: INT vs MART (same latest common date) | `int.int_sales_distributor_dedup` | `mart.fact_sales_distributor_daily` | 0.00% | Pass | Distributor mart totals are expected to tie exactly to deduped INT truth at the aligned date grain. |
| 2026-04-10 | Sales | POS net sales: INT vs MART (same latest common date) | `int.int_pos_dedup` | `mart.fact_sales_pos_daily` | 0.00% | Pass | Confirms POS mart rollup logic remains aligned to standardized and deduped INT inputs. |
| 2026-04-10 | People | Labor hours: INT vs MART (same latest common date) | `int.int_labor_daily` | `mart.fact_labor_daily` | 0.00% | Pass | Labor fact totals tie to INT truth at the daily grain used for downstream productivity KPIs. |
| 2026-04-10 | Ops | Inventory on-hand: INT vs MART (same latest common date) | `int.int_inventory_snapshot_dedup` | `mart.fact_inventory_snapshot_daily` | 0.00% | Pass | Inventory snapshot totals tie after standardization and deduplication. |
| 2026-04-10 | Sales / Ops | Distributor vs POS daily comparison | `mart.fact_sales_distributor_daily` | `mart.fact_sales_pos_daily` via `mart.recon_sales_distributor_vs_pos` | review only | Monitor | This is an operational comparison, not an exact-tie reconciliation. Variance may reflect channel scope, mix, and coverage differences. |
| 2026-04-10 | Finance | Gross sales: modeled sales vs finance actuals | `mart.fact_sales_daily` | `mart.recon_sales_to_gl_monthly` / `mart.fact_actuals_monthly` | 2.00% | Pass | Monthly modeled gross sales reconcile to finance actuals within defined tolerance. |
| 2026-04-10 | Finance | Net sales: modeled sales vs finance actuals | `mart.fact_sales_daily` | `mart.recon_sales_to_gl_monthly` / `mart.fact_actuals_monthly` | 2.00% | Pass | Net sales reconcile within tolerance after aligning modeled scope and tightening simulator drift. |
| 2026-04-10 | Finance | COGS: modeled sales vs finance actuals | `mart.fact_sales_daily` | `mart.recon_sales_to_gl_monthly` / `mart.fact_actuals_monthly` | 2.00% | Pass | COGS reconcile within base-metric tolerance. |
| 2026-04-10 | Finance | Gross margin: modeled sales vs finance actuals | `mart.fact_sales_daily` | `mart.recon_sales_to_gl_monthly` / `mart.fact_actuals_monthly` | 3.50% | Pass | Gross margin uses a distinct tolerance because it is a derived metric and more sensitive to compounded variance than the base finance measures. |
| 2026-04-10 | Controls | Freshness check by mart object | latest source date vs latest mart date | `mart.controls_freshness` | n/a | Expected Warning | Simulated static source drops can appear stale even when the pipeline and SQL build flow are functioning correctly. |
| 2026-04-10 | Controls | Missing dimension joins | fact rows missing expected conformed dimension matches | `mart.controls_missing_dim_joins` | 0 rows preferred | Monitor | This remains a trust metric and should continue to surface on QA / diagnostics reporting. |
| 2026-04-10 | Dimensions | Mart dimension contracts | `mart.dim_date`, `mart.dim_sku` | QA suite checks | 0 contract breaches | Pass | Dimension existence, row presence, uniqueness, and null-key rules currently pass. |
| 2026-04-10 | QA Suite | End-to-end project QA | `sql/_qa/_run_qa.sql` | full INT + MART + RECON validation flow | hard-fail on contract breach | Pass | The current Project 1 pipeline completes with QA passing end to end. |

## Current Interpretation

Project 1 is now in a materially stronger state than earlier iterations:

- core INT-to-MART reconciliations pass
- monthly finance reconciliation passes within defined tolerances
- mart dimension contracts pass
- the remaining freshness exceptions are documented simulation-side warnings, not model failures

## How to Use This Log

- Update this file after meaningful QA or reconciliation changes.
- Keep machine-readable truth in SQL views and QA scripts.
- Use this log as the human-facing summary of current trust status.
- Document warnings explicitly rather than letting them remain implicit.

## Tolerance Notes

Not every control should behave the same way.

- Exact INT-to-MART ties are expected where the mart is a direct rollup of reconciled intermediate truth.
- Finance reconciliation uses controlled tolerance bands because simulated finance actuals are intentionally realistic rather than perfectly identical to operational inputs.
- Gross margin is governed separately from gross sales, net sales, and COGS because it is a derived measure and therefore more sensitive to small upstream variance.

## Next Upgrade

The next improvement is not more SQL tuning. It is making the current trust model visible in the reporting layer:

- reconciliation page design
- semantic model validation notes
- KPI governance
- executive-facing diagnostics and data-health messaging
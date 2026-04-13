# Refresh Assumptions — Project 1

## Purpose

This document defines how the Project 1 semantic model is expected to refresh, what conditions must be true before a refresh is considered trustworthy, and what publish gates should be checked before report outputs are shared.

The model is currently designed around a manual / analyst-driven refresh flow rather than an automated production schedule.

---

## Current Refresh Mode

### Current state
- manual refresh
- analyst-triggered
- SQL pipeline must complete before semantic-model refresh
- publish readiness depends on QA results, not just data availability

### Why
Project 1 is a portfolio simulation built on generated source drops and SQL marts. The goal is to demonstrate trustworthy analytics flow, not pretend there is already a production orchestration layer.

---

## Refresh Dependency Chain

The reporting layer should only be refreshed after the warehouse-side pipeline completes successfully.

### Required sequence

1. generate / load raw source extracts
2. build STG layer
3. build INT layer
4. build MART layer
5. run QA suite
6. refresh semantic model
7. validate key report outputs
8. publish / export screenshots or report outputs

### Current pipeline command

```bash
python3 scripts/generate_project1_data.py --pg-dsn "$P1_PG_OPS" --pg-load-mode truncate_then_append && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/stg/_build_stg.sql && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/int/_build_int.sql && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/mart/_build_mart.sql && \
psql "$P1_PG_OPS" -v ON_ERROR_STOP=1 -f 01_ops_command_center/sql/_qa/_run_qa.sql
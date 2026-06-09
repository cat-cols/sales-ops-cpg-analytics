
# architecture:
- source extracts (sales/ops/people/esg)
- staging
- marts
- Power BI semantic mode
- QA/QC layer
- executive reporting layer

---

Use one repo, four project folders, and a shared “platform” layer.

That’s the cleanest way to look like an actual analyst team instead of four random school assignments duct-taped together.

Here’s the architecture I’d use for `wyld-business-analyst`:

```txt
wyld-business-analyst/
│
├─ README.md
├─ .gitignore
├─ LICENSE
├─ requirements.txt                  # Python deps for generators / QA scripts
├─ environment.yml                   # optional (conda)
├─ Makefile                          # optional but very pro
│
├─ docs/                             # repo-level docs (portfolio-facing)
│  ├─ repository_map.md
│  ├─ portfolio_overview.md
│  ├─ runbook.md
│  └─ screenshots/
│
├─ shared/                           # reusable standards/patterns across all projects
│  ├─ semantic_model/
│  │  ├─ conformed_dimensions.md
│  │  ├─ relationship_standards.md
│  │  ├─ measure_naming_conventions.md
│  │  ├─ dax_patterns.md
│  │  ├─ time_intelligence_patterns.md
│  │  ├─ reconciliation_measure_patterns.md
│  │  ├─ narrative_measure_patterns.md
│  │  └─ semantic_model_qa_checklist.md
│  │
│  ├─ data_governance/
│  │  ├─ source_register_template.md
│  │  ├─ data_dictionary_template.md
│  │  ├─ grain_and_keys_standards.md
│  │  ├─ qa_qc_rule_template.md
│  │  └─ reconciliation_tolerance_policy.md
│  │
│  ├─ reporting_ops/
│  │  ├─ report_publish_checklist.md
│  │  ├─ executive_summary_template.md
│  │  ├─ stakeholder_notes_template.md
│  │  ├─ ad_hoc_request_template.md
│  │  └─ reporting_calendar_template.md
│  │
│  ├─ sql_patterns/
│  │  ├─ staging_sql_template.sql
│  │  ├─ conformance_sql_template.sql
│  │  ├─ mart_sql_template.sql
│  │  ├─ validation_checks_template.sql
│  │  └─ variance_decomposition_patterns.sql
│  │
│  └─ seeds/                         # optional shared seeds (if reused)
│     ├─ state_region_map.csv
│     ├─ holiday_calendar_seed.csv
│     └─ metric_thresholds_seed.csv
│
├─ scripts/                          # reusable generators / loaders / utilities
│  ├─ generate_project1_data.py
│  ├─ generate_project2_dq_inputs.py
│  ├─ generate_project3_forecast_data.py
│  ├─ generate_project4_emissions_data.py
│  ├─ build_all_samples.py
│  └─ export_data_dictionaries.py
│
├─ environment/                      # local environment and setup helpers
│  ├─ sql/
│  │  ├─ postgres/
│  │  │  ├─ init_schema.sql
│  │  │  └─ load_csvs.sql
│  │  └─ duckdb/
│  │     ├─ init_schema.sql
│  │     └─ load_csvs.sql
│  ├─ powerbi/
│  │  └─ refresh_notes.md
│  └─ setup/
│     ├─ setup_instructions.md
│     └─ folder_bootstrap.sh
│
├─ data/                             # top-level shared raw/reference (lightweight only)
│  ├─ reference/
│  │  ├─ public_product_catalog_seed.csv
│  │  ├─ dispensary_master_seed.csv
│  │  └─ emission_factors_reference.csv
│  ├─ sample/                        # tiny cross-project samples safe to commit
│  └─ raw/                           # gitignored
│
├─ project_01_wyld_ops_command_center/
│  ├─ README.md
│  │
│  ├─ data/
│  │  ├─ seeds/                      # project-specific seeds (preferred)
│  │  │  ├─ product_seed.csv
│  │  │  ├─ location_seed.csv
│  │  │  ├─ channel_seed.csv
│  │  │  └─ employee_group_seed.csv
│  │  ├─ source_extracts/
│  │  │  ├─ sales/
│  │  │  ├─ ops/
│  │  │  ├─ people/
│  │  │  └─ finance/
│  │  ├─ standardized/
│  │  ├─ modeled/
│  │  ├─ exceptions/
│  │  ├─ sample/
│  │  └─ raw/                        # gitignored
│  │
│  ├─ sql/
│  │  ├─ staging/
│  │  ├─ conformance/
│  │  ├─ marts/
│  │  └─ validation/
│  │
│  ├─ powerbi/
│  │  ├─ wyld_ops_command_center.pbix
│  │  ├─ semantic_model/
│  │  │  ├─ model_design.md
│  │  │  ├─ relationships_map.md
│  │  │  ├─ dax_measure_catalog.md
│  │  │  ├─ semantic_model_validation.md
│  │  │  ├─ naming_conventions.md
│  │  │  └─ refresh_assumptions.md
│  │  ├─ report_pages/
│  │  │  ├─ page_inventory.md
│  │  │  └─ tooltip_narratives.md
│  │  └─ exports/
│  │
│  ├─ docs/
│  │  ├─ source_register.md
│  │  ├─ fake_data_generation_method.md
│  │  ├─ executive_walkthrough.md
│  │  ├─ reporting_calendar.md
│  │  ├─ stakeholder_notes.md
│  │  └─ reconciliation_log.md
│  │
│  └─ reports/
│     ├─ executive_decks/
│     ├─ ad_hoc_requests/
│     └─ scheduled_exports/
│
├─ project_02_quarterly_data_qaqc_system/
│  ├─ README.md
│  │
│  ├─ data/
│  │  ├─ source_extracts/
│  │  │  ├─ sales/
│  │  │  ├─ finance/
│  │  │  ├─ operations/
│  │  │  └─ people/
│  │  ├─ standardized/
│  │  ├─ exceptions/
│  │  ├─ dq_runs/                    # run outputs by quarter
│  │  ├─ sample/
│  │  └─ raw/
│  │
│  ├─ sql/
│  │  ├─ staging/
│  │  ├─ dq_rules/
│  │  ├─ marts/
│  │  └─ validation/
│  │
│  ├─ powerbi/
│  │  ├─ wyld_data_quality_monitor.pbix
│  │  ├─ semantic_model/
│  │  │  ├─ model_design.md
│  │  │  ├─ dax_measure_catalog.md
│  │  │  └─ semantic_model_validation.md
│  │  └─ report_pages/
│  │     ├─ page_inventory.md
│  │     └─ alert_logic.md
│  │
│  ├─ docs/
│  │  ├─ quarterly_data_collection_playbook.md
│  │  ├─ source_register.md
│  │  ├─ dq_rules_catalog.md
│  │  ├─ release_notes.md
│  │  ├─ reconciliation_workflow.md
│  │  └─ stakeholder_notes.md
│  │
│  └─ reports/
│     ├─ exceptions_reports/
│     ├─ reconciliation_templates/
│     └─ executive_decks/
│
├─ project_03_forecasting_variance_story/
│  ├─ README.md
│  │
│  ├─ data/
│  │  ├─ source_extracts/
│  │  ├─ modeled/
│  │  ├─ forecast_outputs/
│  │  ├─ sample/
│  │  └─ raw/
│  │
│  ├─ sql/
│  │  ├─ staging/
│  │  ├─ marts/
│  │  └─ validation/
│  │
│  ├─ python/
│  │  ├─ forecasting_baseline.py
│  │  ├─ forecasting_sarima_optional.py
│  │  ├─ variance_decomposition.py
│  │  └─ model_evaluation.py
│  │
│  ├─ notebooks/                     # optional if you want demos
│  │  ├─ 01_forecast_exploration.ipynb
│  │  └─ 02_variance_bridge_prototype.ipynb
│  │
│  ├─ powerbi/
│  │  ├─ wyld_forecast_variance.pbix
│  │  ├─ semantic_model/
│  │  │  ├─ model_design.md
│  │  │  ├─ dax_measure_catalog.md
│  │  │  └─ semantic_model_validation.md
│  │  └─ report_pages/
│  │     ├─ page_inventory.md
│  │     └─ variance_bridge_logic.md
│  │
│  ├─ docs/
│  │  ├─ forecasting_methodology.md
│  │  ├─ variance_decomposition_method.md
│  │  ├─ model_assumptions.md
│  │  ├─ executive_walkthrough.md
│  │  └─ stakeholder_notes.md
│  │
│  └─ reports/
│     ├─ executive_decks/
│     ├─ scheduled_exports/
│     └─ ad_hoc_requests/
│
└─ project_04_ghg_scope_reporting/
   ├─ README.md
   │
   ├─ data/
   │  ├─ source_extracts/
   │  │  ├─ utilities/
   │  │  ├─ fuel/
   │  │  ├─ shipping/
   │  │  ├─ packaging/
   │  │  └─ finance_support/
   │  ├─ factors/                    # versioned emission factors
   │  ├─ modeled/
   │  ├─ assurance_pack/
   │  ├─ sample/
   │  └─ raw/
   │
   ├─ sql/
   │  ├─ staging/
   │  ├─ conformance/
   │  ├─ marts/
   │  └─ validation/
   │
   ├─ powerbi/
   │  ├─ wyld_sustainability_scorecard.pbix
   │  ├─ semantic_model/
   │  │  ├─ model_design.md
   │  │  ├─ dax_measure_catalog.md
   │  │  ├─ semantic_model_validation.md
   │  │  └─ factor_versioning_logic.md
   │  └─ report_pages/
   │     ├─ page_inventory.md
   │     └─ assurance_views.md
   │
   ├─ docs/
   │  ├─ methodology.md
   │  ├─ assumptions_table.md
   │  ├─ factor_sources_and_changelog.md
   │  ├─ external_assurance_request_pack_checklist.md
   │  ├─ source_register.md
   │  └─ stakeholder_notes.md
   │
   └─ reports/
      ├─ executive_decks/
      ├─ assurance_exports/
      └─ scheduled_exports/
```

## Why this structure works

It proves three things immediately:

* You understand **project isolation** (each project is self-contained)
* You understand **shared standards** (real teams reuse patterns)
* You understand **delivery** (docs, exports, semantic model, QA — not just code)

Basically: not a toy repo. A mini analytics org.

## A few important conventions

### 1) Keep each project independently runnable

Each project should have its own:

* `README.md`
* `data/`
* `sql/`
* `powerbi/`
* `docs/`
* `reports/`

So if a recruiter opens just Project 2, it still makes sense.

### 2) Use `shared/` for standards, not live project data

`shared/` should hold:

* templates
* naming conventions
* DAX/SQL patterns
* QA checklists

Not giant data files. Keep it lightweight.

### 3) Put “real-ish seeds” where they belong

For your Althea simulation:

* product/dispensary seeds can live in `project_01/.../data/seeds/`
* if reused across projects, also store a canonical copy in top-level `data/reference/`

That’s a nice balance between reuse and project clarity.

### 4) Keep binary files contained

Power BI `.pbix` files are chunky and opaque. Put them in each project’s `powerbi/` folder and mirror the logic in markdown:

* `semantic_model/`
* `report_pages/`
* `dax_measure_catalog.md`

That way your repo still “reads” well on GitHub.

## .gitignore essentials for this repo

Add these so your repo doesn’t become a landfill:

* `**/data/raw/`
* `**/data/source_extracts/` (or keep only tiny samples)
* `**/data/modeled/` (optional; commit samples only)
* `**/*.duckdb`
* `**/*.sqlite`
* `**/__pycache__/`
* `.DS_Store`
* `.venv/`
* `.env`


![Althea Logo](assets/branding/thumbnails/althea.png)

# Althea Medicinals
## Cannabis Gummy Brand Business Analysis Portfolio

![Althea](https://img.shields.io/badge/Althea-Analytics-blue)
![Project](https://img.shields.io/badge/flagship-Ops%20Command%20Center-4f46e5)
![Status](https://img.shields.io/badge/status-core%20build%20substantially%20complete-brightgreen)
![Focus](https://img.shields.io/badge/focus-SQL%20%7C%20QA%20%7C%20reconciliation-blue)
![Docs](https://img.shields.io/badge/docs-playbooks%20%7C%20rules%20%7C%20methodology-0ea5e9)

![P1](https://img.shields.io/badge/P1-95%25%20complete-brightgreen)
![P2](https://img.shields.io/badge/P2-75%25%20complete-green)
![P3](https://img.shields.io/badge/P3-25%25%20complete-yellow)
![P4](https://img.shields.io/badge/P4-85%25%20complete-green)

A multi-project analytics portfolio designed to simulate realistic Business Analyst and Analytics Engineering work across messy source intake, standardization, QA/QC, reconciliation, semantic-model planning, and decision-ready reporting.

This repository is built to show more than dashboarding. It is meant to demonstrate how analytical work holds up when the environment is messy: inconsistent source files, data quality failures, reconciliation gaps, documentation requirements, and reporting controls.

**Workflow focus:**
**source intake → standardization → QA/QC → reconciliation → semantic model → executive reporting**

---

## What this repo proves

- **Cross-functional analytics thinking** across Sales, Operations, Labor, Forecasting, and Sustainability
- **Data quality and reconciliation discipline**, not just report-building
- **SQL-first modeling habits** from staging to conformance to marts to validation
- **Documentation maturity** through playbooks, source registers, reconciliation logs, and methodology docs
- **Portfolio-ready project structure** with reusable templates, shared standards, and realistic project scoping
- **Business-facing communication** through walkthroughs, release notes, and reporting narratives

---

## Current portfolio status

### Project completion overview
- **01_ops_command_center** — 90% complete (manufacturer model integration complete, Tableau dashboards pending)
- **02_quarterly_dc_qaqc_system** — 75% complete (SQL pipeline complete, Power BI dashboards pending)
- **03_forecasting_variance_story** — 25% complete (concept defined, implementation pending)
- **04_ghg_scope_reporting** — 85% complete (SQL pipeline complete, Power BI dashboards pending)
- **05_decision_engine** — 20% complete (concept defined, implementation pending)
- **06_fpna_planning** — 5% complete (scope definition pending)

**Overall portfolio: 50% complete**

### Most complete now
- **01_ops_command_center** — flagship integrated analytics project with manufacturer model
- **02_quarterly_dc_qaqc_system** — governed quarterly QA/QC and reconciliation workflow
- **04_ghg_scope_reporting** — sustainability reporting with audit-ready documentation

### In progress / planned next
- **03_forecasting_variance_story** — forecasting + variance analysis
- **05_decision_engine** — decision engine and recommendation system
- **06_fpna_planning** — FPNA planning and forecasting

### Shared across projects
- **shared/** — reusable SQL, semantic-model, governance, and documentation templates

---

## Repository structure

```text
.
├── 01_ops_command_center/               # Flagship BI + reconciliation project
│   ├── data/
│   ├── sql/
│   ├── powerbi/
│   ├── docs/
│   ├── reports/
│   ├── scripts/
│   └── requirements.txt
|
├── 02_quarterly_dc_qaqc_system/         # Quarterly QA/QC + reconciliation project
├── 03_forecasting_variance_story/       # Forecasting + variance analysis
├── 04_ghg_scope_reporting/              # GHG / ESG reporting + assurance-ready docs
├── 05_decision_engine/                  # Decision engine and recommendation system
├── 06_fpna_planning/                    # FPNA planning and forecasting
├── 07_sales_data_coordinator/           # Sales data coordination and standardization
|
├── shared/                              # Reusable patterns/templates across projects
│   ├── sql/
│   ├── semantic_model/
│   ├── source_systems/
│   ├── templates/
│   └── reporting_ops/
|
├── docs/                                # Cross-project architecture, dictionaries, notes
├── scripts/                             # Data generation + utility scripts
├── assets/diagrams/                     # Architecture / schema diagrams
├── setup_repo.sh                        # Bootstrap script
└── README.md
```

---

## Quick start

### 1) Clone the repo

```bash
git clone git@github.com:cat-cols/sales-ops-cpg-analytics.git
cd sales-ops-cpg-analytics
```

### 2) Bootstrap the project

```bash
bash setup_repo.sh
```

Useful options:

```bash
bash setup_repo.sh --skip-venv
bash setup_repo.sh --venv-name .venv
```

### 3) Activate the environment

```bash
source .venv/bin/activate
```

### 4) Generate sample data

Generate data for a single project:

```bash
# Project 1
python3 01_ops_command_center/scripts/generate_project1_data.py

# Project 2
python3 02_quarterly_dc_qaqc_system/scripts/generate_project2_dq_inputs.py

# Project 3
python3 03_forecasting_variance_story/scripts/generate_project3_forecast_inputs.py

# Project 4
python3 04_ghg_scope_reporting/scripts/generate_project4_ghg_inputs.py
```

Or regenerate data for all projects at once:

```bash
python3 scripts/regenerate_all_data.py
```

---

Large synthetic datasets and local database artifacts are intended to be generated locally or distributed separately so the repo stays easy to clone and review.

---

## Synthetic enterprise analytics sandbox

This portfolio uses a synthetic “Wyld-like” analytics environment designed to simulate realistic business analyst workflows across multiple domains.

### Synthetic environment highlights
* **Date range:** 2022-01-01 to 2026-02-23
* **Domains:** Sales, Inventory, Labor, Forecasting, Emissions
* **Shared dimensions:** Date, Product, Location, Channel, Employee Group
* **Database support:** local SQL workflows with patterns adaptable to PostgreSQL / DuckDB / SQL Server

### Example synthetic row counts

* `fact_sales` — 356,030
* `fact_inventory` — 422,124
* `fact_labor` — 86,197
* `fact_forecast` — 367,284
* `fact_emissions` — 13,714

> All data in this repository is **synthetic** and used only for practice, portfolio demonstration, and workflow design.

---

## Projects

## 01 — Ops Command Center (Sales + Ops + Labor BI)

**Goal:** Build a decision-ready command center that integrates cross-functional data with reconciliation and control logic.

**Status:** 90% complete - Manufacturer model integration complete, Tableau dashboards pending

### What it demonstrates

* cross-functional KPI design
* source-to-model reconciliation
* dimensional modeling and mart design
* SQL validation and QA patterns
* semantic-model and report planning
* executive walkthrough documentation
* manufacturer business model (B2B + Direct + Sell-through)

### Recent updates
* Integrated Althea manufacturer model data (replacing retail POS model)
* Updated SQL pipeline for manufacturer channels (B2B, Direct, Sell-through)
* Created comprehensive metric dictionaries (YAML + Markdown)
* Generated realistic data using Oregon cannabis business licenses (1,053 entities)
* Updated documentation for manufacturer business context

### Key folders

* [`01_ops_command_center/sql/`](01_ops_command_center/sql/) — staging, conformance, marts, validation
* [`01_ops_command_center/docs/`](01_ops_command_center/docs/) — source register, stakeholder notes, reconciliation logs, metric dictionaries
* [`01_ops_command_center/tableau/`](01_ops_command_center/tableau/) — Tableau implementation guides and calculated fields
* [`01_ops_command_center/scripts/`](01_ops_command_center/scripts/) — manufacturer model data generation

---

## 02 — Quarterly Data Collection + QA/QC System

**Goal:** Simulate a governed quarterly intake, validation, reconciliation, and certification workflow for messy departmental submissions.

**Status:** 75% complete - SQL pipeline complete, Power BI dashboards pending

### What it demonstrates

* quarterly data intake process design
* DQ rule governance
* record-level exceptions handling
* release notes / rules change discipline
* operational-to-finance reconciliation
* reporting integrity before publication
* hold-or-certify decision support

### Current implemented outputs
* staged quarterly source views
* governed `dq_rules`, run log, results fact, exceptions detail, and recon tables
* first-pass completeness, uniqueness, and validity checks
* reporting views for:
  * `vw_dq_scorecard`
  * `vw_open_exceptions`
  * `vw_reconciliation_summary`
  * `certified_quarterly_reporting`
* project documentation including:
  * quarterly data collection playbook
  * rules catalog
  * reconciliation guide
  * release notes

### What's needed
* Power BI dashboards (3 pages: Data Quality Monitor, Open Exceptions, Reconciliation & Certification)
* Power BI screenshots for README
* Architecture diagram
* Final README polish

### Current implemented outputs
* staged quarterly source views
* governed `dq_rules`, run log, results fact, exceptions detail, and recon tables
* first-pass completeness, uniqueness, and validity checks
* reporting views for:
  * `vw_dq_scorecard`
  * `vw_open_exceptions`
  * `vw_reconciliation_summary`
  * `certified_quarterly_reporting`
* project documentation including:
  * quarterly data collection playbook
  * rules catalog
  * reconciliation guide
  * release notes

### Key folders

* [`02_quarterly_dc_qaqc_system/sql/`](02_quarterly_dc_qaqc_system/sql/)
* [`02_quarterly_dc_qaqc_system/docs/`](02_quarterly_dc_qaqc_system/docs/)
* [`02_quarterly_dc_qaqc_system/README.md`](02_quarterly_dc_qaqc_system/README.md)

---

## 03 — Forecasting + Variance Story

**Goal:** Build a forecasting and variance-analysis project that explains not just what happened, but why actuals diverged from plan.

**Status:** 25% complete - Concept defined, implementation pending

### Planned focus

* forecast vs actual comparisons
* variance decomposition
* business-driver framing
* narrative reporting for commercial and finance audiences

### What's needed
* Data generation script for forecast/actuals
* Forecasting model implementation (Prophet/SARIMA)
* Variance decomposition logic (price/volume/mix)
* Driver diagnostics (store/SKU/channel/promotions/stockouts)
* Power BI dashboard pages (Forecast, Variance Bridge, Driver Diagnostics)
* Executive storytelling slide deck
* SQL mart views for forecasting

---

## 04 — GHG Scope Reporting + Audit-Ready Documentation

**Goal:** Build a sustainability reporting workflow with methodology clarity, factor versioning, lineage, and audit-friendly controls.

### What it demonstrates

* auditability and controls mindset
* methodology documentation
* source-to-metric lineage
* sustainability reporting structure
* assurance-readiness practices

### Planned/active deliverables

* methodology documentation
* factor/version tracking
* assurance request checklist
* sustainability scorecard/report scaffolding

---

## 05 — Decision Engine

**Goal:** Build a decision-support layer that turns trusted analytics marts into business recommendations, alert tables, opportunity tables, and executive-ready summaries.

**Status:** 20% complete - Concept defined, implementation pending

### What it demonstrates

* KPI driver tree design
* revenue and margin root-cause analysis
* store / SKU / channel performance flagging
* low-margin and inventory-risk alert logic
* opportunity identification
* executive decision summaries
* QA checks for decision outputs

### What's needed
* Data processing logic consuming Project 1 marts
* KPI driver tree implementation
* Revenue variance root-cause analysis
* Alert logic (low margin, inventory risk)
* Opportunity identification logic
* Store/SKU performance flagging
* Executive decision summary views
* QA checks for decision outputs

---

## 06 — FPNA Planning

**Goal:** Build financial planning and analysis capabilities with budget vs actual comparisons, variance analysis, and rolling forecasts.

**Status:** 5% complete - Scope definition pending

### What it demonstrates

* Budget vs actual comparison logic
* Forecast integration
* Variance analysis for financial planning
* Rolling forecasts implementation
* FP&A dashboard development

### What's needed
* Complete project scope definition
* Data model for FP&A planning
* Budget vs actual comparison logic
* Forecast integration
* Variance analysis for financial planning
* Rolling forecasts implementation
* SQL pipeline development
* Power BI planning dashboards
* Documentation

This repo uses a `shared/` layer to show repeatable operating discipline across projects.

* [`shared/source_systems/`](shared/source_systems/) — source register templates, naming standards, ingestion checklists
* [`shared/semantic_model/`](shared/semantic_model/) — relationship standards, naming patterns, QA checklists
* [`shared/sql/`](shared/sql/) — reusable SQL and KPI patterns
* [`shared/templates/`](shared/templates/) — SOPs, methodology, reconciliation templates

This is intentional: the repo is meant to show not just analysis, but **repeatable analytics operations**.

---

## Tech stack

* **SQL** — PostgreSQL / DuckDB-style workflows
* **Python** — pandas, numpy, openpyxl, pyarrow
* **Power BI** — semantic-model and report-design planning
* **Data Quality** — rules-driven QA/QC workflows
* **Forecasting** — planned Project 3 expansion
* **Documentation-first workflow** — playbooks, source registers, methodology, release notes

---

## Where to start

If you want the clearest current examples, start here:

### Flagship project

* [`01_ops_command_center/docs/`](01_ops_command_center/docs/)

### Strongest process-control project

* [`02_quarterly_dc_qaqc_system/README.md`](02_quarterly_dc_qaqc_system/README.md)
* [`02_quarterly_dc_qaqc_system/docs/quarterly_data_collection_playbook.md`](02_quarterly_dc_qaqc_system/docs/quarterly_data_collection_playbook.md)
* [`02_quarterly_dc_qaqc_system/docs/dq_rules_catalog.md`](02_quarterly_dc_qaqc_system/docs/dq_rules_catalog.md)
* [`02_quarterly_dc_qaqc_system/docs/reconciliation_guide.md`](02_quarterly_dc_qaqc_system/docs/reconciliation_guide.md)

### Cross-project docs

* [`docs/`](docs/)

---

## Power BI note

Power BI Desktop is Windows-only. On Mac, this repo still demonstrates:

* SQL modeling
* QA/QC and reconciliation logic
* semantic-model planning
* documentation and output walkthroughs
* reporting-layer design without requiring Desktop itself

---

## Simulation / data disclaimer

This repository uses **simulated and synthetic data** for portfolio purposes.

* no proprietary internal company data is included
* no confidential business records are used
* company-like naming is used only for educational simulation and workflow realism

The focus is on demonstrating **analytics process quality**, not representing any real company’s internal reporting systems.

---

## Roadmap

Near-term improvements:

* finalize Project 2 sample outputs and walkthrough assets
* add screenshot-based report previews
* continue Project 3 forecasting build
* continue Project 4 sustainability reporting build
* keep shared templates and standards aligned across projects

---

## Author

**Brandon Hardison**
GitHub: [cat-cols](https://github.com/cat-cols)
LinkedIn: [brandon-hardison](https://www.linkedin.com/in/brandon-hardison-14003293/)

---

## License

This project is licensed under the terms in [`LICENSE`](LICENSE).

![Althea Logo](assets/branding/thumbnails/althea_2.png)
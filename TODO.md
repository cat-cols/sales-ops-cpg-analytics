# TODO

## PROJECT COMPLETION STATUS

### Project 1 (01_ops_command_center) - 90% Complete
**What's Done:**
- 121 SQL files with complete data pipeline
- Manufacturer model integration (B2B + Direct + Sell-through)
- Full staging, integration, and mart layers
- Data generation script using Althea manufacturer data
- Comprehensive documentation (README, integration plan)
- Metric dictionaries (YAML + Markdown)
- Tableau implementation structure
- QA controls and reconciliation views

**What's Needed:**
- Final Tableau dashboard screenshots
- Executive walkthrough documentation updates
- Final testing of manufacturer model pipeline
- Portfolio presentation materials

### Project 2 (02_quarterly_dc_qaqc_system) - 75% Complete
**What's Done:**
- 19 SQL files with complete DQ framework
- Raw landing tables and staging views
- Governed DQ rules catalog
- Reconciliation logic (sales vs finance)
- Reporting views (DQ scorecard, exceptions, reconciliation)
- Comprehensive documentation (playbook, rules catalog, reconciliation guide)
- Simulated source data with intentional defects

**What's Needed:**
- Power BI dashboards (3 pages: Data Quality Monitor, Open Exceptions, Reconciliation & Certification)
- Power BI screenshots for README
- Architecture diagram
- Final README polish with "How to run" section
- Optional summary deck

### Project 3 (03_forecasting_variance_story) - 25% Complete
**What's Done:**
- 10 SQL files with basic structure
- README with concept definition
- Power BI folder structure
- Basic project outline

**What's Needed:**
- Data generation script for forecast/actuals
- Forecasting model implementation (Prophet/SARIMA)
- Variance decomposition logic (price/volume/mix)
- Driver diagnostics (store/SKU/channel/promotions/stockouts)
- Power BI dashboard pages (Forecast, Variance Bridge, Driver Diagnostics)
- Executive storytelling slide deck
- SQL mart views for forecasting

### Project 4 (04_ghg_scope_reporting) - 85% Complete
**What's Done:**
- 44 SQL files with complete pipeline
- Full SQL workflow (raw → stg → int → mart → qa)
- Data generation scripts with intentional defects
- Scope 1/2/3 emissions modeling
- Versioned emission factor matching
- Comprehensive documentation (methodology, lineage, assumptions, assurance checklist)
- QA controls and exception reporting
- Reportable vs non-reportable row logic

**What's Needed:**
- Power BI Sustainability Scorecard dashboard
- Power BI screenshots for README
- DAX measures for emissions analysis
- Final portfolio presentation materials

### Project 5 (05_decision_engine) - 20% Complete
**What's Done:**
- 8 SQL files with basic structure
- README with concept and planned outputs
- KPI driver tree design concept
- Upstream dependency definitions

**What's Needed:**
- Data processing logic consuming Project 1 marts
- KPI driver tree implementation
- Revenue variance root-cause analysis
- Alert logic (low margin, inventory risk)
- Opportunity identification logic
- Store/SKU performance flagging
- Executive decision summary views
- QA checks for decision outputs

### Project 6 (06_fpna_planning) - 5% Complete
**What's Done:**
- Basic directory structure
- Empty README placeholder

**What's Needed:**
- Complete project scope definition
- Data model for FP&A planning
- Budget vs actual comparison logic
- Forecast integration
- Variance analysis for financial planning
- Rolling forecasts implementation
- SQL pipeline development
- Power BI planning dashboards
- Documentation

**Overall Portfolio: 50% Complete**

## TOP PRIORITY
- [X] align data between projects
    - [X] update generators so they pull from shared seed files

- [ ] Add semantic model test queries to validation folder
- [ ] refactor customers as entity types: wholesale, retail/direct?
- [ ] Add: portfolio system map diagram explanation of how all 6 projects connect to each other and how they fit into the overall data architecture (assets/diagrams/portfolio_system_map.png)

## MEDIUM PRIORITY
- [ ] After projects are built, modify simulated data to be as real as possible

## LOW PRIORITY
- [ ] Add dbt project structure and models

## Repo Polish
- [ ] Reduce repo bloat by moving large databases/assets to GitHub Releases
- [ ] Reconcile duplicate definition files into one master definition file
- [ ] Refactor Project 1 download links in `getting-started.md` so they pull the correct files from GitHub

## Setup & Environment
- [ ] Add `requirements-forecasting` option to bash setup script
- [ ] Add `requirements-dq` option to bash setup script
- [ ] Add setup script option for `minimal` vs `full` environment install
- [ ] Implement ripgrep?

## Project 1 - COMPLETED MANUFACTURER MODEL INTEGRATION
- [X] lock in “one-command rebuild”
- [X] Update data generation script to use manufacturer model
- [X] Update SQL views for manufacturer model (stg, int, mart layers)
- [X] Update documentation for manufacturer model
- [X] Create metric dictionaries (YAML + Markdown)
- [ ] Final Tableau dashboard screenshots
- [ ] Executive walkthrough documentation updates
- [ ] Final testing of manufacturer model pipeline in PostgreSQL

## LEAN SIX SIGMA
- [ ] LEAN SIX SIGMA

## Project 2
- [ ] Build Power BI dashboards (3 pages: Data Quality Monitor, Open Exceptions, Reconciliation & Certification)
- [ ] Power BI screenshots for README
- [ ] Architecture diagram
- [ ] Final README polish with "How to run" section
- [ ] Optional summary deck

## Project 3
- [ ] Data generation script for forecast/actuals
- [ ] Forecasting model implementation (Prophet/SARIMA)
- [ ] Variance decomposition logic (price/volume/mix)
- [ ] Driver diagnostics (store/SKU/channel/promotions/stockouts)
- [ ] Power BI dashboard pages (Forecast, Variance Bridge, Driver Diagnostics)
- [ ] Executive storytelling slide deck
- [ ] SQL mart views for forecasting

## Project 4
- [ ] Power BI Sustainability Scorecard dashboard
- [ ] Power BI screenshots for README
- [ ] DAX measures for emissions analysis
- [ ] Final portfolio presentation materials

## Project 5
- [ ] Data processing logic consuming Project 1 marts
- [ ] KPI driver tree implementation
- [ ] Revenue variance root-cause analysis
- [ ] Alert logic (low margin, inventory risk)
- [ ] Opportunity identification logic
- [ ] Store/SKU performance flagging
- [ ] Executive decision summary views
- [ ] QA checks for decision outputs

## Project 6
- [ ] Complete project scope definition
- [ ] Data model for FP&A planning
- [ ] Budget vs actual comparison logic
- [ ] Forecast integration
- [ ] Variance analysis for financial planning
- [ ] Rolling forecasts implementation
- [ ] SQL pipeline development
- [ ] Power BI planning dashboards
- [ ] Documentation

## Portfolio Presentation
- [ ] Finalize clean root README (what it is, what it proves, how to run)
- [ ] Add architecture diagram to README/docs
- [ ] Add sample dashboard screenshot
- [ ] Add sample DQ scorecard screenshot
- [ ] Ensure only small sample data is tracked
- [ ] Finalize reproducible setup steps
- [ ] Add clear simulation / no proprietary data disclaimer

## README
- [ ] Update the author line if you want a different display name
- [ ] Add 2–3 screenshots (even placeholders) ASAP — that gives the repo instant visual credibility
- [ ] If you want, I can also write a **killer Project 1 README** next so the root README links into something equally polished.

## Screenshots (add these to strengthen the repo)
Add these to `assets/screenshots/` and embed them here:

- [ ] Ops Command Center dashboard
- [ ] Reconciliation / data confidence page
- [ ] DQ scorecard (Project 2)
- [ ] GHG scorecard (Project 4)
- [ ] Star schema / data flow diagram

Example (replace paths once added):
```md
![Ops Command Center](assets/screenshots/ops_command_center.png)
![DQ Scorecard](assets/screenshots/dq_scorecard.png)
```

## Results / Insights

- [ ] Add one “Results / Insights” section in root README with 3–5 bullets (what business questions Project 1 answers). Right now you describe architecture and process well, but business outcomes need one more spotlight

---


- [ ] Add 01_ops_command_center/docs/metrics_dictionary.md (your repo-level dictionary is solid; now you need the project-level one to match what your root README claims)

- [ ] A “DQ/reconciliation checks passing” screenshot (even from SQL output) is catnip for this job.

# Add screenshots
- [ ] A dashboard screenshot mock is fine if Power BI isn’t actually runnable on Mac.
- [ ] A “DQ/reconciliation checks passing” screenshot (even from SQL output) is catnip for this job.

# Future Iterations
- [ ] Add dbt project structure and models

1. reconcile existing definition files into one master file?
2. refactor download links in project1 getting-started.md so they actually download the files from repo/github
3. Add requirements-forecasting options in bash script
4. Add requirements-dq options in bash script
5. give bash setup script option to install bare minimum or full environment

---
---

Yes, but with important boundaries. Business analysts can unlock competitive strategies, but it's typically **one part of a broader collaborative effort** rather than the sole responsibility.

## Business Analyst Role in Competitive Strategy

**Within Scope:**
- **Data-driven insights**: Analyze market data, competitor positioning, sales trends
- **Market intelligence**: Identify gaps, opportunities, and threats using data
- **Performance analysis**: Compare metrics against benchmarks and competitors
- **Scenario modeling**: Model different strategic approaches with data
- **Recommendation support**: Provide data-backed recommendations to decision-makers

**Beyond Traditional Scope (Requires Collaboration):**
- **Final strategic decisions**: Usually made by executives/strategy teams
- **Brand positioning**: Marketing and brand strategy expertise needed
- **Pricing strategy**: Requires finance, marketing, and executive input
- **Partnership negotiations**: Sales and business development lead
- **Competitive response tactics**: Cross-functional coordination required

## How Your Project Supports Competitive Strategy

The Oregon Cannabis Market Intelligence Platform you've built provides **strategic inputs**:

**Market Intelligence:**
- Geographic gaps in retailer coverage
- Competition density by region
- Territory prioritization for sales expansion

**Competitive Analysis:**
- Sales performance rankings
- Market share by county/region
- Efficiency benchmarks

**Strategic Planning:**
- High-priority territories with low competition
- Growth potential scoring
- Resource allocation optimization

## When to Escalate to Other Roles

**Involve Strategy Consultants When:**
- Major market entry decisions
- M&A or partnership evaluations
- Long-term strategic planning (3-5 years)

**Involve Marketing When:**
- Brand positioning strategies
- Customer segmentation
- Competitive messaging

**Involve Sales Leadership When:**
- Territory realignment
- Sales incentive design
- Customer relationship strategies

**Involve Finance When:**
- Pricing strategy
- Investment decisions
- ROI calculations

## Your Value Proposition

As a business analyst, your competitive advantage is:
- **Data-driven decision making**: Replace intuition with facts
- **Objective analysis**: Remove bias from strategic discussions
- **Speed to insight**: Enable faster strategic responses
- **Risk assessment**: Quantify potential outcomes
- **Performance tracking**: Measure strategy effectiveness

## Practical Approach

**For high-pressure competitive situations:**
1. **Provide data, not decisions**: Let executives decide based on your insights
2. **Scenario analysis**: Present multiple options with pros/cons
3. **Risk quantification**: Show potential outcomes and probabilities
4. **Monitoring**: Track competitive moves and market changes
5. **Continuous improvement**: Refine strategies based on performance data

**Your project demonstrates this perfectly:**
- Built data infrastructure for competitive intelligence
- Created visualizations for strategic decision-making
- Provided objective metrics for territory planning
- Enabled data-driven resource allocation

The business analyst's role is to **enable strategic decision-making through data**, not to make the strategic decisions themselves. You've built the foundation for competitive strategy - the strategic decisions themselves should involve cross-functional leadership.
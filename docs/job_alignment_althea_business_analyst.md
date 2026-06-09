# Job Alignment Analysis — Althea Business Analyst

**Job Title:** Business Analyst  
**Company:** Althea  
**Location:** Clackamas, OR (Hybrid)  
**Compensation:** $70,000 - $95,000 / year  
**Analysis Date:** June 8, 2026  
**Overall Alignment:** 85-90% match

---

## Executive Summary

This portfolio demonstrates **exceptional alignment** with the Althea Business Analyst role, particularly in areas that differentiate candidates: reconciliation discipline, audit-ready documentation, cross-functional analytics, and business value quantification.

**Key Strengths:**
- GHG emissions verification (Project 4) is a perfect match for job requirements
- Quarterly data collection & QA/QC workflow (Project 2) directly addresses core responsibilities
- Cross-functional data integration across Sales, Operations, Labor, Finance, Sustainability
- Strong data storytelling with quantified business impact ($245K monthly improvement identified)
- SQL-first analytics engineering approach with rigorous QA controls

**Priority Gaps to Address:**
1. Power BI implementation (currently planning-only, needs actual dashboards)
2. ROI/breakeven analysis KPIs (mentioned but not fully implemented)
3. Excel/PowerPoint examples (not demonstrated in portfolio)

---

## Detailed Requirement Mapping

### Excellent Matches (Job → Portfolio)

#### 1. GHG Emissions Verification
**Job Requirement:** "Assist with verification of greenhouse gas emissions and all phases of Scope, following internal procedures and maintaining external standards and guidelines"

**Portfolio Match:** Project 4 — GHG Scope Reporting + Audit-Ready Documentation
- ✅ Scope 1, Scope 2, Scope 3 emissions modeling
- ✅ Versioned emission factor matching with traceability
- ✅ Audit-ready documentation (methodology, assurance checklist, control catalog)
- ✅ Source-to-metric lineage
- ✅ QA controls and exception reporting
- ✅ Reportable vs. non-reportable row logic

**Evidence:**
- `04_ghg_scope_reporting/docs/Methodology.md`
- `04_ghg_scope_reporting/docs/assurance_request_checklist.md`
- `04_ghg_scope_reporting/docs/control_catalog.md`
- `04_ghg_scope_reporting/docs/source_lineage.md`

**Alignment:** Perfect match — this project directly demonstrates the exact GHG verification work required

---

#### 2. Quarterly Data Collection & QA/QC
**Job Requirement:** "Measuring progress to find improvements in implemented systems by reconciling data across sources and tracking data gaps, outliers, and other discrepancies during quarterly data collection"

**Portfolio Match:** Project 2 — Quarterly Data Collection + QA/QC System
- ✅ Governed quarterly intake, validation, reconciliation, and certification workflow
- ✅ DQ rule governance with rules catalog
- ✅ Record-level exceptions handling
- ✅ Operational-to-finance reconciliation
- ✅ Release notes / rules change discipline
- ✅ Hold-or-certify decision support

**Evidence:**
- `02_quarterly_dc_qaqc_system/docs/quarterly_data_collection_playbook.md`
- `02_quarterly_dc_qaqc_system/docs/dq_rules_catalog.md`
- `02_quarterly_dc_qaqc_system/docs/reconciliation_guide.md`

**Alignment:** Excellent match — entire project dedicated to this specific workflow

---

#### 3. Cross-Functional Data Integration
**Job Requirement:** "Integrates data from diverse business areas (Sales, Operations, People) to reveal relationships and craft visual narratives that support actionable decision-making"

**Portfolio Match:** Project 1 — Ops Command Center
- ✅ Manufacturer model integrating B2B, Direct, Sell-through channels
- ✅ Sales, Inventory, Labor, Finance data integration
- ✅ Conformed dimensions (Date, Store, SKU) across functions
- ✅ Cross-functional KPIs (Sales per Labor Hour, Gross Margin, In-Stock Rate)
- ✅ Reconciliation across sources (distributor vs. POS, sales vs. GL)

**Evidence:**
- `01_ops_command_center/sql/mart/` — cross-functional mart layer
- `01_ops_command_center/docs/business_analysis_examples.md` — integrated analysis examples
- `01_ops_command_center/sql/_qa/` — reconciliation controls

**Alignment:** Strong match — demonstrates exactly the cross-functional integration required

---

#### 4. Data Storytelling
**Job Requirement:** "Thinking creatively and transforming sometimes technical content into easy-to-understand narratives by presenting information through verbal, written, and digital communication"

**Portfolio Match:** Business Analysis Examples (Project 1)
- ✅ Store performance deep dives with root cause analysis
- ✅ Variance analysis beyond flagging (driver decomposition)
- ✅ Business recommendations with financial impact quantification
- ✅ Executive summaries with actionable insights
- ✅ $245K monthly improvement identified with specific recommendations

**Evidence:**
- `01_ops_command_center/docs/business_analysis_examples.md`
  - Store #47 underperformance analysis ($18.7K monthly opportunity)
  - Store #12 margin erosion analysis ($16.9K monthly recovery)
  - Store #33 labor productivity analysis ($8.9K monthly savings)
  - Variance decomposition with business narratives

**Alignment:** Excellent match — demonstrates strong narrative capability with quantified impact

---

#### 5. Documentation for External Assurance
**Job Requirement:** "Documenting data processes to support external assurance activities and information requests"

**Portfolio Match:** Project 4 — GHG Scope Reporting
- ✅ Methodology documentation with calculation logic
- ✅ Source-to-metric lineage from extracts to mart outputs
- ✅ Assumptions log with limitations and future improvements
- ✅ Assurance request checklist for audit-style review
- ✅ Control catalog with QA definitions and remediation guidance
- ✅ Source drop manifest with load metadata

**Evidence:**
- `04_ghg_scope_reporting/docs/Methodology.md`
- `04_ghg_scope_reporting/docs/source_lineage.md`
- `04_ghg_scope_reporting/docs/assumptions_log.md`
- `04_ghg_scope_reporting/docs/assurance_request_checklist.md`
- `04_ghg_scope_reporting/docs/control_catalog.md`

**Alignment:** Perfect match — demonstrates audit-ready documentation practices

---

### Gaps to Address

#### 1. Power BI Implementation (Critical Gap)
**Job Requirement:** "Highly proficient in Power BI, SQL, DAX, and Power Query is preferred"

**Current State:**
- Power BI semantic model planning documentation exists
- DAX measures catalog exists
- Relationship planning documented
- **No actual Power BI dashboards built**

**Portfolio Evidence:**
- `01_ops_command_center/powerbi/IMPLEMENTATION_GUIDE.md` (planning only)
- `01_ops_command_center/powerbi/semantic_model/` (DAX catalog, relationship planning)

**Gap:** Job requires proficiency in Power BI, but portfolio only shows planning, not implementation

**Action Required:**
- Build 1-2 actual Power BI dashboards using the existing mart layer
- Demonstrate DAX measures in working dashboards
- Show Power Query transformations if applicable
- Publish to Power BI service or provide screenshots

**Priority:** High — this is a stated preference in the job description

---

#### 2. ROI and Breakeven Analysis (Moderate Gap)
**Job Requirement:** "Evaluate ROI and breakeven analysis on new projects"

**Current State:**
- ROI/breakeven KPIs mentioned in TODO and mart layer structure
- `mart.roi_monthly` and `mart.breakeven_monthly` referenced in documentation
- Business analysis examples show financial impact analysis but not formal ROI/breakeven calculations

**Portfolio Evidence:**
- `01_ops_command_center/TODO.md` — mentions ROI/breakeven KPIs as 0-byte files to implement
- `01_ops_command_center/README.md` — lists ROI and breakeven as example KPIs
- Business analysis examples show financial impact but not ROI methodology

**Gap:** Job specifically calls out ROI/breakeven analysis, but portfolio doesn't demonstrate this analytical technique

**Action Required:**
- Complete implementation of `mart.kpi_roi_monthly` and `mart.kpi_breakeven_monthly`
- Add ROI analysis to business analysis examples
- Show breakeven analysis for specific initiatives (e.g., new store opening, product launch)
- Document ROI calculation methodology

**Priority:** Medium — job mentions this but it's not the primary focus

---

#### 3. Excel and PowerPoint (Minor Gap)
**Job Requirement:** "Power BI, Power Point, Excel and other mediums"

**Current State:**
- No Excel analysis examples demonstrated
- No PowerPoint executive summary templates shown
- Portfolio focuses on SQL, Tableau, documentation

**Gap:** Job lists Excel and PowerPoint as communication mediums, but portfolio doesn't demonstrate proficiency

**Action Required:**
- Add Excel-based analysis example (pivot table analysis from mart data, financial model)
- Create PowerPoint executive summary template
- Show data export and analysis workflow
- Document Excel/PowerPoint integration with SQL pipeline

**Priority:** Low — these are tools, not core analytical capabilities

---

## Portfolio Strengths That Differentiate

### 1. Reconciliation Discipline
**What It Shows:** Most portfolios don't demonstrate this level of QA/QC rigor
**Evidence:**
- `mart.recon_sales_to_gl_monthly` — finance reconciliation with tolerance logic
- `mart.recon_sales_distributor_vs_pos` — source-to-source reconciliation
- `mart.controls_rowcounts_daily` — row count monitoring
- `mart.controls_missing_dim_joins` — dimension join validation
- Hard-fail QA suite that stops pipeline on contract violations

**Differentiation:** Shows you understand that trustworthy analytics requires reconciliation, not just visualization

---

### 2. Audit-Ready Documentation
**What It Shows:** Assurance thinking is rare in analytics portfolios
**Evidence:**
- Project 4 has complete assurance request checklist
- Methodology documentation with calculation logic
- Source-to-metric lineage
- Control catalog with risk remediation
- Assumptions log with limitations

**Differentiation:** Demonstrates you can work in regulated environments requiring external review

---

### 3. Business Value Quantification
**What It Shows:** You translate analysis into actionable financial impact
**Evidence:**
- $245K monthly improvement identified in business analysis examples
- Specific recommendations with expected financial impact
- Store-level remediation plans with dollar-value recovery
- Variance decomposition with business narratives

**Differentiation:** Most portfolios show technical work; few show business value quantification

---

### 4. Cross-Functional Thinking
**What It Shows:** You understand how Sales, Ops, Labor, Finance, and Sustainability connect
**Evidence:**
- 6 projects spanning different business domains
- Shared dimensions and conformed logic across functions
- Cross-functional KPIs (Sales per Labor Hour, Gross Margin, In-Stock Rate)
- Integrated analysis across business areas

**Differentiation:** Shows you can think beyond single-function analytics

---

### 5. SQL-First Approach
**What It Shows:** Strong foundation that's harder to fake than dashboarding
**Evidence:**
- 79 SQL views across staging, integration, mart layers
- Complex data modeling (conformed dimensions, truth selection, grain management)
- Hard-fail QA suite with contract validation
- Layered warehouse pattern (Raw → STG → INT → MART)

**Differentiation:** SQL proficiency is a core skill that's difficult to fake; dashboarding is easier to learn

---

## Action Plan

### Priority 1: Power BI Implementation (High)
**Timeline:** 2-3 weeks  
**Effort:** 10-15 hours

**Actions:**
1. Build Executive Overview dashboard in Power BI using Project 1 mart layer
2. Build Reconciliation & Data Health dashboard in Power BI
3. Implement key DAX measures (Net Sales, Gross Margin %, Sales per Labor Hour)
4. Create Power BI semantic model with relationships
5. Add screenshots to README and update tech stack documentation

**Deliverables:**
- Working Power BI dashboard (.pbix file)
- DAX measures catalog (updated with actual implementations)
- Dashboard screenshots for portfolio
- Power BI implementation notes

---

### Priority 2: ROI/Breakeven KPIs (Medium)
**Timeline:** 1-2 weeks  
**Effort:** 5-8 hours

**Actions:**
1. Implement `mart.kpi_roi_monthly` SQL view
2. Implement `mart.kpi_breakeven_monthly` SQL view
3. Add ROI analysis to business analysis examples
4. Document ROI calculation methodology
5. Create breakeven analysis example (e.g., new store investment)

**Deliverables:**
- Working ROI and breakeven KPI views
- ROI analysis example with methodology
- Updated business analysis documentation

---

### Priority 3: Excel Analysis Example (Low)
**Timeline:** 3-5 days  
**Effort:** 3-5 hours

**Actions:**
1. Export mart data to Excel
2. Create pivot table analysis example
3. Build simple financial model in Excel
4. Document Excel workflow
5. Add Excel file to portfolio (or screenshots)

**Deliverables:**
- Excel analysis example file
- Documentation of Excel workflow
- Screenshots for portfolio

---

## Additional Job-Specific Considerations

### Hybrid Work Requirement
**Job:** "Must be able to reliably work hybrid and commute to and from Clackamas, OR"

**Portfolio Impact:** N/A — portfolio doesn't demonstrate location/work arrangement

**Action:** Not applicable to portfolio; address in cover letter/interview

---

### Cannabis Industry Context
**Job:** Althea produces cannabis edibles and operates in multiple states

**Portfolio Impact:** Your portfolio uses Oregon cannabis business license data (1,053 entities) for realistic manufacturer model

**Strength:** Shows industry awareness and realistic data simulation

**Action:** Highlight this in cover letter — portfolio demonstrates understanding of cannabis CPG business model

---

### Social and Environmental Interest
**Job:** "Strong interest in social and environmental affairs"

**Portfolio Impact:** Project 4 (GHG emissions reporting) demonstrates environmental sustainability focus

**Strength:** Shows alignment with company values around environmental responsibility

**Action:** Emphasize Project 4 in cover letter as demonstration of environmental commitment

---

## Conclusion

Your portfolio is **exceptionally well-aligned** with this specific Althea Business Analyst role. The GHG emissions verification requirement is a perfect match for Project 4, and the quarterly QA/QC workflow directly addresses a core responsibility.

**Key Differentiators:**
1. Reconciliation discipline (most candidates don't show this)
2. Audit-ready documentation (rare in portfolios)
3. Business value quantification ($245K impact identified)
4. Cross-functional thinking across 6 domains
5. SQL-first foundation (harder to fake than dashboarding)

**Critical Gap to Close:**
- Power BI implementation (job states "proficient in Power BI is preferred")

**Recommended Approach:**
1. Build 1-2 Power BI dashboards (Priority 1)
2. Complete ROI/breakeven KPIs (Priority 2)
3. Add Excel analysis example (Priority 3)
4. Apply with confidence — your portfolio demonstrates exactly the disciplined, cross-functional analytics work this job requires

**Timeline:** 3-4 weeks to address all gaps

---

## Tracking

**Analysis Date:** June 8, 2026  
**Last Updated:** June 8, 2026  
**Status:** Active — gaps identified, action plan in progress

**Progress:**
- [x] Job alignment analysis completed
- [ ] Power BI dashboards built
- [ ] ROI/breakeven KPIs implemented
- [ ] Excel analysis example added

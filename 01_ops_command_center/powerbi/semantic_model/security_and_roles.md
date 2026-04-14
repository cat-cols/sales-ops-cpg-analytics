# Security and Roles — Project 1

## Purpose

This document defines the intended security and report-access model for Project 1.

The current project is a portfolio case study and does not require full production security implementation, but documenting expected roles is still important because it shows how the semantic model would be governed in a real business environment.

---

## Security Philosophy

The semantic model should support different reporting audiences without exposing every user to every diagnostic or detailed object by default.

Security design should aim to:

- give leadership broad summary visibility
- restrict operational detail where appropriate
- separate executive consumption from analyst diagnostics
- make row-level access possible if the model later expands into a real deployment

---

## Current State

### Implemented today
- security is documented, not fully enforced in Power BI
- QA and trust controls exist at the SQL layer
- report-page design already separates executive and diagnostic content logically

### Future implementation target
- role-based access in Power BI
- optional row-level security by state or store
- audience-specific report views

---

## Proposed Roles

## 1. Executive

### Intended audience
- CEO / GM
- VP-level stakeholders
- senior leadership

### Access level
- full read access to summary reporting
- access to executive overview and performance pages
- access to reconciliation summary indicators
- no need for raw diagnostics detail by default

### Primary pages
- Executive Overview
- Sales & Margin
- Ops & Inventory
- People & Productivity

---

## 2. Analyst

### Intended audience
- business analyst
- BI analyst
- analytics engineer
- finance analyst

### Access level
- full read access to all report pages
- access to reconciliation and diagnostics pages
- access to detailed drillthrough
- access to trust / control outputs

### Primary pages
- all pages

### Notes
This is the broadest read-access role in the current design.

---

## 3. Regional / Area Manager

### Intended audience
- regional commercial lead
- regional operations leader
- area manager

### Access level
- summary and performance pages
- row-level scope limited to assigned state or region
- optional access to reconciliation pages filtered to owned scope

### Potential row-level filter
- `dim_store.state`
- or a future region mapping table

---

## 4. Store / Operations Manager

### Intended audience
- local store or operations lead

### Access level
- visibility into assigned store or small set of stores
- operational and productivity pages emphasized
- limited exposure to enterprise-wide data

### Potential row-level filter
- `dim_store.store_code`

---

## 5. Finance / Trust Reviewer

### Intended audience
- finance partner
- data quality reviewer
- trust / governance stakeholder

### Access level
- read access to reconciliation and diagnostics pages
- access to finance-style controls
- access to core KPI pages for comparison context

### Primary pages
- Executive Overview
- Reconciliation & Data Health
- Sales & Margin

---

## Proposed Security Layers

## Report-page access
Use page design itself to separate:
- executive summary use
- detailed operational analysis
- diagnostics / trust review

## Row-level security
If implemented later, RLS would most likely filter on:
- `dim_store.state`
- `dim_store.store_code`

## Sensitive-detail handling
If the semantic model later includes more workforce-sensitive detail, employee-level pages may need more restricted access than store-level summary pages.

---

## Example Role Matrix

| Role | Executive Overview | Sales & Margin | Ops & Inventory | People & Productivity | Reconciliation & Data Health | Detail Drillthrough |
|---|---|---|---|---|---|---|
| Executive | Yes | Yes | Yes | Yes | Summary only | No |
| Analyst | Yes | Yes | Yes | Yes | Yes | Yes |
| Regional Manager | Yes | Yes | Yes | Yes | Limited | Limited |
| Store / Ops Manager | Yes | Limited | Yes | Yes | Limited | Limited |
| Finance / Trust Reviewer | Yes | Yes | Optional | Optional | Yes | Yes |

---

## Role Design Principles

- the executive role should see trusted summary signals, not every technical detail
- the analyst role should have the fullest visibility
- regional and store roles should be row-filtered where relevant
- diagnostics access should be intentional, not accidental
- the first version of the model should prioritize clarity over overly complex security logic

---

## Current Recommendation

For Project 1 documentation, treat security as:

- **designed**
- **documented**
- **ready for later Power BI implementation**

The current value is in showing that the semantic model was built with audience separation in mind, even before a production deployment exists.
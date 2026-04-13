# Page Inventory — Project 1 (Ops Command Center)

## Purpose

This document defines the intended report-page architecture for Project 1.

The goal is to make the reporting layer feel like a real business product:

- each page has a clear audience
- each page has a clear decision purpose
- KPI usage is intentional
- reconciliation and trust are visible, not hidden

The report is designed around six pages:

1. Executive Overview
2. Sales & Margin
3. Ops & Inventory
4. People & Productivity
5. Reconciliation & Data Health
6. Detail Drillthrough

---

## Page 1 — Executive Overview

### Audience
- executive leadership
- GM / VP-level stakeholders
- cross-functional business leads

### Purpose
Provide a high-level operating snapshot across Sales, Margin, Inventory, and Labor productivity.

### Core questions answered
- Are we performing above or below expectation?
- What changed versus the prior period?
- Where are the biggest risks or opportunities?
- Is the data trustworthy enough to act on?

### Core KPIs
- Net Sales
- Gross Sales
- Gross Margin $
- Gross Margin %
- Net Sales per Labor Hour
- In-Stock Rate
- Reconciliation Status

### Suggested visuals
- KPI cards across the top
- Net Sales trend line
- Gross Margin % trend line
- Sales by state or store bar chart
- Top / bottom movers table
- short trust-status card or banner

### Key filters
- Date
- State
- Store
- Channel
- SKU category or product family

### Notes
This page should be simple, fast to read, and executive-friendly. It should emphasize signal over detail.

---

## Page 2 — Sales & Margin

### Audience
- commercial leaders
- finance partners
- sales / revenue stakeholders

### Purpose
Analyze top-line sales performance, product mix, discounts, and margin behavior.

### Core questions answered
- What is driving sales and margin?
- Which stores, SKUs, or channels are strongest or weakest?
- Are discounts compressing margin?
- How is performance trending over time?

### Core KPIs
- Gross Sales
- Net Sales
- Discount Amount
- Gross Margin $
- Gross Margin %
- Units Sold
- Average Order Value
- Units per Order

### Suggested visuals
- sales trend by month / week
- gross margin % trend
- sales by store
- sales by SKU / product family
- discount vs margin scatter or combo view
- top and bottom SKU table

### Key filters
- Date
- Store
- SKU
- Product family
- Channel
- Sales source

### Notes
This page should use `mart.fact_sales_daily` as the primary reporting surface, with drill capability into source-specific sales facts when needed.

---

## Page 3 — Ops & Inventory

### Audience
- operations
- supply chain
- inventory planning

### Purpose
Show inventory health, availability, and fulfillment support metrics.

### Core questions answered
- Are key items in stock?
- Where are stockouts or inventory risks building?
- How much inventory coverage do we have?
- Are shipments supporting demand?

### Core KPIs
- In-Stock Rate
- Days of Supply
- On Hand Units
- Units Shipped
- Backorder-related metrics if surfaced
- Coverage exceptions

### Suggested visuals
- in-stock rate trend
- days of supply heatmap by SKU / store
- inventory by store
- on-hand vs shipped comparison
- low-coverage SKU table
- stockout / risk exception table

### Key filters
- Date
- Store
- SKU
- Product family
- State

### Notes
This page should balance summary KPIs with exception visibility. It should help users identify operational bottlenecks quickly.

---

## Page 4 — People & Productivity

### Audience
- operations leadership
- people / workforce stakeholders
- finance partners reviewing efficiency

### Purpose
Connect labor inputs to business output.

### Core questions answered
- How much labor was used?
- How productive were stores?
- Which stores are generating strong or weak sales per labor hour?
- Are labor and sales moving together appropriately?

### Core KPIs
- Labor Hours
- Labor Cost
- Net Sales per Labor Hour
- Gross Sales per Labor Hour
- Overtime-related metrics if added later
- Headcount / employee-level diagnostics if surfaced later

### Suggested visuals
- labor hours trend
- net sales per labor hour trend
- store productivity ranking
- labor hours vs net sales comparison
- employee-level or team-level detail table for later expansion

### Key filters
- Date
- Store
- State
- Department / team if added later

### Notes
This is the main cross-functional productivity page and should connect clearly back to both sales and workforce inputs.

---

## Page 5 — Reconciliation & Data Health

### Audience
- analysts
- finance partners
- stakeholders who need trust / QA visibility

### Purpose
Make data quality, reconciliation status, and trust metrics explicit.

### Core questions answered
- Do modeled results tie to source and finance references?
- Are there any missing dimension joins?
- Are control checks passing?
- Are current warnings acceptable?

### Core KPIs
- Sales vs GL Delta $
- Sales vs GL Delta %
- Reconciliation Status
- Missing Dimension Join Count
- Data Freshness Status
- Rowcount / coverage control summaries

### Suggested visuals
- reconciliation status cards
- monthly sales-to-GL comparison table
- distributor vs POS variance table
- missing dimension join table
- freshness / control banner
- QA summary matrix

### Key filters
- Date
- Metric
- Store where relevant
- Domain / control type

### Notes
This page should look operational and diagnostic rather than polished like an executive scorecard. It is a trust page.

---

## Page 6 — Detail Drillthrough

### Audience
- analysts
- power users
- anyone investigating a specific store / SKU / date issue

### Purpose
Provide row-level or lower-grain diagnostic detail behind summary metrics.

### Core questions answered
- Which specific store, SKU, or date is behind this issue?
- What detail supports the KPI shown on the summary page?
- Where exactly is the exception or variance occurring?

### Suggested views
- drillthrough table by store / SKU / date
- source-specific detail slices
- labor detail by store / date
- inventory detail by store / SKU
- recon detail by metric / period

### Key filters
- inherited drillthrough context
- Date
- Store
- SKU
- Metric

### Notes
This page is primarily investigative. It does not need to be visually fancy; it needs to be useful.

---

## Cross-Page Filter Strategy

### Recommended shared slicers
- Date
- State
- Store
- SKU / product family

### Use with care
- Channel
- Sales source
- KPI metric selector

These are useful but can confuse business users if overused globally.

---

## Navigation Guidance

### Recommended order
1. Executive Overview
2. Sales & Margin
3. Ops & Inventory
4. People & Productivity
5. Reconciliation & Data Health
6. Detail Drillthrough

### Reason
This order mirrors how stakeholders usually consume information:

- what happened
- why it happened
- where the risk is
- whether the data can be trusted
- where to investigate further

---

## Page Design Principles

- keep each page focused on one decision theme
- avoid overloading pages with too many visuals
- show KPIs first, then trends, then exceptions
- use diagnostics intentionally rather than scattering trust metrics everywhere
- make drill paths obvious
- keep executive pages simple and analysis pages denser

---

## Current Project Recommendation

For the first Power BI version, build these pages in order:

1. Executive Overview
2. Reconciliation & Data Health
3. Sales & Margin

That gives the strongest portfolio story fastest:

- leadership-facing value
- trust and QA maturity
- commercial analysis depth
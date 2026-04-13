# Tooltip Narratives — Project 1 (Ops Command Center)

## Purpose

This document defines the narrative tooltip approach for Project 1.

The goal is to make Power BI tooltips do more than restate a number. Tooltips should help answer:

- what changed
- where it changed
- whether it matters
- whether the result is trustworthy

These tooltip narratives are intended to support executive-friendly storytelling while staying grounded in the semantic model.

---

## Design Principles

- keep tooltip text short and readable
- explain change, not just restate value
- highlight one or two likely drivers
- surface trust caveats only when relevant
- avoid robotic or overly technical language
- tie narratives back to governed measures

---

## Tooltip Categories

### 1. KPI summary tooltips
Used on KPI cards and top-line summary visuals.

Purpose:
- explain current value
- add period-over-period context
- highlight the main driver if available

### 2. trend tooltips
Used on line charts, bar charts, and trend visuals.

Purpose:
- explain what changed in the hovered period
- identify where the biggest contribution came from
- highlight exceptions or unusual movement

### 3. trust / reconciliation tooltips
Used on reconciliation, QA, and diagnostics visuals.

Purpose:
- explain why a status is pass, warning, or fail
- summarize the variance
- make data-health signals understandable to non-technical users

### 4. operational exception tooltips
Used on inventory, stockout, or coverage visuals.

Purpose:
- explain what is elevated or at risk
- identify where the issue is concentrated
- suggest what the user should inspect next

---

## Narrative Style Rules

### Preferred style
- plain English
- one to three sentences
- interpretive, not overly descriptive
- business-facing tone

### Good examples
- Net Sales increased 6.2% vs the prior period, led by stronger performance in OR and CA.
- In-Stock Rate is below target today, with the biggest pressure concentrated in THC gummy SKUs.
- Sales to GL reconciliation is within tolerance for the selected month, so modeled sales can be treated as trusted for summary reporting.

### Avoid
- repeating raw numbers without interpretation
- overly technical SQL language
- long paragraphs
- unexplained acronyms
- making unsupported causal claims

---

## Suggested Narrative Patterns

## Pattern 1 — KPI card narrative

### Template
**`<Metric>` is `<up/down/flat>` by `<x%>` vs `<comparison period>`, driven mainly by `<driver>` and partially offset by `<secondary driver>`.**

### Example
Net Sales is up 4.8% vs the prior month, driven mainly by higher unit volume in WA and OR, partially offset by lower margin mix in AZ.

---

## Pattern 2 — trend point narrative

### Template
In `<period>`, `<metric>` was `<value>`, `<up/down>` `<x%>` vs `<comparison period>`. The largest contribution came from `<dimension member>`.

### Example
In January 2025, Gross Sales were $941K, up 2.1% vs the prior reference period. The largest contribution came from OR stores.

---

## Pattern 3 — reconciliation narrative

### Template
`<Metric>` is currently `<within / outside>` tolerance at `<x%>` variance. `<Short explanation of status>`.

### Example
Gross Margin is currently within tolerance at 3.1% variance. This metric uses a wider tolerance than base finance measures because it is derived from both net sales and COGS.

---

## Pattern 4 — operational risk narrative

### Template
`<Metric>` is elevated / below target at `<value>`. The issue is most concentrated in `<location / SKU / channel>`.

### Example
Days of Supply is low for the selected slice. The tightest coverage is concentrated in WA stores for core gummy SKUs.

---

## Pattern 5 — trust warning narrative

### Template
This result should be interpreted with caution because `<control condition>`. `<Optional next step>`.

### Example
This result should be interpreted with caution because freshness warnings are present for the current simulated data snapshot. Review the Reconciliation & Data Health page before using this output in a decision summary.

---

## Recommended Narrative Measures

These are suggested report-layer narrative measures to build in Power BI.

### Executive / KPI narratives
- `Narrative - Net Sales`
- `Narrative - Gross Margin`
- `Narrative - Sales per Labor Hour`
- `Narrative - In-Stock Rate`

### Reconciliation / trust narratives
- `Narrative - Sales vs GL Status`
- `Narrative - Reconciliation Status`
- `Narrative - Freshness Status`
- `Narrative - Missing Dimension Joins`

### Operational / exception narratives
- `Narrative - Days of Supply`
- `Narrative - Inventory Risk`
- `Narrative - Productivity Exception`

---

## Example Narrative Logic by Page

## Executive Overview

### Net Sales tooltip
Net Sales is [up/down] [x%] vs [prior period], with the largest contribution coming from [top state/store]. [Optional trust note].

### Gross Margin tooltip
Gross Margin is [up/down] [x%] vs [prior period]. Margin performance reflects changes in both sales mix and COGS behavior.

### Reconciliation Status tooltip
Current reconciliation status is [Pass/Warning/Fail]. Use the Reconciliation & Data Health page for metric-level variance details.

---

## Sales & Margin

### Sales trend tooltip
In [period], Net Sales were [value], [up/down] [x%] vs [comparison period]. The strongest contribution came from [top store/SKU/channel].

### Gross Margin % tooltip
Gross Margin % is [value], [up/down] [x bps or x%] vs [comparison period]. This metric is sensitive to both discount behavior and COGS mix.

### Discount tooltip
Discount Amount is [value]. Elevated discounts may support volume but can compress gross margin if not offset by mix or demand.

---

## Ops & Inventory

### In-Stock Rate tooltip
In-Stock Rate is [value]. The lowest availability is concentrated in [store/SKU group].

### Days of Supply tooltip
Days of Supply is [value]. Coverage is [healthy / tight / elevated] relative to recent demand.

### Inventory risk tooltip
Inventory risk is highest in [location or SKU slice]. Review low-coverage items and shipment support before the next replenishment cycle.

---

## People & Productivity

### Labor Hours tooltip
Labor Hours are [value], [up/down] [x%] vs [comparison period]. Review alongside sales output to assess efficiency.

### Net Sales per Labor Hour tooltip
Net Sales per Labor Hour is [value], [up/down] [x%] vs [comparison period]. [Top store or state] is contributing most to current productivity.

### Productivity exception tooltip
Productivity is below benchmark in [store / state]. Check labor hours against recent sales trend and mix.

---

## Reconciliation & Data Health

### Sales vs GL tooltip
[Metric] is [within / outside] tolerance at [x%] variance. This check compares modeled sales outputs to finance-style monthly actuals.

### Missing dimension joins tooltip
There are [count] rows missing expected dimension matches. These should be reviewed before trusting highly sliced reporting outputs.

### Freshness tooltip
Freshness status is [Pass/Warn/Fail]. In this project, warnings may be expected because the source data is simulated and static between runs.

---

## Suggested DAX Structure

Narrative measures should generally be built from:

- a current metric value
- a prior-period comparison
- a status or driver component
- optional trust language

### Common DAX building blocks
- `FORMAT()`
- `DIVIDE()`
- `IF()`
- `SWITCH()`
- comparison measures like prior-period delta
- status measures from recon / control views
- top-contributor helper measures if added later

---

## Example Pseudo-DAX Pattern

```text
Narrative - Net Sales =
"Net Sales is " &
[Direction Label] &
" by " &
FORMAT([Net Sales vs Prior Period %], "0.0%") &
" vs the prior period, driven mainly by " &
[Top Contributor Label] &
"."
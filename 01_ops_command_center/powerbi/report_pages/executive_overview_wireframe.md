# Executive Overview Wireframe — Project 1 (Ops Command Center)

## Purpose

This page is the first screen an executive should be able to open and understand quickly.

It should answer:

- Are we performing well?
- What changed?
- Where is the biggest risk or opportunity?
- Can the current numbers be trusted?

This page is not meant to show everything. It is meant to show the most important signals with enough context to guide the next click.

---

## Audience

Primary audience:

- executive leadership
- GM / VP-level stakeholders
- cross-functional business leads

Secondary audience:

- analysts using this page as the starting point for deeper drill-through

---

## Design Goals

- make the page readable in under 30 seconds
- show top-line business performance first
- include one clear trust / reconciliation signal
- balance commercial, operational, and workforce context
- avoid clutter
- make drill paths obvious

---

## Layout Overview

Recommended page structure:

1. global filters row
2. top KPI row
3. trend + mix row
4. performance and risk row
5. trust / action row

---

## Page Filters

Place these at the top of the page.

### Recommended slicers
- Date
- State
- Store
- SKU / Product Family
- Channel
- Sales Source

### Guidance
- keep slicers compact
- avoid overloading the page with too many global controls
- use synced slicers only where they improve usability
- Date should be the primary slicer

---

## Section 1 — KPI Header Row

This row should contain the most important top-line cards.

### KPI cards
1. **Net Sales**
2. **Gross Margin %**
3. **Net Sales per Labor Hour**
4. **In-Stock Rate**
5. **Reconciliation Status**

### Optional sixth KPI
6. **Days of Supply** or **Labor Hours**

### KPI card behavior
Each KPI card should ideally show:
- current value
- prior-period delta
- directional indicator
- tooltip narrative

### Recommended interpretation
- Net Sales = top-line commercial signal
- Gross Margin % = profitability signal
- Net Sales per Labor Hour = productivity signal
- In-Stock Rate = operational health signal
- Reconciliation Status = trust signal

---

## Section 2 — Trend and Mix Row

This row should explain what changed over time and where performance is coming from.

### Left visual
**Net Sales Trend**
- line chart
- x-axis: date
- y-axis: net sales
- optional comparison to prior period

### Middle visual
**Gross Margin % Trend**
- line or combo chart
- x-axis: date
- y-axis: gross margin %
- optional secondary line for net sales

### Right visual
**Sales Mix by State / Store / Channel**
Choose one depending on the strongest business story:
- clustered bar chart by state
- bar chart by top stores
- stacked bar by channel

### Goal of this row
Help answer:
- Is performance improving or deteriorating?
- Is change broad-based or concentrated?
- Which slices are driving the result?

---

## Section 3 — Performance and Risk Row

This row should connect performance to operations and labor.

### Left visual
**Top / Bottom Stores**
- ranked bar chart or table
- metric toggle:
  - Net Sales
  - Gross Margin %
  - Net Sales per Labor Hour

### Middle visual
**Inventory Health Snapshot**
Options:
- In-Stock Rate by store
- Days of Supply by SKU / store heatmap
- exception table for low coverage

### Right visual
**Productivity Snapshot**
Options:
- Net Sales per Labor Hour by store
- labor hours vs net sales scatter
- store productivity ranking

### Goal of this row
Help answer:
- Where is performance strongest or weakest?
- Are operations supporting demand?
- Is labor efficiency aligned with sales?

---

## Section 4 — Trust and Action Row

This row should make data-health and actionability visible without overwhelming the page.

### Left visual
**Reconciliation / Trust Banner**
This can be:
- a KPI card
- a text box driven by a measure
- a compact matrix showing pass / warning / fail counts

Suggested content:
- Reconciliation Status
- Missing Dimension Join Count
- Freshness Status

### Middle visual
**Narrative Summary Box**
A text-driven summary such as:
- Net Sales increased vs prior period
- strongest contribution came from OR and WA
- inventory risk is elevated in selected SKU group
- current reconciliation status is pass / warning

This should be powered by narrative measures if possible.

### Right visual
**Recommended Focus / Exception Table**
A small table showing:
- top 5 issues
- top 5 opportunities
- top exception stores / SKUs

Examples:
- lowest in-stock rate
- weakest gross margin %
- highest sales vs GL delta
- weakest sales per labor hour

---

## Suggested Wireframe Sketch

```text
+--------------------------------------------------------------------------------------------------+
| Date | State | Store | Product Family | Channel | Sales Source                                   |
+--------------------------------------------------------------------------------------------------+

+----------------+-------------------+---------------------------+----------------+----------------------+
| Net Sales      | Gross Margin %    | Net Sales / Labor Hour   | In-Stock Rate  | Reconciliation Status|
| value + delta  | value + delta     | value + delta            | value + delta  | pass / warn / fail   |
+----------------+-------------------+---------------------------+----------------+----------------------+

+-----------------------------------+-----------------------------------+-----------------------------------+
| Net Sales Trend                   | Gross Margin % Trend              | Sales Mix by State / Store / Ch.  |
+-----------------------------------+-----------------------------------+-----------------------------------+

+-----------------------------------+-----------------------------------+-----------------------------------+
| Top / Bottom Stores               | Inventory Health Snapshot         | Productivity Snapshot             |
+-----------------------------------+-----------------------------------+-----------------------------------+

+-----------------------------------+-----------------------------------+-----------------------------------+
| Trust / Recon Banner              | Narrative Summary                 | Focus / Exception Table           |
+-----------------------------------+-----------------------------------+-----------------------------------+

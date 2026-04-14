# Measure Display Folders — Project 1

## Purpose

This document defines the recommended Power BI display-folder structure for Project 1.

The goal is to keep the semantic model readable for report developers and maintainable as the measure layer grows. Display folders should make it easy to distinguish:

- base measures
- derived KPIs
- comparison measures
- reconciliation / trust measures
- narrative measures

---

## Folder Design Principles

- keep folder names short and obvious
- group by business purpose, not by table name
- separate base measures from derived measures
- keep diagnostic / trust measures away from executive KPI folders
- use a consistent structure across report pages

---

## Recommended Display Folder Structure

### Base Measures
Use for simple additive or direct aggregation measures.

Examples:
- Gross Sales
- Net Sales
- COGS
- Discount Amount
- Units Sold
- Orders
- Customers
- Labor Hours
- Labor Cost
- On Hand Units
- Units Shipped

### Sales KPIs
Use for derived commercial measures.

Examples:
- Gross Margin $
- Gross Margin %
- Average Order Value
- Units per Order

### Labor KPIs
Use for workforce efficiency measures.

Examples:
- Net Sales per Labor Hour
- Gross Sales per Labor Hour

### Inventory KPIs
Use for operations and availability measures.

Examples:
- In-Stock Rate
- Days of Supply

### Finance KPIs
Use for finance-style modeled outputs.

Examples:
- ROI
- Breakeven Net Sales

### Time Intelligence
Use for prior-period and trend comparison logic.

Examples:
- Net Sales vs Prior Period $
- Net Sales vs Prior Period %
- Gross Margin bps Change
- Labor Productivity vs Prior Period %

### Reconciliation
Use for explicit source-to-model or model-to-finance comparison measures.

Examples:
- Sales vs GL Delta $
- Sales vs GL Delta %
- Distributor vs POS Delta $
- Distributor vs POS Delta %

### Diagnostics / Trust
Use for model-health and trust indicators.

Examples:
- Reconciliation Status
- Missing Dimension Join Count
- Data Freshness Status
- Control Warning Count

### Narrative Measures
Use for text outputs, tooltips, and plain-English summaries.

Examples:
- Narrative - Net Sales
- Narrative - Gross Margin
- Narrative - Net Sales per Labor Hour
- Narrative - In-Stock Rate
- Narrative - Sales vs GL Status

---

## Suggested Folder Map

| Measure | Display Folder |
|---|---|
| Gross Sales | Base Measures |
| Net Sales | Base Measures |
| COGS | Base Measures |
| Discount Amount | Base Measures |
| Units Sold | Base Measures |
| Orders | Base Measures |
| Customers | Base Measures |
| Labor Hours | Base Measures |
| Labor Cost | Base Measures |
| On Hand Units | Base Measures |
| Units Shipped | Base Measures |
| Gross Margin $ | Sales KPIs |
| Gross Margin % | Sales KPIs |
| Average Order Value | Sales KPIs |
| Units per Order | Sales KPIs |
| Net Sales per Labor Hour | Labor KPIs |
| Gross Sales per Labor Hour | Labor KPIs |
| In-Stock Rate | Inventory KPIs |
| Days of Supply | Inventory KPIs |
| ROI | Finance KPIs |
| Breakeven Net Sales | Finance KPIs |
| Net Sales vs Prior Period $ | Time Intelligence |
| Net Sales vs Prior Period % | Time Intelligence |
| Gross Margin bps Change | Time Intelligence |
| Sales vs GL Delta $ | Reconciliation |
| Sales vs GL Delta % | Reconciliation |
| Distributor vs POS Delta % | Reconciliation |
| Reconciliation Status | Diagnostics / Trust |
| Missing Dimension Join Count | Diagnostics / Trust |
| Data Freshness Status | Diagnostics / Trust |
| Narrative - Net Sales | Narrative Measures |
| Narrative - Gross Margin | Narrative Measures |
| Narrative - Sales vs GL Status | Narrative Measures |

---

## Naming Guidance

- display folders should use `Title Case`
- do not prefix folder names with table names
- do not create one-off folders unless there are multiple related measures
- avoid deeply nested folder structures for the first version

---

## Current Recommendation

For Project 1, use this exact first-pass folder structure:

- Base Measures
- Sales KPIs
- Labor KPIs
- Inventory KPIs
- Finance KPIs
- Time Intelligence
- Reconciliation
- Diagnostics / Trust
- Narrative Measures

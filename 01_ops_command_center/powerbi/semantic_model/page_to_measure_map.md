# Page to Measure Map — Project 1

## Purpose

This document maps report pages to the governed measures they should use.

The goal is to prevent random measure sprawl and make sure each page is built from an intentional set of metrics tied to its audience and decision purpose.

---

## Page 1 — Executive Overview

### Purpose
High-level cross-functional snapshot for leadership.

### Core measures
- Net Sales
- Gross Margin %
- Net Sales per Labor Hour
- In-Stock Rate
- Reconciliation Status

### Supporting measures
- Gross Sales
- Gross Margin $
- Days of Supply
- Missing Dimension Join Count
- Data Freshness Status

### Narrative measures
- Narrative - Net Sales
- Narrative - Gross Margin
- Narrative - Net Sales per Labor Hour
- Narrative - In-Stock Rate
- Narrative - Sales vs GL Status

---

## Page 2 — Sales & Margin

### Purpose
Commercial performance, mix, discounts, and profitability analysis.

### Core measures
- Gross Sales
- Net Sales
- Discount Amount
- Gross Margin $
- Gross Margin %
- Units Sold
- Orders
- Customers

### Supporting measures
- Average Order Value
- Units per Order
- Net Sales vs Prior Period $
- Net Sales vs Prior Period %
- Gross Margin bps Change

### Narrative measures
- Narrative - Net Sales
- Narrative - Gross Margin

---

## Page 3 — Ops & Inventory

### Purpose
Inventory health, coverage, and movement.

### Core measures
- In-Stock Rate
- Days of Supply
- On Hand Units
- Units Shipped

### Supporting measures
- Missing Dimension Join Count
- Data Freshness Status

### Narrative measures
- Narrative - In-Stock Rate
- Narrative - Inventory Risk

---

## Page 4 — People & Productivity

### Purpose
Labor usage, workforce efficiency, and productivity analysis.

### Core measures
- Labor Hours
- Labor Cost
- Net Sales per Labor Hour
- Gross Sales per Labor Hour

### Supporting measures
- Net Sales vs Prior Period %
- Labor Productivity vs Prior Period %

### Narrative measures
- Narrative - Net Sales per Labor Hour
- Narrative - Productivity Exception

---

## Page 5 — Reconciliation & Data Health

### Purpose
Trust, QA, and diagnostics.

### Core measures
- Sales vs GL Delta $
- Sales vs GL Delta %
- Reconciliation Status
- Distributor vs POS Delta $
- Distributor vs POS Delta %
- Missing Dimension Join Count
- Data Freshness Status

### Supporting measures
- Control Warning Count
- Control Fail Count

### Narrative measures
- Narrative - Sales vs GL Status
- Narrative - Freshness Status
- Narrative - Missing Dimension Joins

---

## Page 6 — Detail Drillthrough

### Purpose
Investigative drillthrough by store, SKU, metric, or date.

### Measures allowed
- Net Sales
- Gross Sales
- COGS
- Gross Margin $
- Labor Hours
- Net Sales per Labor Hour
- In-Stock Rate
- Days of Supply
- Sales vs GL Delta $
- Sales vs GL Delta %

### Notes
This page should inherit context from the page the user came from and avoid introducing unrelated KPI cards.

---

## Build Rules

- every page should have a small, intentional measure set
- executive pages should favor summary KPIs and trust indicators
- diagnostics pages should favor reconciliation and control measures
- detailed or investigative measures should stay off the executive page unless they support the headline story directly

---

## Current Recommendation

Use this page-to-measure map as the default report build guide for the first Power BI version.

If a measure is added to a page, update this file so page scope stays governed rather than drifting over time.
## In-scope sources

Simulate five B2B-style quarterly submissions that better match a Althea-like operating model:

- `retail_account_sales_quarterly_extract.csv`
- `wholesale_account_sales_quarterly_extract.csv`
- `finance_quarterly_actuals.csv`
- `inventory_quarterly_extract.csv`
- `trade_adjustments_extract.csv`

## Realistic issues to simulate

- Missing keys (`dispensary_account_id`, `wholesale_account_id`, `sku_id`, `week_end_date`)
- Duplicate business-grain rows
- Missing weeks inside the quarter
- Negative quantities or invalid sales values
- Impossible margins or suspicious percent values
- Wrong template version
- Late submission relative to deadline
- Cross-source mismatch between Sales and Finance totals
- Required fields left blank
- Bad date formats or inconsistent casing/whitespace
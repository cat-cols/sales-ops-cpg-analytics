insert into ops.intake_submission_log (
    quarter_id,
    department_name,
    source_file_name,
    template_version,
    expected_by,
    received_flag,
    qa_status,
    certified_flag,
    notes
)
values
    ('2026Q1', 'Sales Operations', 'retail_account_sales_quarterly_extract.csv', 'v1.0', '2026-04-05 17:00:00', false, 'pending', false, 'Expected quarterly retail sales submission'),
    ('2026Q1', 'Commercial / Wholesale', 'wholesale_account_sales_quarterly_extract.csv', 'v1.0', '2026-04-05 17:00:00', false, 'pending', false, 'Expected quarterly wholesale sales submission'),
    ('2026Q1', 'Finance', 'finance_quarterly_actuals.csv', 'v1.0', '2026-04-07 17:00:00', false, 'pending', false, 'Expected quarterly finance submission'),
    ('2026Q1', 'Supply Chain / Inventory Control', 'inventory_quarterly_extract.csv', 'v1.0', '2026-04-06 17:00:00', false, 'pending', false, 'Expected quarterly inventory submission'),
    ('2026Q1', 'Trade Marketing / Finance', 'trade_adjustments_extract.csv', 'v1.0', '2026-04-07 17:00:00', false, 'pending', false, 'Expected quarterly trade adjustments submission');
#!/usr/bin/env python3
"""
Separate exempt addresses from original recreational retailer data
"""

import csv

input_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer.csv'
exempt_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer_exempt.csv'
valid_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer_valid.csv'

exempt_rows = []
valid_rows = []

with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames
    
    for row in reader:
        if row['physical_address'] == 'Exempt from Public Disclosure':
            exempt_rows.append(row)
        else:
            valid_rows.append(row)

# Write exempt addresses
with open(exempt_file, 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(exempt_rows)

# Write valid addresses
with open(valid_file, 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(valid_rows)

print(f"Separated {len(exempt_rows)} exempt addresses to {exempt_file}")
print(f"Separated {len(valid_rows)} valid addresses to {valid_file}")
print(f"Total: {len(exempt_rows) + len(valid_rows)} entries")

# Show sample exempt entries
print("\nSample exempt entries:")
for row in exempt_rows[:3]:
    print(f"  {row['license_number']}: {row['business_name']} - {row['physical_address']}")

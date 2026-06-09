#!/usr/bin/env python3
"""
Split Oregon cannabis licenses CSV by license group
"""

import csv
from collections import defaultdict

input_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/or_recreational_retailers_wholesalers_filtered.csv'

# Dictionary to hold data for each license group
license_groups = defaultdict(list)

# Read the input CSV
with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames
    
    for row in reader:
        license_group = row['license_group']
        license_groups[license_group].append(row)

# Write separate CSV files for each license group
for license_group, rows in license_groups.items():
    # Create safe filename
    safe_name = license_group.replace('/', '_').replace(' ', '_').lower()
    output_file = f'/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/{safe_name}.csv'
    
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    
    print(f"Created {output_file} with {len(rows)} rows")

print(f"\nTotal license groups: {len(license_groups)}")
for group, rows in license_groups.items():
    print(f"  {group}: {len(rows)} rows")

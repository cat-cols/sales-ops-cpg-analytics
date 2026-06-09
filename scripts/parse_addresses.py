#!/usr/bin/env python3
"""
Parse physical addresses into street, city, state, zip components
"""

import csv
import re
from typing import Dict, Optional

def parse_address(address: str) -> Dict[str, Optional[str]]:
    """
    Parse a physical address into components
    """
    if not address or address.strip() == "Exempt from Public Disclosure":
        return {
            'street_address': None,
            'city': None,
            'state': None,
            'zip_code': None
        }
    
    # Clean up the address
    address = address.strip()
    
    # Pattern for ZIP code (5 digits or 5-4 digits)
    zip_pattern = r'(\d{5}(?:-\d{4})?)'
    zip_match = re.search(zip_pattern, address)
    zip_code = zip_match.group(1) if zip_match else None
    
    # Remove ZIP from address for further parsing
    if zip_code:
        address = address.replace(zip_code, '').strip()
    
    # Pattern for state abbreviation (2 letters) - look for OR specifically
    state_pattern = r'\b(OR)\b'
    state_match = re.search(state_pattern, address)
    state = state_match.group(1) if state_match else None
    
    # Remove state from address for further parsing
    if state:
        address = address.replace(state, '', 1).strip()
    
    # The remaining part should be street + city
    # Try to separate city from street address
    # Cities are typically at the end before the state
    parts = address.split()
    
    if len(parts) >= 2:
        # Assume last word is city
        city = parts[-1]
        street_address = ' '.join(parts[:-1])
    else:
        city = None
        street_address = address
    
    return {
        'street_address': street_address if street_address else None,
        'city': city if city else None,
        'state': state,
        'zip_code': zip_code
    }

# Read and process the CSV
input_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer.csv'
output_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/recreational_retailer_parsed.csv'

with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames + ['street_address', 'city', 'state', 'zip_code']
    
    rows = []
    for row in reader:
        # Parse the physical address
        parsed = parse_address(row['physical_address'])
        
        # Add parsed components to row
        row['street_address'] = parsed['street_address']
        row['city'] = parsed['city']
        row['state'] = parsed['state']
        row['zip_code'] = parsed['zip_code']
        
        rows.append(row)

# Write the updated CSV
with open(output_file, 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"Created {output_file} with {len(rows)} rows")
print(f"Added columns: street_address, city, state, zip_code")

# Show some examples
print("\nSample parsed addresses:")
for row in rows[:5]:
    print(f"Original: {row['physical_address']}")
    print(f"Parsed: {row['street_address']}, {row['city']}, {row['state']}, {row['zip_code']}")
    print()

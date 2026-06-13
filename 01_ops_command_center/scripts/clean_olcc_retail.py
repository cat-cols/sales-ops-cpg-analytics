#!/usr/bin/env python3
"""
Clean and parse OLCC retailer data using Python
This script handles data cleaning, column renaming, and address parsing with validation
"""

import csv
import re
from typing import Dict, Optional

# List of known Oregon cities (multi-word cities first for better matching)
OREGON_CITIES = [
    'Grants Pass', 'Forest Grove', 'Coos Bay', 'Baker City', 'Lake Oswego',
    'Oregon City', 'Roseburg', 'Medford', 'Portland', 'Eugene', 'Salem',
    'Bend', 'Corvallis', 'Springfield', 'Hillsboro', 'Beaverton', 'Gresham',
    'Tigard', 'McMinnville', 'Albany', 'Lebanon', 'Keizer', 'Monmouth',
    'Astoria', 'Seaside', 'Cannon Beach', 'Lincoln City', 'Newport',
    'Florence', 'Coquille', 'North Bend', 'Klamath Falls', 'Ashland',
    'Talent', 'Phoenix', 'Sutherlin', 'Reedsport', 'Bandon', 'Brookings',
    'Gold Beach', 'Gold Hill', 'Central Point', 'Pacific City', 'Lakeside',
    'Cave Junction', 'Madras', 'Veneta', 'Oakridge', 'Detroit',
    'Pendleton', 'Hermiston', 'La Grande', 'John Day', 'Burns',
    'Ontario', 'The Dalles', 'Hood River', 'St. Helens', 'Saint Helens', 'Scappoose',
    'Rainier', 'Hines', 'Lafayette', 'Molalla', 'Canby', 'Wilsonville',
    'Tualatin', 'Sherwood', 'Newberg', 'Dallas', 'Independence',
    'Silverton', 'Stayton', 'Woodburn', 'Sandy', 'Troutdale',
    'Fairview', 'Happy Valley', 'Milwaukie', 'Clackamas', 'West Linn',
    'Cornelius', 'Gaston', 'Banks', 'North Plains', 'Junction City',
    'Cottage Grove', 'Creswell', 'Pleasant Hill', 'Lowell',
    'Tillamook', 'Manzanita', 'Willamina', 'Myrtle Creek', 'Otis', 'Cloverdale',
    'Rhododendron', 'Sisters', 'Prineville', 'Redmond', 'La Pine',
    'Hubbard', 'Depoe Bay', 'Yachats', 'White City',
    'Waldport', 'Aurora', 'Merlin', 'Port Orford', 'Gearhart',
    'Sweet Home', 'Dundee', 'Vernonia', 'Rockaway Beach',
    'Harbor', 'Drain', 'Toledo', 'Mill City', 'Welches', 'King City', 'Brownsville',
    'Chiloquin', 'Myrtle Point', 'Damascus', 'Amity', 'Rogue River',
    'Lakeview', 'Selma', 'Warren', 'Tangent', 'Joseph', 'Wheeler',
    'Winston', 'Sheridan', 'Sumpter', 'Turner', 'Wood Village', 'Kerby'
]

def parse_address(address: str) -> Dict[str, Optional[str]]:
    """
    Parse a physical address into components with validation
    """
    if not address or address.strip() == "Exempt from Public Disclosure":
        return {
            'street_address': None,
            'city': None,
            'state': None,
            'zip_code': None
        }

    # Clean up the address
    original_address = address.strip()
    address = original_address

    # Pattern for state abbreviation (2 letters) - look for OR specifically
    state_pattern = r'\b(OR)\b'
    state_match = re.search(state_pattern, address)
    state = state_match.group(1) if state_match else None

    # Remove state from address for further parsing (but not from city names)
    if state:
        # Only remove state if it's a separate word at the end
        address = re.sub(r'\s' + state + r'\s*$', '', address).strip()

    # Pattern for ZIP code (5 digits or 5-4 digits) - look for it at the end
    zip_pattern = r'(\d{5}(?:-\d{4})?)\s*$'
    zip_match = re.search(zip_pattern, address)
    zip_code = zip_match.group(1) if zip_match else None

    # Remove ZIP from address for further parsing
    if zip_code:
        address = address.replace(zip_code, '').strip()

    # The remaining part should be street + city
    # Try to separate city from street address using known Oregon cities
    city = None
    street_address = address
    
    # Try to match known multi-word cities first
    for known_city in OREGON_CITIES:
        if known_city.lower() in address.lower():
            # Find the position of the city in the address
            city_match = re.search(re.escape(known_city), address, re.IGNORECASE)
            if city_match:
                city = city_match.group()
                # Remove city from address to get street
                street_address = address.replace(city_match.group(), '', 1).strip()
                break
    
    # If no known city found, try simple parsing (last word)
    if not city:
        parts = address.split()
        if len(parts) >= 2:
            city = parts[-1]
            street_address = ' '.join(parts[:-1])
        else:
            city = None
            street_address = address
    
    # Fallback: if city is still blank, use last 1-2 words from original address
    if not city:
        original_parts = original_address.split()
        if len(original_parts) >= 2:
            city = ' '.join(original_parts[-2:])
            street_address = ' '.join(original_parts[:-2])
        elif len(original_parts) == 1:
            city = original_parts[0]
            street_address = None
    
    # Clean up street address - remove any remaining state abbreviations
    if street_address:
        street_address = re.sub(r'\sOR\s*$', '', street_address).strip()
        # Clean up extra whitespace
        street_address = re.sub(r'\s+', ' ', street_address).strip()

    # Validation: city must not contain numbers or ZIP patterns
    if city and re.search(r'\d', city):
        city = None
    
    # Validation: city must not be just the state abbreviation
    if city and city.upper() == 'OR':
        city = None
    
    # Convert city to UPPERCASE
    if city:
        city = city.upper()
    
    # Remove commas from street address
    if street_address:
        street_address = street_address.replace(',', '')

    # Validation: ZIP must not contain letters
    if zip_code and re.search(r'[A-Za-z]', zip_code):
        zip_code = None

    return {
        'street_address': street_address if street_address else None,
        'city': city if city else None,
        'state': state,
        'zip_code': zip_code
    }

# Read and process the CSV
input_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/raw/olcc_retail_utf8.csv'
output_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/olcc_retailer_cleaned.csv'

rows = []
blank_rows = 0
exempt_rows = 0

with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f, delimiter='\t')
    
    # Get fieldnames and remove the trailing empty column if present
    fieldnames = reader.fieldnames
    if fieldnames and fieldnames[-1] == '':
        fieldnames = fieldnames[:-1]

    for row in reader:
        # Remove the trailing empty column from each row
        if '' in row:
            del row['']
        
        # Remove blank rows (rows where all key fields are empty)
        license_num = row.get('License Number', '').strip()
        business_name = row.get('Business Name', '').strip()
        physical_addr = row.get('PhysicalAddress', '').strip()

        if not license_num and not business_name and not physical_addr:
            blank_rows += 1
            continue

        # Rename PhysicalAddress to raw_physical_address
        row['raw_physical_address'] = row.pop('PhysicalAddress')

        # Parse the address
        parsed = parse_address(row['raw_physical_address'])

        # Add parsed components to row
        row['street_address'] = parsed['street_address']
        row['city'] = parsed['city']
        row['state'] = parsed['state']
        row['zip_code'] = parsed['zip_code']

        # Count exempt rows
        if row['raw_physical_address'] == 'Exempt from Public Disclosure':
            exempt_rows += 1

        # Remove blank/empty columns from the row (but keep column structure consistent)
        # Only remove columns that are completely empty strings, not None values
        row = {k: v for k, v in row.items() if v != ''}

        rows.append(row)

# Write the cleaned CSV
with open(output_file, 'w', encoding='utf-8', newline='') as f:
    fieldnames = list(rows[0].keys()) if rows else []
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"Created {output_file} with {len(rows)} rows")
print(f"Removed {blank_rows} blank rows")
print(f"Found {exempt_rows} exempt addresses")
print(f"Added columns: street_address, city, state, zip_code")

# Show some examples
print("\nSample parsed addresses:")
for row in rows[:5]:
    print(f"Original: {row['raw_physical_address']}")
    print(f"Parsed: {row['street_address']}, {row['city']}, {row['state']}, {row['zip_code']}")

    # Validation status
    validation_issues = []
    if row['city'] and re.search(r'\d', row['city']):
        validation_issues.append('City contains numbers')
    if row['zip_code'] and re.search(r'[A-Za-z]', row['zip_code']):
        validation_issues.append('ZIP contains letters')

    if validation_issues:
        print(f"Validation: {', '.join(validation_issues)}")
    else:
        print("Validation: VALID")
    print()

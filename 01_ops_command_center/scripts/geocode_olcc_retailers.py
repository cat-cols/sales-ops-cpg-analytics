"""
Geocode OLCC retailer addresses to add latitude/longitude coordinates
This script uses the geopy library to geocode addresses for mapping in Tableau
"""

import csv
import time
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter

# Input and output files
input_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/olcc_retailer_cleaned.csv'
output_file = '/Users/b/data/projects/althea-sales-ops-cpg/data/reference/or_licenses/derived/olcc_retailer_geocoded.csv'

# Initialize geocoder with rate limiting (Nominatim has usage limits)
geolocator = Nominatim(user_agent="althea_ops_geocoding")
geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)

def geocode_address(street, city, state, zip_code):
    """
    Geocode an address using street, city, state, and zip code
    Returns (latitude, longitude) or (None, None) if geocoding fails
    """
    # Build full address
    address_parts = []
    if street:
        address_parts.append(street)
    if city:
        address_parts.append(city)
    if state:
        address_parts.append(state)
    if zip_code:
        address_parts.append(zip_code)

    full_address = ", ".join(address_parts)

    try:
        location = geocode(full_address)
        if location:
            return location.latitude, location.longitude
        else:
            # Try with just city, state, zip
            city_state_zip = f"{city}, {state} {zip_code}" if city and state and zip_code else f"{city}, {state}" if city and state else None
            if city_state_zip:
                location = geocode(city_state_zip)
                if location:
                    return location.latitude, location.longitude
        return None, None
    except Exception as e:
        print(f"Error geocoding {full_address}: {e}")
        return None, None

# Read the input CSV and add geocoding
geocoded_rows = []
with open(input_file, 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for i, row in enumerate(reader):
        print(f"Geocoding row {i+1}/{reader.line_num}: {row.get('business_name', 'Unknown')}")

        # Get address components
        street = row.get('street_address', '')
        city = row.get('city', '')
        state = row.get('state', '')
        zip_code = row.get('zip_code', '')

        # Geocode the address
        lat, lon = geocode_address(street, city, state, zip_code)

        # Add coordinates to row
        row['latitude'] = lat
        row['longitude'] = lon

        geocoded_rows.append(row)

        # Rate limiting is handled by RateLimiter, but add small delay between requests
        time.sleep(0.5)

# Write the geocoded data to output CSV
if geocoded_rows:
    fieldnames = geocoded_rows[0].keys()
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(geocoded_rows)

    # Count successful geocodes
    successful = sum(1 for row in geocoded_rows if row['latitude'] is not None)
    print(f"\nGeocoding complete:")
    print(f"Total rows: {len(geocoded_rows)}")
    print(f"Successfully geocoded: {successful}")
    print(f"Failed: {len(geocoded_rows) - successful}")
    print(f"Output saved to: {output_file}")
else:
    print("No rows to geocode")

#!/usr/bin/env python3
"""
Geocode location data for Tableau mapping
Adds latitude, longitude, full addresses, and ZIP codes to location data
"""

import psycopg2
import time
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Oregon county to city mapping for better geocoding accuracy
OREGON_COUNTY_CITIES = {
    'Multnomah': 'Portland',
    'Lane': 'Eugene',
    'Jackson': 'Medford',
    'Marion': 'Salem',
    'Washington': 'Hillsboro',
    'Clackamas': 'Oregon City',
    'Deschutes': 'Bend',
    'Josephine': 'Grants Pass',
    'Linn': 'Albany',
    'Clatsop': 'Astoria',
    'Douglas': 'Roseburg',
    'Klamath': 'Klamath Falls',
    'Benton': 'Corvallis',
    'Wasco': 'The Dalles',
    'Coos': 'Coos Bay',
    'Umatilla': 'Pendleton',
    'Yamhill': 'McMinnville',
    'Polk': 'Dallas',
    'Lincoln': 'Newport',
    'Tillamook': 'Tillamook',
    'Malheur': 'Ontario',
    'Harney': 'Burns',
    'Lake': 'Lakeview',
    'Crook': 'Prineville',
    'Jefferson': 'Madras',
    'Wheeler': 'Fossil',
    'Grant': 'Canyon City',
    'Union': 'La Grande',
    'Baker': 'Baker City',
    'Wallowa': 'Enterprise',
    'Morrow': 'Heppner',
    'Gilliam': 'Condon',
    'Sherman': 'Wasco',
    'Hood River': 'Hood River'
}

def get_db_connection():
    """Get PostgreSQL database connection"""
    return psycopg2.connect(
        dbname="althea_ops",
        user="b",  # Update with your username
        host="localhost",
        port="5432"
    )

def geocode_location(geolocator, location_name, county, state):
    """
    Geocode a location using multiple strategies
    """
    # Strategy 1: Try exact business name + county + state
    try:
        query = f"{location_name}, {county}, {state}"
        logger.info(f"Geocoding: {query}")
        location = geolocator.geocode(query, timeout=10)
        if location:
            return {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'full_address': location.address,
                'city': extract_city(location.address),
                'zip_code': extract_zip(location.address)
            }
    except (GeocoderTimedOut, GeocoderServiceError) as e:
        logger.warning(f"Strategy 1 failed for {location_name}: {e}")
    
    # Strategy 2: Try business name + city (from county mapping) + state
    try:
        city = OREGON_COUNTY_CITIES.get(county, county)
        query = f"{location_name}, {city}, {state}"
        logger.info(f"Strategy 2: {query}")
        location = geolocator.geocode(query, timeout=10)
        if location:
            return {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'full_address': location.address,
                'city': city,
                'zip_code': extract_zip(location.address)
            }
    except (GeocoderTimedOut, GeocoderServiceError) as e:
        logger.warning(f"Strategy 2 failed for {location_name}: {e}")
    
    # Strategy 3: Try just city + state for county centroid
    try:
        city = OREGON_COUNTY_CITIES.get(county, county)
        query = f"{city}, {state}"
        logger.info(f"Strategy 3: {query}")
        location = geolocator.geocode(query, timeout=10)
        if location:
            return {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'full_address': f"{city}, {state}",
                'city': city,
                'zip_code': extract_zip(location.address) if location.address else None
            }
    except (GeocoderTimedOut, GeocoderServiceError) as e:
        logger.warning(f"Strategy 3 failed for {location_name}: {e}")
    
    # Return None if all strategies fail
    logger.error(f"All geocoding strategies failed for {location_name}")
    return None

def extract_city(address):
    """Extract city from geocoded address"""
    if not address:
        return None
    parts = address.split(',')
    if len(parts) >= 2:
        city = parts[-2].strip()
        # Remove any postal codes
        city = city.split('(')[0].strip()
        return city
    return None

def extract_zip(address):
    """Extract ZIP code from geocoded address"""
    if not address:
        return None
    import re
    zip_match = re.search(r'\b\d{5}(?:-\d{4})?\b', address)
    return zip_match.group(0) if zip_match else None

def update_location_geocoding(conn, location_key, geo_data):
    """Update location with geocoded data"""
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                UPDATE raw.dim_location 
                SET latitude = %s,
                    longitude = %s,
                    full_address = %s,
                    city = %s,
                    zip_code = %s
                WHERE location_key = %s
            """, (
                geo_data['latitude'],
                geo_data['longitude'],
                geo_data['full_address'],
                geo_data['city'],
                geo_data['zip_code'],
                location_key
            ))
        conn.commit()
        logger.info(f"Updated {location_key}")
        return True
    except Exception as e:
        logger.error(f"Failed to update {location_key}: {e}")
        conn.rollback()
        return False

def main():
    """Main geocoding process"""
    logger.info("Starting location geocoding process")
    
    # Initialize geocoder
    geolocator = Nominatim(user_agent="althea_ops_geocoding")
    
    # Get database connection
    conn = get_db_connection()
    
    try:
        # Get locations that need geocoding
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT location_key, location_name, location_type, county, state
                FROM raw.dim_location
                WHERE latitude IS NULL OR longitude IS NULL
                ORDER BY location_type, county, location_name
            """)
            locations = cursor.fetchall()
        
        logger.info(f"Found {len(locations)} locations to geocode")
        
        # Geocode each location
        success_count = 0
        failure_count = 0
        
        for idx, (location_key, location_name, location_type, county, state) in enumerate(locations, 1):
            logger.info(f"Processing {idx}/{len(locations)}: {location_name}")
            
            # Rate limiting to avoid overwhelming the geocoding service
            if idx > 1 and idx % 10 == 0:
                logger.info("Pausing for rate limiting...")
                time.sleep(2)
            
            # Geocode the location
            geo_data = geocode_location(geolocator, location_name, county, state)
            
            if geo_data:
                # Update database
                if update_location_geocoding(conn, location_key, geo_data):
                    success_count += 1
                else:
                    failure_count += 1
            else:
                failure_count += 1
                # Set default values for failed geocoding
                try:
                    with conn.cursor() as cursor:
                        city = OREGON_COUNTY_CITIES.get(county, county)
                        cursor.execute("""
                            UPDATE raw.dim_location 
                            SET city = %s,
                                full_address = %s
                            WHERE location_key = %s
                        """, (city, f"{city}, {state}", location_key))
                    conn.commit()
                    logger.warning(f"Set default city for {location_name}")
                except Exception as e:
                    logger.error(f"Failed to set defaults for {location_name}: {e}")
        
        logger.info(f"Geocoding complete: {success_count} successful, {failure_count} failed")
        
        # Update staging view to include new columns
        with conn.cursor() as cursor:
            cursor.execute("""
                CREATE OR REPLACE VIEW stg.stg_location AS
                SELECT 
                    location_key,
                    location_name,
                    location_type,
                    county,
                    state,
                    preferred_channel,
                    location_id,
                    latitude,
                    longitude,
                    full_address,
                    city,
                    zip_code
                FROM raw.dim_location;
            """)
        conn.commit()
        logger.info("Updated stg.stg_location view")
        
        # Update mart view to include geographic data
        with conn.cursor() as cursor:
            cursor.execute("""
                CREATE OR REPLACE VIEW mart.fact_sales_daily AS
                SELECT 
                    s.date_key,
                    s.product_key,
                    s.location_key,
                    s.channel_key,
                    s.units_sold,
                    s.unit_list_price,
                    s.unit_net_price,
                    s.discount_rate,
                    s.gross_sales_amount,
                    s.discount_amount,
                    s.net_sales_amount,
                    s.cogs_amount,
                    s.order_count,
                    s.customer_count,
                    p.product_name,
                    p.sku,
                    p.category,
                    p.pack_size,
                    l.location_name,
                    l.location_type,
                    l.county,
                    l.state,
                    l.latitude,
                    l.longitude,
                    l.full_address,
                    l.city,
                    l.zip_code,
                    c.channel_name,
                    d.full_date,
                    d.year,
                    d.month_num,
                    d.month_name,
                    d.quarter
                FROM stg.stg_sales s
                JOIN stg.stg_product p ON s.product_key = p.product_key
                JOIN stg.stg_location l ON s.location_key = l.location_key
                JOIN stg.stg_channel c ON s.channel_key = c.channel_key
                JOIN stg.stg_date d ON s.date_key = d.date_key;
            """)
        conn.commit()
        logger.info("Updated mart.fact_sales_daily view with geographic data")
        
    except Exception as e:
        logger.error(f"Geocoding process failed: {e}")
        conn.rollback()
    finally:
        conn.close()
        logger.info("Database connection closed")

if __name__ == "__main__":
    main()

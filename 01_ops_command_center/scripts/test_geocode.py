#!/usr/bin/env python3
"""
Test geocoding with a small sample of locations
"""

import psycopg2
from geopy.geocoders import Nominatim
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_db_connection():
    return psycopg2.connect(
        dbname="althea_ops",
        user="b",
        host="localhost",
        port="5432"
    )

def test_geocoding():
    conn = get_db_connection()
    geolocator = Nominatim(user_agent="althea_ops_test")
    
    try:
        # Get just 5 locations for testing
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT location_key, location_name, county, state
                FROM raw.dim_location
                WHERE latitude IS NULL
                LIMIT 5
            """)
            locations = cursor.fetchall()
        
        logger.info(f"Testing with {len(locations)} locations")
        
        for location_key, location_name, county, state in locations:
            logger.info(f"Geocoding: {location_name}, {county}, {state}")
            
            try:
                location = geolocator.geocode(f"{location_name}, {county}, {state}", timeout=10)
                if location:
                    logger.info(f"✓ Found: {location.latitude}, {location.longitude}")
                    logger.info(f"  Address: {location.address}")
                else:
                    logger.warning(f"✗ Not found")
            except Exception as e:
                logger.error(f"✗ Error: {e}")
    
    finally:
        conn.close()

if __name__ == "__main__":
    test_geocoding()

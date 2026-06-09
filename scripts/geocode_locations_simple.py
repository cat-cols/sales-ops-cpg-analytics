#!/usr/bin/env python3
"""
Simple geocoding using county centroids and city mapping
More reliable than business name geocoding for cannabis businesses
"""

import psycopg2
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Oregon county centroids (approximate lat/long for county centers)
OREGON_COUNTY_CENTROIDS = {
    'Multnomah': {'lat': 45.5151, 'lng': -122.6784, 'city': 'Portland'},
    'Lane': {'lat': 44.0521, 'lng': -123.0868, 'city': 'Eugene'},
    'Jackson': {'lat': 42.3265, 'lng': -122.8756, 'city': 'Medford'},
    'Marion': {'lat': 44.8491, 'lng': -122.9700, 'city': 'Salem'},
    'Washington': {'lat': 45.5238, 'lng': -122.9766, 'city': 'Hillsboro'},
    'Clackamas': {'lat': 45.0062, 'lng': -122.5704, 'city': 'Oregon City'},
    'Deschutes': {'lat': 44.0582, 'lng': -121.3153, 'city': 'Bend'},
    'Josephine': {'lat': 42.5446, 'lng': -123.4103, 'city': 'Grants Pass'},
    'Linn': {'lat': 44.6329, 'lng': -123.0267, 'city': 'Albany'},
    'Clatsop': {'lat': 46.1879, 'lng': -123.8313, 'city': 'Astoria'},
    'Douglas': {'lat': 43.2195, 'lng': -123.3749, 'city': 'Roseburg'},
    'Klamath': {'lat': 42.2249, 'lng': -121.7817, 'city': 'Klamath Falls'},
    'Benton': {'lat': 44.5646, 'lng': -123.2792, 'city': 'Corvallis'},
    'Wasco': {'lat': 45.5960, 'lng': -121.1788, 'city': 'The Dalles'},
    'Coos': {'lat': 43.3665, 'lng': -124.2126, 'city': 'Coos Bay'},
    'Umatilla': {'lat': 45.8696, 'lng': -118.6150, 'city': 'Pendleton'},
    'Yamhill': {'lat': 45.3127, 'lng': -123.0188, 'city': 'McMinnville'},
    'Polk': {'lat': 44.8548, 'lng': -123.5930, 'city': 'Dallas'},
    'Lincoln': {'lat': 44.5720, 'lng': -124.0025, 'city': 'Newport'},
    'Tillamook': {'lat': 45.4562, 'lng': -123.8375, 'city': 'Tillamook'},
    'Malheur': {'lat': 43.7868, 'lng': -117.2343, 'city': 'Ontario'},
    'Harney': {'lat': 43.7892, 'lng': -118.9471, 'city': 'Burns'},
    'Lake': {'lat': 42.1892, 'lng': -120.3783, 'city': 'Lakeview'},
    'Crook': {'lat': 44.2097, 'lng': -120.8465, 'city': 'Prineville'},
    'Jefferson': {'lat': 44.6926, 'lng': -121.2698, 'city': 'Madras'},
    'Wheeler': {'lat': 44.7702, 'lng': -120.0192, 'city': 'Fossil'},
    'Grant': {'lat': 44.1718, 'lng': -118.9569, 'city': 'Canyon City'},
    'Union': {'lat': 45.3237, 'lng': -117.8462, 'city': 'La Grande'},
    'Baker': {'lat': 44.7798, 'lng': -117.8343, 'city': 'Baker City'},
    'Wallowa': {'lat': 45.5717, 'lng': -117.5292, 'city': 'Enterprise'},
    'Morrow': {'lat': 45.4856, 'lng': -119.6690, 'city': 'Heppner'},
    'Gilliam': {'lat': 45.4640, 'lng': -120.2817, 'city': 'Condon'},
    'Sherman': {'lat': 45.6911, 'lng': -120.6751, 'city': 'Wasco'},
    'Hood River': {'lat': 45.7144, 'lng': -121.5155, 'city': 'Hood River'}
}

# Oregon ZIP codes by county (representative ZIP for each county)
OREGON_COUNTY_ZIPS = {
    'Multnomah': '97201',
    'Lane': '97401',
    'Jackson': '97501',
    'Marion': '97301',
    'Washington': '97124',
    'Clackamas': '97045',
    'Deschutes': '97701',
    'Josephine': '97526',
    'Linn': '97321',
    'Clatsop': '97103',
    'Douglas': '97470',
    'Klamath': '97601',
    'Benton': '97333',
    'Wasco': '97058',
    'Coos': '97420',
    'Umatilla': '97801',
    'Yamhill': '97127',
    'Polk': '97317',
    'Lincoln': '97365',
    'Tillamook': '97141',
    'Malheur': '97914',
    'Harney': '97731',
    'Lake': '97630',
    'Crook': '97754',
    'Jefferson': '97741',
    'Wheeler': '97846',
    'Grant': '97820',
    'Union': '97850',
    'Baker': '97814',
    'Wallowa': '97885',
    'Morrow': '97836',
    'Gilliam': '97844',
    'Sherman': '97065',
    'Hood River': '97031'
}

def get_db_connection():
    """Get PostgreSQL database connection"""
    return psycopg2.connect(
        dbname="althea_ops",
        user="b",
        host="localhost",
        port="5432"
    )

def update_location_geocoding(conn, location_key, county, state):
    """Update location with county-level geocoding"""
    try:
        # Get county centroid data
        county_data = OREGON_COUNTY_CENTROIDS.get(county)
        zip_code = OREGON_COUNTY_ZIPS.get(county)
        
        if not county_data:
            logger.warning(f"No centroid data for county: {county}")
            return False
        
        city = county_data['city']
        lat = county_data['lat']
        lng = county_data['lng']
        
        # Create full address
        full_address = f"{city}, {state} {zip_code}"
        
        with conn.cursor() as cursor:
            cursor.execute("""
                UPDATE raw.dim_location 
                SET latitude = %s,
                    longitude = %s,
                    full_address = %s,
                    city = %s,
                    zip_code = %s
                WHERE location_key = %s
            """, (lat, lng, full_address, city, zip_code, location_key))
        conn.commit()
        
        logger.info(f"✓ Updated {location_key}: {city}, {county} ({lat}, {lng})")
        return True
        
    except Exception as e:
        logger.error(f"✗ Failed to update {location_key}: {e}")
        conn.rollback()
        return False

def main():
    """Main geocoding process using county centroids"""
    logger.info("Starting county-level geocoding process")
    
    conn = get_db_connection()
    
    try:
        # Get locations that need geocoding
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT location_key, location_name, county, state
                FROM raw.dim_location
                WHERE latitude IS NULL OR longitude IS NULL
                ORDER BY location_type, county, location_name
            """)
            locations = cursor.fetchall()
        
        logger.info(f"Found {len(locations)} locations to geocode")
        
        # Geocode each location using county centroids
        success_count = 0
        failure_count = 0
        
        for idx, (location_key, location_name, county, state) in enumerate(locations, 1):
            if idx % 100 == 0:
                logger.info(f"Progress: {idx}/{len(locations)}")
            
            if update_location_geocoding(conn, location_key, county, state):
                success_count += 1
            else:
                failure_count += 1
        
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
        logger.info("✓ Updated stg.stg_location view")
        
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
        logger.info("✓ Updated mart.fact_sales_daily view with geographic data")
        
        # Verify the update
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    COUNT(*) as total_locations,
                    COUNT(latitude) as geocoded_locations,
                    COUNT(city) as cities_added,
                    COUNT(zip_code) as zips_added
                FROM stg.stg_location
            """)
            result = cursor.fetchone()
            logger.info(f"Verification: {result[0]} total, {result[1]} geocoded, {result[2]} cities, {result[3]} ZIPs")
        
    except Exception as e:
        logger.error(f"Geocoding process failed: {e}")
        conn.rollback()
    finally:
        conn.close()
        logger.info("Database connection closed")

if __name__ == "__main__":
    main()

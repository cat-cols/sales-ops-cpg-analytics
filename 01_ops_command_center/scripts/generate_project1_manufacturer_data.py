#!/usr/bin/env python3
"""
Project 1 Data Generator - Manufacturer Model

Generates data for Althea cannabis gummies manufacturer model.
Replaces retail POS model with manufacturer B2B model.

Data Sources:
- B2B orders (wholesaler orders to Althea)
- Distributor shipments (Althea ships to wholesalers)
- Sell-through data (wholesalers sell to retailers)
- Direct-to-retailer data (Althea sells directly to large chains)
- Inventory snapshots (Althea warehouse inventory)

Based on Oregon cannabis business licenses for realistic business entities.
"""

import argparse
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
import random
import json

# Configuration
REPO_ROOT = Path(__file__).parent.parent.parent
ALTHEA_DATA_DIR = REPO_ROOT / "data/reference/althea_manufacturer"
OUTPUT_DIR = REPO_ROOT / "01_ops_command_center/data/source_extracts"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Date range
START_DATE = datetime(2024, 1, 1)
END_DATE = datetime(2025, 12, 31)

def load_althea_data():
    """Load Althea manufacturer data."""
    print("Loading Althea manufacturer data...")

    b2b_orders = pd.read_csv(ALTHEA_DATA_DIR / "althea_b2b_orders.csv")
    b2b_orders['order_date'] = pd.to_datetime(b2b_orders['order_date'])

    shipments = pd.read_csv(ALTHEA_DATA_DIR / "althea_distributor_shipments.csv")
    shipments['shipment_date'] = pd.to_datetime(shipments['shipment_date'])

    sell_through = pd.read_csv(ALTHEA_DATA_DIR / "althea_sell_through.csv")
    sell_through['sale_date'] = pd.to_datetime(sell_through['sale_date'])

    direct_sales = pd.read_csv(ALTHEA_DATA_DIR / "althea_direct_to_retailer.csv")
    direct_sales['sale_date'] = pd.to_datetime(direct_sales['sale_date'])

    inventory = pd.read_csv(ALTHEA_DATA_DIR / "althea_inventory_snapshots.csv")
    inventory['snapshot_date'] = pd.to_datetime(inventory['snapshot_date'])

    wholesalers = pd.read_csv(ALTHEA_DATA_DIR / "wholesalers_reference.csv")
    retailers = pd.read_csv(ALTHEA_DATA_DIR / "retailers_reference.csv")
    sku_catalog = pd.read_csv(ALTHEA_DATA_DIR / "althea_sku_catalog.csv")

    print(f"  - B2B orders: {len(b2b_orders):,}")
    print(f"  - Shipments: {len(shipments):,}")
    print(f"  - Sell-through: {len(sell_through):,}")
    print(f"  - Direct sales: {len(direct_sales):,}")
    print(f"  - Inventory: {len(inventory):,}")
    print(f"  - Wholesalers: {len(wholesalers):,}")
    print(f"  - Retailers: {len(retailers):,}")
    print(f"  - SKUs: {len(sku_catalog):,}")

    return {
        'b2b_orders': b2b_orders,
        'shipments': shipments,
        'sell_through': sell_through,
        'direct_sales': direct_sales,
        'inventory': inventory,
        'wholesalers': wholesalers,
        'retailers': retailers,
        'sku_catalog': sku_catalog
    }

def generate_dim_location(wholesalers, retailers):
    """Generate location dimension from business entities."""
    print("Generating location dimension...")

    locations = []
    
    # Add wholesalers
    for _, wholesaler in wholesalers.iterrows():
        locations.append({
            'location_key': wholesaler['License Number'],
            'location_name': wholesaler['Business Name'],
            'location_type': 'Wholesaler',
            'county': wholesaler['County'],
            'state': 'OR',
            'preferred_channel': 'Wholesale'
        })
    
    # Add retailers
    for _, retailer in retailers.iterrows():
        locations.append({
            'location_key': retailer['License Number'],
            'location_name': retailer['Business Name'],
            'location_type': 'Retailer',
            'county': retailer['County'],
            'state': 'OR',
            'preferred_channel': 'Retail'
        })
    
    df = pd.DataFrame(locations)
    df['location_id'] = range(1, len(df) + 1)
    
    print(f"  - Generated {len(df)} locations")
    return df

def generate_dim_product(sku_catalog):
    """Generate product dimension from SKU catalog."""
    print("Generating product dimension...")

    products = []
    for _, sku in sku_catalog.iterrows():
        products.append({
            'product_key': sku['sku'],
            'product_name': sku['name'],
            'sku': sku['sku'],
            'category': sku['category'],
            'pack_size': sku['pack_size'],
            'base_list_price': sku['unit_price']
        })
    
    df = pd.DataFrame(products)
    df['product_id'] = range(1, len(df) + 1)
    
    print(f"  - Generated {len(df)} products")
    return df

def generate_dim_channel():
    """Generate channel dimension."""
    print("Generating channel dimension...")

    channels = [
        {'channel_key': 1, 'channel_name': 'Wholesale'},
        {'channel_key': 2, 'channel_name': 'Direct'},
        {'channel_key': 3, 'channel_name': 'Distributor'}
    ]
    
    df = pd.DataFrame(channels)
    print(f"  - Generated {len(df)} channels")
    return df

def generate_dim_date(start_date, end_date):
    """Generate date dimension."""
    print("Generating date dimension...")

    dates = []
    current = start_date
    while current <= end_date:
        dates.append({
            'date_key': current.strftime('%Y%m%d'),
            'full_date': current,
            'year': current.year,
            'month_num': current.month,
            'month_name': current.strftime('%B'),
            'day_of_month': current.day,
            'day_of_week': current.weekday(),
            'day_name': current.strftime('%A'),
            'quarter': (current.month - 1) // 3 + 1
        })
        current += timedelta(days=1)
    
    df = pd.DataFrame(dates)
    print(f"  - Generated {len(df)} dates")
    return df

def add_data_quality_issues(df, issue_rate=0.01):
    """Add realistic data quality issues."""
    if len(df) == 0:
        return df
    
    df = df.copy()
    n_rows = len(df)
    n_issues = int(n_rows * issue_rate)
    
    if n_issues > 0:
        # Random trailing spaces in string columns
        string_cols = df.select_dtypes(include=['object']).columns
        for col in string_cols:
            mask = np.random.random(n_rows) < (issue_rate / len(string_cols))
            df.loc[mask, col] = df.loc[mask, col].astype(str) + ' '
    
    return df

def generate_source_extracts(althea_data, dim_location, dim_product, dim_channel):
    """Generate source extracts with data quality issues."""
    print("Generating source extracts...")

    # Create output directories
    sales_dir = OUTPUT_DIR / "sales"
    ops_dir = OUTPUT_DIR / "ops"
    sales_dir.mkdir(parents=True, exist_ok=True)
    ops_dir.mkdir(parents=True, exist_ok=True)

    # B2B orders (replace POS transactions)
    print("  - Generating B2B orders extract...")
    b2b_orders = althea_data['b2b_orders'].copy()
    b2b_orders = b2b_orders.rename(columns={
        'order_date': 'sale_date',
        'wholesaler_license': 'store_code',
        'quantity_packs': 'qty',
        'discount_percent': 'discount_rate',
        'gross_amount': 'gross_sales',
        'net_amount': 'net_sales'
    })
    b2b_orders['channel'] = 'Wholesale'
    b2b_orders = add_data_quality_issues(b2b_orders, issue_rate=0.008)
    b2b_orders.to_csv(sales_dir / "b2b_orders_extract.csv", index=False)
    
    # Direct sales
    print("  - Generating direct sales extract...")
    direct_sales = althea_data['direct_sales'].copy()
    direct_sales = direct_sales.rename(columns={
        'sale_date': 'sale_date',
        'retailer_license': 'store_code',
        'quantity_packs': 'qty',
        'discount_percent': 'discount_rate',
        'gross_amount': 'gross_sales',
        'net_amount': 'net_sales'
    })
    direct_sales['channel'] = 'Direct'
    direct_sales = add_data_quality_issues(direct_sales, issue_rate=0.008)
    direct_sales.to_csv(sales_dir / "direct_sales_extract.csv", index=False)
    
    # Sell-through (distributor sales)
    print("  - Generating sell-through extract...")
    sell_through = althea_data['sell_through'].copy()
    # Calculate discount rate before renaming
    sell_through['discount_rate'] = (sell_through['retail_price'] - sell_through['wholesale_price']) / sell_through['retail_price']
    sell_through['net_sales'] = sell_through['gross_amount'] * (1 - sell_through['discount_rate'])
    sell_through['cogs'] = sell_through['net_sales'] * 0.45  # Approximate COGS
    sell_through = sell_through.rename(columns={
        'sale_date': 'sale_date',
        'retailer_license': 'store_code',
        'quantity_packs': 'qty',
        'retail_price': 'unit_list_price',
        'gross_amount': 'gross_sales'
    })
    sell_through['channel'] = 'Distributor'
    sell_through = add_data_quality_issues(sell_through, issue_rate=0.008)
    sell_through.to_csv(sales_dir / "sell_through_extract.csv", index=False)
    
    # Inventory
    print("  - Generating inventory extract...")
    inventory = althea_data['inventory'].copy()
    inventory = inventory.rename(columns={
        'snapshot_date': 'snapshot_date',
        'sku': 'sku',
        'ending_inventory_packs': 'on_hand_units'
    })
    inventory = add_data_quality_issues(inventory, issue_rate=0.005)
    inventory.to_csv(ops_dir / "inventory_extract.csv", index=False)
    
    # Shipments
    print("  - Generating shipments extract...")
    shipments = althea_data['shipments'].copy()
    shipments = shipments.rename(columns={
        'shipment_date': 'shipment_date',
        'wholesaler_license': 'store_code',
        'quantity_packs_shipped': 'qty_shipped'
    })
    shipments = add_data_quality_issues(shipments, issue_rate=0.005)
    shipments.to_csv(ops_dir / "shipments_extract.csv", index=False)
    
    print("  - Source extracts generated")

def generate_modeled_tables(althea_data, dim_location, dim_product, dim_channel, dim_date):
    """Generate modeled truth tables."""
    print("Generating modeled tables...")
    
    modeled_dir = REPO_ROOT / "01_ops_command_center/data/modeled"
    modeled_dir.mkdir(parents=True, exist_ok=True)
    
    # Save dimension tables
    dim_location.to_csv(modeled_dir / "dim_location.csv", index=False)
    dim_product.to_csv(modeled_dir / "dim_product.csv", index=False)
    dim_channel.to_csv(modeled_dir / "dim_channel.csv", index=False)
    dim_date.to_csv(modeled_dir / "dim_date.csv", index=False)
    
    # Generate fact_sales from manufacturer data
    print("  - Generating fact_sales...")
    fact_sales_rows = []
    
    # B2B orders
    for _, row in althea_data['b2b_orders'].iterrows():
        order_date = pd.to_datetime(row['order_date'])
        fact_sales_rows.append({
            'date_key': order_date.strftime('%Y%m%d'),
            'product_key': row['sku'],
            'location_key': row['wholesaler_license'],
            'channel_key': 1,  # Wholesale
            'units_sold': row['quantity_packs'],
            'unit_list_price': row['unit_price'],
            'unit_net_price': row['unit_price'] * (1 - row['discount_percent']),
            'discount_rate': row['discount_percent'],
            'gross_sales_amount': row['gross_amount'],
            'discount_amount': row['discount_amount'],
            'net_sales_amount': row['net_amount'],
            'cogs_amount': row['net_amount'] * 0.42,  # Approximate COGS
            'order_count': 1,
            'customer_count': 1
        })
    
    # Direct sales
    for _, row in althea_data['direct_sales'].iterrows():
        sale_date = pd.to_datetime(row['sale_date'])
        fact_sales_rows.append({
            'date_key': sale_date.strftime('%Y%m%d'),
            'product_key': row['sku'],
            'location_key': row['retailer_license'],
            'channel_key': 2,  # Direct
            'units_sold': row['quantity_packs'],
            'unit_list_price': row['unit_price'],
            'unit_net_price': row['unit_price'] * (1 - row['discount_percent']),
            'discount_rate': row['discount_percent'],
            'gross_sales_amount': row['gross_amount'],
            'discount_amount': row['discount_amount'],
            'net_sales_amount': row['net_amount'],
            'cogs_amount': row['net_amount'] * 0.42,
            'order_count': 1,
            'customer_count': 1
        })
    
    # Sell-through (distributor to retailer)
    for _, row in althea_data['sell_through'].iterrows():
        sale_date = pd.to_datetime(row['sale_date'])
        fact_sales_rows.append({
            'date_key': sale_date.strftime('%Y%m%d'),
            'product_key': row['sku'],
            'location_key': row['retailer_license'],
            'channel_key': 3,  # Distributor
            'units_sold': row['quantity_packs'],
            'unit_list_price': row['retail_price'],
            'unit_net_price': row['wholesale_price'],
            'discount_rate': (row['retail_price'] - row['wholesale_price']) / row['retail_price'],
            'gross_sales_amount': row['gross_amount'],
            'discount_amount': row['gross_amount'] - (row['quantity_packs'] * row['wholesale_price']),
            'net_sales_amount': row['quantity_packs'] * row['wholesale_price'],
            'cogs_amount': (row['quantity_packs'] * row['wholesale_price']) * 0.45,
            'order_count': 1,
            'customer_count': 1
        })
    
    fact_sales = pd.DataFrame(fact_sales_rows)
    fact_sales.to_csv(modeled_dir / "fact_sales.csv", index=False)
    print(f"  - Generated {len(fact_sales):,} fact_sales rows")
    
    # Generate fact_inventory
    print("  - Generating fact_inventory...")
    fact_inventory_rows = []
    for _, row in althea_data['inventory'].iterrows():
        snapshot_date = pd.to_datetime(row['snapshot_date'])
        fact_inventory_rows.append({
            'date_key': snapshot_date.strftime('%Y%m%d'),
            'product_key': row['sku'],
            'location_key': 'ALTHEA_WAREHOUSE',  # Single warehouse
            'on_hand_units': row['ending_inventory_packs'],
            'received_units': row['units_produced'],
            'shipped_units': row['units_shipped_total']
        })
    
    fact_inventory = pd.DataFrame(fact_inventory_rows)
    fact_inventory.to_csv(modeled_dir / "fact_inventory.csv", index=False)
    print(f"  - Generated {len(fact_inventory):,} fact_inventory rows")

def generate_manifest(althea_data):
    """Generate data manifest."""
    print("Generating data manifest...")
    
    manifest = {
        'generated_at': datetime.now().isoformat(),
        'data_source': 'Althea Manufacturer Model',
        'date_range': {
            'start': START_DATE.strftime('%Y-%m-%d'),
            'end': END_DATE.strftime('%Y-%m-%d')
        },
        'row_counts': {
            'b2b_orders': len(althea_data['b2b_orders']),
            'shipments': len(althea_data['shipments']),
            'sell_through': len(althea_data['sell_through']),
            'direct_sales': len(althea_data['direct_sales']),
            'inventory': len(althea_data['inventory']),
            'wholesalers': len(althea_data['wholesalers']),
            'retailers': len(althea_data['retailers']),
            'skus': len(althea_data['sku_catalog'])
        },
        'revenue': {
            'b2b_revenue': althea_data['b2b_orders']['net_amount'].sum(),
            'direct_revenue': althea_data['direct_sales']['net_amount'].sum(),
            'total_revenue': althea_data['b2b_orders']['net_amount'].sum() + althea_data['direct_sales']['net_amount'].sum()
        }
    }
    
    manifest_path = OUTPUT_DIR / "data_manifest.json"
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"  - Manifest saved to {manifest_path}")

def main():
    """Main data generation function."""
    print("=" * 60)
    print("Project 1 Data Generator - Manufacturer Model")
    print("=" * 60)
    print()
    
    # Load Althea manufacturer data
    althea_data = load_althea_data()
    
    # Generate dimensions
    dim_location = generate_dim_location(althea_data['wholesalers'], althea_data['retailers'])
    dim_product = generate_dim_product(althea_data['sku_catalog'])
    dim_channel = generate_dim_channel()
    dim_date = generate_dim_date(START_DATE, END_DATE)
    
    # Generate source extracts
    generate_source_extracts(althea_data, dim_location, dim_product, dim_channel)
    
    # Generate modeled tables
    generate_modeled_tables(althea_data, dim_location, dim_product, dim_channel, dim_date)
    
    # Generate manifest
    generate_manifest(althea_data)
    
    print("\n" + "=" * 60)
    print("Data generation complete!")
    print(f"Output directory: {OUTPUT_DIR}")
    print("=" * 60)

if __name__ == "__main__":
    main()

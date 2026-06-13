#!/usr/bin/env python3
"""
Althea Cannabis Gummies - Manufacturer Model Data Generator

Generates realistic data for a cannabis CPG manufacturer (Althea) that sells:
- Direct to wholesalers (distributors)
- Direct to recreational retailers (dispensaries)

Based on Oregon cannabis business licenses data for realistic business entities.

Data Sources Generated:
1. Distributor shipment data (what Althea ships to wholesalers)
2. B2B order data (wholesaler orders placed with Althea)
3. Sell-through data (what wholesalers sell to dispensaries)
4. Direct-to-retailer data (Althea sells directly to large dispensary chains)
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
import random

# Configuration
REPO_ROOT = Path(__file__).parent.parent
LICENSES_CSV = REPO_ROOT / "data/reference/or_licenses/raw/Cannabis-Business-Licenses-All.csv"
OUTPUT_DIR = REPO_ROOT / "data/reference/althea_manufacturer"
OUTPUT_DIR.mkdir(exist_ok=True)

# Date range
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2025, 12, 31)

# Althea product catalog (realistic gummy SKUs)
ALTHEA_SKUS = [
    {"sku": "ALT-PCH-100", "name": "Watermelon 1:1 THC:CBD 100mg", "category": "Edibles", "pack_size": 20, "unit_price": 18.00},
    {"sku": "ALT-PCH-200", "name": "Pineapple 1:1 THC:CBD 200mg", "category": "Edibles", "pack_size": 20, "unit_price": 32.00},
    {"sku": "ALT-RSP-100", "name": "Raspberry 1:1 THC:CBD 100mg", "category": "Edibles", "pack_size": 20, "unit_price": 18.00},
    {"sku": "ALT-RSP-200", "name": "Raspberry 1:1 THC:CBD 200mg", "category": "Edibles", "pack_size": 20, "unit_price": 32.00},
    {"sku": "ALT-BRR-100", "name": "Mango 1:1 THC:CBD 100mg", "category": "Edibles", "pack_size": 20, "unit_price": 18.00},
    {"sku": "ALT-BRR-200", "name": "Strawberry 1:1 THC:CBD 200mg", "category": "Edibles", "pack_size": 20, "unit_price": 32.00},
    {"sku": "ALT-LMN-100", "name": "Lemon 1:1 THC:CBD 100mg", "category": "Edibles", "pack_size": 20, "unit_price": 18.00},
    {"sku": "ALT-LMN-200", "name": "Lemon 1:1 THC:CBD 200mg", "category": "Edibles", "pack_size": 20, "unit_price": 32.00},
    {"sku": "ALT-CHY-100", "name": "Cherry 1:1 THC:CBD 100mg", "category": "Edibles", "pack_size": 20, "unit_price": 18.00},
    {"sku": "ALT-CHY-200", "name": "Cherry 1:1 THC:CBD 200mg", "category": "Edibles", "pack_size": 20, "unit_price": 32.00},
    {"sku": "ALT-HYB-100", "name": "Huckleberry 1:1 THC:CBD 100mg", "category": "Edibles", "pack_size": 20, "unit_price": 18.00},
    {"sku": "ALT-HYB-200", "name": "Huckleberry 1:1 THC:CBD 200mg", "category": "Edibles", "pack_size": 20, "unit_price": 32.00},
]

def load_licenses():
    """Load and parse Oregon cannabis business licenses."""
    print("Loading cannabis business licenses...")
    df = pd.read_csv(LICENSES_CSV)

    # Filter for relevant license types
    wholesalers = df[df['License Type'] == 'Recreational Wholesaler'].copy()
    retailers = df[df['License Type'] == 'Recreational Retailer'].copy()
    processors = df[df['License Type'] == 'Recreational Processor'].copy()

    # Clean and standardize
    for df_clean in [wholesalers, retailers, processors]:
        df_clean['Business Name'] = df_clean['Business Name'].str.strip()
        df_clean['County'] = df_clean['County'].str.strip()
        df_clean = df_clean.dropna(subset=['Business Name'])

    print(f"  - {len(wholesalers)} wholesalers found")
    print(f"  - {len(retailers)} retailers found")
    print(f"  - {len(processors)} processors found")

    return wholesalers, retailers, processors

def select_business_entities(wholesalers_df, retailers_df):
    """Use all available business entities for comprehensive geographic coverage."""
    # Use all wholesalers and retailers for accurate Tableau mapping
    selected_wholesalers = wholesalers_df.copy()
    selected_retailers = retailers_df.copy()

    return selected_wholesalers, selected_retailers

def generate_b2b_orders(wholesalers, start_date, end_date):
    """Generate B2B orders from wholesalers to Wyld."""
    print("Generating B2B orders...")

    orders = []
    current_date = start_date

    while current_date <= end_date:
        # Generate orders for each wholesaler (not every day)
        for _, wholesaler in wholesalers.iterrows():
            # Wholesalers order 2-3 times per week on average
            if random.random() < 0.4:  # 40% chance of order on any given day
                # Order 3-8 SKUs per order
                num_skus = random.randint(3, 8)
                selected_skus = random.sample(ALTHEA_SKUS, num_skus)

                for sku in selected_skus:
                    # Order quantity: 10-100 packs per SKU
                    quantity = random.randint(10, 100)

                    orders.append({
                        'order_date': current_date,
                        'order_id': f"ORD-{current_date.strftime('%Y%m%d')}-{random.randint(1000, 9999)}",
                        'wholesaler_license': wholesaler['License Number'],
                        'wholesaler_name': wholesaler['Business Name'],
                        'wholesaler_county': wholesaler['County'],
                        'sku': sku['sku'],
                        'sku_name': sku['name'],
                        'category': sku['category'],
                        'pack_size': sku['pack_size'],
                        'unit_price': sku['unit_price'],
                        'quantity_packs': quantity,
                        'total_units': quantity * sku['pack_size'],
                        'gross_amount': quantity * sku['unit_price'],
                        'discount_percent': random.uniform(0.05, 0.15),  # 5-15% wholesale discount
                    })

        current_date += timedelta(days=1)

    orders_df = pd.DataFrame(orders)
    orders_df['discount_amount'] = orders_df['gross_amount'] * orders_df['discount_percent']
    orders_df['net_amount'] = orders_df['gross_amount'] - orders_df['discount_amount']

    print(f"  - Generated {len(orders_df)} order line items")
    return orders_df

def generate_distributor_shipments(b2b_orders, wholesalers):
    """Generate shipment data from Wyld to distributors."""
    print("Generating distributor shipments...")

    # Shipments typically follow orders with 1-3 day lead time
    shipments = []

    for _, order in b2b_orders.iterrows():
        # Ship 1-2 days after order
        ship_date = order['order_date'] + timedelta(days=random.randint(1, 2))

        # Shipments may be split (partial fulfillment)
        if random.random() < 0.1:  # 10% chance of partial shipment
            ship_quantity = int(order['quantity_packs'] * random.uniform(0.7, 0.9))
        else:
            ship_quantity = order['quantity_packs']

        shipments.append({
            'shipment_date': ship_date,
            'shipment_id': f"SHP-{ship_date.strftime('%Y%m%d')}-{random.randint(1000, 9999)}",
            'order_id': order['order_id'],
            'wholesaler_license': order['wholesaler_license'],
            'wholesaler_name': order['wholesaler_name'],
            'sku': order['sku'],
            'sku_name': order['sku_name'],
            'quantity_packs_shipped': ship_quantity,
            'total_units_shipped': ship_quantity * order['pack_size'],
            'shipment_status': 'Shipped' if ship_quantity == order['quantity_packs'] else 'Partial',
        })

    shipments_df = pd.DataFrame(shipments)
    print(f"  - Generated {len(shipments_df)} shipment records")
    return shipments_df

def generate_sell_through_data(wholesalers, retailers, b2b_orders, start_date, end_date):
    """Generate sell-through data (what wholesalers sell to retailers)."""
    print("Generating sell-through data...")

    sell_through = []
    
    # For each wholesaler, simulate sales to retailers
    for _, wholesaler in wholesalers.iterrows():
        # Get orders for this wholesaler
        wholesaler_orders = b2b_orders[b2b_orders['wholesaler_license'] == wholesaler['License Number']]
        
        # Assign retailers to this wholesaler (each wholesaler serves 5-15 retailers)
        num_retailers = random.randint(5, 15)
        assigned_retailers = retailers.sample(n=min(num_retailers, len(retailers)), random_state=random.randint(1, 100))
        
        current_date = start_date
        while current_date <= end_date:
            # Generate daily sell-through for assigned retailers
            for _, retailer in assigned_retailers.iterrows():
                # Retailers purchase from wholesalers 3-5 times per week
                if random.random() < 0.5:
                    # Select 2-5 SKUs
                    num_skus = random.randint(2, 5)
                    selected_skus = random.sample(ALTHEA_SKUS, num_skus)
                    
                    for sku in selected_skus:
                        # Purchase quantity: 5-30 packs
                        quantity = random.randint(5, 30)
                        
                        # Markup from wholesale price (20-40%)
                        wholesale_price = sku['unit_price'] * 0.7  # Approximate wholesale cost
                        retail_markup = random.uniform(1.2, 1.4)
                        retail_price = wholesale_price * retail_markup
                        
                        sell_through.append({
                            'sale_date': current_date,
                            'wholesaler_license': wholesaler['License Number'],
                            'wholesaler_name': wholesaler['Business Name'],
                            'retailer_license': retailer['License Number'],
                            'retailer_name': retailer['Business Name'],
                            'retailer_county': retailer['County'],
                            'sku': sku['sku'],
                            'sku_name': sku['name'],
                            'quantity_packs': quantity,
                            'total_units': quantity * sku['pack_size'],
                            'wholesale_price': wholesale_price,
                            'retail_price': retail_price,
                            'gross_amount': quantity * retail_price,
                        })
            
            current_date += timedelta(days=1)
    
    sell_through_df = pd.DataFrame(sell_through)
    print(f"  - Generated {len(sell_through_df)} sell-through records")
    return sell_through_df

def generate_direct_to_retailer_data(retailers, start_date, end_date):
    """Generate direct-to-retailer data (Wyld sells directly to large chains)."""
    print("Generating direct-to-retailer data...")
    
    # Select top 10 retailers as "direct accounts" (large chains)
    direct_retailers = retailers.sample(n=min(10, len(retailers)), random_state=43)
    
    direct_sales = []
    current_date = start_date
    
    while current_date <= end_date:
        # Direct accounts order weekly
        for _, retailer in direct_retailers.iterrows():
            if random.random() < 0.15:  # Weekly orders
                # Order 5-10 SKUs in larger quantities
                num_skus = random.randint(5, 10)
                selected_skus = random.sample(ALTHEA_SKUS, num_skus)
                
                for sku in selected_skus:
                    # Larger order quantities: 50-200 packs
                    quantity = random.randint(50, 200)
                    
                    direct_sales.append({
                        'sale_date': current_date,
                        'order_id': f"DIR-{current_date.strftime('%Y%m%d')}-{random.randint(1000, 9999)}",
                        'retailer_license': retailer['License Number'],
                        'retailer_name': retailer['Business Name'],
                        'retailer_county': retailer['County'],
                        'account_type': 'Direct',
                        'sku': sku['sku'],
                        'sku_name': sku['name'],
                        'category': sku['category'],
                        'pack_size': sku['pack_size'],
                        'unit_price': sku['unit_price'],
                        'quantity_packs': quantity,
                        'total_units': quantity * sku['pack_size'],
                        'gross_amount': quantity * sku['unit_price'],
                        'discount_percent': random.uniform(0.10, 0.20),  # 10-20% direct account discount
                    })
        
        current_date += timedelta(days=1)
    
    direct_sales_df = pd.DataFrame(direct_sales)
    direct_sales_df['discount_amount'] = direct_sales_df['gross_amount'] * direct_sales_df['discount_percent']
    direct_sales_df['net_amount'] = direct_sales_df['gross_amount'] - direct_sales_df['discount_amount']
    
    print(f"  - Generated {len(direct_sales_df)} direct sales records")
    return direct_sales_df

def generate_inventory_data(b2b_orders, direct_sales, start_date, end_date):
    """Generate inventory snapshot data for Wyld's warehouse."""
    print("Generating inventory data...")
    
    inventory = []
    current_date = start_date
    
    # Calculate daily production and shipments
    while current_date <= end_date:
        for sku in ALTHEA_SKUS:
            # Production: 100-500 packs per day per SKU
            daily_production = random.randint(100, 500)
            
            # Shipments: sum of orders for this date
            daily_shipments = b2b_orders[b2b_orders['order_date'] == current_date]
            daily_direct = direct_sales[direct_sales['sale_date'] == current_date]
            
            sku_shipments = daily_shipments[daily_shipments['sku'] == sku['sku']]['quantity_packs'].sum()
            sku_direct = daily_direct[daily_direct['sku'] == sku['sku']]['quantity_packs'].sum()
            total_shipments = sku_shipments + sku_direct
            
            # Calculate ending inventory (simplified)
            # In reality, this would be cumulative
            ending_inventory = max(0, daily_production - total_shipments + random.randint(500, 2000))
            
            inventory.append({
                'snapshot_date': current_date,
                'sku': sku['sku'],
                'sku_name': sku['name'],
                'category': sku['category'],
                'pack_size': sku['pack_size'],
                'units_produced': daily_production,
                'units_shipped_wholesale': sku_shipments,
                'units_shipped_direct': sku_direct,
                'units_shipped_total': total_shipments,
                'ending_inventory_packs': ending_inventory,
                'ending_inventory_units': ending_inventory * sku['pack_size'],
                'days_of_supply': (ending_inventory * sku['pack_size']) / max(1, total_shipments) if total_shipments > 0 else 999,
            })
        
        current_date += timedelta(days=1)
    
    inventory_df = pd.DataFrame(inventory)
    print(f"  - Generated {len(inventory_df)} inventory snapshot records")
    return inventory_df

def main():
    """Main data generation function."""
    print("=" * 60)
    print("Althea Cannabis Gummies - Manufacturer Model Data Generator")
    print("=" * 60)
    print()
    
    # Load business licenses
    wholesalers, retailers, processors = load_licenses()
    
    # Select business entities (use all for comprehensive geographic coverage)
    selected_wholesalers, selected_retailers = select_business_entities(wholesalers, retailers)
    print(f"\nUsing {len(selected_wholesalers)} wholesalers and {len(selected_retailers)} retailers")
    
    # Generate data
    b2b_orders = generate_b2b_orders(selected_wholesalers, START_DATE, END_DATE)
    shipments = generate_distributor_shipments(b2b_orders, selected_wholesalers)
    sell_through = generate_sell_through_data(selected_wholesalers, selected_retailers, b2b_orders, START_DATE, END_DATE)
    direct_sales = generate_direct_to_retailer_data(selected_retailers, START_DATE, END_DATE)
    inventory = generate_inventory_data(b2b_orders, direct_sales, START_DATE, END_DATE)
    
    # Save to CSV
    print("\nSaving data files...")
    b2b_orders.to_csv(OUTPUT_DIR / "althea_b2b_orders.csv", index=False)
    shipments.to_csv(OUTPUT_DIR / "althea_distributor_shipments.csv", index=False)
    sell_through.to_csv(OUTPUT_DIR / "althea_sell_through.csv", index=False)
    direct_sales.to_csv(OUTPUT_DIR / "althea_direct_to_retailer.csv", index=False)
    inventory.to_csv(OUTPUT_DIR / "althea_inventory_snapshots.csv", index=False)
    
    # Save business entity reference
    selected_wholesalers.to_csv(OUTPUT_DIR / "wholesalers_reference.csv", index=False)
    selected_retailers.to_csv(OUTPUT_DIR / "retailers_reference.csv", index=False)
    
    # Save SKU catalog
    pd.DataFrame(ALTHEA_SKUS).to_csv(OUTPUT_DIR / "althea_sku_catalog.csv", index=False)
    
    print("\n" + "=" * 60)
    print("Data generation complete!")
    print(f"Output directory: {OUTPUT_DIR}")
    print("=" * 60)
    
    # Print summary statistics
    print("\nSummary Statistics:")
    print(f"  B2B Orders: {len(b2b_orders):,} line items")
    print(f"  Shipments: {len(shipments):,} records")
    print(f"  Sell-through: {len(sell_through):,} records")
    print(f"  Direct Sales: {len(direct_sales):,} records")
    print(f"  Inventory Snapshots: {len(inventory):,} records")
    print(f"  Total Revenue (B2B): ${b2b_orders['net_amount'].sum():,.2f}")
    print(f"  Total Revenue (Direct): ${direct_sales['net_amount'].sum():,.2f}")
    print(f"  Combined Revenue: ${(b2b_orders['net_amount'].sum() + direct_sales['net_amount'].sum()):,.2f}")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3

from pathlib import Path
import numpy as np
import pandas as pd


# ------------------------------------------------------------
# 1. PROJECT PATHS
# ------------------------------------------------------------

project_dir = Path("03_forecasting_variance_story")
output_dir = project_dir / "data" / "source_extracts"
output_dir.mkdir(parents=True, exist_ok=True)

output_file = output_dir / "forecast_actuals_weekly.csv"


# ------------------------------------------------------------
# 2. RANDOM SEED
# ------------------------------------------------------------
# A seed makes the random data repeatable.
# If you run the script twice, you get the same fake data.

rng = np.random.default_rng(42)


# ------------------------------------------------------------
# 3. BASIC BUSINESS DIMENSIONS
# ------------------------------------------------------------

weeks = pd.date_range(
    start="2025-01-06",
    end="2026-03-30",
    freq="W-MON"
)

stores = [
    "OR001", "OR002", "OR003", "OR004", "OR005",
    "WA001", "WA002", "WA003", "WA004", "WA005",
    "CA001", "CA002", "CA003", "CA004", "CA005",
    "CO001", "CO002", "CO003", "CO004", "CO005",
]

skus = [
    "SKU0001", "SKU0002", "SKU0003", "SKU0004", "SKU0005",
    "SKU0006", "SKU0007", "SKU0008", "SKU0009", "SKU0010",
]

channels = ["retail", "wholesale", "distributor"]


# ------------------------------------------------------------
# 4. LOOKUP TABLES / BUSINESS ASSUMPTIONS
# ------------------------------------------------------------

sku_base_units = {
    "SKU0001": 52,
    "SKU0002": 48,
    "SKU0003": 44,
    "SKU0004": 40,
    "SKU0005": 38,
    "SKU0006": 35,
    "SKU0007": 33,
    "SKU0008": 30,
    "SKU0009": 28,
    "SKU0010": 25,
}

sku_base_price = {
    "SKU0001": 10.00,
    "SKU0002": 10.00,
    "SKU0003": 10.50,
    "SKU0004": 10.50,
    "SKU0005": 10.00,
    "SKU0006": 10.50,
    "SKU0007": 10.00,
    "SKU0008": 10.50,
    "SKU0009": 10.50,
    "SKU0010": 10.50,
}

channel_unit_multiplier = {
    "retail": 1.00,
    "wholesale": 0.75,
    "distributor": 0.60,
}

channel_price_multiplier = {
    "retail": 1.00,
    "wholesale": 0.88,
    "distributor": 0.82,
}


# ------------------------------------------------------------
# 5. BUILD ROWS
# ------------------------------------------------------------

rows = []

for week in weeks:
    month = week.month

    if month in [6, 7, 8]:
        seasonality = 1.12
    elif month in [11, 12]:
        seasonality = 1.18
    elif month in [1, 2]:
        seasonality = 0.90
    else:
        seasonality = 1.00

    for store in stores:

        if store.startswith("OR"):
            store_multiplier = 1.10
        elif store.startswith("WA"):
            store_multiplier = 1.05
        elif store.startswith("CA"):
            store_multiplier = 1.20
        elif store.startswith("CO"):
            store_multiplier = 0.95
        else:
            store_multiplier = 1.00

        for sku in skus:
            for channel in channels:

                base_units = sku_base_units[sku]
                base_price = sku_base_price[sku]

                channel_units = channel_unit_multiplier[channel]
                channel_price = channel_price_multiplier[channel]

                forecast_noise = rng.normal(1.00, 0.08)

                forecast_units = (
                    base_units
                    * store_multiplier
                    * channel_units
                    * seasonality
                    * forecast_noise
                )

                forecast_units = max(1, round(forecast_units))

                forecast_unit_price = base_price * channel_price

                promo_flag = False
                stockout_flag = False

                # Promo example:
                # SKU0001 and SKU0002 get a summer promo in retail.
                if sku in ["SKU0001", "SKU0002"] and channel == "retail" and month in [7, 8]:
                    promo_flag = True

                # Stockout example:
                # SKU0003 has occasional stockout pressure.
                if sku == "SKU0003" and store.startswith("CA") and month in [11, 12]:
                    stockout_flag = True

                actual_units = forecast_units
                actual_unit_price = forecast_unit_price

                # Add normal actual demand noise.
                actual_units = actual_units * rng.normal(1.00, 0.12)

                # Promotions usually increase units but reduce price.
                if promo_flag:
                    actual_units = actual_units * 1.25
                    actual_unit_price = actual_unit_price * 0.92

                # Stockouts reduce actual units.
                if stockout_flag:
                    actual_units = actual_units * 0.65

                # Channel-level forecast bias.
                # This makes the project more realistic.
                if channel == "wholesale":
                    actual_units = actual_units * 0.95
                elif channel == "distributor":
                    actual_units = actual_units * 1.08

                actual_units = max(0, round(actual_units))

                forecast_net_sales = round(forecast_units * forecast_unit_price, 2)
                actual_net_sales = round(actual_units * actual_unit_price, 2)

                # Most recent week has partial actuals.
                # This simulates reporting lag.
                if week == weeks.max() and rng.random() < 0.35:
                    actual_units_value = np.nan
                    actual_unit_price_value = np.nan
                    actual_net_sales_value = np.nan
                else:
                    actual_units_value = actual_units
                    actual_unit_price_value = round(actual_unit_price, 2)
                    actual_net_sales_value = actual_net_sales

                rows.append({
                    "week_start_date": week.date().isoformat(),
                    "store_code": store,
                    "sku": sku,
                    "channel": channel,
                    "forecast_units": forecast_units,
                    "actual_units": actual_units_value,
                    "forecast_net_sales": forecast_net_sales,
                    "actual_net_sales": actual_net_sales_value,
                    "forecast_unit_price": round(forecast_unit_price, 2),
                    "actual_unit_price": actual_unit_price_value,
                    "promo_flag": promo_flag,
                    "stockout_flag": stockout_flag,
                    "plan_version": "latest_forecast",
                })


# ------------------------------------------------------------
# 6. TURN ROWS INTO A DATAFRAME
# ------------------------------------------------------------

df = pd.DataFrame(rows)


# ------------------------------------------------------------
# 7. WRITE CSV
# ------------------------------------------------------------

df.to_csv(output_file, index=False)


# ------------------------------------------------------------
# 8. PRINT RUN SUMMARY
# ------------------------------------------------------------

print("")
print("Project 3 forecast input file created.")
print(f"Output file: {output_file}")
print(f"Rows written: {len(df):,}")
print(f"Date range: {df['week_start_date'].min()} to {df['week_start_date'].max()}")
print(f"Stores: {df['store_code'].nunique()}")
print(f"SKUs: {df['sku'].nunique()}")
print(f"Channels: {df['channel'].nunique()}")
print(f"Total forecast net sales: ${df['forecast_net_sales'].sum():,.2f}")
print(f"Total actual net sales: ${df['actual_net_sales'].sum():,.2f}")
print(f"Rows missing actuals: {df['actual_net_sales'].isna().sum():,}")
print("")
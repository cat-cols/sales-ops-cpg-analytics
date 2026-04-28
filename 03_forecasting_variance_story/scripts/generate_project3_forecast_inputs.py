#!/usr/bin/env python3

from pathlib import Path
import numpy as np
import pandas as pd


# ------------------------------------------------------------
# 1. PROJECT + SHARED PATHS
# ------------------------------------------------------------
# Shared seeds = reusable reference/master data.
# Project 3 source_extracts = Project 3-specific generated fact/source data.

repo_dir = Path(".")
project_dir = repo_dir / "03_forecasting_variance_story"
shared_seed_dir = repo_dir / "shared" / "seeds"

project_output_dir = project_dir / "data" / "source_extracts"

shared_seed_dir.mkdir(parents=True, exist_ok=True)
project_output_dir.mkdir(parents=True, exist_ok=True)

forecast_output_file = project_output_dir / "forecast_actuals_weekly.csv"


location_seed_file = shared_seed_dir / "location_seed.csv"
product_seed_file = shared_seed_dir / "product_seed.csv"
channel_seed_file = shared_seed_dir / "channel_seed.csv"
calendar_seed_file = shared_seed_dir / "calendar_seed.csv"


# ------------------------------------------------------------
# 2. RANDOM SEED
# ------------------------------------------------------------
# A seed makes the random data repeatable.
# If you run the script twice, you get the same fake data.

rng = np.random.default_rng(42)


# ------------------------------------------------------------
# 3. CREATE SHARED STORE SEED IF IT DOES NOT EXIST
# ------------------------------------------------------------

if not location_seed_file.exists() or location_seed_file.stat().st_size == 0:
    location_rows = [
        {"store_code": "OR001", "state": "OR", "region": "Pacific Northwest", "store_multiplier": 1.10},
        {"store_code": "OR002", "state": "OR", "region": "Pacific Northwest", "store_multiplier": 1.08},
        {"store_code": "OR003", "state": "OR", "region": "Pacific Northwest", "store_multiplier": 1.05},
        {"store_code": "OR004", "state": "OR", "region": "Pacific Northwest", "store_multiplier": 1.03},
        {"store_code": "OR005", "state": "OR", "region": "Pacific Northwest", "store_multiplier": 1.00},

        {"store_code": "WA001", "state": "WA", "region": "Pacific Northwest", "store_multiplier": 1.07},
        {"store_code": "WA002", "state": "WA", "region": "Pacific Northwest", "store_multiplier": 1.05},
        {"store_code": "WA003", "state": "WA", "region": "Pacific Northwest", "store_multiplier": 1.03},
        {"store_code": "WA004", "state": "WA", "region": "Pacific Northwest", "store_multiplier": 1.01},
        {"store_code": "WA005", "state": "WA", "region": "Pacific Northwest", "store_multiplier": 0.98},

        {"store_code": "CA001", "state": "CA", "region": "West", "store_multiplier": 1.22},
        {"store_code": "CA002", "state": "CA", "region": "West", "store_multiplier": 1.18},
        {"store_code": "CA003", "state": "CA", "region": "West", "store_multiplier": 1.14},
        {"store_code": "CA004", "state": "CA", "region": "West", "store_multiplier": 1.10},
        {"store_code": "CA005", "state": "CA", "region": "West", "store_multiplier": 1.06},

        {"store_code": "CO001", "state": "CO", "region": "Mountain", "store_multiplier": 0.98},
        {"store_code": "CO002", "state": "CO", "region": "Mountain", "store_multiplier": 0.96},
        {"store_code": "CO003", "state": "CO", "region": "Mountain", "store_multiplier": 0.94},
        {"store_code": "CO004", "state": "CO", "region": "Mountain", "store_multiplier": 0.92},
        {"store_code": "CO005", "state": "CO", "region": "Mountain", "store_multiplier": 0.90},
    ]

    location_seed_df = pd.DataFrame(location_rows)
    location_seed_df.to_csv(location_seed_file, index=False)


# ------------------------------------------------------------
# 4. CREATE SHARED PRODUCT SEED IF IT DOES NOT EXIST
# ------------------------------------------------------------

if not product_seed_file.exists() or product_seed_file.stat().st_size == 0:
    product_rows = [
        {
            "sku": "SKU0001",
            "product_name": "Blood Orange Gummies",
            "product_family": "gummies",
            "base_units": 52,
            "base_price": 10.00,
        },
        {
            "sku": "SKU0002",
            "product_name": "Boysenberry Gummies",
            "product_family": "gummies",
            "base_units": 48,
            "base_price": 10.00,
        },
        {
            "sku": "SKU0003",
            "product_name": "Elderberry Gummies",
            "product_family": "gummies",
            "base_units": 44,
            "base_price": 10.50,
        },
        {
            "sku": "SKU0004",
            "product_name": "Grapefruit Gummies",
            "product_family": "gummies",
            "base_units": 40,
            "base_price": 10.50,
        },
        {
            "sku": "SKU0005",
            "product_name": "Huckleberry Gummies",
            "product_family": "gummies",
            "base_units": 38,
            "base_price": 10.00,
        },
        {
            "sku": "SKU0006",
            "product_name": "Kiwi Gummies",
            "product_family": "gummies",
            "base_units": 35,
            "base_price": 10.50,
        },
        {
            "sku": "SKU0007",
            "product_name": "Marionberry Gummies",
            "product_family": "gummies",
            "base_units": 33,
            "base_price": 10.00,
        },
        {
            "sku": "SKU0008",
            "product_name": "Peach Gummies",
            "product_family": "gummies",
            "base_units": 30,
            "base_price": 10.50,
        },
        {
            "sku": "SKU0009",
            "product_name": "Pear Gummies",
            "product_family": "gummies",
            "base_units": 28,
            "base_price": 10.50,
        },
        {
            "sku": "SKU0010",
            "product_name": "Pomegranate Gummies",
            "product_family": "gummies",
            "base_units": 25,
            "base_price": 10.50,
        },
    ]

    product_seed_df = pd.DataFrame(product_rows)
    product_seed_df.to_csv(product_seed_file, index=False)


# ------------------------------------------------------------
# 5. CREATE SHARED CHANNEL SEED IF IT DOES NOT EXIST
# ------------------------------------------------------------

if not channel_seed_file.exists() or channel_seed_file.stat().st_size == 0:
    channel_rows = [
        {
            "channel": "retail",
            "channel_unit_multiplier": 1.00,
            "channel_price_multiplier": 1.00,
            "actual_bias_multiplier": 1.00,
        },
        {
            "channel": "wholesale",
            "channel_unit_multiplier": 0.75,
            "channel_price_multiplier": 0.88,
            "actual_bias_multiplier": 0.95,
        },
        {
            "channel": "distributor",
            "channel_unit_multiplier": 0.60,
            "channel_price_multiplier": 0.82,
            "actual_bias_multiplier": 1.08,
        },
    ]

    channel_seed_df = pd.DataFrame(channel_rows)
    channel_seed_df.to_csv(channel_seed_file, index=False)


# ------------------------------------------------------------
# 6. CREATE SHARED CALENDAR SEED IF IT DOES NOT EXIST
# ------------------------------------------------------------

if not calendar_seed_file.exists() or calendar_seed_file.stat().st_size == 0:
    weeks = pd.date_range(
        start="2025-01-06",
        end="2026-03-30",
        freq="W-MON",
    )

    calendar_rows = []

    for week in weeks:
        month = week.month

        if month in [6, 7, 8]:
            seasonality_multiplier = 1.12
            seasonality_label = "summer_lift"
        elif month in [11, 12]:
            seasonality_multiplier = 1.18
            seasonality_label = "holiday_lift"
        elif month in [1, 2]:
            seasonality_multiplier = 0.90
            seasonality_label = "winter_softness"
        else:
            seasonality_multiplier = 1.00
            seasonality_label = "baseline"

        calendar_rows.append(
            {
                "week_start_date": week.date().isoformat(),
                "calendar_year": week.year,
                "calendar_month": week.month,
                "calendar_quarter": f"Q{week.quarter}",
                "seasonality_label": seasonality_label,
                "seasonality_multiplier": seasonality_multiplier,
            }
        )

    calendar_seed_df = pd.DataFrame(calendar_rows)
    calendar_seed_df.to_csv(calendar_seed_file, index=False)


# ------------------------------------------------------------
# 7. READ SHARED SEEDS
# ------------------------------------------------------------
# From this point forward, the generator uses the shared seed files
# instead of hardcoding stores/products/channels inside the row loop.

locations_df = pd.read_csv(location_seed_file)
products_df = pd.read_csv(product_seed_file)
channels_df = pd.read_csv(channel_seed_file)
calendar_df = pd.read_csv(calendar_seed_file)


# ------------------------------------------------------------
# 8. BUILD PROJECT 3 FORECAST + ACTUAL ROWS
# ------------------------------------------------------------

rows = []

for _, calendar_row in calendar_df.iterrows():
    week_start_date = calendar_row["week_start_date"]
    month = int(calendar_row["calendar_month"])
    seasonality_multiplier = float(calendar_row["seasonality_multiplier"])
    seasonality_label = calendar_row["seasonality_label"]

    for _, location_row in locations_df.iterrows():
        store_code = location_row["store_code"]
        state = location_row["state"]
        region = location_row["region"]
        store_multiplier = float(location_row["store_multiplier"])

        for _, product_row in products_df.iterrows():
            sku = product_row["sku"]
            product_name = product_row["product_name"]
            product_family = product_row["product_family"]
            base_units = float(product_row["base_units"])
            base_price = float(product_row["base_price"])

            for _, channel_row in channels_df.iterrows():
                channel = channel_row["channel"]
                channel_unit_multiplier = float(channel_row["channel_unit_multiplier"])
                channel_price_multiplier = float(channel_row["channel_price_multiplier"])
                actual_bias_multiplier = float(channel_row["actual_bias_multiplier"])

                forecast_noise = rng.normal(1.00, 0.08)

                forecast_units = (
                    base_units
                    * store_multiplier
                    * channel_unit_multiplier
                    * seasonality_multiplier
                    * forecast_noise
                )

                forecast_units = max(1, round(forecast_units))

                forecast_unit_price = base_price * channel_price_multiplier

                promo_flag = False
                stockout_flag = False
                business_event = "none"

                # Promo scenario:
                # Top gummies receive a summer retail promo.
                if sku in ["SKU0001", "SKU0002"] and channel == "retail" and month in [7, 8]:
                    promo_flag = True
                    business_event = "summer_retail_promo"

                # Stockout scenario:
                # Elderberry has stockout pressure in CA during holiday months.
                if sku == "SKU0003" and state == "CA" and month in [11, 12]:
                    stockout_flag = True
                    business_event = "holiday_stockout_pressure"

                actual_units = forecast_units
                actual_unit_price = forecast_unit_price

                # Normal actual demand noise.
                actual_units = actual_units * rng.normal(1.00, 0.12)

                # Promotions increase units but reduce unit price.
                if promo_flag:
                    actual_units = actual_units * 1.25
                    actual_unit_price = actual_unit_price * 0.92

                # Stockouts reduce actual units.
                if stockout_flag:
                    actual_units = actual_units * 0.65

                # Channel-level forecast bias.
                actual_units = actual_units * actual_bias_multiplier

                actual_units = max(0, round(actual_units))

                forecast_net_sales = round(forecast_units * forecast_unit_price, 2)
                actual_net_sales = round(actual_units * actual_unit_price, 2)

                # Most recent week has partial actuals.
                # This simulates reporting lag.
                if week_start_date == calendar_df["week_start_date"].max() and rng.random() < 0.35:
                    actual_units_value = np.nan
                    actual_unit_price_value = np.nan
                    actual_net_sales_value = np.nan
                    is_partial_actual = True
                else:
                    actual_units_value = actual_units
                    actual_unit_price_value = round(actual_unit_price, 2)
                    actual_net_sales_value = actual_net_sales
                    is_partial_actual = False

                rows.append(
                    {
                        "week_start_date": week_start_date,
                        "store_code": store_code,
                        "state": state,
                        "region": region,
                        "sku": sku,
                        "product_name": product_name,
                        "product_family": product_family,
                        "channel": channel,
                        "forecast_units": forecast_units,
                        "actual_units": actual_units_value,
                        "forecast_net_sales": forecast_net_sales,
                        "actual_net_sales": actual_net_sales_value,
                        "forecast_unit_price": round(forecast_unit_price, 2),
                        "actual_unit_price": actual_unit_price_value,
                        "promo_flag": promo_flag,
                        "stockout_flag": stockout_flag,
                        "is_partial_actual": is_partial_actual,
                        "seasonality_label": seasonality_label,
                        "business_event": business_event,
                        "plan_version": "latest_forecast",
                    }
                )


# ------------------------------------------------------------
# 9. TURN ROWS INTO A DATAFRAME
# ------------------------------------------------------------

forecast_df = pd.DataFrame(rows)


# ------------------------------------------------------------
# 10. WRITE PROJECT 3 SOURCE EXTRACT
# ------------------------------------------------------------

forecast_df.to_csv(forecast_output_file, index=False)


# ------------------------------------------------------------
# 11. PRINT RUN SUMMARY
# ------------------------------------------------------------

print("")
print("Project 3 forecast input file created.")
print(f"Output file: {forecast_output_file}")
print("")
print("Shared seed files used:")
print(f"- {location_seed_file}")
print(f"- {product_seed_file}")
print(f"- {channel_seed_file}")
print(f"- {calendar_seed_file}")
print("")
print(f"Rows written: {len(forecast_df):,}")
print(f"Date range: {forecast_df['week_start_date'].min()} to {forecast_df['week_start_date'].max()}")
print(f"Stores: {forecast_df['store_code'].nunique()}")
print(f"Products/SKUs: {forecast_df['sku'].nunique()}")
print(f"Channels: {forecast_df['channel'].nunique()}")
print(f"Total forecast net sales: ${forecast_df['forecast_net_sales'].sum():,.2f}")
print(f"Total actual net sales: ${forecast_df['actual_net_sales'].sum():,.2f}")
print(f"Rows missing actuals: {forecast_df['actual_net_sales'].isna().sum():,}")
print("")
print("Business event counts:")
print(forecast_df["business_event"].value_counts(dropna=False).to_string())
print("")
#!/usr/bin/env python3
# 04_ghg_scope_reporting/scripts/generate_project4_ghg_inputs.py

"""
Project 4 source simulator: GHG Scope Reporting + Audit-Ready Documentation.

Purpose:
1) Generate synthetic monthly GHG activity source extracts.
2) Make the source extracts intentionally messy enough to justify staging SQL.
3) Create a versioned emissions factor reference file.
4) Write a source drop manifest so the project has audit-style lineage from day one.

Generated source extracts:
- facility_master.csv
- product_line_master.csv
- electricity_bills_monthly.xlsx
- fuel_usage_facility.csv
- shipping_miles_logistics.csv
- packaging_materials_procurement.csv
- emission_factors_reference.csv
- ghg_source_drop_manifest.csv

All values are synthetic and for portfolio/demo use only.
"""

from __future__ import annotations

import argparse
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


# -----------------------------
# Config
# -----------------------------

@dataclass
class Config:
    start: str = "2025-01-01"
    end: str = "2025-12-01"
    seed: int = 44

    pct_duplicate: float = 0.04
    pct_missing_facility: float = 0.03
    pct_missing_product_line: float = 0.03
    pct_bad_month_format: float = 0.10
    pct_negative_usage: float = 0.02
    pct_unit_mismatch: float = 0.08
    pct_text_casing_drift: float = 0.10


def get_project_root() -> Path:
    """Return the 04_ghg_scope_reporting project folder."""
    return Path(__file__).resolve().parents[1]


def ensure_dirs(project_root: Path) -> None:
    (project_root / "data" / "source_extracts").mkdir(parents=True, exist_ok=True)
    (project_root / "docs").mkdir(parents=True, exist_ok=True)


def current_dir(project_root: Path, source_name: str) -> Path:
    path = project_root / "data" / "source_extracts" / source_name / "current"
    path.mkdir(parents=True, exist_ok=True)
    return path


def incoming_dir(project_root: Path, source_name: str, drop_date: pd.Timestamp) -> Path:
    path = (
        project_root
        / "data"
        / "source_extracts"
        / source_name
        / "incoming"
        / f"{drop_date.year:04d}"
        / f"{drop_date.month:02d}"
        / f"{drop_date.day:02d}"
    )
    path.mkdir(parents=True, exist_ok=True)
    return path

def get_repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def get_shared_source_systems_dir(repo_root: Path) -> Path:
    return repo_root / "shared" / "source_systems"


def get_shared_seed_dir(repo_root: Path) -> Path:
    return repo_root / "shared" / "seeds"

# -----------------------------
# Reference data
# -----------------------------

def make_facilities(shared_seed_dir: Path) -> pd.DataFrame:
    """Facilities are the shared location dimension for Scope 1/2/3 reporting."""
    location_seed_file = shared_seed_dir / "location_seed.csv"

    if not location_seed_file.exists():
        raise FileNotFoundError(f"Shared seed file not found: {location_seed_file}")

    location_df = pd.read_csv(location_seed_file)

    # Dynamic mapping based on actual seed data
    # Use first 5 locations from seed for demo purposes
    facility_type_map = {
        "OR": ["Manufacturing", "Distribution"],
        "WA": ["Warehouse"],
        "CA": ["Office"],
        "CO": ["Manufacturing"],
    }

    city_map = {
        "OR": ["Portland", "Clackamas"],
        "WA": ["Vancouver"],
        "CA": ["Oakland"],
        "CO": ["Denver"],
    }

    rows = []
    for i, (_, loc_row) in enumerate(location_df.head(5).iterrows(), start=1):
        store_code = loc_row["store_code"]
        state = loc_row["state"]

        # Get facility type and city dynamically based on state
        state_facility_types = facility_type_map.get(state, ["Warehouse"])
        state_cities = city_map.get(state, ["Unknown"])

        # Use index to cycle through available types/cities for that state
        facility_type = state_facility_types[(i - 1) % len(state_facility_types)]
        city = state_cities[(i - 1) % len(state_cities)]

        rows.append({
            "facility_id": f"FAC{i:03d}",
            "facility_name": f"{city} {facility_type}",
            "facility_type": facility_type,
            "city": city,
            "state_province": state,
            "country": "US",
            "grid_region": state,
            "active_flag": "Y",
            "opened_date": "2021-01-01",
        })

    return pd.DataFrame(rows)


def make_product_lines(shared_seed_dir: Path) -> pd.DataFrame:
    """Product line lets us calculate intensity by business line later."""
    product_seed_file = shared_seed_dir / "product_seed.csv"
    
    if not product_seed_file.exists():
        raise FileNotFoundError(f"Shared seed file not found: {product_seed_file}")
    
    product_df = pd.read_csv(product_seed_file)
    
    # Extract unique product families from seed and map to product lines
    unique_families = product_df["product_family"].unique()
    
    rows = []
    for i, family in enumerate(unique_families, start=1):
        rows.append({
            "product_line_id": f"PL{i:03d}",
            "product_line_name": f"{family.capitalize()} Line",
            "product_family": family,
            "active_flag": "Y",
        })
    
    # Add packaging shared line for GHG reporting
    rows.append({
        "product_line_id": "PL004",
        "product_line_name": "Packaging Shared",
        "product_family": "Shared",
        "active_flag": "Y",
    })
    
    return pd.DataFrame(rows)


def make_emission_factors() -> pd.DataFrame:
    """
    Synthetic factor table.

    factor_value_kg_co2e_per_unit means:
    activity_amount * factor_value_kg_co2e_per_unit = kg CO2e
    """
    rows = [
        # Scope 2 electricity factors by grid region
        {"factor_id": "EF_ELEC_OR_2025", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "OR", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.178, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2025-01-01", "effective_end": "2025-12-31", "version": "2025.1", "is_current": "N"},
        {"factor_id": "EF_ELEC_WA_2025", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "WA", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.102, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2025-01-01", "effective_end": "2025-12-31", "version": "2025.1", "is_current": "N"},
        {"factor_id": "EF_ELEC_CA_2025", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "CA", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.210, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2025-01-01", "effective_end": "2025-12-31", "version": "2025.1", "is_current": "N"},
        {"factor_id": "EF_ELEC_CO_2025", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "CO", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.512, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2025-01-01", "effective_end": "2025-12-31", "version": "2025.1", "is_current": "N"},
        {"factor_id": "EF_ELEC_OR_2026", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "OR", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.171, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2026-01-01", "effective_end": "2026-12-31", "version": "2026.1", "is_current": "Y"},
        {"factor_id": "EF_ELEC_WA_2026", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "WA", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.097, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2026-01-01", "effective_end": "2026-12-31", "version": "2026.1", "is_current": "Y"},
        {"factor_id": "EF_ELEC_CA_2026", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "CA", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.198, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2026-01-01", "effective_end": "2026-12-31", "version": "2026.1", "is_current": "Y"},
        {"factor_id": "EF_ELEC_CO_2026", "scope": "Scope 2", "factor_type": "electricity_kwh", "region": "CO", "activity_unit": "kWh", "factor_value_kg_co2e_per_unit": 0.493, "source_authority": "Synthetic eGRID-style factor", "effective_start": "2026-01-01", "effective_end": "2026-12-31", "version": "2026.1", "is_current": "Y"},
        # Scope 1 fuel factors
        {"factor_id": "EF_NG_THERM_2025", "scope": "Scope 1", "factor_type": "natural_gas_therm", "region": "US", "activity_unit": "therm", "factor_value_kg_co2e_per_unit": 5.31, "source_authority": "Synthetic combustion factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        {"factor_id": "EF_DIESEL_GAL_2025", "scope": "Scope 1", "factor_type": "diesel_gallon", "region": "US", "activity_unit": "gallon", "factor_value_kg_co2e_per_unit": 10.21, "source_authority": "Synthetic combustion factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        {"factor_id": "EF_GASOLINE_GAL_2025", "scope": "Scope 1", "factor_type": "gasoline_gallon", "region": "US", "activity_unit": "gallon", "factor_value_kg_co2e_per_unit": 8.89, "source_authority": "Synthetic combustion factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        # Scope 3 factors
        {"factor_id": "EF_TRUCK_TON_MILE_2025", "scope": "Scope 3", "factor_type": "freight_truck_ton_mile", "region": "US", "activity_unit": "ton_mile", "factor_value_kg_co2e_per_unit": 0.164, "source_authority": "Synthetic freight factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        {"factor_id": "EF_AIR_TON_MILE_2025", "scope": "Scope 3", "factor_type": "freight_air_ton_mile", "region": "US", "activity_unit": "ton_mile", "factor_value_kg_co2e_per_unit": 1.102, "source_authority": "Synthetic freight factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        {"factor_id": "EF_PAPER_KG_2025", "scope": "Scope 3", "factor_type": "packaging_paper_kg", "region": "US", "activity_unit": "kg", "factor_value_kg_co2e_per_unit": 1.20, "source_authority": "Synthetic material factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        {"factor_id": "EF_PLASTIC_KG_2025", "scope": "Scope 3", "factor_type": "packaging_plastic_kg", "region": "US", "activity_unit": "kg", "factor_value_kg_co2e_per_unit": 2.65, "source_authority": "Synthetic material factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
        {"factor_id": "EF_GLASS_KG_2025", "scope": "Scope 3", "factor_type": "packaging_glass_kg", "region": "US", "activity_unit": "kg", "factor_value_kg_co2e_per_unit": 0.91, "source_authority": "Synthetic material factor", "effective_start": "2025-01-01", "effective_end": "2026-12-31", "version": "2025.1", "is_current": "Y"},
    ]
    return pd.DataFrame(rows)


# -----------------------------
# Mess helpers
# -----------------------------

def maybe_duplicate_rows(df: pd.DataFrame, rng: np.random.Generator, pct: float) -> pd.DataFrame:
    if df.empty:
        return df
    n = int(round(len(df) * pct))
    if n <= 0:
        return df
    sample = df.sample(n=min(n, len(df)), random_state=int(rng.integers(1, 1_000_000)))
    return pd.concat([df, sample], ignore_index=True)


def maybe_missing_values(series: pd.Series, rng: np.random.Generator, pct: float) -> pd.Series:
    if series.empty:
        return series
    n = int(round(len(series) * pct))
    if n <= 0:
        return series
    out = series.copy()
    idx = rng.choice(out.index.to_numpy(), size=min(n, len(out)), replace=False)
    out.loc[idx] = None
    return out


def maybe_bad_month_format(series: pd.Series, rng: np.random.Generator, pct: float) -> pd.Series:
    if series.empty:
        return series
    n = int(round(len(series) * pct))
    if n <= 0:
        return series
    out = series.copy()
    idx = rng.choice(out.index.to_numpy(), size=min(n, len(out)), replace=False)
    parsed = pd.to_datetime(out.loc[idx], errors="coerce")
    for i, ix in enumerate(idx):
        if pd.isna(parsed.loc[ix]):
            continue
        if i % 2 == 0:
            out.loc[ix] = parsed.loc[ix].strftime("%b-%Y")
        else:
            out.loc[ix] = parsed.loc[ix].strftime("%m/%d/%Y")
    return out


def maybe_casing_drift(series: pd.Series, rng: np.random.Generator, pct: float) -> pd.Series:
    if series.empty:
        return series
    n = int(round(len(series) * pct))
    if n <= 0:
        return series
    out = series.copy()
    idx = rng.choice(out.index.to_numpy(), size=min(n, len(out)), replace=False)
    for i, ix in enumerate(idx):
        value = str(out.loc[ix])
        if i % 3 == 0:
            out.loc[ix] = value.upper()
        elif i % 3 == 1:
            out.loc[ix] = value.lower()
        else:
            out.loc[ix] = f" {value}  "
    return out


def maybe_negative_numbers(series: pd.Series, rng: np.random.Generator, pct: float) -> pd.Series:
    if series.empty:
        return series
    n = int(round(len(series) * pct))
    if n <= 0:
        return series
    out = series.copy()
    idx = rng.choice(out.index.to_numpy(), size=min(n, len(out)), replace=False)
    out.loc[idx] = -out.loc[idx].abs()
    return out


# -----------------------------
# Source generators
# -----------------------------

def generate_electricity_bills(cfg: Config, rng: np.random.Generator, months: pd.DatetimeIndex, facilities: pd.DataFrame) -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    base_kwh_by_type = {
        "Manufacturing": 48_000,
        "Distribution": 26_000,
        "Warehouse": 19_000,
        "Office": 7_500,
    }
    providers = {
        "OR": "Pacific Power",
        "WA": "Clark Public Utilities",
        "CO": "Xcel Energy",
        "CA": "PG&E",
    }

    for month in months:
        seasonal_factor = 1.0 + (0.12 if month.month in [7, 8, 12, 1] else 0.0)
        for facility in facilities.to_dict("records"):
            base = base_kwh_by_type[facility["facility_type"]]
            usage_kwh = max(500, rng.normal(base * seasonal_factor, base * 0.08))
            rate = rng.uniform(0.09, 0.16)
            rows.append(
                {
                    "bill_month": month.strftime("%Y-%m-01"),
                    "facility_id": facility["facility_id"],
                    "facility_name": facility["facility_name"],
                    "utility_provider": providers[facility["grid_region"]],
                    "meter_number": f"MTR-{facility['facility_id'][-3:]}-{month.year}",
                    "usage_amount": round(usage_kwh, 2),
                    "usage_unit": "kWh",
                    "invoice_amount_usd": round(usage_kwh * rate, 2),
                    "invoice_number": f"UTL-{month.strftime('%Y%m')}-{facility['facility_id']}",
                }
            )

    df = pd.DataFrame(rows)
    df = maybe_duplicate_rows(df, rng, cfg.pct_duplicate)
    df["facility_id"] = maybe_missing_values(df["facility_id"], rng, cfg.pct_missing_facility)
    df["bill_month"] = maybe_bad_month_format(df["bill_month"], rng, cfg.pct_bad_month_format)
    df["usage_amount"] = maybe_negative_numbers(df["usage_amount"], rng, cfg.pct_negative_usage)
    df["utility_provider"] = maybe_casing_drift(df["utility_provider"], rng, cfg.pct_text_casing_drift)

    unit_idx = rng.choice(df.index.to_numpy(), size=max(1, int(len(df) * cfg.pct_unit_mismatch)), replace=False)
    df.loc[unit_idx, "usage_unit"] = "KW HRS"

    return df


def generate_fuel_usage(cfg: Config, rng: np.random.Generator, months: pd.DatetimeIndex, facilities: pd.DataFrame) -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    for month in months:
        for facility in facilities.to_dict("records"):
            if facility["facility_type"] in ["Manufacturing", "Warehouse", "Distribution"]:
                natural_gas_therms = max(50, rng.normal(2_200 if facility["facility_type"] == "Manufacturing" else 700, 120))
                rows.append(
                    {
                        "activity_month": month.strftime("%Y-%m-01"),
                        "facility_id": facility["facility_id"],
                        "fuel_type": "Natural Gas",
                        "activity_amount": round(natural_gas_therms, 2),
                        "activity_unit": "therm",
                        "vendor_name": "NW Natural",
                        "invoice_number": f"FUEL-NG-{month.strftime('%Y%m')}-{facility['facility_id']}",
                        "cost_usd": round(natural_gas_therms * rng.uniform(1.1, 1.7), 2),
                    }
                )

            if facility["facility_type"] in ["Distribution", "Warehouse"]:
                diesel_gallons = max(20, rng.normal(850, 90))
                rows.append(
                    {
                        "activity_month": month.strftime("%Y-%m-01"),
                        "facility_id": facility["facility_id"],
                        "fuel_type": "Diesel",
                        "activity_amount": round(diesel_gallons, 2),
                        "activity_unit": "gallon",
                        "vendor_name": "Fleet Fuel Services",
                        "invoice_number": f"FUEL-DIESEL-{month.strftime('%Y%m')}-{facility['facility_id']}",
                        "cost_usd": round(diesel_gallons * rng.uniform(3.8, 5.4), 2),
                    }
                )

            if facility["facility_type"] == "Office":
                gasoline_gallons = max(10, rng.normal(130, 25))
                rows.append(
                    {
                        "activity_month": month.strftime("%Y-%m-01"),
                        "facility_id": facility["facility_id"],
                        "fuel_type": "Gasoline",
                        "activity_amount": round(gasoline_gallons, 2),
                        "activity_unit": "gallon",
                        "vendor_name": "Fleet Card Export",
                        "invoice_number": f"FUEL-GAS-{month.strftime('%Y%m')}-{facility['facility_id']}",
                        "cost_usd": round(gasoline_gallons * rng.uniform(3.6, 5.1), 2),
                    }
                )

    df = pd.DataFrame(rows)
    df = maybe_duplicate_rows(df, rng, cfg.pct_duplicate)
    df["facility_id"] = maybe_missing_values(df["facility_id"], rng, cfg.pct_missing_facility)
    df["activity_month"] = maybe_bad_month_format(df["activity_month"], rng, cfg.pct_bad_month_format)
    df["fuel_type"] = maybe_casing_drift(df["fuel_type"], rng, cfg.pct_text_casing_drift)
    df["activity_amount"] = maybe_negative_numbers(df["activity_amount"], rng, cfg.pct_negative_usage)

    unit_idx = rng.choice(df.index.to_numpy(), size=max(1, int(len(df) * cfg.pct_unit_mismatch)), replace=False)
    df.loc[unit_idx, "activity_unit"] = "gal"  # staging should normalize this to gallon

    return df


def generate_shipping_miles(cfg: Config, rng: np.random.Generator, months: pd.DatetimeIndex, facilities: pd.DataFrame, product_lines: pd.DataFrame) -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    destination_states = ["OR", "WA", "CA", "CO", "NV", "AZ", "IL", "MI"]
    modes = ["Truck", "Truck", "Truck", "Air"]
    carriers = ["UPS Freight", "FedEx Freight", "Internal Fleet", "Regional 3PL"]

    shipping_facilities = facilities.loc[facilities["facility_type"].isin(["Distribution", "Warehouse", "Manufacturing"])]
    product_line_ids = product_lines.loc[product_lines["product_line_id"] != "PL004", "product_line_id"].tolist()

    for month in months:
        n_shipments = int(rng.integers(80, 140))
        for i in range(n_shipments):
            origin = shipping_facilities.sample(n=1, random_state=int(rng.integers(1, 1_000_000))).iloc[0]
            product_line_id = str(rng.choice(product_line_ids))
            mode = str(rng.choice(modes))
            distance_miles = max(15, rng.normal(620 if mode == "Truck" else 1_350, 250))
            weight_lb = max(25, rng.normal(900 if mode == "Truck" else 180, 120))
            ton_miles = distance_miles * (weight_lb / 2000)
            shipment_date = month + pd.Timedelta(days=int(rng.integers(0, 27)))

            rows.append(
                {
                    "shipment_id": f"SHP-GHG-{month.strftime('%Y%m')}-{i:04d}",
                    "shipment_date": shipment_date.strftime("%Y-%m-%d"),
                    "origin_facility_id": origin["facility_id"],
                    "destination_state": str(rng.choice(destination_states)),
                    "product_line_id": product_line_id,
                    "shipping_mode": mode,
                    "carrier": str(rng.choice(carriers)),
                    "distance_miles": round(distance_miles, 2),
                    "shipment_weight_lb": round(weight_lb, 2),
                    "ton_miles": round(ton_miles, 4),
                    "freight_cost_usd": round(distance_miles * rng.uniform(1.2, 2.5), 2),
                }
            )

    df = pd.DataFrame(rows)
    df = maybe_duplicate_rows(df, rng, cfg.pct_duplicate)
    df["origin_facility_id"] = maybe_missing_values(df["origin_facility_id"], rng, cfg.pct_missing_facility)
    df["product_line_id"] = maybe_missing_values(df["product_line_id"], rng, cfg.pct_missing_product_line)
    df["shipping_mode"] = maybe_casing_drift(df["shipping_mode"], rng, cfg.pct_text_casing_drift)
    df["ton_miles"] = maybe_negative_numbers(df["ton_miles"], rng, cfg.pct_negative_usage)

    return df


def generate_packaging_materials(cfg: Config, rng: np.random.Generator, months: pd.DatetimeIndex, facilities: pd.DataFrame, product_lines: pd.DataFrame) -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    materials = [
        {"material_type": "Paper", "unit_weight_kg": 0.012, "supplier": "Cascade Packaging"},
        {"material_type": "Plastic", "unit_weight_kg": 0.018, "supplier": "Pacific Flexibles"},
        {"material_type": "Glass", "unit_weight_kg": 0.120, "supplier": "Northwest Bottling Supply"},
    ]
    product_line_ids = product_lines["product_line_id"].tolist()
    purchasing_facilities = facilities.loc[facilities["facility_type"].isin(["Manufacturing", "Distribution"])]

    for month in months:
        for facility in purchasing_facilities.to_dict("records"):
            for product_line_id in product_line_ids:
                for material in materials:
                    units_purchased = int(max(100, rng.normal(22_000, 4_000)))
                    material_weight_kg = units_purchased * material["unit_weight_kg"] * rng.uniform(0.92, 1.08)
                    rows.append(
                        {
                            "invoice_month": month.strftime("%Y-%m-01"),
                            "facility_id": facility["facility_id"],
                            "product_line_id": product_line_id,
                            "material_type": material["material_type"],
                            "supplier_name": material["supplier"],
                            "units_purchased": units_purchased,
                            "material_weight_kg": round(material_weight_kg, 2),
                            "invoice_number": f"PKG-{month.strftime('%Y%m')}-{facility['facility_id']}-{product_line_id}-{material['material_type'][:3].upper()}",
                            "cost_usd": round(units_purchased * rng.uniform(0.025, 0.11), 2),
                        }
                    )

    df = pd.DataFrame(rows)
    df = maybe_duplicate_rows(df, rng, cfg.pct_duplicate)
    df["facility_id"] = maybe_missing_values(df["facility_id"], rng, cfg.pct_missing_facility)
    df["product_line_id"] = maybe_missing_values(df["product_line_id"], rng, cfg.pct_missing_product_line)
    df["invoice_month"] = maybe_bad_month_format(df["invoice_month"], rng, cfg.pct_bad_month_format)
    df["material_type"] = maybe_casing_drift(df["material_type"], rng, cfg.pct_text_casing_drift)
    df["material_weight_kg"] = maybe_negative_numbers(df["material_weight_kg"], rng, cfg.pct_negative_usage)

    return df


# -----------------------------
# Writers
# -----------------------------

def write_csv_to_current_and_incoming(df: pd.DataFrame, project_root: Path, source_name: str, file_name: str, drop_date: pd.Timestamp) -> tuple[Path, Path]:
    current_path = current_dir(project_root, source_name) / file_name
    incoming_path = incoming_dir(project_root, source_name, drop_date) / file_name
    df.to_csv(current_path, index=False)
    df.to_csv(incoming_path, index=False)
    return current_path, incoming_path


def write_excel_to_current_and_incoming(df: pd.DataFrame, project_root: Path, source_name: str, file_name: str, sheet_name: str, drop_date: pd.Timestamp) -> tuple[Path, Path]:
    current_path = current_dir(project_root, source_name) / file_name
    incoming_path = incoming_dir(project_root, source_name, drop_date) / file_name
    with pd.ExcelWriter(current_path, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name=sheet_name)
    with pd.ExcelWriter(incoming_path, engine="openpyxl") as writer:
        df.to_excel(writer, index=False, sheet_name=sheet_name)
    return current_path, incoming_path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", default="2025-01-01")
    parser.add_argument("--end", default="2026-03-01")
    parser.add_argument("--seed", type=int, default=44)
    args = parser.parse_args()

    cfg = Config(start=args.start, end=args.end, seed=args.seed)
    rng = np.random.default_rng(cfg.seed)

    repo_root = get_repo_root()
    project_root = get_project_root()
    ensure_dirs(project_root)
    shared_source_systems_dir = get_shared_source_systems_dir(project_root)
    shared_seed_dir = get_shared_seed_dir(repo_root)

    months = pd.date_range(cfg.start, cfg.end, freq="MS")
    drop_date = months.max() + pd.offsets.MonthEnd(0)
    load_id = uuid.uuid4().hex[:12]

    facilities = make_facilities(shared_seed_dir)
    product_lines = make_product_lines(shared_seed_dir)
    emission_factors = make_emission_factors()

    electricity = generate_electricity_bills(cfg, rng, months, facilities)
    fuel = generate_fuel_usage(cfg, rng, months, facilities)
    shipping = generate_shipping_miles(cfg, rng, months, facilities, product_lines)
    packaging = generate_packaging_materials(cfg, rng, months, facilities, product_lines)

    manifest_rows: list[dict[str, Any]] = []

    def add_manifest(source_name: str, file_name: str, current_path: Path, incoming_path: Path, rows_written: int, notes: str) -> None:
        manifest_rows.append(
            {
                "load_id": load_id,
                "source_name": source_name,
                "file_name": file_name,
                "drop_date": drop_date.date().isoformat(),
                "current_path": str(current_path.relative_to(project_root)),
                "incoming_path": str(incoming_path.relative_to(project_root)),
                "rows_written": rows_written,
                "notes": notes,
            }
        )

    current_path, incoming_path = write_csv_to_current_and_incoming(
        facilities,
        project_root,
        "facility_master",
        "facility_master.csv",
        drop_date,
    )
    add_manifest("facility_master", "facility_master.csv", current_path, incoming_path, len(facilities), "Clean reference file for facility dimension and grid-region mapping.")

    current_path, incoming_path = write_csv_to_current_and_incoming(
        product_lines,
        project_root,
        "product_line_master",
        "product_line_master.csv",
        drop_date,
    )
    add_manifest("product_line_master", "product_line_master.csv", current_path, incoming_path, len(product_lines), "Clean reference file for product-line intensity reporting.")

    current_path, incoming_path = write_excel_to_current_and_incoming(
        electricity,
        project_root,
        "electricity_bills",
        "electricity_bills_monthly.xlsx",
        "electricity_bills",
        drop_date,
    )
    add_manifest("electricity_bills", "electricity_bills_monthly.xlsx", current_path, incoming_path, len(electricity), "Scope 2 activity; duplicates, missing facility IDs, mixed month formats, negative usage, and unit drift injected.")

    current_path, incoming_path = write_csv_to_current_and_incoming(
        fuel,
        project_root,
        "fuel_usage",
        "fuel_usage_facility.csv",
        drop_date,
    )
    add_manifest("fuel_usage", "fuel_usage_facility.csv", current_path, incoming_path, len(fuel), "Scope 1 activity; fuel type casing drift, missing facility IDs, negative amounts, and unit synonyms injected.")

    current_path, incoming_path = write_csv_to_current_and_incoming(
        shipping,
        project_root,
        "shipping_miles",
        "shipping_miles_logistics.csv",
        drop_date,
    )
    add_manifest("shipping_miles", "shipping_miles_logistics.csv", current_path, incoming_path, len(shipping), "Scope 3 freight activity; duplicate shipments, missing keys, casing drift, and negative ton-miles injected.")

    current_path, incoming_path = write_csv_to_current_and_incoming(
        packaging,
        project_root,
        "packaging_materials",
        "packaging_materials_procurement.csv",
        drop_date,
    )
    add_manifest("packaging_materials", "packaging_materials_procurement.csv", current_path, incoming_path, len(packaging), "Scope 3 purchased packaging activity; missing keys, material casing drift, mixed month formats, and negative weights injected.")

    current_path, incoming_path = write_csv_to_current_and_incoming(
        emission_factors,
        project_root,
        "emission_factors",
        "emission_factors_reference.csv",
        drop_date,
    )
    add_manifest("emission_factors", "emission_factors_reference.csv", current_path, incoming_path, len(emission_factors), "Versioned synthetic factor table for Scope 1, Scope 2, and Scope 3 calculations.")

    manifest = pd.DataFrame(manifest_rows)
    manifest_path = project_root / "docs" / "ghg_source_drop_manifest.csv"
    manifest.to_csv(manifest_path, index=False)

    print("\n✅ Project 4 GHG source extracts generated.")
    print(f"Project root: {project_root}")
    print(f"Load ID: {load_id}")
    print(f"Reporting months: {months.min().date()} through {months.max().date()}")
    print(f"Manifest: {manifest_path.relative_to(project_root)}")
    print("\nFiles created:")
    for row in manifest_rows:
        print(f"  - {row['current_path']} ({row['rows_written']} rows)")
    print("")


if __name__ == "__main__":
    main()

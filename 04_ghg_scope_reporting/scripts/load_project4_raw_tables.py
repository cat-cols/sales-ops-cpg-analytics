#!/usr/bin/env python3
# 04_ghg_scope_reporting/scripts/load_project4_raw_tables.py

from pathlib import Path
import os

import pandas as pd
from sqlalchemy import create_engine, text


project_root = Path(__file__).resolve().parents[1]
source_root = project_root / "data" / "source_extracts"

pg_dsn = os.getenv("P1_PG_OPS")

if not pg_dsn:
    raise SystemExit("Missing P1_PG_OPS environment variable.")

engine = create_engine(pg_dsn)

load_plan = [
    {
        "table": "raw.ghg_facility_master",
        "path": source_root / "facility_master" / "current" / "facility_master.csv",
        "type": "csv",
    },
    {
        "table": "raw.ghg_product_line_master",
        "path": source_root / "product_line_master" / "current" / "product_line_master.csv",
        "type": "csv",
    },
    {
        "table": "raw.ghg_electricity_bills_monthly",
        "path": source_root / "electricity_bills" / "current" / "electricity_bills_monthly.xlsx",
        "type": "xlsx",
        "sheet_name": "electricity_bills",
    },
    {
        "table": "raw.ghg_fuel_usage_facility",
        "path": source_root / "fuel_usage" / "current" / "fuel_usage_facility.csv",
        "type": "csv",
    },
    {
        "table": "raw.ghg_shipping_miles_logistics",
        "path": source_root / "shipping_miles" / "current" / "shipping_miles_logistics.csv",
        "type": "csv",
    },
    {
        "table": "raw.ghg_packaging_materials_procurement",
        "path": source_root / "packaging_materials" / "current" / "packaging_materials_procurement.csv",
        "type": "csv",
    },
    {
        "table": "raw.ghg_emission_factors_reference",
        "path": source_root / "emission_factors" / "current" / "emission_factors_reference.csv",
        "type": "csv",
    },
]

with engine.begin() as conn:
    for item in load_plan:
        table_name = item["table"]
        file_path = item["path"]

        if not file_path.exists():
            raise FileNotFoundError(f"Missing source file: {file_path}")

        print(f"Loading {file_path} -> {table_name}")

        if item["type"] == "csv":
            df = pd.read_csv(file_path, dtype=str)
        elif item["type"] == "xlsx":
            df = pd.read_excel(file_path, sheet_name=item["sheet_name"], dtype=str)
        else:
            raise ValueError(f"Unsupported file type: {item['type']}")

        schema_name, raw_table_name = table_name.split(".")

        conn.execute(text(f"truncate table {schema_name}.{raw_table_name};"))

        df.to_sql(
            name=raw_table_name,
            con=conn,
            schema=schema_name,
            if_exists="append",
            index=False,
            method="multi",
            chunksize=1000,
        )

        print(f"  rows loaded: {len(df):,}")

print("")
print("✅ Project 4 raw tables loaded.")

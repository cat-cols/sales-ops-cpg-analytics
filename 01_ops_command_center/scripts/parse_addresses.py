#!/usr/bin/env python3
"""
Parse physical addresses into street, city, state, and ZIP components.

Usage:
    python scripts/parse_addresses.py \
      --input data/reference/or_licenses/derived/recreational_retailer.csv \
      --output data/reference/or_licenses/derived/recreational_retailer_parsed.csv \
      --address-column physical_address
"""

import argparse
import csv
import re
from pathlib import Path
from typing import Dict, Optional


US_STATE_PATTERN = r"\b([A-Z]{2})\b"
ZIP_PATTERN = r"(\d{5}(?:-\d{4})?)"


def parse_address(
    address: str,
    redacted_value: str = "Exempt from Public Disclosure",
) -> Dict[str, Optional[str]]:
    """
    Parse a physical address into components.

    Expected formats include:
        123 MAIN ST PORTLAND OR 97201
        123 MAIN ST, PORTLAND, OR 97201

    Note:
        Without commas or a city reference table, multi-word cities can be ambiguous.
    """
    if not address or address.strip() == redacted_value:
        return {
            "street_address": None,
            "city": None,
            "state": None,
            "zip_code": None,
        }

    cleaned = " ".join(address.strip().replace(",", " ").split())

    zip_match = re.search(ZIP_PATTERN, cleaned)
    zip_code = zip_match.group(1) if zip_match else None

    if zip_code:
        cleaned = cleaned.replace(zip_code, "", 1).strip()

    state_match = re.search(US_STATE_PATTERN, cleaned)
    state = state_match.group(1) if state_match else None

    if state:
        cleaned = re.sub(rf"\b{state}\b", "", cleaned, count=1).strip()

    parts = cleaned.split()

    if len(parts) >= 2:
        city = parts[-1]
        street_address = " ".join(parts[:-1])
    else:
        city = None
        street_address = cleaned or None

    return {
        "street_address": street_address,
        "city": city,
        "state": state,
        "zip_code": zip_code,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Parse physical addresses in a CSV file."
    )

    parser.add_argument(
        "--input",
        required=True,
        type=Path,
        help="Path to input CSV file.",
    )

    parser.add_argument(
        "--output",
        required=True,
        type=Path,
        help="Path to output CSV file.",
    )

    parser.add_argument(
        "--address-column",
        default="physical_address",
        help="Name of the column containing the address.",
    )

    parser.add_argument(
        "--redacted-value",
        default="Exempt from Public Disclosure",
        help="Value used when an address is redacted.",
    )

    parser.add_argument(
        "--show-samples",
        type=int,
        default=5,
        help="Number of parsed examples to print.",
    )

    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if not args.input.exists():
        raise FileNotFoundError(f"Input file not found: {args.input}")

    args.output.parent.mkdir(parents=True, exist_ok=True)

    rows = []

    with args.input.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)

        if reader.fieldnames is None:
            raise ValueError(f"Input file has no header row: {args.input}")

        if args.address_column not in reader.fieldnames:
            raise ValueError(
                f"Address column '{args.address_column}' not found. "
                f"Available columns: {reader.fieldnames}"
            )

        new_columns = ["street_address", "city", "state", "zip_code"]
        fieldnames = list(reader.fieldnames)

        for column in new_columns:
            if column not in fieldnames:
                fieldnames.append(column)

        for row in reader:
            parsed = parse_address(
                row.get(args.address_column, ""),
                redacted_value=args.redacted_value,
            )

            row.update(parsed)
            rows.append(row)

    with args.output.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Created {args.output} with {len(rows)} rows")
    print("Added columns: street_address, city, state, zip_code")

    if args.show_samples > 0:
        print("\nSample parsed addresses:")
        for row in rows[: args.show_samples]:
            print(f"Original: {row.get(args.address_column)}")
            print(
                "Parsed: "
                f"{row.get('street_address')}, "
                f"{row.get('city')}, "
                f"{row.get('state')}, "
                f"{row.get('zip_code')}"
            )
            print()


if __name__ == "__main__":
    main()
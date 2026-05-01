# Source Lineage — GHG Scope Reporting

## Purpose

This document maps each Project 4 source extract to the modeled SQL layers and final reporting outputs.

The purpose is to make the emissions reporting workflow traceable from source evidence to final metrics, QA controls, and Power BI-ready mart views.

---

## Lineage Summary

```text
source extract
→ raw landing table
→ staging view
→ conformance view
→ mart view
→ reporting / QA output
```

---

## Source System Lineage

| Source Extract                        | Raw Table                                 | Staging View                      | Conformance Layer                                                | Mart Output           | Primary Use                                      |
| ------------------------------------- | ----------------------------------------- | --------------------------------- | ---------------------------------------------------------------- | --------------------- | ------------------------------------------------ |
| `facility_master.csv`                 | `raw.ghg_facility_master`                 | `stg.stg_ghg_facility_master`     | `int.int_ghg_activity_with_factors`                              | `mart.fact_emissions` | Facility attributes, grid region, facility joins |
| `product_line_master.csv`             | `raw.ghg_product_line_master`             | `stg.stg_ghg_product_line_master` | `int.int_ghg_activity_with_factors`                              | `mart.fact_emissions` | Product-line attributes and product-line joins   |
| `emission_factors_reference.csv`      | `raw.ghg_emission_factors_reference`      | `stg.stg_ghg_emission_factors`    | `int.int_ghg_activity_with_factors`                              | `mart.fact_emissions` | Factor matching and emissions calculation        |
| `electricity_bills_monthly.xlsx`      | `raw.ghg_electricity_bills_monthly`       | `stg.stg_ghg_electricity_bills`   | `int.int_ghg_activity_all` → `int.int_ghg_activity_with_factors` | `mart.fact_emissions` | Scope 2 purchased electricity emissions          |
| `fuel_usage_facility.csv`             | `raw.ghg_fuel_usage_facility`             | `stg.stg_ghg_fuel_usage`          | `int.int_ghg_activity_all` → `int.int_ghg_activity_with_factors` | `mart.fact_emissions` | Scope 1 natural gas, diesel, gasoline emissions  |
| `shipping_miles_logistics.csv`        | `raw.ghg_shipping_miles_logistics`        | `stg.stg_ghg_shipping_miles`      | `int.int_ghg_activity_all` → `int.int_ghg_activity_with_factors` | `mart.fact_emissions` | Scope 3 freight emissions                        |
| `packaging_materials_procurement.csv` | `raw.ghg_packaging_materials_procurement` | `stg.stg_ghg_packaging_materials` | `int.int_ghg_activity_all` → `int.int_ghg_activity_with_factors` | `mart.fact_emissions` | Scope 3 purchased packaging emissions            |

---

## Metric Lineage

| Metric / Output           | Source Inputs                               | Transformation Logic                                                                                                      | Final Output                                      |
| ------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| `kg_co2e`                 | Activity source + emission factor reference | `activity_amount * factor_value_kg_co2e_per_unit`                                                                         | `mart.fact_emissions.kg_co2e`                     |
| `metric_tons_co2e`        | Activity source + emission factor reference | `kg_co2e / 1000`                                                                                                          | `mart.fact_emissions.metric_tons_co2e`            |
| Reportable emissions      | Activity rows + QA flags                    | Exclude rows with negative activity, missing keys, invalid dates, unknown activity type, failed joins, or missing factors | `mart.fact_emissions.is_reportable_emissions_row` |
| Emissions by scope        | All activity sources                        | Group reportable emissions by `scope`                                                                                     | Power BI / scorecard output                       |
| Emissions by facility     | Activity sources + facility master          | Join activity to `facility_id`; group by facility attributes                                                              | Power BI / scorecard output                       |
| Emissions by product line | Shipping + packaging + product line master  | Join activity to `product_line_id`; group by product-line attributes                                                      | Power BI / scorecard output                       |
| Emissions intensity       | Reportable emissions + cost/activity fields | Divide emissions by selected denominator                                                                                  | `mart.kpi_emissions_intensity_monthly`            |

---

## Control Lineage

| Control View                          | Depends On            | Purpose                                                                            |
| ------------------------------------- | --------------------- | ---------------------------------------------------------------------------------- |
| `mart.controls_missing_factor_joins`  | `mart.fact_emissions` | Surfaces activity rows where no emission factor matched                            |
| `mart.controls_negative_activity`     | `mart.fact_emissions` | Surfaces rows with invalid negative activity amounts                               |
| `mart.controls_missing_dim_joins`     | `mart.fact_emissions` | Surfaces failed facility or product-line joins                                     |
| `mart.controls_unknown_activity_type` | `mart.fact_emissions` | Surfaces activity/unit combinations that cannot be mapped to approved factor types |

---

## QA Lineage

| QA Check                      | Depends On            | Pass Condition                                        |
| ----------------------------- | --------------------- | ----------------------------------------------------- |
| Raw rowcount check            | Raw tables            | All expected source tables contain loaded rows        |
| Activity ID uniqueness        | `mart.fact_emissions` | No duplicate `activity_id` values                     |
| Reportable emissions not null | `mart.fact_emissions` | Reportable rows have non-null `metric_tons_co2e`      |
| Clean rows have factor joins  | `mart.fact_emissions` | Clean activity rows have matched emission factors     |
| QA summary                    | `mart.fact_emissions` | Produces source-level exception and emissions summary |

---

## Evidence Fields

The model preserves source evidence fields for audit review.

| Field                | Purpose                                          |
| -------------------- | ------------------------------------------------ |
| `source_system`      | Identifies originating extract                   |
| `source_record_id`   | Preserves row-level source reference             |
| `evidence_reference` | Stores invoice, shipment, or evidence identifier |
| `activity_month`     | Reporting month                                  |
| `facility_id`        | Facility-level traceability                      |
| `product_line_id`    | Product-line traceability where applicable       |
| `factor_id`          | Emission factor used                             |
| `factor_version`     | Emission factor version used                     |
| `source_authority`   | Factor source description                        |

---

## Example Lineage Walkthrough

Example: purchased electricity emissions.

```text
electricity_bills_monthly.xlsx
→ raw.ghg_electricity_bills_monthly
→ stg.stg_ghg_electricity_bills
→ int.int_ghg_activity_all
→ int.int_ghg_activity_with_factors
→ mart.fact_emissions
→ Scope 2 emissions by facility/month
```

Key transformations:

1. Parse `bill_month` into `activity_month`.
2. Normalize `facility_id`.
3. Normalize electricity units to `kwh`.
4. Assign `scope = Scope 2`.
5. Assign `factor_type = electricity_kwh`.
6. Join to facility master for grid region.
7. Join to emission factors by factor type, unit, region, and effective date.
8. Calculate `kg_co2e` and `metric_tons_co2e`.
9. Exclude non-reportable rows from final reportable totals.

---

## Known Lineage Limitations

This project uses synthetic data and synthetic emission factors.

The lineage structure is intended to demonstrate audit-ready analytics design. It does not represent official emissions reporting for any real company.

Future enhancements could include:

* persistent run IDs
* source file checksums
* source owner certification status
* exception resolution workflow
* evidence file archive links
* factor-source citation links
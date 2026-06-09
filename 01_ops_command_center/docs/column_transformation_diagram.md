# Column Transformation Diagram - PostgreSQL Implementation

## Overview
Color-coded visual diagrams showing how specific columns transform through the database cycle from CSV to mart layer.

## Color Legend
- 🔴 **Red**: CSV Layer (raw source data)
- 🟡 **Yellow**: Raw Layer (direct copy)
- 🟢 **Green**: Staging Layer (cleaned & typed)
- 🔵 **Blue**: Integration Layer (deduplicated & integrated)
- 🟣 **Purple**: Mart Layer (business-ready)

---

## Column 1: Store Code

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"PDX001 " → "PDX001 " → "PDX001" → "PDX001" → "PDX001"
"OR002"  → "OR002"  → "OR002"  → "OR002"  → "OR002"
"WA003"  → "WA003"  → "WA003"  → "WA003"  → "WA003"

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Trim whitespace, null if empty
🟢→🔵: No change (canonical ID)
🔵→🟣: No change (canonical ID)
```

---

## Column 2: Quantity (Units Sold)

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"40" → "40" → 40 → 40 (sum) → 40 (sum)
"25" → "25" → 25 → 25 (sum) → 25 (sum)
"10" → "10" → 10 → 10 (sum) → 10 (sum)

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Text → numeric conversion
🟢→🔵: Sum of quantities (aggregation)
🔵→🟣: Sum of quantities (aggregation)
```

---

## Column 3: Unit Price

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"24.99" → "24.99" → 24.99 → (aggregated) → 24.99 (VWAP)
"19.99" → "19.99" → 19.99 → (aggregated) → 19.99 (VWAP)
"29.99" → "29.99" → 29.99 → (aggregated) → 29.99 (VWAP)

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Text → numeric conversion
🟢→🔵: Aggregated (not stored as column)
🔵→🟣: Calculated as gross_sales / qty (VWAP)
```

---

## Column 4: Gross Sales Amount

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"999.60" → "999.60" → 999.60 → 999.60 (sum) → 999.60 (sum)
"499.80" → "499.80" → 499.80 → 499.80 (sum) → 499.80 (sum)
"299.90" → "299.90" → 299.90 → 299.90 (sum) → 299.90 (sum)

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Text → numeric conversion
🟢→🔵: Sum of gross_sales (aggregation)
🔵→🟣: Sum of gross_sales (aggregation)
```

---

## Column 5: Transaction Date

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"2024-01-01" → "2024-01-01" → 2024-01-01 → 2024-01-01 → 2024-01-01
"2024-01-02" → "2024-01-02" → 2024-01-02 → 2024-01-02 → 2024-01-02
"2024-01-03" → "2024-01-03" → 2024-01-03 → 2024-01-03 → 2024-01-03

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Text → date conversion
🟢→🔵: Date type maintained
🔵→🟣: Date type maintained (renamed to sale_date)
```

---

## Column 6: Product SKU

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"WYLD-RASP-10" → "WYLD-RASP-10" → "WYLD-RASP-10" → "WYLD-RASP-10" → "WYLD-RASP-10"
"WYLD-MARB-10" → "WYLD-MARB-10" → "WYLD-MARB-10" → "WYLD-MARB-10" → "WYLD-MARB-10"
"WYLD-HUCK-10" → "WYLD-HUCK-10" → "WYLD-HUCK-10" → "WYLD-HUCK-10" → "WYLD-HUCK-10"

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Trimmed whitespace, null if empty
🟢→🔵: No change (canonical SKU)
🔵→🟣: No change (canonical SKU)
```

---

## Column 7: Discount Amount

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"49.60" → "49.60" → 49.60 → (not stored) → 49.60 (calc)
"24.90" → "24.90" → 24.90 → (not stored) → 24.90 (calc)
"14.95" → "14.95" → 14.95 → (not stored) → 14.95 (calc)

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Text → numeric conversion
🟢→🔵: Not stored (calculated later)
🔵→🟣: Calculated as gross_sales - net_sales
```

---

## Column 8: Net Sales Amount

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"950.00" → "950.00" → 950.00 → 950.00 (sum) → 950.00 (sum)
"474.90" → "474.90" → 474.90 → 474.90 (sum) → 474.90 (sum)
"284.95" → "284.95" → 284.95 → 284.95 (sum) → 284.95 (sum)

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Text → numeric conversion
🟢→🔵: Sum of net_sales (aggregation)
🔵→🟣: Sum of net_sales (aggregation)
```

---

## Column 9: Transaction ID

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"100000" → "100000" → "100000" → (dedup) → (dedup)
"100001" → "100001" → "100001" → (dedup) → (dedup)
"100002" → "100002" → "100002" → (dedup) → (dedup)

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: No change
🟢→🔵: Deduplicated using row_number()
🔵→🟣: Deduplicated using row_number()
```

---

## Column 10: Channel (Business Logic)

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
(none) → (none) → (none) → (none) → "retail"
(none) → (none) → (none) → (none) → "retail"
(none) → (none) → (none) → (none) → "retail"

Transformations:
🔴→🟡: Not present
🟡→🟢: Not present
🟢→🔵: Not present
🔵→🟣: Added as 'retail' (business logic)
```

---

## Column 11: Product Name (Dimension Join)

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
"Raspberry Gummies" → "Raspberry Gummies" → (none) → (none) → "Raspberry Gummies"
"Marionberry Gummies" → "Marionberry Gummies" → (none) → (none) → "Marionberry Gummies"
"Huckleberry Gummies" → "Huckleberry Gummies" → (none) → (none) → "Huckleberry Gummies"

Transformations:
🔴→🟡: No change (direct copy)
🟡→🟢: Not present in staging view
🟢→🔵: Not present in integration view
🔵→🟣: Joined from mart.dim_sku dimension
```

---

## Column 12: Quality Flags (Data Quality)

```
🔴 CSV → 🟡 Raw → 🟢 Staging → 🔵 Integration → 🟣 Mart
─────────────────────────────────────────────────────────────
(none) → (none) → false → (none) → (none)
(none) → (none) → false → (none) → (none)
(none) → (none) → false → (none) → (none)

Transformations:
🔴→🟡: Not present
🟡→🟢: Added as data quality flag
🟢→🔵: Not present
🔵→🟣: Not present
```

---

## Visual Summary

```
🔴 CSV Layer (Raw Source Data)
   ↓ Direct copy
🟡 Raw Layer (Preserve Original)
   ↓ Clean & type
🟢 Staging Layer (Cleaned Data)
   ↓ Deduplicate & integrate
🔵 Integration Layer (Integrated Data)
   ↓ Business logic & dimensions
🟣 Mart Layer (Business-Ready Data)
```

---

## Transformation Pattern Summary

| Column Type | 🔴→🟡 | 🟡→🟢 | 🟢→🔵 | 🔵→🟣 |
|-------------|-------|-------|-------|-------|
| Identifiers | No change | Trim, null handling | No change | No change |
| Measures | No change | Text → numeric | Aggregation | Aggregation |
| Dates | No change | Text → date | Date maintained | Date maintained |
| Business Logic | Not present | Not present | Not present | Added |
| Dimensions | No change | Not present | Not present | Joined |
| Quality Flags | Not present | Added | Not present | Not present |

**Key Pattern:** 🔴 → 🟡 → 🟢 → 🔵 → 🟣 (progressively cleaner, more aggregated, more business-enriched)

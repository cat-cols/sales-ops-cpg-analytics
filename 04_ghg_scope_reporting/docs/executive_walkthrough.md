# Executive Walkthrough — GHG Scope Reporting

## 1. Business question
How do we turn messy sustainability activity data into traceable Scope 1/2/3 emissions reporting?

## 2. KPI snapshot
- Total reportable metric tons CO2e
- Reportable row rate
- Non-reportable rows
- Missing factor rows
- Top scope / facility / activity driver

## 3. What the model controls
- invalid units
- missing facilities
- missing factor joins
- negative activity
- duplicate source records

## 4. Key finding
Example: natural gas gallons are excluded because the approved factor expects therms.

## 5. Recommendation
Fix source unit mapping, review duplicate source shipments, and certify factor table before publishing.
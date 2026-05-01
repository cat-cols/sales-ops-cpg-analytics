-- ============================================================
-- Project 5: Decision Engine
-- QA: mart.decision_kpi_driver_tree
--
-- Purpose:
--   Validate that the KPI driver tree exists, has clean required
--   fields, has no duplicate driver definitions, and only uses
--   expected business areas.
--
-- Why this matters:
--   The Decision Engine depends on this driver tree as its
--   business logic map. If this view is broken, downstream
--   decision outputs become less trustworthy.
-- ============================================================

\echo ''
\echo 'QA: mart.decision_kpi_driver_tree'

-- ------------------------------------------------------------
-- Check 1: The view must exist.
-- ------------------------------------------------------------

do $$
begin
    if to_regclass('mart.decision_kpi_driver_tree') is null then
        raise exception 'QA failed: mart.decision_kpi_driver_tree does not exist.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 2: The view must contain rows.
-- ------------------------------------------------------------

do $$
begin
    if (
        select count(*)
        from mart.decision_kpi_driver_tree
    ) = 0 then
        raise exception 'QA failed: mart.decision_kpi_driver_tree has zero rows.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 3: Required fields must not be null.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_kpi_driver_tree
        where business_area is null
           or parent_metric is null
           or child_metric is null
           or metric_level is null
           or driver_type is null
           or decision_question is null
           or example_decision is null
           or recommended_output is null
    ) then
        raise exception 'QA failed: mart.decision_kpi_driver_tree has null required fields.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 4: One row per business area / parent metric / child metric.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select
            business_area,
            parent_metric,
            child_metric
        from mart.decision_kpi_driver_tree
        group by
            business_area,
            parent_metric,
            child_metric
        having count(*) > 1
    ) then
        raise exception 'QA failed: mart.decision_kpi_driver_tree has duplicate driver definitions.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 5: Business areas must stay inside the approved driver tree.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_kpi_driver_tree
        where business_area not in (
            'Revenue',
            'Margin',
            'Inventory Health',
            'Labor Efficiency'
        )
    ) then
        raise exception 'QA failed: mart.decision_kpi_driver_tree has an unexpected business_area.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 6: Metric level must be a positive number.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_kpi_driver_tree
        where metric_level <= 0
    ) then
        raise exception 'QA failed: mart.decision_kpi_driver_tree has an invalid metric_level.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 7: Recommended outputs should point to mart objects.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_kpi_driver_tree
        where recommended_output not like 'mart.%'
    ) then
        raise exception 'QA failed: recommended_output should reference a mart object.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Informational summary.
-- This does not fail the pipeline. It prints a useful review table.
-- ------------------------------------------------------------

select
    business_area,
    count(*) as driver_count
from mart.decision_kpi_driver_tree
group by business_area
order by business_area;

\echo 'QA passed: mart.decision_kpi_driver_tree'
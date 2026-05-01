-- ============================================================
-- Project 5: Decision Engine
-- QA: mart.decision_revenue_variance_root_cause
--
-- Purpose:
--   Validate that the revenue root-cause view is complete,
--   clean, and mathematically reasonable.
--
-- Why this matters:
--   This view turns sales facts into decision labels. If the
--   math or labels are wrong, leadership recommendations could
--   be misleading.
-- ============================================================

\echo ''
\echo 'QA: mart.decision_revenue_variance_root_cause'

-- ------------------------------------------------------------
-- Check 1: The view must exist.
-- ------------------------------------------------------------

do $$
begin
    if to_regclass('mart.decision_revenue_variance_root_cause') is null then
        raise exception 'QA failed: mart.decision_revenue_variance_root_cause does not exist.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 2: The view must contain rows.
-- ------------------------------------------------------------

do $$
begin
    if (
        select count(*)
        from mart.decision_revenue_variance_root_cause
    ) = 0 then
        raise exception 'QA failed: mart.decision_revenue_variance_root_cause has zero rows.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 3: Required dimension fields must not be null.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_revenue_variance_root_cause
        where store_code is null
           or sku is null
           or channel is null
    ) then
        raise exception 'QA failed: revenue root-cause view has null store_code, sku, or channel.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 4: Required decision fields must not be null.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_revenue_variance_root_cause
        where primary_revenue_driver is null
           or recommended_action is null
           or variance_impact_rank is null
    ) then
        raise exception 'QA failed: revenue root-cause view has null decision fields.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 5: Current/prior sales and units should not be negative.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_revenue_variance_root_cause
        where current_units_sold < 0
           or prior_units_sold < 0
           or current_net_sales < 0
           or prior_net_sales < 0
    ) then
        raise exception 'QA failed: revenue root-cause view has negative sales or unit values.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 6: Net sales variance math must be correct.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_revenue_variance_root_cause
        where abs(
            net_sales_variance - (current_net_sales - prior_net_sales)
        ) > 0.01
    ) then
        raise exception 'QA failed: net_sales_variance does not equal current_net_sales - prior_net_sales.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 7: Driver labels must stay inside the approved list.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_revenue_variance_root_cause
        where primary_revenue_driver not in (
            'New / growing business',
            'Lost / declining business',
            'Volume-driven decline',
            'Price-driven decline',
            'Volume-driven growth',
            'Price-driven growth',
            'Stable / low movement'
        )
    ) then
        raise exception 'QA failed: revenue root-cause view has an unexpected primary_revenue_driver label.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Check 8: Impact rank must be positive.
-- ------------------------------------------------------------

do $$
begin
    if exists (
        select 1
        from mart.decision_revenue_variance_root_cause
        where variance_impact_rank <= 0
    ) then
        raise exception 'QA failed: variance_impact_rank must be greater than zero.';
    end if;
end $$;

-- ------------------------------------------------------------
-- Informational summary.
-- This does not fail the pipeline. It helps you review results.
-- ------------------------------------------------------------

select
    primary_revenue_driver,
    count(*) as row_count,
    round(sum(net_sales_variance)::numeric, 2) as total_net_sales_variance
from mart.decision_revenue_variance_root_cause
group by primary_revenue_driver
order by abs(sum(net_sales_variance)) desc;

\echo 'QA passed: mart.decision_revenue_variance_root_cause'
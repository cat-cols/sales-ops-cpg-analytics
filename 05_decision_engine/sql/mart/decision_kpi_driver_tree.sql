-- ============================================================
-- Project 5: Decision Engine
-- Object: mart.decision_kpi_driver_tree
--
-- Purpose:
--   Stores the business-facing KPI hierarchy used by the
--   Decision Engine. This view explains which metrics drive
--   revenue, margin, inventory health, and labor efficiency.
--
-- Grain:
--   One row per business area / parent metric / child metric.
--
-- Why this matters:
--   This turns the KPI driver tree from documentation into
--   queryable decision logic that can support marts, QA checks,
--   semantic models, and executive summaries.
-- ============================================================

create schema if not exists mart;

create or replace view mart.decision_kpi_driver_tree as

select
    business_area,
    parent_metric,
    child_metric,
    metric_level,
    driver_type,
    decision_question,
    example_decision,
    recommended_output
from (
    values
        (
            'Revenue',
            'Net Sales',
            'Units Sold',
            2,
            'Volume',
            'Did revenue change because we sold more or fewer units?',
            'Investigate demand, distribution coverage, inventory availability, or store/account performance.',
            'mart.decision_revenue_variance_root_cause'
        ),
        (
            'Revenue',
            'Net Sales',
            'Average Net Price',
            2,
            'Price',
            'Did revenue change because realized selling price changed?',
            'Review pricing, discounting, promo depth, or channel pricing strategy.',
            'mart.decision_revenue_variance_root_cause'
        ),
        (
            'Revenue',
            'Net Sales',
            'Discount Rate',
            2,
            'Price / Promo',
            'Did revenue or margin change because discounting increased?',
            'Review promo ROI, reduce unnecessary discounting, or adjust price floors.',
            'mart.alerts_low_margin'
        ),
        (
            'Revenue',
            'Net Sales',
            'Channel Mix',
            2,
            'Mix',
            'Did revenue change because sales shifted across channels?',
            'Rebalance retail, wholesale, and distributor strategy.',
            'mart.decision_revenue_variance_root_cause'
        ),
        (
            'Revenue',
            'Net Sales',
            'Store / Account Mix',
            2,
            'Mix',
            'Did revenue change because performance shifted across stores or accounts?',
            'Focus field support on underperforming or high-opportunity stores.',
            'mart.store_performance_flags'
        ),
        (
            'Revenue',
            'Net Sales',
            'SKU Mix',
            2,
            'Mix',
            'Did revenue change because product mix shifted?',
            'Prioritize high-growth or high-margin SKUs.',
            'mart.opportunity_high_growth_skus'
        ),

        (
            'Margin',
            'Gross Margin %',
            'Net Sales',
            2,
            'Revenue Base',
            'Is margin changing because revenue changed?',
            'Grow sales where margin remains healthy.',
            'mart.alerts_low_margin'
        ),
        (
            'Margin',
            'Gross Margin %',
            'COGS',
            2,
            'Cost',
            'Is margin changing because cost of goods changed?',
            'Investigate product cost, cost assumptions, or SKU-level margin erosion.',
            'mart.alerts_low_margin'
        ),
        (
            'Margin',
            'Gross Margin %',
            'Discount Amount',
            2,
            'Promo',
            'Is margin changing because discount dollars increased?',
            'Review discounting strategy and promo effectiveness.',
            'mart.alerts_low_margin'
        ),
        (
            'Margin',
            'Gross Margin %',
            'SKU Mix',
            2,
            'Mix',
            'Is margin changing because sales shifted toward lower- or higher-margin products?',
            'Promote higher-margin SKUs or investigate low-margin growth.',
            'mart.opportunity_high_growth_skus'
        ),
        (
            'Margin',
            'Gross Margin %',
            'Channel Mix',
            2,
            'Mix',
            'Is margin changing because revenue shifted across channels?',
            'Review wholesale, distributor, and retail economics.',
            'mart.decision_revenue_variance_root_cause'
        ),

        (
            'Inventory Health',
            'In-Stock Rate',
            'On-Hand Units',
            2,
            'Supply',
            'Do we have enough inventory available to support demand?',
            'Replenish fast-moving SKUs or reduce excess stock.',
            'mart.alerts_inventory_risk'
        ),
        (
            'Inventory Health',
            'In-Stock Rate',
            'Backordered Units',
            2,
            'Supply Risk',
            'Are customers or stores experiencing fulfillment gaps?',
            'Prioritize replenishment where backorders are concentrated.',
            'mart.alerts_inventory_risk'
        ),
        (
            'Inventory Health',
            'Days of Supply',
            'Units Sold',
            2,
            'Demand Velocity',
            'Is demand velocity high enough to create stockout risk?',
            'Increase supply for fast-moving SKUs.',
            'mart.alerts_inventory_risk'
        ),
        (
            'Inventory Health',
            'Days of Supply',
            'Shipments',
            2,
            'Fulfillment',
            'Are shipments keeping up with demand?',
            'Investigate supply chain or fulfillment delays.',
            'mart.alerts_inventory_risk'
        ),
        (
            'Inventory Health',
            'In-Stock Rate',
            'SKU Distribution Status',
            2,
            'Assortment',
            'Is the SKU actually carried where demand exists?',
            'Expand distribution or clean assortment setup.',
            'mart.opportunity_high_growth_skus'
        ),

        (
            'Labor Efficiency',
            'Sales per Labor Hour',
            'Net Sales',
            2,
            'Output',
            'Are labor hours producing enough revenue?',
            'Compare staffing levels to sales activity.',
            'mart.store_performance_flags'
        ),
        (
            'Labor Efficiency',
            'Sales per Labor Hour',
            'Labor Hours',
            2,
            'Input',
            'Are labor hours aligned with sales activity?',
            'Review staffing levels and scheduling assumptions.',
            'mart.store_performance_flags'
        ),
        (
            'Labor Efficiency',
            'Sales per Labor Hour',
            'Labor Cost',
            2,
            'Cost',
            'Is labor cost creating pressure relative to sales?',
            'Monitor labor cost pressure and store productivity.',
            'mart.store_performance_flags'
        ),
        (
            'Labor Efficiency',
            'Sales per Labor Hour',
            'OT Hours',
            2,
            'Overtime',
            'Is overtime increasing without matching sales growth?',
            'Reduce overtime or rebalance staffing.',
            'mart.store_performance_flags'
        ),
        (
            'Labor Efficiency',
            'Sales per Labor Hour',
            'Store Mix',
            2,
            'Location Mix',
            'Are efficiency issues concentrated in specific stores?',
            'Investigate underperforming locations.',
            'mart.store_performance_flags'
        )
) as driver_tree (
    business_area,
    parent_metric,
    child_metric,
    metric_level,
    driver_type,
    decision_question,
    example_decision,
    recommended_output
);


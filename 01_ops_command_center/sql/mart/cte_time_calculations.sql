-- Time-Based Calculations CTE
-- Pre-calculates period-over-period comparisons and rolling averages
-- This view provides optimized time-based metrics for trend analysis dashboards

DROP VIEW IF EXISTS mart.vw_time_calculations;

CREATE VIEW mart.vw_time_calculations AS
WITH time_comparison AS (
    SELECT 
        d.date_key,
        d.full_date,
        d.year,
        d.month_num,
        d.month_name,
        d.day_of_month,
        d.day_of_week,
        d.day_name,
        d.quarter,
        SUM(f.net_sales_amount) AS daily_sales,
        SUM(f.gross_sales_amount) AS daily_gross_sales,
        SUM(f.units_sold) AS daily_units,
        SUM(f.order_count) AS daily_orders,
        COUNT(DISTINCT f.location_key) AS daily_active_locations,
        -- Rolling averages
        AVG(SUM(f.net_sales_amount)) OVER (ORDER BY d.date_key ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7day_avg_sales,
        AVG(SUM(f.net_sales_amount)) OVER (ORDER BY d.date_key ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS rolling_30day_avg_sales,
        -- Period comparisons
        LAG(SUM(f.net_sales_amount), 7) OVER (ORDER BY d.date_key) AS sales_7days_ago,
        LAG(SUM(f.net_sales_amount), 30) OVER (ORDER BY d.date_key) AS sales_30days_ago,
        LAG(SUM(f.net_sales_amount), 365) OVER (ORDER BY d.date_key) AS sales_1year_ago,
        -- Monthly aggregations
        SUM(SUM(f.net_sales_amount)) OVER (PARTITION BY d.year, d.month_num ORDER BY d.date_key) AS monthly_running_total,
        SUM(SUM(f.net_sales_amount)) OVER (PARTITION BY d.year, d.month_num) AS monthly_total,
        -- Year-to-date
        SUM(SUM(f.net_sales_amount)) OVER (PARTITION BY d.year ORDER BY d.date_key) AS ytd_sales,
        -- Growth calculations
        CASE 
            WHEN LAG(SUM(f.net_sales_amount), 7) OVER (ORDER BY d.date_key) IS NOT NULL 
            THEN (SUM(f.net_sales_amount) - LAG(SUM(f.net_sales_amount), 7) OVER (ORDER BY d.date_key)) / 
                 NULLIF(LAG(SUM(f.net_sales_amount), 7) OVER (ORDER BY d.date_key), 0)
            ELSE NULL 
        END AS wow_growth_pct,
        CASE 
            WHEN LAG(SUM(f.net_sales_amount), 30) OVER (ORDER BY d.date_key) IS NOT NULL 
            THEN (SUM(f.net_sales_amount) - LAG(SUM(f.net_sales_amount), 30) OVER (ORDER BY d.date_key)) / 
                 NULLIF(LAG(SUM(f.net_sales_amount), 30) OVER (ORDER BY d.date_key), 0)
            ELSE NULL 
        END AS mom_growth_pct,
        CASE 
            WHEN LAG(SUM(f.net_sales_amount), 365) OVER (ORDER BY d.date_key) IS NOT NULL 
            THEN (SUM(f.net_sales_amount) - LAG(SUM(f.net_sales_amount), 365) OVER (ORDER BY d.date_key)) / 
                 NULLIF(LAG(SUM(f.net_sales_amount), 365) OVER (ORDER BY d.date_key), 0)
            ELSE NULL 
        END AS yoy_growth_pct
    FROM raw.fact_sales f
    JOIN raw.dim_date d ON f.date_key = d.date_key
    GROUP BY d.date_key, d.full_date, d.year, d.month_num, d.month_name, d.day_of_month, d.day_of_week, d.day_name, d.quarter
)
SELECT 
    date_key,
    full_date,
    year,
    month_num,
    month_name,
    day_of_month,
    day_of_week,
    day_name,
    quarter,
    daily_sales,
    daily_gross_sales,
    daily_units,
    daily_orders,
    daily_active_locations,
    rolling_7day_avg_sales,
    rolling_30day_avg_sales,
    sales_7days_ago,
    sales_30days_ago,
    sales_1year_ago,
    monthly_running_total,
    monthly_total,
    ytd_sales,
    ROUND(wow_growth_pct::numeric, 4) AS wow_growth_pct,
    ROUND(mom_growth_pct::numeric, 4) AS mom_growth_pct,
    ROUND(yoy_growth_pct::numeric, 4) AS yoy_growth_pct,
    -- Trend indicators
    CASE 
        WHEN wow_growth_pct > 0.05 THEN 'Strong Growth'
        WHEN wow_growth_pct > 0 THEN 'Growth'
        WHEN wow_growth_pct > -0.05 THEN 'Stable'
        ELSE 'Decline'
    END AS weekly_trend,
    -- Performance vs rolling average
    CASE 
        WHEN daily_sales > rolling_7day_avg_sales * 1.1 THEN 'Above Average'
        WHEN daily_sales < rolling_7day_avg_sales * 0.9 THEN 'Below Average'
        ELSE 'On Track'
    END AS performance_vs_avg
FROM time_comparison;

-- Add comments
COMMENT ON VIEW mart.vw_time_calculations IS 'Pre-calculated time-based metrics for optimized trend analysis';
COMMENT ON COLUMN mart.vw_time_calculations.rolling_7day_avg_sales IS '7-day rolling average of sales';
COMMENT ON COLUMN mart.vw_time_calculations.wow_growth_pct IS 'Week-over-week growth percentage';
COMMENT ON COLUMN mart.vw_time_calculations.yoy_growth_pct IS 'Year-over-year growth percentage';

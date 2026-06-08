-- Grain: work_date + store_code
-- Roll up employee labor to the store/day level.

with e as (
  select
    work_date,
    store_code,
    employee_id,
    hours_worked,
    minutes_worked,
    n_shift_pairs,
    n_events,
    n_unpaired_in,
    n_out_events,
    min_ingested_at,
    max_ingested_at,
    min_drop_date,
    max_drop_date
  from {{ ref('int_labor_daily_employee') }}
)
select
  work_date,
  store_code,

  sum(coalesce(hours_worked,0))::numeric as hours_worked,
  sum(coalesce(minutes_worked,0))::numeric as minutes_worked,

  count(distinct employee_id)::bigint as n_employees,
  sum(coalesce(n_shift_pairs,0))::bigint as n_shift_pairs,
  sum(coalesce(n_events,0))::bigint as n_events,

  sum(coalesce(n_unpaired_in,0))::bigint as n_unpaired_in,
  sum(coalesce(n_out_events,0))::bigint as n_out_events,

  case when nullif(count(distinct employee_id),0) is null then null
       else (sum(coalesce(hours_worked,0)) / nullif(count(distinct employee_id),0))::numeric
  end as avg_hours_per_employee,

  min(min_ingested_at) as min_ingested_at,
  max(max_ingested_at) as max_ingested_at,
  min(min_drop_date)   as min_drop_date,
  max(max_drop_date)   as max_drop_date

from e
group by 1,2

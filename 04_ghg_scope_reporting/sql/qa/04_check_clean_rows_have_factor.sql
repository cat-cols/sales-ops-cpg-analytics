do $$
begin
    if exists (
        select 1
        from mart.fact_emissions
        where has_missing_factor_join
          and not has_negative_activity
          and not has_missing_facility_id
          and not has_invalid_activity_month
          and not has_unknown_activity_type
          and not has_missing_facility_join
    ) then
        raise exception 'QA failed: clean emissions activity rows are missing emission factor joins';
    end if;
end $$;

select
    'PASS: clean emissions activity rows have factor joins' as qa_result;
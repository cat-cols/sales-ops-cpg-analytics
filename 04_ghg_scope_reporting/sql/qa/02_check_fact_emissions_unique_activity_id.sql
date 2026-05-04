do $$
begin
    if exists (
        select activity_id
        from mart.fact_emissions
        group by activity_id
        having count(*) > 1
    ) then
        raise exception 'QA failed: duplicate activity_id values found in mart.fact_emissions';
    end if;
end $$;

select
    'PASS: mart.fact_emissions activity_id is unique' as qa_result;
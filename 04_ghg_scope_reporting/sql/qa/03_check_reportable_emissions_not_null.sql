do $$
begin
    if exists (
        select 1
        from mart.fact_emissions
        where is_reportable_emissions_row
          and metric_tons_co2e is null
    ) then
        raise exception 'QA failed: reportable rows have null metric_tons_co2e';
    end if;
end $$;

select
    'PASS: all reportable emissions rows have calculated metric_tons_co2e' as qa_result;
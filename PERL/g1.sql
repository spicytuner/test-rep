select distinct orig_dt, sum(call_duration_seconds/60+call_duration_minutes)
 from qwest_march
where ani='4068303002'
group by orig_dt
order by orig_dt;

set head off
set pagesize 0
set linesize 150
set colsep ','
spool q3.log

select distinct category, count(*)
from bz_incident_dat
where trunc(create_date) >= trunc(sysdate-200)
group by category
order by count(*);

spool off;
exit;

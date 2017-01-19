select submitter, count(*)
from bz_incident_dat
where create_date >= trunc(sysdate -30)
and create_date < trunc(sysdate)
group by submitter
order by count(*) DESC;

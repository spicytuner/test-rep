set pagesize 0
set head off
select pending_reason, count(*)
from bz_incident_dat
where status='Pending'
group by pending_reason;

exit

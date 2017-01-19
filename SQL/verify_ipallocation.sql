set head off;
select trunc(eventtime), count(*)
from ip_allocation_events
where eventtime >= sysdate-20
group by trunc(eventtime);

spool iae_count.log
select trunc(eventtime), count(*)
from metaserv31.ip_allocation_events partition(IP_ALLOCATION_EVENTS_30JUN2008)
group by trunc(eventtime);
spool off
exit

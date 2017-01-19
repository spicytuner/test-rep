set head off
set pagesize 0

select cmts, devicetype, count(*)
from cust
group by cmts, devicetype
order by cmts;

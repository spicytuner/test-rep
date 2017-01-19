set head off
set pagesize 0

select a.userid 
from pi a
where a.parentref not in (select parentref from hsd where deletestatus=0)
and a.deletestatus=0
and userid not like '8313%'
order by userid;

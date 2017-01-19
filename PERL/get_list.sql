set pagesize 0
set head off

select b.node_id, count(b.cm_mac)
from cm a, live_cm b
where a.cm_mac=b.cm_mac
and a.node_id != b.node_id 
group by b.node_id
order by count(b.cm_mac);


select a.cm_mac
from live_cm a, cm b
where a.node_id=&node_id
and a.cm_mac=b.cm_mac
and a.node_id != b.node_id
order by cm_mac;


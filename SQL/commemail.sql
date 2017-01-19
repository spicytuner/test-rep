set head off
set pagesize 0
spool email.lst

select userid
from email a
where deletestatus=0
and isowner=1
and parentref in
(select parentref
from subscribertopackage where packageid like 'COM%')
order by userid;

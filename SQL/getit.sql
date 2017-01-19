set head off
set pagesize 0
spool phil.lst

select accountnumber, cmmac, packageid
from cust
where packageid like '%BBS%';

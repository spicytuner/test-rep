set pagesize 0
set head off
set echo off
set linesize 90
set feedback off
set termout off
spool william.txt

select cmmac,node,street1,street2,city,state,zip
from cust ;

spool off
exit;

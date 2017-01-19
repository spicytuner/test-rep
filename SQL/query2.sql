set head off
set pagesize 0
set linesize 150
set colsep ','
spool q2.log

select submitter, Category, Type, Create_Date, Resolution_Date
from bz_incident_dat
where account_number is null
and trunc(create_date)>= trunc(sysdate-7)
and source ='Phone';

spool off;
exit;

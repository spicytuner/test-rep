set head on
set linesize 10000
set pagesize 0
set colsep ,
set termout off
set feedback off
set echo off
set trimspool on
spool chinook_cvc.csv


select a.*
from chinook_june_2010 a
union all
select a.*
from chinook_july_2010 a
union all
select a.*
from chinook_august_2010 a;

spool off
exit

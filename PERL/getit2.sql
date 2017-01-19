set pagesize 0
set linesize 1000
set echo off
set feedback off
set termout off
set colsep ^
spool sheet2.csv
select * from chinook_september
where chinook_id in 
(select chinook_id from chinook_september
minus
select chinook_id from chinook_bill_september);
spool off
exit

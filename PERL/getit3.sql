set pagesize 0
set linesize 3000
set echo off
set feedback off
set termout off
set colsep ^
spool sheet3.csv
select * from chinook_september;
spool off
exit

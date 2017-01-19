set pagesize 0
set linesize 100
set echo off
set feedback off
#set termout off
set colsep ^
spool sheet1.csv
select * from chinook_bill_september;
spool off
exit

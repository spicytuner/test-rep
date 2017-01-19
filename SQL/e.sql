set pagesize 0
set linesize 100
set space 0
set echo off
set termout off
set feedback off
set trim on 
set wrap off
set colsep ,

col "Call Duration" format a7

spool new_detail_april.txt
ttitle left 'Dialed Number,Date,Orig Time,Term Time,Call Duration,OCN,CPM,Band/Tier,Amount Billed'
select sysdate from dual;

spool off
exit

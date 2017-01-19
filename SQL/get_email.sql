set pagesize 0
set head off
set termout off
set echo off
set feedback off

spool email.log
select accountnumber, email from cust_remedy 
where email is not null;
spool off
exit

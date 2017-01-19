set head off
set pagesize 0
set termout off
set feedback off
set echo off
col account_number format a16
spool del.sh
select './joe_deletesub.pl '||account_number || ' acct delete'
from delete_account
where account_number not in 
(select account_number from nodelete_account);
spool off
exit;

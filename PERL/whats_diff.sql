set head off
set linesize 50
set pagesize 0
spool diff.log

select a.account, a.node, b.node
from verify_node a, account_node_status b
where a.account=b.accountnumber
and b.status='Active';

spool off
exit;

select osuser, username, count(*)
from v$session
where sql_id='faxkzvhaa1ybr'
group by osuser, username;

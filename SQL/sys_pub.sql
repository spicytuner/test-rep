set head off
set pagesize 0
spool revoke_select.sql;

select 'revoke select on '||owner||'.'|| table_name||' from public;' 
from dba_tab_privs
where grantee='PUBLIC'
and grantor='SYS'
and privilege='SELECT'
order by privilege;

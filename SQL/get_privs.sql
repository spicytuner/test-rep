set head off
set pagesize 0

spool pub_select.sql;

select 'revoke select on '||owner||'.'|| table_name||' from public;'
from dba_tab_privs
where grantee='PUBLIC'
and privilege='SELECT';

spool off;

spool pub_update.sql;

select 'revoke update on '||owner||'.'|| table_name||' from public;'
from dba_tab_privs
where grantee='PUBLIC'
and privilege = 'UPDATE';

spool off;

spool pub_insert.sql;

select 'revoke insert on '||owner||'.'|| table_name||' from public;'
from dba_tab_privs
where grantee='PUBLIC'
and privilege = 'INSERT';

spool off;

spool pub_delete.sql;

select 'revoke delete on '||owner||'.'|| table_name||' from public;'
from dba_tab_privs
where grantee='PUBLIC'
and privilege = 'DELETE';

spool off;

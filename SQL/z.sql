set head off
set pagesize 0
spool analyze_this.sql

select table_name from dba_tables
where owner='ARADMIN';

spool off
exit

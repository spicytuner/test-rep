set head off
set pagesize 0
set linesize 100
spool analyze_this.sql

select 'analyze table '|| owner||'.'|| table_name || ' estimate statistics;'
from dba_tables
where owner not in ('SYS','SYSTEM')
and last_analyzed is null;

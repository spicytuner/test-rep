set head off
set pagesize 0
spool exp_parts.log
select table_name||'('||partition_name||')'
from dba_tab_partitions
where table_name='IP_ALLOCATION_EVENTS';

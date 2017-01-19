set head off 
set pagesize 0
set linesize 100
spool drop_parts.sql

select 'alter table metaserv31.ip_allocation_events drop partition '||partition_name ||';'
from dba_tab_partitions
where table_name ='IP_ALLOCATION_EVENTS';
spool off

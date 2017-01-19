set head off
set pagesize 0
set linesize 150
spool get_parts.txt

select 'alter table metaserv31.ip_allocation_events drop partition '||partition_name, high_value from dba_tab_partitions
where table_name='IP_ALLOCATION_EVENTS'
and partition_name like '%2009%';
exit

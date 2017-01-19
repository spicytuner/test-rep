select partition_name from dba_tab_partitions
where table_name='IP_ALLOCATION_EVENTS'
and partition_name like '%SEP2008';

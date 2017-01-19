/*alter tablespace metaserv31_data read write;
alter tablespace archive_data read write;

alter session set nls_date_format='dd-MON-YYYY hh24:mi:ss';

alter  TABLE metaserv31.IP_ALLOCATION_EVENTS  add  partition IP_ALLOCATION_EVENTS_08SEP2008
values less than (to_date('08-Sep-2008','dd-Mon-yyyy'));

select subpartition_name from dba_tab_subpartitions 
where partition_name='IP_ALLOCATION_EVENTS_08SEP2008'
and table_owner='METASERV31';

*/

ALTER TABLE metaserv31.IP_ALLOCATION_EVENTS EXCHANGE SUBPARTITION SYS_SUBP42
WITH TABLE IP_ALLOCATION_EVENTS_08SEP2008 Including indexes;




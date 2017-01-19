alter tablespace archive_data read write;
alter tablespace metaserv31_data read write;

alter session set nls_date_format='dd-MON-YYYY hh24:mi:ss';
 
create table IP_ALLOCATION_EVENTS_24SEP2008 tablespace metaserv31_data 
NOLOGGING STORAGE (INITIAL 500M next 500M)
as select * from IP_ALLOCATION_EVENTS@SAMPRD 
where eventtime between '23-SEP-2008 00:00:00' and '23-SEP-2008 23:59:59';
 
Create index ip_24SEP2008_IND01 on IP_ALLOCATION_EVENTS_24SEP2008(eventtime,eventtype)
NOLOGGING storage(initial 500M next 200M);
 
Create index ip_24SEP2008_ip on IP_ALLOCATION_EVENTS_24SEP2008(ipaddress) 
NOLOGGING storage(initial 500M next 200M);   

alter  TABLE metaserv31.IP_ALLOCATION_EVENTS  add  partition IP_ALLOCATION_EVENTS_24SEP2008
values less than (to_date('24-Sep-2008','dd-Mon-yyyy'));
 
select subpartition_name from dba_tab_subpartitions 
where partition_name='IP_ALLOCATION_EVENTS_24SEP2008'
and table_owner='METASERV31';
 
ALTER TABLE metaserv31.IP_ALLOCATION_EVENTS EXCHANGE SUBPARTITION &new_part_name
WITH TABLE IP_ALLOCATION_EVENTS_24SEP2008 Including indexes;
 

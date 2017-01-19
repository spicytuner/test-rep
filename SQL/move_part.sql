alter tablespace archive_data read write;
alter tablespace metaserv31_data read write;

Create index ip_08SEP2008_IND01 on IP_ALLOCATION_EVENTS_08SEP2008(eventtime,eventtype)
NOLOGGING storage(initial 500M next 200M) tablespace archive_data;
 
Create index ip_08SEP2008_ip on IP_ALLOCATION_EVENTS_08SEP2008(ipaddress) 
NOLOGGING storage(initial 500M next 200M) tablespace archive_data;   

ALTER TABLE IP_ALLOCATION_EVENTS 
EXCHANGE SUBPARTITION SYS_SUBP24 WITH TABLE IP_ALLOCATION_EVENTS_08SEP2008 Including indexes; 

alter tablespace archive_data read only;
alter tablespace metaserv31_data read only;

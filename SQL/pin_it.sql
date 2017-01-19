alter table smp42cm.sub_svc cache;
alter table smp42cm.svc cache;
alter table smp42cm.sub_svc_parm cache;
alter table smp42cm.sub_addr cache;
alter table smp42cm.location_dtl cache;

set head off
set feedback off
set echo off
set termout off

select * from smp42cm.sub_svc;
select * from smp42cm.svc;
select * from smp42cm.sub_svc_parm;
select * from smp42cm.sub_addr_cache;
select * from smp42cm.location_dtl;

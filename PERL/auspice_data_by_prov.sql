spool ausplice_cust.log
truncate table cust_backup;
drop table cust_backup;
create table cust_backup as select * from cust ;
truncate table cust;
drop table cust;
create table cust as select * from cust_auspice;
grant select on cust to public;
create index cust_acctnum on cust (accountnumber);
create index cust_phone on cust(phone);
analyze index cust_acctnum validate structure;
analyze index cust_phone validate structure;
analyze table cust estimate statistics;
update cust set node='trans' where imagefile like '%ransp%';
commit;
update cust set node='RFTOOLS' where imagefile like '%RFT%';
commit;

update cust a
set a.cmts=(select new_cmts
from cmts_ass
where a.cmts=old_cmts)
where a.cmts in (select distinct old_cmts from cmts_ass);

commit ;

update cust a
set a.cmsfqdn=(select b.cms from cmts_cms_map b
where a.cmts=b.cmts)
where bdp=1;

commit ;

spool off
exit;

spool ausplice_remedy.log
grant select on cust_remedy to public;
create index cust_remedy_acctnum on cust_remedy (accountnumber);
create index cust_remedy_phone on cust_remedy(phone);
analyze index cust_remedy_acctnum validate structure;
analyze index cust_remedy_phone validate structure;
analyze table cust_remedy estimate statistics;

update cust_remedy a
set a.cmts=(select new_cmts
from cmts_ass
where a.cmts=old_cmts)
where a.cmts in (select distinct old_cmts from cmts_ass);

commit ;

update cust_remedy a
set a.cmsfqdn=(select b.cms from cmts_cms_map b
where a.cmts=b.cmts)
where bdp=1;

commit ;

spool off
exit;

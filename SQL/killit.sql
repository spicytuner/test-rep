set feedback off
set termout off

drop table temp1;
drop table temp2;

create table temp1
as
		select distinct account_number
		from bz_incident_dat
		where create_date > trunc(sysdate-7)
		and service_affecting=1
		and substr(account_number,1,4) = '8313';

select count(*) from temp1;

create table temp2
as
	select account_number
	from bz_incident_dat
	where create_date>trunc(sysdate-30)
	and service_affecting=1
	and account_number in (select account_number from temp1)
	group by account_number
	having count(*) >1;


select count(*) from temp2;

set head off
set pages 0
set lines 500
set echo on
set colsep ,
set feedback off
set termout off
set echo off
set trim on
set trims on
spool res.txt

select b.gl, '^'||a.account_number, a.incident_id, a.create_date, a.category, a.type, a.item, a.submitter, 
a.market, a.city, a.node_name, a.status
from bz_incident_dat a, customer_info b
where a.create_date> trunc(sysdate-30)
and a.service_affecting=1
and a.account_number=b.accountnumber
and a.account_number in (select account_number from temp2)
order by a.account_number;

spool off
exit

alter session set nls_date_format='DD-MON-YYYY';

truncate table  missing_ipae;

drop table  missing_ipae;

create table missing_ipae
as
select recordnumber from metaserv31.ip_allocation_events@samprd
where eventtime >='01-SEP-2010'
and eventtime < '01-OCT-2010'
minus
select recordnumber from metaserv31.ip_allocation_events
where eventtime >='01-SEP-2010'
and eventtime < '01-OCT-2010';

insert into metaserv31.ip_allocation_events
select * from metaserv31.ip_allocation_events@samprd
where eventtime >='01-SEP-2010'
and eventtime < '01-OCT-2010'
and recordnumber in (select recordnumber from missing_ipae);

commit;

exit;

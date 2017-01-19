alter  TABLE metaserv31.IP_ALLOCATION_EVENTS  
add  partition IP_ALLOCATION_EVENTS_13NOV2008
values less than (to_date('13-Nov-2008','dd-Mon-yyyy'));
 
insert into metaserv31.IP_ALLOCATION_EVENTS
select * from metaserv31.IP_ALLOCATION_EVENTS@samprd
where eventtime > '11/12/2008'
and eventtime < '11/13/2008';

commit

alter  TABLE metaserv31.IP_ALLOCATION_EVENTS  
add  partition IP_ALLOCATION_EVENTS_14NOV2008
values less than (to_date('14-Nov-2008','dd-Mon-yyyy'));
 
insert into metaserv31.IP_ALLOCATION_EVENTS
select * from metaserv31.IP_ALLOCATION_EVENTS@samprd
where eventtime > '11/13/2008'
and eventtime < '11/14/2008';

commit

alter  TABLE metaserv31.IP_ALLOCATION_EVENTS  
add  partition IP_ALLOCATION_EVENTS_15NOV2008
values less than (to_date('15-Nov-2008','dd-Mon-yyyy'));
 
insert into metaserv31.IP_ALLOCATION_EVENTS
select * from metaserv31.IP_ALLOCATION_EVENTS@samprd
where eventtime > '11/14/2008'
and eventtime < '11/15/2008';

commit

exit

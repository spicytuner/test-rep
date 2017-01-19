alter rollback segment BIG_RBS online;

set transaction use rollback segment BIG_RBS;
select a.userid from pi a
where deletestatus=0
and parentref in (
select parentref from endpoint
where deletestatus=0
and macaddressofmta in (
select macaddressofmta from endpoint
where deletestatus=0
minus
select mtamac
from cust
)
);

alter rollback segment BIG_RBS offline;


set head off
set pagesize 0
select userid,firstname,lastname from pi
where parentref in 
(select distinct parentref
from subscribertopackage a
where 
rowid >
(select min(rowid)
from subscribertopackage b
where b.parentref=a.parentref
and b.deletestatus=0)
and a.deletestatus=0
and upper(a.packageid) like '%RES%'
union
select distinct parentref
from subscribertopackage a
where 
rowid >
(select min(rowid)
from subscribertopackage b
where b.parentref=a.parentref
and b.deletestatus=0)
and a.deletestatus=0
and upper(a.packageid) like '%COM%')
and userid like '8313%'
order by userid;

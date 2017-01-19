(select userid
from pi
where deletestatus=0
and userid like '8313%'
minus
select account_number
from subscriber_details_info)
minus
select a.userid
from pi a, hsd b
where a.parentref=b.parentref
and a.deletestatus=0
and b.deletestatus=0
and userid in (
select userid
from pi
where deletestatus=0
and userid like '8313%'
minus
select account_number
from subscriber_details_info);


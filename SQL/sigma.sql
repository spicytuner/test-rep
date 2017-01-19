set pagesize 10000

select distinct (subscriber_ref)
from subscriber_events se,subscriber s
where se.subscriber_ref=s.recordnumber
and s.SUBSCRIPTIONSTATUS='complete'
and not exists
( select 1 from pi where parentref=se.subscriber_ref);

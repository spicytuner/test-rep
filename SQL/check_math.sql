select state_called,call_area,prcmp_id, count(*)
from chinook_march_2008
where class_type=0
and dialedno like '&num%'
group by state_called,call_area,prcmp_id;

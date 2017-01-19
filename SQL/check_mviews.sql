set pagesize 100
select mview_name, refresh_mode, refresh_method,
last_refresh_type, last_refresh_date
from dba_mviews
order by mview_name;
exit

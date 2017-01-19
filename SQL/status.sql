alter session set nls_date_format='MM/DD/YYYY hh24:mi:ss';

select sid,sofar, totalwork, start_time, last_update_time, time_remaining, target
from v$session_longops
where sofar < totalwork;

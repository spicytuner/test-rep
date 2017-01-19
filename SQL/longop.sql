select a.osuser, a.username, a.process, b.target, b.message, b.start_time, b.last_update_time, b.time_remaining
from v$session a, v$session_longops b
where a.sid=b.sid
and a.serial#=b.serial#;

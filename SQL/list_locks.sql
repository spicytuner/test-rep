column lock_type format a12
column mode_held format a10
column mode_requested format a10
column blocking_others format a20
column username format a10
SELECT	session_id
,	lock_type
,	mode_held
,	mode_requested
,	blocking_others
,	lock_id1
FROM	dba_lock l
WHERE 	lock_type NOT IN ('Media Recovery', 'Redo Thread')
/

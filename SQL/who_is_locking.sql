set lines 100 pages 999
col username 	format a20
col sess_id 	format a10
col object	format a25
col mode_held	format a10
select	oracle_username || ' (' || s.osuser || ')' username
,	s.sid || ',' || s.serial# sess_id
,	owner || '.' ||	object_name object
,	object_type
,	decode(	l.block
	,	0, 'Not Blocking'
	,	1, 'Blocking'
	,	2, 'Global') status
,	decode(v.locked_mode
	,	0, 'None'
	,	1, 'Null'
	,	2, 'Row-S (SS)'
	,	3, 'Row-X (SX)'
	,	4, 'Share'
	,	5, 'S/Row-X (SSX)'
	,	6, 'Exclusive', TO_CHAR(lmode)) mode_held
from	v$locked_object v
,	dba_objects d
,	v$lock l
,	v$session s
where 	v.object_id = d.object_id
and 	v.object_id = l.id1
and 	v.session_id = s.sid
order by oracle_username
,	session_id
/

select
    s1.username || '@' || s1.machine 
    || ' ( SID,S#=' || s1.sid || ',' || s1.serial# || ' )  is blocking '
    || s2.username || '@' || s2.machine
    || ' ( SID,S#=' || s2.sid || ',' || s2.serial# || ' )'
        AS blocking_status
from
    v$lock l1,
    v$session s1,
    v$lock l2,
    v$session s2
where
    s1.sid = l1.sid
    and s2.sid = l2.sid
    and l1.BLOCK = 1
    and l2.request > 0
    and l1.id1 = l2.id1
    and l2.id2 = l2.id2
/

exit

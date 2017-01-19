set linesize 100
set pagesize 0
col owner format a15
col object_name format a35
col object_type format a35
spool get_obj.sql

select 'select * from '||object_name||' where rownum<1;'
from dba_objects
where status='INVALID';


set linesize 200
set pagesize 10000

col type format a5
col owner format a7
select owner, original_name, type, droptime, can_undrop
from dba_recyclebin
where owner like 'SMP%'
and type='INDEX'
order by droptime;



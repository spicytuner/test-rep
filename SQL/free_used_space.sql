/*
This script will show used/free space in M by tablespace name
*/

set pagesize 100
spool /home/jsoria/SCRIPTS/SQL/used_free_space.log

select total.name "Tablespace Name",
free_space, (total_space-free_space) used_space, total_space
from (select tablespace_name, sum(bytes/1024/1024) free_space
from sys.dba_free_space
group by tablespace_name) free,
(select b.name, sum(bytes/1024/1024) total_space
from sys.v_$datafile a, sys.v_$tablespace b
where a.ts#=b.ts#
group by b.name)
total
where free.tablespace_name=total.name;


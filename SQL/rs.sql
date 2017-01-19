set head off
set pagesize 0
spool large_tables.sql

select table_name,num_rows, ((num_rows * avg_space)/1024)/1024 "total bytes"
from dba_tables
where tablespace_name='METASERV31_DATA'
order by num_rows DESC;

spool off;
exit

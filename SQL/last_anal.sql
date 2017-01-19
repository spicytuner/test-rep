alter session set nls_date_format='MM/DD/YYYY hh24:mi:ss';
set head off
set pagesize 0
spool anal_this.sql


select table_name, last_analyzed, num_rows
from dba_tables
where owner='SMP42CM'
and num_rows >= 11000
order by last_analyzed DESC;


set head off
set pagesize 0
spool gs1.sql

select table_name from dba_tables
where last_analyzed != '27-JUN-11'
and owner='SMP42CM'
order by last_analyzed;

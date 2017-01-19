set head off
alter session set nls_date_format='MM/DD/YYYY hh24:mi:ss';
select sysdate from dual;
select job, last_date, next_date, failures, broken from dba_jobs;
exit;


select owner||'.'||table_name from dba_tables
where table_name like '%N%T%W%K%';

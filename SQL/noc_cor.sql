set head off
set linesize 500
set delim ,
set pagesize 0
spool noc_cor.csv

select * from noc_cor

spool off;
exit

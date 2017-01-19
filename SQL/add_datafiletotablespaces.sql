spool add_dbf.log

alter tablespace &tablespace
add datafile '&filename'
size &size;

spool off
exit

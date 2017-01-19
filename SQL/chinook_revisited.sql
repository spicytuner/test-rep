set termout off
set feedback off
set echo off
set colsep ,

spool march_ani.csv

select * from qwest_200803
where ani='4068303002';

spool off
exit

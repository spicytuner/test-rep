set head off
set colsep ,
set feedback off
set echo off
set termout off
set linesize 500
spool chinook_by_ani.csv

/*
select * 
from qwest_april
where (authorization_code_full like '%2137'
or authorization_code_full like '%418'
or authorization_code_full like '%2214') 
and (dialedno not like '800%'
or dialedno not like '866%'
or dialedno not like '877%')
and orig_ocn like '%008E'  
order by authorization_code_full ; 
*/
select * from qwest_march
where ani='4068303002';

exit

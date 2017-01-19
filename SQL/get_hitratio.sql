
column xn1 format a50
column xn2 format a50
column xn3 format a50
column xv1 new_value xxv1 noprint
column xv2 new_value xxv2 noprint
column xv3 new_value xxv3 noprint
column d1  format a50
column d2  format a50

prompt HIT RATIO:
prompt
prompt Values Hit Ratio is calculated against:
prompt

select lpad(name,20,' ')||'  =  '||value xn1, value xv1
from   v$sysstat
where  name = 'db block gets'
/

select lpad(name,20,' ')||'  =  '||value xn2, value xv2
from   v$sysstat
where  name = 'consistent gets'
/

select lpad(name,20,' ')||'  =  '||value xn3, value xv3
from   v$sysstat b
where  name = 'physical reads'
/

set pages 60

select 'Logical reads = db block gets + consistent gets ',
        lpad ('Logical Reads = ',24,' ')||to_char(&xxv1+&xxv2) d1
from    dual
/

select 'Hit Ratio = (logical reads - physical reads) / logical reads',
        lpad('Hit Ratio = ',24,' ')||
        round( (((&xxv2+&xxv1) - &xxv3) / (&xxv2+&xxv1))*100,2 )||'%' d2
from    dual
/

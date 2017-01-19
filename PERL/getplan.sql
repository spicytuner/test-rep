explain plan for select sysdate from dual;
select count(*) 
from aradmin.bz_incident
where CATEGORY = 'Video' 
AND STATUS not in ('Cancelled', 'Closed', 'Resolved');

select 
  substr (lpad(' ', level-1) || operation || ' (' || options || ')',1,30 ) "Operation", 
  object_name                                                              "Object"
from 
  plan_table ;

select sysdate from dual;

select count(*) 
from aradmin.bz_incident
where CATEGORY = 'Video' 
AND STATUS not in ('Cancelled', 'Closed', 'Resolved');

select sysdate from dual;

exp masterm@remprd file=cust.dmp tables=masterm.cust rows=y

sqlplus masterm@remdev

truncate table cust;
drop table cust;

exit

imp masterm@remdev file=cust.dmp fromuser=masterm touser=masterm rows=y

sqlplus masterm@remdev

grant select on cust to aradmin;

create public synonym cust for masterm.cust;

exit


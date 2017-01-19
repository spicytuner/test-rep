set echo on
spool bc.log
/*
create table qwest_november as
select *
from CHINOOK_NOVEMBER;

*/ 
truncate table chinook_november;

insert into chinook_november
select * from qwest_november
where dialedno not like '800%'
and (authorization_code_full='          2137'
or authorization_code_full='          2214'
or authorization_code_full='           418'
and orig_ocn not like '008E%')
or (dialedno not like '866%'
and authorization_code_full = '          2137'
or authorization_code_full = '          2214'
or authorization_code_full='           418'
and orig_ocn not like '008E') 
or (dialedno not like '877%'
and authorization_code_full like '          2137'
or authorization_code_full  = '          2214'
or authorization_code_full= '418'
and orig_ocn not like '008E');

--alter table qwest_data rename to qwest_november;

create table chinook_september as
select *
from QWEST_SEPTEMBER
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
and orig_ocn not like '008E');



select distinct authorization_code_full, count(*)
from chinook_march
where 
(authorization_code_full like '%2214'
and orig_ocn like '008E%')
or
(authorization_code_full like '%2137'
and orig_ocn like '008E%')
or 
(authorization_code_full like  '%418'
and orig_ocn like '008E%')
group by authorization_code_full;

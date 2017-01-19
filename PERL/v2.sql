spool v2.log
select count(*) from qwest_march
where authorization_code_full like '%418';

select sum(estimated_charge) from qwest_march
where authorization_code_full like '%418';

select count(*) from chinook_march
where authorization_code_full like '%418';

select sum(estimated_charge) from chinook_march
where authorization_code_full like '%418';

select distinct dialedno
from chinook_march
where authorization_code_full like '%418'
and dialedno like '8%';

select count(*) from qwest_march
where authorization_code_full like '%2214';

select sum(estimated_charge) from qwest_march
where authorization_code_full like '%2214';


select count(*) from chinook_march
where authorization_code_full like '%2214';

select sum(estimated_charge) from chinook_march
where authorization_code_full like '%2214';


select distinct dialedno
from chinook_march
where authorization_code_full like '%2214'
and dialedno like '8%';

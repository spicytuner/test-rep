select authorization_code_full, sum(estimated_charge)
from chinook_april
where
(authorization_code_full like '%2137'
or authorization_code_full like '%2214'
or authorization_code_full like '%418')
group by authorization_code_full;

select authorization_code_full, sum(estimated_charge)
from qwest_april
where
(authorization_code_full like '%2137'
or authorization_code_full like '%2214'
or authorization_code_full like '%418')
group by authorization_code_full;


select * from chinook_bill_april
where chinook_id in (
select chinook_id
from chinook_bill_april
group by chinook_id
having count(*) > 1);

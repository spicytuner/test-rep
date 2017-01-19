select distinct authorization_code_full
from qwest_december;

select authorization_code_full, sum(estimated_charge)
from qwest_november
where authorization_code_full in ('418','2214','2137')
group by authorization_code_full;

select authorization_code_full, sum(estimated_charge)
from qwest_december
where authorization_code_full in ('418','2214','2137')
group by authorization_code_full;

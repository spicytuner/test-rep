select authorization_code_full,sum(call_duration_seconds/60+call_duration_minutes)
from qwest_march
where (authorization_code_full like '%2214')
or (authorization_code_full like '%2137' and ani=4068303002)
or (authorization_code_full like '%418' and ani=4068303002)
group by authorization_code_full;

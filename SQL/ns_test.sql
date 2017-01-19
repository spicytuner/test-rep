select substr(dialedno,1,6) "NPA/NXX", 
sum(a.call_duration_minutes) + (sum(a.call_duration_seconds)/60) "TOTAL MOU", 
nvl(a.term_ocn,null) "OCN", nvl(a.class_type,null) "Band / Tier", 
sum(b."Charge") 
from chinook_march a, chinook_bill_march b 
where a.chinook_id=b.chinook_id 
and a.call_area = 1 
and a.prcmp_id != 1 
group by substr(dialedno,1,6), term_ocn, a.class_type 
union 
select substr(dialedno,1,6) "NPA/NXX", 
sum(a.call_duration_minutes) + (sum(a.call_duration_seconds)/60) "TOTAL MOU", 
nvl(a.term_ocn,null) "OCN", nvl(a.class_type,null) "Band / Tier", 
sum(b."Charge") 
from chinook_march a, chinook_bill_march b, interstate_rate_sheet c 
where a.chinook_id=b.chinook_id 
and a.call_area = 2 
and a.prcmp_id != 1 
and to_number(a.class_type)=c.class_type 
group by substr(dialedno,1,6), term_ocn, a.class_type 
union 
select substr(dialedno,1,6) "NPA/NXX", 
sum(a.call_duration_minutes) + (sum(a.call_duration_seconds)/60) "TOTAL MOU", 
nvl(a.term_ocn,null) "OCN", 'Canada' "Band / Tier", 
sum(b."Charge") 
from chinook_march a, chinook_bill_march b 
where a.chinook_id=b.chinook_id 
and a.call_area in (1,2) 
and a.prcmp_id = 1 
group by substr(dialedno,1,6), term_ocn, 'Canada';

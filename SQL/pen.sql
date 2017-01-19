explain select first_name, count(*) as mullah
from actor
where last_name like '%s%'
group by first_name
having mullah>1;

SELECT
  LAG(first_name, 1) 
    OVER(ORDER BY first_name) as prev,
  first_name, 
  LEAD(first_name, 1) 
    OVER(ORDER BY first_name) as next
FROM actor
ORDER BY first_name

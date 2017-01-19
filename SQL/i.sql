set head off
select a.* 
from pi a, hsd b
where a.parentref=b.parentref
and b.macaddressofcm='001225464eaa';

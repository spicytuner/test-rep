select new_value 
from forever_boost a, vw_cust b
where a.acct_number=b.csg_act
and upper(b.cmmac)=upper('&CMMAC');

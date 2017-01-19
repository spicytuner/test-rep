select a.csg_act 
from vw_cust a
where a.cmmac='001311F42D71';

select new_value 
from forever_boost a, vw_cust b
where a.acct_number=b.csg_act
and b.cmmac='001311F42D71';



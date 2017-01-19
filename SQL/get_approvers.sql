select distinct b.first_name, b.last_name
from aradmin.rcmm_approvers a, aradmin.shr_people b
where a.people_entry_id=b.entry_id;

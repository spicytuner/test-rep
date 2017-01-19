select count(*) from bz_incident_dat
where create_date >= '06/01/2008'
and create_date < '07/01/2008'
and account_number is not null;

select count(*) 
from bz_incident_dat a, aradmin.bz_incident@remprd b
where a.create_date >= '06/01/2008'
and a.create_date < '07/01/2008'
and a.incident_id=b.incident_id
and b.work_order_id is not null;

set pagesize 0
set head off

select incident_id, work_order_id, job_number, csg_resolution_code, csg_resolution_description
from aradmin.bz_incident
where NEW_TIME(to_date('01/01/1970 00:00:00')+ create_date/86400,'GMT','MST') >= trunc(sysdate-7)
and work_order_id is not null
and job_number is not null
and csg_resolution_code is not null
and csg_resolution_description is not null
and status in ('Resolved','Closed');

update aradmin.bz_incident
set status='Closed'
where incident_id='INC000003489219';

commit;

update aradmin.bz_incident
set status='Closed',
resolution_description='Notification not needed for this event',resolution_date='1304438110',
resolution_code='Notification not needed for this event'
where parent_id='INC000003489219';

commit;

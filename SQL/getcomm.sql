set colsep ,
set head off
set pagesize 0
set linesize 2000
set termout off
spool comm.lst

select incident_id,'^'||account_number,customer_first_name,customer_last_name,
contact_phone,market,city,status,priority,create_date,resolution_date,category,type,item,
submitter,assigned_to,last_modified_by,description,resolution_description
from bz_incident_dat
where create_date >= '04/01/2008'
and create_date <= '05/01/2008'
and category = 'Commercial Voice'
order by category DESC;

spool off
exit

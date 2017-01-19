drop view br_report;

create table br_report
as 
select market, city, category, type, create_date, resolution_date, incident_id
from bz_incident_dat
where create_date >= '11/01/2007'
and create_date < '12/01/2007';

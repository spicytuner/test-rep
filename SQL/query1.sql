set head off
set pagesize 0
set linesize 150
set colsep ','
spool tbdsa.csv

select trunc(create_date),count(*)
from bz_incident_dat
where category in ('CE Res Email','Commercial Non-Voice','Commercial Voice','HSI_Connection',
'HSI_Email','Video','Voice')
and type in ('BDP','BOL','Cable','Cable Card','Cable Issues','Cable Modem','Cable Modem',
'Cable Wiring','Call Completion','Configuration','Connection','Customer Equipment','DCT',
'Dropped Call','DVR','DVR-Motorola','DVR-PACE','Email TS','HD','Home Network','HSI Services',
'HSI TS','Internet Issues','IP Conflict','Mail Client','MTA','NIC','No Dial Tone',
'Operating System','Phone Issues','PPV','Reception','Remote','Remote Issues','Security Manager',
'Simulcast','Speed','USB','Video TS','VoD','Voice Quality','Webmail')
and new_time(create_date,'GMT','MST') >= '12/01/2007'
group by trunc(create_date);

spool off;
exit;

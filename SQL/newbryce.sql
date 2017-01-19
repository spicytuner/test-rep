set head off
set pagesize 0
set linesize 150
col market format a2
col city format a20
col category a20
col type a20
set colsep ','
spool test.csv

select nvl(market,'Unknown')||','||nvl(city,'Unknown')||','||category||','||type||','||count(*)
from bz_incident_dat
where category in ('CE Res Email','Commercial Voice','Commercial Non-Voice','HSI_Connection',
'HSI_Email','Video','Voice')
and type in ('Abuse','DAC','BDP','BOL','Connection','Cable','DVR','Cable Issues','Email TS','HSI TS','Video TS',
'Cable Modem','Cable Wiring','Hardware','Home Network','HSI Services','IP Conflict','NIC',
'Operating System','Security Manager','USB','Mail Client','Webmail','Cable Card',
'Customer Equipment','DCT','DVR-Motorola','DVR-PACE','HD','Outage','PPV','Reception','Remote','VoD',
'Call Completion','MTA','No Dial Tone','Voice Quality','Internet Issues',
'Phone Issues','Remote Issues','Simulcast','Speed')
and item != 'Order'
and new_time(create_date,'GMT','MST') >= '01/12/2008'
and new_time(create_date,'GMT','MST') < '01/13/2008'
group by market, city, category, type;


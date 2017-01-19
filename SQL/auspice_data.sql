SET ECHO OFF
SET NEWPAGE 0
SET PAGESIZE 2000
SET SPACE 0
SET PAGESIZE 0
SET FEEDBACK OFF
SET HEADING OFF
SET TRIMSPOOL ON
SET TERMOUT OFF
set colsep ,

spool /home/jsoria/SCRIPTS/DATA/missoula.csv

select cmmac, node, devicetype, '','', '','',mtamac,
firstname, lastname, '',street1, street2, city, state, 
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'mls%'
order by b.prov;

spool off


spool /home/jsoria/SCRIPTS/DATA/cheyenne.csv

select cmmac, node, devicetype, '','', '','',mtamac,
firstname, lastname, '',street1, street2, city, state, 
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'chywy%'
order by b.prov;

spool off;

spool /home/jsoria/SCRIPTS/DATA/billings.csv

select cmmac, node, devicetype, '','', '','',mtamac,
firstname, lastname, '',street1, street2, city, state, 
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'bl%'
order by b.prov;

spool off

spool /home/jsoria/SCRIPTS/DATA/grandjunction.csv

select cmmac, node, devicetype, '','', '','',mtamac,
firstname, lastname, '',street1, street2, city, state, 
zip, accountnumber, '', phone, '', cmsfqdn, a.cmts, '', b.prov
from cust a, cmts_to_prov b
where a.cmts=b.cmts(+)
and prov like 'gdj%'
order by b.prov;

spool off



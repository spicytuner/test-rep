set pages 0
set lines 200
spool  chronic.txt

--Ticket detail for accounts that have multiple servie affecting tickets in the last 30 days
select a.gl, b.account_number, b.incident_id, b.create_date, b.category, b.type, b.item, 
b.submitter, b.market, b.city, b.node_name, b.status
from customer_info@remprd a, bz_incident_dat b
where a.accountnumber=b.account_number
and b.create_date >= trunc(sysdate-30)
and b.service_affecting=1
and b.account_number in
               --Account numbers that have multiple service affecting tickets within the last 30 days
               (select account_number 
               from bz_incident_dat
               where create_date >= trunc(sysdate-30)
               and service_affecting=1
               and account_number in
                   --Account numbers that have a service affecting ticket created against them in the last 7 days
                       (select account_number
                       from bz_incident_dat
                       where create_date >= trunc(sysdate-7)
                       and service_affecting=1
                       and account_number like '8313%')
               group by account_number
               having count(*) >1)
order by b.account_number;

spool off
exit

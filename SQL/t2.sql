set head off
set linesize 200
set pagesize 0

select a.customeraccount, to_date('01/01/1970 hh24:mi:ss','MM/DD/YYYY hh24:mi:ss')+b.strike_registered/86400, 
null "STRIKE NUMBER", 
c.mediatitle, c.complainantname, a.firstname, a.lastname, a.addressline1, 
a.addressline2, a.city, a.state, a.zipcode, a.phonenumber, a.status, 
null "STRIKESCRIPT"
from aradmin.dmca_violationrecord a, aradmin.dmca_violationstrikes b, aradmin.dmca_violationlog c
where b.ip_lookup_id=c.iplookupid
and b.customer_account = a.customeraccount;

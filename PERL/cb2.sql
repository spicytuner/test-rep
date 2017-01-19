set colsep ^
set pagesize 0
spool cb2.log

--(1)Bill all directory assistance calls
--DIR ASST calls are determined by prcmp_id=3
--All calls are rated at $.75 each regardless of time.

truncate table chinook_bill_september;
drop table chinook_bill_september;
create table chinook_bill_september as
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
to_number(.75) "Charge"
from chinook_september a
where prcmp_id=3;

--(2)Bill all international (including canada) and intra-lata calls placed outside of montana
--rate increase of 35% based upon unrounded_price column from Qwest
--international calls are determined by state_called=IT or terminating_lata='0888'
insert into chinook_bill_september
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(to_number(1.35) * to_number(substr(unrounded_price,1,4)||'.'||substr(unrounded_price,5,6)),2) "Charge"
from chinook_september
where prcmp_id !=3
and (state_called='IT'
or terminating_lata='0888');

--(3)Bill Intra Lata Calls originating from MT
insert into chinook_bill_september
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) "Charge"
from chinook_september a, intrastate_billing_rates b
where class_type=1
and intra_lata_ind=1
and state_called='MT'
and prcmp_id != 3
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class1
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class2),2) "Charge"
from chinook_september a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=2
and intra_lata_ind=1
and state_called='MT'
and prcmp_id != 3
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class2
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class3),2) "Charge"
from chinook_september a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=3
and intra_lata_ind=1
and state_called='MT'
and prcmp_id != 3
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds,b.class3
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class4),2) "Charge"
from chinook_september a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=4
and intra_lata_ind=1
and state_called='MT'
and prcmp_id != 3
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class4
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class5),2) "Charge"
from chinook_september a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=5
and intra_lata_ind=1
and state_called='MT'
and prcmp_id != 3
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class5
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class6),2) "Charge"
from chinook_september a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=6
and intra_lata_ind=1
and state_called='MT'
and prcmp_id != 3
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6;

--(4)Bill long distance calls based upon interstate_billing_ratest association

insert into chinook_bill_september
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) "Charge"
from chinook_september a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=1
and intra_lata_ind=0
and prcmp_id != 3
and state_called != 'IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class1
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class2),2) "Charge"
from chinook_september a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=2
and intra_lata_ind=0
and prcmp_id != 3
and state_called !='IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class2
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class3),2) "Charge"
from chinook_september a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=3
and intra_lata_ind=0
and prcmp_id != 3
and state_called !='IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds,b.class3
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class4),2) "Charge"
from chinook_september a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=4
and intra_lata_ind=0
and prcmp_id != 3
and state_called !='IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class4
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class5),2) "Charge"
from chinook_september a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=5
and intra_lata_ind=0
and prcmp_id != 3
and state_called !='IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class5
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class6),2) "Charge"
from chinook_september a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=6
and intra_lata_ind=0
and prcmp_id != 3
and state_called !='IT'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6;

--(5)bill all other calls that are not on the interlata rate sheet
insert into chinook_bill_september
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * .025,2) "Charge"
from chinook_september a
where intra_lata_ind=0
and prcmp_id != 3
and state_called not in ('IT','MT')
and terminating_lata!='0888'
and a.terminating_lata not in (select distinct lata from interstate_billing_rates)
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds;

--(6)Bill all intralata calls outside montana like long distance calls
--intralata=1 state != 'MT'
--prcmp_id != 3

insert into chinook_bill_september
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs", 
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) "Charge"
from chinook_september, interstate_billing_rates b
where intra_lata_ind=1 
and state_called not in ('IT','MT')
and prcmp_id != 3
and class_type=1
and terminating_lata=b.lata
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class1
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs", 
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class2),2) "Charge"
from chinook_september, interstate_billing_rates b
where intra_lata_ind=1 
and state_called not in ('IT', 'MT')
and prcmp_id != 3
and class_type=2
and terminating_lata=b.lata
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class2
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs", 
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class3),2) "Charge"
from chinook_september, interstate_billing_rates b
where intra_lata_ind=1 
and state_called not in ('IT', 'MT')
and prcmp_id != 3
and class_type=3
and terminating_lata=b.lata
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class3
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs", 
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class4),2) "Charge"
from chinook_september, interstate_billing_rates b
where intra_lata_ind=1 
and state_called not in ('IT', 'MT')
and prcmp_id != 3
and class_type=4
and terminating_lata=b.lata
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class4
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs", 
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class5),2) "Charge"
from chinook_september, interstate_billing_rates b
where intra_lata_ind=1 
and state_called not in ('IT', 'MT')
and prcmp_id != 3
and class_type=5
and terminating_lata=b.lata
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class5
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs", 
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class6),2) "Charge"
from chinook_september, interstate_billing_rates b
where intra_lata_ind=1 
and state_called not in ('IT', 'MT')
and prcmp_id != 3
and class_type=6
and terminating_lata=b.lata
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6;

select count(distinct chinook_id) from chinook_bill_september;
select count(*) from chinook_bill_september;

spool off
exit

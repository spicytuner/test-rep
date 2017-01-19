--Bill all directory assistance calls
--All calls are rated at $.75 each regardless of time.
select * from (
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
to_number(.75) "Charge"
from chinook_august a
where prcmp_id=3
union 
--Total Calls: 193
--144.75


--Bill all international (including canada) and intra-lata calls placed outside of montana
--rate increase of 35% based upon unrounded_price column from Qwest
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(to_number(1.35) * to_number(substr(unrounded_price,1,4)||'.'||substr(unrounded_price,5,6)),2) "Charge"
from chinook_august
where state_called='IT'
or terminating_lata='0888'
or (intra_lata_ind=1 and state_called != 'MT')
and city_called != 'DIR ASST'

union
--Total Calls: 246962
--7768.69 without canada/intra_lata calls
--8362.66 with canada without intra_lata calls
--28485.52

--Bill Intra Lata Calls originating from MT


select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) "Charge"
from chinook_august a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=1
and intra_lata_ind=1
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
from chinook_august a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=2
and intra_lata_ind=1
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
from chinook_august a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=3
and intra_lata_ind=1
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
from chinook_august a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=4
and intra_lata_ind=1
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
from chinook_august a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=5
and intra_lata_ind=1
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
from chinook_august a, intrastate_billing_rates b
where a.state_called=b.lata
and class_type=6
and intra_lata_ind=1
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6

union

--Total Calls: 10572
--1522.61

--Bill long distance calls based upon interstate_billing_ratest association

select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class0),2) "Charge"
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=0
and intra_lata_ind=0
and city_called != 'DIR ASST'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class0
union
select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * to_number(b.class1),2) "Charge"
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=1
and intra_lata_ind=0
and city_called != 'DIR ASST'
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
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=2
and intra_lata_ind=0
and city_called != 'DIR ASST'
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
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=3
and intra_lata_ind=0
and city_called != 'DIR ASST'
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
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=4
and intra_lata_ind=0
and city_called != 'DIR ASST'
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
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=5
and intra_lata_ind=0
and city_called != 'DIR ASST'
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
from chinook_august a, interstate_billing_rates b
where a.terminating_lata=b.lata
and class_type=6
and intra_lata_ind=0
and city_called != 'DIR ASST'
group by chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds, b.class6
union
--Total Interstate Calls:    346498
--19535.47


--Total Dir Asst Calls:         193  
--Total International Calls: 246962
--Total Interstate Calls:    346498
--Total Intralata Calls:      10572 


--Total Calls:  604968
--Missing Calls:  413
--Total Charges: 49740.26


--select chinook_id, count(*) from chinook_august
--select chinook_id, 605381-604968 from dual


select chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,3,3)*60)+call_duration_seconds)/60) * .025,2) "Charge"
from chinook_august a
where intra_lata_ind = 0
and prcmp_id != 3
and state_called != 'IT'
and terminating_lata!='0888'
and state_called != state_calling
and a.terminating_lata not in (select distinct lata from interstate_billing_rates)
group by chinook_id, chinook_id, substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,3,3) ||':'|| call_duration_seconds
)
order by "Date", "Time"





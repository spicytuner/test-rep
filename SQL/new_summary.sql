set pagesize 0
set linesize 100
set space 0
set echo off
set termout off
set feedback off
set trim on 
set wrap off
set colsep ,

col "Call Duration" format a7

spool new_detail_april.txt

select 'Dialed Number,Date,Orig Time,Term Time,Call Duration,OCN,CPM,Band/Tier,Amount Billed' from dual;

select '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'||substr(a.dialedno,7,4) "Dialed Number",
orig_dt "Date",
substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2) "Orig Time",
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2) "Term Time",
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds "Call Duration",
nvl(a.TERM_OCN,null) "OCN", c.cpm "CPM",nvl(a.class_type,null) "Band/Tier",sum(b."Charge") "Amount Billed"
from chinook_march a, chinook_bill_march b, intrastate_rate_sheet c
where a.chinook_id=b.chinook_id
and a.call_area = 1
and a.prcmp_id != 1
and to_number(a.class_type)=c.class_type
group by '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4),
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds, a.TERM_OCN,
a.class_type,c.cpm
union
select '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'||
substr(a.dialedno,7,4) "Dialed Number",
orig_dt "Date",
substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2) "Orig Time",
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2) "Term Time",
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds "Call Duration",
nvl(a.TERM_OCN,null) "OCN", c.cpm "CPM",
nvl(a.class_type,null) "Band/Tier",
sum(b."Charge") "Amount Billed"
from chinook_march a, chinook_bill_march b, interstate_rate_sheet c
where a.chinook_id=b.chinook_id
and a.call_area = 2
and a.prcmp_id != 1
and to_number(a.class_type)=c.class_type
group by '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4),
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds, a.TERM_OCN, a.class_type,
c.cpm
union
select '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'||substr(a.dialedno,7,4) "Dialed Number",
orig_dt "Date",
substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2) "Orig Time",
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2) "Term Time",
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds "Call Duration",
nvl(a.TERM_OCN,null) "OCN", to_number('.75') "CPM",'DA' "Band/Tier",to_number('.75') "Amount Billed"
from chinook_march a, chinook_bill_march b
where a.chinook_id=b.chinook_id
and a.call_area = 4
group by '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4),
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds, a.TERM_OCN, '.75','DA','.75'
union
select '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'||substr(a.dialedno,7,4) "Dialed Number",
orig_dt "Date",
substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2) "Orig Time",
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2) "Term Time",
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds "Call Duration",
null "OCN",
round(to_number(1.35)*to_number(substr(a.rate_per_minute,1,4)||'.'||substr(a.rate_per_minute,5,6)),2)/100 "CPM",
'Canada' "Band/Tier",
round(to_number(1.35) * to_number(substr(a.unrounded_price,1,4)||'.'||substr(a.unrounded_price,5,6)),2) "Amount Billed"
from chinook_march a, chinook_bill_march b
where a.chinook_id=b.chinook_id
and a.call_area in (1,2)
and a.prcmp_id = 1
group by '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4),
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds,
a.TERM_OCN,round(to_number(1.35)*to_number(substr(a.rate_per_minute,1,4)||'.'||
substr(a.rate_per_minute,5,6)),2),
round(to_number(1.35) * to_number(substr(a.unrounded_price,1,4)||'.'||
substr(a.unrounded_price,5,6)),2)
union
select a.dialedno "Dialed Number",orig_dt "Date",
substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2) "Orig Time",
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2) "Term Time",
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds "Call Duration",
null "OCN",
round(to_number(1.35)*to_number(substr(a.rate_per_minute,1,4)||'.'||substr(a.rate_per_minute,5,6)),2)/100 "CPM",
'International' "Band/Tier",
round(to_number(1.35) * to_number(substr(a.unrounded_price,1,4)||'.'||substr(a.unrounded_price,5,6)),2) "Amount Billed"
from chinook_march a, chinook_bill_march b
where a.chinook_id=b.chinook_id
and (a.call_area = 3
or a.call_area=2 and a.prcmp_id=5)
group by a.dialedno,
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds,
round(to_number(1.35)*to_number(substr(a.rate_per_minute,1,4)||'.'||
substr(a.rate_per_minute,5,6)),2),
round(to_number(1.35) * to_number(substr(a.unrounded_price,1,4)||'.'||
substr(a.unrounded_price,5,6)),2);

spool off

set linesize 80
col "NPA/NXX" format 999999
col "TOTAL MOU" format a10
col "OCN" format a10
col "Band / Tier" format a12


spool new_summary_april.txt

select 'Total Billed March-April 23:' from dual; 
select sum("Charge") charges from chinook_bill_march;

select 'NPA/NXX,Total MOU,OCN,Band/Tier' from dual;

select substr(dialedno,1,6) "NPA/NXX", 
replace((sum(a.call_duration_minutes) + nvl(substr(sum(a.call_duration_seconds)/60,1,instr(sum(a.call_duration_seconds)/60,'.',1,1) -1),0)) ||':'||
substr(sum(a.call_duration_seconds)/60, instr(sum(a.call_duration_seconds)/60,'.',1,1)+1)*6,':6',':06') "TOTAL MOU", 
nvl(a.term_ocn,null) "OCN", nvl(a.class_type,null) "Band / Tier"
from chinook_march a, chinook_bill_march b
where a.chinook_id=b.chinook_id
and a.call_area in (1,2)
and a.prcmp_id != 1
group by substr(dialedno,1,6), term_ocn, a.class_type
union
select substr(dialedno,1,6) "NPA/NXX", 
replace((sum(a.call_duration_minutes) + nvl(substr(sum(a.call_duration_seconds)/60,1,instr(sum(a.call_duration_seconds)/60,'.',1,1) -1),0)) ||':'||
substr(sum(a.call_duration_seconds)/60, instr(sum(a.call_duration_seconds)/60,'.',1,1)+1)*6,':6',':06') "TOTAL MOU", 
nvl(a.term_ocn,null) "OCN", 'Canada' "Band / Tier"
from chinook_march a, chinook_bill_march b
where a.chinook_id=b.chinook_id
and a.call_area in (1,2)
and a.prcmp_id = 1
group by substr(dialedno,1,6), term_ocn, 'Canada';

spool off
exit

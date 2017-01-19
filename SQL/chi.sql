set linesize 1000
set pagesize 0
set colsep ,
set feedback off
set termout off
set echo off

spool chinook_bill_march.csv
select * from chinook_bill_march
order by "Date","Time";
spool off

spool chinook_call_detail_report_march.csv
select to_number(a.chinook_id), '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4) "Dialed Number", 
orig_dt "Date",
substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2) "Orig Time",
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2) "Term Time",
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds "Call Duration", 
nvl(a.TERM_OCN,null) "OCN", c.cpm "CPM", 
nvl(a.class_type,null) "Band/Tier",
sum(b."Charge") "Amount Billed"
from chinook_march a, chinook_bill_march b, intrastate_rate_sheet c
where a.chinook_id=b.chinook_id
and a.call_area = 1
and to_number(a.class_type)=c.class_type
group by to_number(a.chinook_id), '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4), 
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds, a.TERM_OCN, a.class_type, c.cpm
union
select to_number(a.chinook_id), '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4) "Dialed Number", 
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
and to_number(a.class_type)=c.class_type
group by to_number(a.chinook_id), '('|| substr(a.dialedno,1,3) || ') ' || substr(a.dialedno,4,3)||'-'|| substr(a.dialedno,7,4), 
orig_dt, substr(a.orig_time,1,2)||':'||substr(a.orig_time,3,2)||':'||substr(a.orig_time,5,2),
substr(a.discn_time,1,2)||':'||substr(a.discn_time,3,2)||':'||substr(a.discn_time,5,2),
to_number(a.call_duration_minutes) ||':'||a.call_duration_seconds, a.TERM_OCN, a.class_type, c.cpm;

spool off

spool chinook_summary_report_march.csv

select term_pricing_npa || term_pricing_nxx "NPA/NXX", 
(sum(a.call_duration_minutes) + nvl(substr(sum(a.call_duration_seconds)/60,1,instr(sum(a.call_duration_seconds)/60,'.',1,1) -1),0)) ||':'||
substr(sum(a.call_duration_seconds)/60, instr(sum(a.call_duration_seconds)/60,'.',1,1)+1)*6 "TOTAL MOU", 
nvl(a.term_ocn,null) "OCN", nvl(a.class_type,null) "Band / Tier"
from chinook_march a, chinook_bill_march b
where a.chinook_id=b.chinook_id
and a.call_area in (1,2)
group by term_pricing_npa || term_pricing_nxx, term_ocn, a.class_type
order by term_pricing_npa || term_pricing_nxx;

spool off
spool estimated_charges_march.lst
select authorization_code_full, sum(estimated_charge) 
from chinook_march
where authorization_code_full like '%  2137'
or authorization_code_full like       '%  2214'
or authorization_code_full like        '%  418'
group by authorization_code_full

exit;

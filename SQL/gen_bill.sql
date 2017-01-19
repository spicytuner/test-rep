select sum("Charge")
from (
select substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4)  "Date",
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2)  "Time",
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4)  "Called Number",
city_called ||', '|| state_called "Location", substr(call_duration_minutes,4,2) ||':'|| call_duration_seconds "Mins-Secs",
round(sum(((substr(call_duration_minutes,4,2)*60)+call_duration_seconds/6) * b.class1),2) "Charge"
from QWEST_DATA a, interstate_billing_rates b
where a.originating_lata=b.lata
GROUP BY substr(orig_dt,5,2) ||'/'||  substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4),
substr(orig_time,1,2) ||':'|| substr(orig_time,3,2) ||':'|| substr(orig_time,5,2),
substr(calledno,1,3) ||'-'|| substr(calledno,4,3) ||'-'|| substr(calledno,7,4),
city_called ||', '|| state_called, substr(call_duration_minutes,4,2) ||':'|| call_duration_seconds
ORDER BY substr(orig_dt,5,2) ||'/'|| substr(orig_dt,7,2) ||'/'|| substr(orig_dt,1,4), 
substr(orig_time,1,2) || ':' || substr(orig_time,3,2) || ':' || substr(orig_time,5,2)
);

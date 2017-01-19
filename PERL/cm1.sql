set pagesize 0
select intra_lata_ind, calledno, city_called, state_called, terminating_lata,
call_duration_minutes, call_duration_seconds from chinook_september
where chinook_id not in (select chinook_id from chinook_bill_september);

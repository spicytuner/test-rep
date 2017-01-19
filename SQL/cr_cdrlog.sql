drop table cdr_log;

create table cdr_log
(
call_type			varchar2(10),
cdr_date			varchar2(20),
calling_number			varchar2(20),
called_number			varchar2(20),
length_of_call			varchar2(20),
call_time			varchar2(20),
carrier_connect_date		varchar2(20),
carrier_connect_time		varchar2(20),
carrier_elapse_time		varchar2(20),
trunk_group_number		varchar2(50)
);

exit;

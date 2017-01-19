create table call_logs
(
Caller_DN			varchar2(20),
Called_DN			varchar2(20),
Call_Initiated			varchar2(20),
Call_Connected			varchar2(20),
Call_End			varchar2(20),
Inbound_Media_Channel		varchar2(20),
Inbound_Circuit_ID		varchar2(20),
Outbound_Media_Channel		varchar2(20),
Outbound_Circuit_ID		varchar2(20),
Release_Cause			varchar2(20),
ANI_Digits			varchar2(20),
Redirect_Info			varchar2(20),
Call_Path			varchar2(20)
) tablespace users;

create public synonym call_logs for masterm.call_logs;

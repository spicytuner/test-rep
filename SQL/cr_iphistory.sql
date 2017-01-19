create table ip_history
(account_number	varchar2(20),
cm_mac		varchar2(20),
cpe_mac		varchar2(20),
ipaddress	varchar2(20),
starttime	date,
endtime		date,
lastupdate	date) tablespace users;

create table validation
(cmts_ip	varchar2(20),
cmts_ts		date) tablespace users;

create public synonym ip_history for masterm.ip_history;
create public synonym validation for masterm.validation;

grant select on ip_history to public;
grant select on validation to public;

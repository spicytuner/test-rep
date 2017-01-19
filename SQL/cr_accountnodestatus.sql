create table account_node_status
(accountnumber	varchar2(20),
node	varchar2(8),
last_modified	date,
status	varchar2(10)) tablespace users;

grant all on account_node_status to scripts;
create public synonym account_node_status for masterm.account_node_status;


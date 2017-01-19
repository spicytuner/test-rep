truncate table chinook_lata_ocn_lookup;
drop table chinook_lata_ocn_lookup;

create table chinook_lata_ocn_lookup
(terminating_lata	varchar2(4),
term_ocn	varchar2(4)) tablespace users;

grant select on chinook_lata_ocn_lookup to public;
drop public synonym chinook_lata_ocn_lookup
create public synonym chinook_lata_ocn_lookup for masterm.chinook_lata_ocn_lookup;

@ins.sql

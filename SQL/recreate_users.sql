set serveroutput on

spool create_user_account.sql

declare
curr varchar2(30):= ?TEST_USER?;
v_ext varchar2(3);
begin
for user in(select * from dba_users where username = curr)
loop
dbms_output.put_line(?create tablespace ?||user.default_tablespace);
for dat_file in(select * from dba_data_files where
tablespace_name=user.default_tablespace)
loop
if dat_file.autoextensible=?YES?
then
v_ext:=?ON?;
else
v_ext:=?OFF?;
end if;
dbms_output.put_line(?datafile ?||??||dat_file.file_name||??||? size
?||floor(dat_file.bytes/1024/1024)||?m');
dbms_output.put_line(?autoextend ?||v_ext);
dbms_output.put_line(?maxsize ?||floor(dat_file.maxbytes/1024/1024)||?m');
end loop;
dbms_output.put_line(?/');
dbms_output.put_line(?create user ?||user.username||? identified by
?||user.username||?;');
dbms_output.put_line(?alter user ?||user.username||? default tablespace
?||user.default_tablespace||?;');
dbms_output.put_line(?alter user ?||user.username||? temporary tablespace
?||user.temporary_tablespace||?;');
dbms_output.put_line(?alter user ?||user.username||? profile
?||user.profile||?;');
if user.account_status<>?OPEN?
then
dbms_output.put_line(?alter user ?||user.username||? account lock;?);
end if;
end loop;
for role in(select * from dba_role_privs where grantee=curr)
loop
if role.admin_option = ?YES?
then
dbms_output.put_line(?grant ?||role.granted_role||? to ?||role.grantee||? with
admin option?||?;');
else
dbms_output.put_line(?grant ?||role.granted_role||? to ?||role.grantee||?;');
end if;
end loop;
for sys_priv in(select * from dba_sys_privs where grantee=curr)
loop
if sys_priv.admin_option = ?YES?
then
dbms_output.put_line(?grant ?||sys_priv.privilege||? to ?||sys_priv.grantee||?
with admin option?||?;');
else
dbms_output.put_line(?grant ?||sys_priv.privilege||? to
?||sys_priv.grantee||?;');
end if;
end loop;
for tab_priv in(select * from dba_tab_privs where grantee=curr)
loop
if tab_priv.grantable = ?YES?
then
dbms_output.put_line(?grant ?||tab_priv.privilege||? on
?||tab_priv.owner||?.'||tab_priv.table_name||? to ?||tab_priv.grantee||? with
grant option;?);
else
dbms_output.put_line(?grant ?||tab_priv.privilege||? on
?||tab_priv.owner||?.'||tab_priv.table_name||? to ?||tab_priv.grantee||?;');
end if;
end loop;
end;
/
spool off

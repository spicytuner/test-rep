create or replace trigger <trigger_name>
before insert on <table_name>
for each row
begin
if :new.<column_name> is null
then
select <trigger_name>.nextval into :new.<column_name> from  dual;
end if;
end <trigger_name>;
/

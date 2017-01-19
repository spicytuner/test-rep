create or replace procedure
joe_md_return as
begin
variable v varchar2(2000);
variable j varchar2(2000);

select exec :v := dbms_obfuscation_toolkit.md5 -
(input_string=> 'b4db33k3r') in j;

dbms_output.put_line(j);

end;
/

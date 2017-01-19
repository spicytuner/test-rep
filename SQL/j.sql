set serveroutput on;

declare
rtn varchar2(2000);
a   varchar2(2000);
begin
   rtn := dbms_obfuscation_toolkit.md5 (input_string=> 'test');
   dbms_output.put_line(rtn);

   select rawtohex(rtn) into a from dual;
   dbms_output.put_line(a);

end;
/

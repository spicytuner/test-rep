declare
v raw;
a varchar2(8);
begin
exec :v := dbms_obfuscation_toolkit.md5 -
(input_string=> 'b4db33k3r')

   a := rawtohex(v);
   dbms_output.put_line(a);
   select rawtohex(:v) into a from dual;
   dbms_output.put_line(a);
end;


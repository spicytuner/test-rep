rem
rem This script reports parameters affecting the SGA 
rem and stats on effectiveness. 
rem 
rem    The pin hit rate should be high (close to 1) 
rem  
rem Author: Joe Soria jsoria@jatocom.com
rem Usage: @/export/home/jsoria/ORACLE/SCRIPTS/show_sga.sql;

SET ECHO OFF; 
spool /home/jsoria/SCRIPTS/SQL/show_sga.log;

ttitle cen 'Current SGA Parameters'  - 
right 'Page:' format 999 sql.pno skip skip 
set feedback off;
 
 
btitle off;
column nline newline;

set pagesize 54;
set linesize 78;
set heading off;
set embedded off;
set verify off;

accept report_comment char prompt 'Enter a comment to identify system: ' 
select 'Date -  '||to_char(sysdate,'Day Ddth Month YYYY     HH24:MI:SS'), 
        'At            -  '||'&&report_comment' nline, 
        'Username      -  '||USER  nline 
from sys.dual; 
 
prompt 
set embedded on 
set heading on 
 
 
set feedback 6 
column name     format a36      heading 'Parameter Name' wrap 
column val      format a36      heading 'Value' wrap  
 
select name 
,lpad(decode(type,1,'Boolean',2,'Character',3,'Integer',4,'File',null),9) 
 ||' '||value val 
from   v$parameter 
order by 1; 
set embedded off 
set newpage 2 pagesize 16 lines 78 
ttitle cen 'Current SGA Storage Summary' - 
right 'Page:' format 999 sql.pno skip skip 
set newpage 2 pagesize 16  
column name     format a20      heading 'SGA Segment' 
column value    format 999,999,999       heading 'Size|(Bytes)' 
column kbval    format 999,999,999.99 heading 'Size|(Kb)' 
break on report 
compute sum of value kbval on report 
set newpage 0 
 
select name 
      ,value 
      ,round(value/1024,1) kbval 
from   v$sga;
 
ttitle cen 'Current SGA Library Summary'  
set newpage 3 
set pagesize 60 
column library format A15 heading 'Library|Name' 
column gets format 999,999,999,999 heading 'Gets' 
column gethitratio format 999.99 heading 'Get Hit|Ratio' 
column pins format 999,999,999,999 heading 'Pins' 
column pinhitratio format 999.99 heading 'Pin Hit|Ratio' 
column reloads format 999,999,999 heading 'Reloads' 
column invalidations format 99,999,999 heading 'Invalid' 
select initcap(namespace) library, 
       gets, 
       gethitratio, 
       pins, 
       pinhitratio, 
       reloads, invalidations 
  from v$librarycache;

prompt 
prompt The pin hit rate should be high (close to 1) 
prompt 
prompt End of Report 
spool off; 
set termout off; 
clear break column sql 
ttitle off 
btitle off 
set newpage 0 pagesize 56 lines 78 
set termout on feedback 6 

exit

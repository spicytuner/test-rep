set pagesize 0
set head off
set echo off
set linesize 350
set feedback off
set termout off
col NODE format a7
col CM_MAC_ADDRESS format a17
set colsep ' ZZZZ '
spool william.txt

select distinct  substr(CM_MAC_ADDRESS,0,17),substr(NODE,0,12),substr(first_name,0,30),substr(LAST_NAME,0,30),substr(ADDRESS_LINE_1,0,30),substr(ADDRESS_LINE_2,0,30),substr(CITY,0,25),substr(STATE,0,5),substr(ZIP_CODE,0,12),substr(TELEPHONE_NUM,0,12),substr(ACCOUNT_NUM,0,30)  from auspice_subscriber_inventory;

spool off
exit;

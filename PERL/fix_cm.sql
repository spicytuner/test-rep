set head off
set linesize 100
set pagesize 0
set termout off
set echo off
set feedback off
spool fix_now.sql

select 'update cm set node_id='''||b.node_id||''' where cm_mac='''||b.cm_mac||''';'
        from cm a, live_cm b
        where a.cm_mac=b.cm_mac
        and a.node_id != b.node_id;
spool off
exit


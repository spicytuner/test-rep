set head off
set linesize 100
set pagesize 0
set termout off
set echo off
set feedback off
spool fix_node_now.sql

select 'update modem set node='''||b.node||''' where cm_mac='''||a.cm_mac||''';'
        from verify_node a, account_node_status b
        where a.account=b.accountnumber
        and a.node != b.node;
spool off
exit


variable v_jobnum number
begin
dbms_job.submit(:v_jobnum, 'exec dbms_stats.gather_schema_stats', sysdate+.05, 'sysdate + 600/(24*60*60)');
end;
/


SET SERVEROUTPUT ON
DECLARE
  l_job  NUMBER;
BEGIN

  DBMS_JOB.submit(l_job,
                  'BEGIN DBMS_STATS.gather_schema_stats(''MASTERM''); END;',
                  SYSDATE,
                  'SYSDATE + .010');
  COMMIT;
  DBMS_OUTPUT.put_line('Job: ' || l_job);
END;
/

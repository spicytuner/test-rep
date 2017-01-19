select trunc(add_months(sysdate,-1),'MM') from dual;

select last_day(trunc(add_months(sysdate,-1),'MM')) from dual;

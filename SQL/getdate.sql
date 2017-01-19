select to_date(trunc(sysdate-1),'DDMONYYYY'), to_date(trunc(sysdate-1),'dd-Mon-yyyy'), 
to_date(trunc(sysdate-2),'dd-Mon-yyyy')
from dual;

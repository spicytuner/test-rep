select distinct s.EXTERNAL_KEY 
from smp42cm.sub s 
where s.SUB_STATUS_ID=7 
and s.CREATED_BY like'%MIG%'
and s.external_key='8313300310376578';

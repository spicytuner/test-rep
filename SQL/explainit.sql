select 
  substr (lpad(' ', level-1) || operation || ' (' || options || ')',1,30 ) "Operation", 
  object_name                                                              "Object"
from 
  plan_table ;


column dictcache format 999.99 heading 'Dictionary Cache | Ratio %'

select sum(getmisses) / (sum(gets)+0.00000000001) * 100 dictcache
from   v$rowcache
/

exit

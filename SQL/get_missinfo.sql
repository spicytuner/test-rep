select 'Ratio of MISSES to GETS: '||
        round((sum(misses)/(sum(gets)+0.00000000001) * 100),2)||'%'
from    v$latch
where   name in ('redo allocation',  'redo copy')
/

select 'Ratio of IMMEDIATE_MISSES to IMMEDIATE_GETS: '||
        round((sum(immediate_misses)/
       (sum(immediate_misses+immediate_gets)+0.00000000001) * 100),2)||'%'
from    v$latch
where   name in ('redo allocation',  'redo copy')
/
exit

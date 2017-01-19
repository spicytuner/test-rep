SELECT entry_time, queue_size, processed_today, errors_total  
FROM `nms`.`csg_queues`
where entry_time between "2011-06-07" and "2011-06-08"
and hour(entry_time) not in (3,4,5,6)
and queue_size > 0
group by entry_time
order by queue_size desc;


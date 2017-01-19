alter system set pga_aggregate_target=500M;

create index ip_allocation_events_cmmac on metaserv31.ip_allocation_events
(macaddressofcm) local
storage (initial 100M next 100M)
tablespace metaserv31_idx nologging;


alter index ip_allocation_events_cmmac logging;

analyze index ip_allocation_events_cmmac validate structure;

exit

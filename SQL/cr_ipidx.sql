set transaction use rollback segment big_rbs;

Create index IP_ALLOCATION_EVENTS_CMMAC on IP_ALLOCATION_EVENTS(MACADDRESSOFCM)
nologging storage(initial 5M next 5M) local;

analyze index IP_ALLOCATION_EVENTS_CMMAC validate structure;

analyze table IP_ALLOCATION_EVENTS estimate statistics;

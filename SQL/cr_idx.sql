Create Index METASERV31.SUBS_SERVICE_TO_DEVICE_FKM on METASERV31.SUBS_SERVICE_TO_DEVICE(SUBSTOPACKAGE_REF )
NOLOGGING STORAGE(INITIAL 5M NEXT 5M) online tablespace metaserv31_idx;

analyze index metaserv31.subs_service_to_device_fkm validate structre;

analyze table metaserv31.subs_service_to_device estimate statistics;

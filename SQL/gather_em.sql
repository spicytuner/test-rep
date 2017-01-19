exec dbms_stats.gather_index_stats('SMP42CM','REFSTATUS_IDX');
exec dbms_stats.gather_table_stats('SMP42CM','REF_STATUS');

exec dbms_stats.gather_index_stats('SMP42CM','SOI_IDX');
exec dbms_stats.gather_table_stats('SMP42CM','SUB_ORDR_ITEM');

exec dbms_stats.gather_index_stats('SMP42CM','ROT_IDX');
exec dbms_stats.gather_table_stats('SMP42CM','REF_OBJECT_TYP');

exec dbms_stats.gather_index_stats('SMP42CM','OIEC_IDX');
exec dbms_stats.gather_table_stats('SMP42CM','ORDR_ITEM_ENTITY_CHG');

exec dbms_stats.gather_index_stats('SMP42CM','SP_IDX');
exec dbms_stats.gather_table_stats('SMP42CM','SUB_PARM');


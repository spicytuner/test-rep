create index refstatus_idx
on ref_status(status) ;

create index soi_idx
on sub_ordr_item(modified_dtm);

create index rot_idx
on ref_object_typ(object_nm);

create index oiec_idx
on ordr_item_entity_chg(sub_ordr_item_id);

create index sp_idx
on sub_parm(sub_id);


create or replace view yesterdays_boost as
SELECT sp.val         AS acct_number,
    srs.status          AS acct_status,
    oi.display_info     AS tn_number,
    o.sub_ordr_id       AS order_id,
    oi.sub_ordr_item_id AS order_item_id,
    rot.object_nm       AS order_item_name,
    oiecp.parm_nm       AS param,
    oiec.old_val        AS old_value,
    oiec.val            AS new_value,
    ois.status          AS state,
    roa.ordr_action_nm  AS action,
    oi.modified_dtm     AS modified_date
  FROM SMP42CM.sub_ordr o,
    SMP42CM.sub_ordr_item oi,
    SMP42CM.ordr_item_entity_chg oiec,
    SMP42CM.parm oiecp,
    SMP42CM.ref_object_typ rot,
    SMP42CM.ref_ordr_action roa,
    SMP42CM.ref_status ois,
    SMP42CM.sub_parm sp,
    SMP42cm.sub s,
    SMP42cm.ref_status srs
  WHERE oi.modified_dtm >= trunc(sysdate-1)
  and oi.modified_dtm < trunc(sysdate)
  AND o.sub_ordr_id          = oi.sub_ordr_id
  AND rot.object_typ_id        = oi.object_typ_id
  AND oiec.sub_ordr_item_id(+) = oi.sub_ordr_item_id
  AND oiecp.parm_id            = oiec.parm_id
  AND sp.sub_id                = o.sub_id
  AND sp.parm_id              IN
    (SELECT parm_id FROM SMP42CM.parm WHERE parm_nm = 'acct'
    )
  AND oi.ordr_action_id = roa.ordr_action_id
  AND ois.status_id     = oi.ordr_item_status_id
  AND rot.object_nm    IN ('emta_device_control', 'cm_device_control')
  AND ois.status        = 'closed.completed.enforced'
  AND s.sub_id          = sp.sub_id
  AND srs.status_id     = s.sub_status_id 

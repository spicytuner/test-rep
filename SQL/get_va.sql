SELECT DECODE(ssp2.val, 'TM402P', 2, 'TM402G', 2, 'TM502P', 2, 'TM502G', 2, 'TM504G', 4, 'TM508', 8, 'TM602G', 2, 'TM604G', 4, 'TM608G', 8, 'SBV5220', 2,'SBV5222',2, 'TM512', 12, 'TMP612', 12, 'TM802G',2, 'DPQ3925', 2, 'TM822G', 2, 0) AS max_voice_port_num 
FROM smp42cm.sub_svc_parm ssp, smp42cm.sub_svc ss, smp42cm.parm p1, smp42cm.ref_status sref, 
smp42cm.sub_svc_parm ssp2, smp42cm.parm p2 
WHERE ss.svc_id = 177 
AND ss.sub_svc_id = ssp.sub_svc_id 
AND ssp.parm_id = p1.parm_id 
AND p1.parm_nm = 'device_id' 
AND UPPER(ssp.val) = UPPER(?) 
AND sref.status_id = ss.sub_svc_status_id 
AND sref.status <> 'deleted' 
AND ssp2.sub_svc_id = ss.sub_svc_id 
AND ssp2.parm_id = p2.parm_id 
AND p2.parm_nm = 'model';

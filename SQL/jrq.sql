set pagesize 0
set linesize 2500
set colsep ,
set feedback off
set termout off
set echo off
set trimspool off
col acct.val format 9999999999999999

spool jrq.lst

SELECT --ss.sub_svc_id, svc.svc_nm,
  act.val AS CSG_ACCOUNT,
  substr(mac.val, 1,2)||':'||substr(mac.val,3,2)||':'||
        substr(mac.val,5,2)||':'||substr(mac.val, 7,2)||':'||
        substr(mac.val,9,2)||':'||substr(mac.val,11,2) as DEVICE_MAC, 
--  sc.val as SERVICE_CODES, 
    DECODE(sc.service_string,
      '00000','Transponder',
      '00001','ResVoice','00010','ResData','00011','ResDataVoice',
      '00100','ComHIP','00101','ComHIP','00110','ComHIP','00111','ComHIP',
      '01000','ComVoice','01001','ComVoice',
      '01010','ComDataVoice','01011','ComDataVoice',
      '01100','ComVoiceHIP','01101','ComVoiceHIP',
      '01110','ComDataVoiceHIP','01111','ComDataVoiceHIP',
      '10000','ComData','10010','ComData',
      '10001','ComDataVoice','10011','ComDataVoice',
      '10100','ComDataHIP','10110','ComDataHIP',
      '10101','ComDataVoiceHIP','10111','ComDataVoiceHIP',
      '11000','ComDataVoice','11001','ComDataVoice','11010','ComDataVoice','11011','ComDataVoice',
      '11100','ComDataVoiceHIP','11101','ComDataVoiceHIP','11110','ComDataVoiceHIP','11111','ComDataVoiceHIP'
    ) as CLASS_OF_SERVICE,
--  sc.comm_data,sc.comm_voice,sc.comm_hip,sc.res_data,sc.res_voice,
  'provisionedCM' as DHCP_CRITERIA, 
  'c' as HOST_NAME_PREPEND,
  ds.val as DS,
  us.val as US,
  to_char(GREATEST(sc.res_data, sc.com_data) * 10 + sc.com_hip + GREATEST(sc.res_voice, sc.com_voice)) as MAX_CPE,
  CASE 
    WHEN (sc.res_data + sc.res_voice > 0) AND (sc.com_data + sc.com_voice + sc.com_hip = 0) THEN 'res'
    ELSE '~~skip~~' 
  END as ACL,
  sspnd.val as SUSPEND,
  lower(make.val) as MAKE,
  lower(model.val) as MODEL,
  CASE WHEN us.val > 1101005 THEN '3075' ELSE '1600' END as MAX_BURST,
  '~~skip~~' as ENDPTS,
  '~~skip~~' as CALLMGR
FROM svc, sub_svc ss, sub,
  (SELECT sub1_ss.sub_svc_id as id, sub1_ssp.val as val 
   FROM parm sub1_p, sub_svc_parm sub1_ssp, sub_svc sub1_ss
   WHERE sub1_ssp.parm_id = sub1_p.parm_id 
   AND sub1_p.parm_id = 84679 -- serial
   AND sub1_ssp.sub_svc_id = sub1_ss.sub_svc_id
  ) mac, 
  (SELECT sub2_ss.sub_svc_id as id, sub2_ssp.val as val, 
    sign(regexp_instr(sub2_ssp.val,'ASL.{3,4}C')) as com_data,
    sign(regexp_instr(sub2_ssp.val,'BBSPHN[1-2]')) as com_voice, 
    sign(regexp_instr(sub2_ssp.val,'HIP')) as com_hip,
    sign(regexp_instr(sub2_ssp.val,'A(SL|MW)\d{2}[MX]\d')) as res_data, 
    sign(regexp_instr(sub2_ssp.val,'VOIPFP1')) as res_voice,
    sign(regexp_instr(sub2_ssp.val,'ASL.{3,4}C')) ||
    sign(regexp_instr(sub2_ssp.val,'BBSPHN[1-2]')) || 
    sign(regexp_instr(sub2_ssp.val,'HIP')) ||
    sign(regexp_instr(sub2_ssp.val,'A(SL|MW)\d{2}[MX]\d')) ||
    sign(regexp_instr(sub2_ssp.val,'VOIPFP1')) service_string
   FROM parm sub2_p, sub_svc_parm sub2_ssp, sub_svc sub2_ss
   WHERE sub2_ssp.parm_id = sub2_p.parm_id 
   AND sub2_p.parm_id = 84694 -- service_codes
   AND sub2_ssp.sub_svc_id = sub2_ss.sub_svc_id
  ) sc,
  (SELECT sub3_ss.sub_svc_id as id, sub3_ssp.val as val
   FROM parm sub3_p, sub_svc_parm sub3_ssp, sub_svc sub3_ss
   WHERE sub3_ssp.parm_id = sub3_p.parm_id 
   AND sub3_p.parm_id = 84680 -- manufacturer
   AND sub3_ssp.sub_svc_id = sub3_ss.sub_svc_id
  ) make, 
  (SELECT sub4_ss.sub_svc_id as id, sub4_ssp.val as val
   FROM parm sub4_p, sub_svc_parm sub4_ssp, sub_svc sub4_ss
   WHERE sub4_ssp.parm_id = sub4_p.parm_id 
   AND sub4_p.parm_id = 84681 -- model
   AND sub4_ssp.sub_svc_id = sub4_ss.sub_svc_id
  ) model,
  (SELECT sub5_pass.sub_svc_id as id, sub5_ss.sub_svc_id as inet_id, sub5_ssp.val as val
   FROM parm sub5_p, sub_svc_parm sub5_ssp, sub_svc sub5_ss, sub_svc_assoc sub5_ssa, sub_svc sub5_ass, sub_svc sub5_pass
   WHERE sub5_ss.svc_id = 102
   AND sub5_p.parm_id = 81216 -- upstream_speed
   AND sub5_ssp.parm_id = sub5_p.parm_id 
   AND sub5_ssp.sub_svc_id = sub5_ss.sub_svc_id
   AND sub5_ss.sub_svc_id = sub5_ssa.sub_svc_id
   AND sub5_ssa.assoc_sub_svc_id = sub5_ass.sub_svc_id
   AND sub5_ass.parent_sub_svc_id = sub5_pass.sub_svc_id
  ) us,
  (SELECT sub6_pass.sub_svc_id as id, sub6_ssp.val as val
   FROM parm sub6_p, sub_svc_parm sub6_ssp, sub_svc sub6_ss, sub_svc_assoc sub6_ssa, sub_svc sub6_ass, sub_svc sub6_pass
   WHERE sub6_ss.svc_id = 102
   AND sub6_p.parm_id = 81215 -- downstream_speed
   AND sub6_ssp.parm_id = sub6_p.parm_id 
   AND sub6_ssp.sub_svc_id = sub6_ss.sub_svc_id
   AND sub6_ss.sub_svc_id = sub6_ssa.sub_svc_id
   AND sub6_ssa.assoc_sub_svc_id = sub6_ass.sub_svc_id
   AND sub6_ass.parent_sub_svc_id = sub6_pass.sub_svc_id
  ) ds,
  (SELECT sub7_sub.sub_id as id, sub7_sp.val as val
   FROM sub sub7_sub, sub_parm sub7_sp, parm sub7_p
   WHERE sub7_p.parm_id = 86423 --acct
   AND sub7_p.parm_id = sub7_sp.parm_id
   AND sub7_sub.sub_id = sub7_sp.sub_id
  ) act,
  (SELECT sub8_ss.sub_svc_id as id,
   CASE WHEN (sub8_sub.sub_status_id IN (24, 25, 26, 27) OR sub8_ss.sub_svc_status_id IN (24, 25, 26, 27)) THEN 'suspend'
   ELSE '~~skip~~' END as val
   FROM sub sub8_sub, sub_svc sub8_ss
   WHERE sub8_ss.svc_id = 102
   AND sub8_ss.sub_id = sub8_sub.sub_id
  ) sspnd
WHERE svc.svc_id = ss.svc_id
AND sub.sub_id = ss.sub_id
AND svc.svc_id IN (177,196)
AND mac.id = ss.sub_svc_id
AND sc.id = ss.sub_svc_id
AND make.id = ss.sub_svc_id
AND model.id = ss.sub_svc_id
AND us.id = ss.parent_sub_svc_id
AND ds.id = ss.parent_sub_svc_id
AND act.id = sub.sub_id
AND sspnd.id = us.inet_id

UNION

SELECT --ss.sub_svc_id, svc.svc_nm,
  act.val AS CSG_ACCOUNT,
  substr(mac.val, 1,2)||':'||substr(mac.val,3,2)||':'||
        substr(mac.val,5,2)||':'||substr(mac.val, 7,2)||':'||
        substr(mac.val,9,2)||':'||substr(mac.val,11,2) as DEVICE_MAC,
  CASE WHEN sc.com_voice = 1 OR (sc.res_voice = 1 AND (sc.com_hip = 1 OR sc.com_data = 1)) THEN 'ComMTA' 
    ELSE 'ResMTA' END as CLASS_OF_SERVICE,
  'provisionedMTA' as DHCP_CRITERIA, 
  'a' as HOST_NAME_PREPEND,
  '~~skip~~' as DS,
  '~~skip~~' as US,
  '~~skip~~' as MAX_CPE,
  '~~skip~~' as ACL,
  '~~skip~~' as SUSPEND,
  lower(make.val) as MAKE,
  lower(model.val) as MODEL,
  '~~skip~~' as MAX_BURST,
  CASE WHEN (to_number(regexp_instr(model.val, 'TM\d{3}.*')) > 0) THEN to_char(to_number(SUBSTR(model.val, 4, 2)))
    ELSE '0' END as ENDPTS,
  cms.val as CALLMGR
FROM svc, sub_svc ss, sub,
  (SELECT sub1_ss.sub_svc_id as id, sub1_ssp.val as val 
   FROM parm sub1_p, sub_svc_parm sub1_ssp, sub_svc sub1_ss
   WHERE sub1_ssp.parm_id = sub1_p.parm_id 
   AND sub1_p.parm_id = 84669 -- serial
   AND sub1_ssp.sub_svc_id = sub1_ss.sub_svc_id
  ) mac, 
  (SELECT sub2_ss.sub_svc_id as id, sub2_ssp.val as val, 
    sign(regexp_instr(sub2_ssp.val,'ASL.{3,4}C')) as com_data,
    sign(regexp_instr(sub2_ssp.val,'BBSPHN[1-2]')) as com_voice, 
    sign(regexp_instr(sub2_ssp.val,'HIP')) as com_hip,
    sign(regexp_instr(sub2_ssp.val,'A(SL|MW)\d{2}[MX]\d')) as res_data, 
    sign(regexp_instr(sub2_ssp.val,'VOIPFP1')) as res_voice,
    sign(regexp_instr(sub2_ssp.val,'ASL.{3,4}C')) ||
    sign(regexp_instr(sub2_ssp.val,'BBSPHN[1-2]')) || 
    sign(regexp_instr(sub2_ssp.val,'HIP')) ||
    sign(regexp_instr(sub2_ssp.val,'A(SL|MW)\d{2}[MX]\d')) ||
    sign(regexp_instr(sub2_ssp.val,'VOIPFP1')) service_string
   FROM parm sub2_p, sub_svc_parm sub2_ssp, sub_svc sub2_ss
   WHERE sub2_ssp.parm_id = sub2_p.parm_id 
   AND sub2_p.parm_id = 84694 -- service_codes
   AND sub2_ssp.sub_svc_id = sub2_ss.sub_svc_id
  ) sc,
  (SELECT sub3_ss.sub_svc_id as id, sub3_ssp.val as val
   FROM parm sub3_p, sub_svc_parm sub3_ssp, sub_svc sub3_ss
   WHERE sub3_ssp.parm_id = sub3_p.parm_id 
   AND sub3_p.parm_id = 84680 -- manufacturer
   AND sub3_ssp.sub_svc_id = sub3_ss.sub_svc_id
  ) make, 
  (SELECT sub4_ss.sub_svc_id as id, sub4_ssp.val as val
   FROM parm sub4_p, sub_svc_parm sub4_ssp, sub_svc sub4_ss
   WHERE sub4_ssp.parm_id = sub4_p.parm_id 
   AND sub4_p.parm_id = 84681 -- model
   AND sub4_ssp.sub_svc_id = sub4_ss.sub_svc_id
  ) model,
  (SELECT sub7_sub.sub_id as id, sub7_sp.val as val
   FROM sub sub7_sub, sub_parm sub7_sp, parm sub7_p
   WHERE sub7_p.parm_id = 86423 --acct
   AND sub7_p.parm_id = sub7_sp.parm_id
   AND sub7_sub.sub_id = sub7_sp.sub_id
  ) act,
  (SELECT sub8_ss.sub_svc_id as id, sub8_sn.subntwk_nm || '.int.bresnan.net' as val
   FROM sub_svc sub8_ss, sub_svc_ntwk sub8_ssn, subntwk sub8_sn
   WHERE sub8_ss.sub_svc_id = sub8_ssn.sub_svc_id
   AND sub8_ssn.subntwk_id = sub8_sn.subntwk_id
   AND sub8_sn.subntwk_typ_id = 6 --subnetwork cms instance by current def
  ) cms
WHERE svc.svc_id = ss.svc_id
AND sub.sub_id = ss.sub_id
AND svc.svc_id IN (177)
AND mac.id = ss.sub_svc_id
AND sc.id = ss.sub_svc_id
AND make.id = ss.sub_svc_id
AND model.id = ss.sub_svc_id
AND act.id = sub.sub_id
AND cms.id = ss.sub_svc_id;

exit;

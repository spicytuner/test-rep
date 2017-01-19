Create or replace PROCEDURE delete_hsd_by_mac(CM_MAC IN VARCHAR2)
IS
BEGIN
        for h in (select parentref subs_rec, RECORDNUMBER h_rec from HSD where MACADDRESSOFCM = CM_MAC and deletestatus=0)
        LOOP
                delete from CPEDETAILS where PARENTREF = h.h_rec;
                delete from HSD where RECORDNUMBER = h.h_rec;
 
                DELETE FROM CMINVENTORY WHERE macaddress = CM_MAC;
                DELETE FROM CMMONITORTABLE WHERE cmmac = CM_MAC;
 
                delete from  SUBS_SERVICE_TO_DEVICE
                        where  SERVICE_RECORD_NUMBER=h.h_rec
                        and  SUBSCRIBER_REF = h.subs_rec
                        and  SERVICE_NAME='HSD';
 
        END LOOP;
 
        for v in (select parentref subs_rec, RECORDNUMBER v_rec, MACADDRESSOFMTA mtamac from VOICE where MACADDRESSOFCM = CM_MAC and deletestatus=0)
        LOOP
                for e in (select recordnumber e_rec from ENDPOINT where MACADDRESSOFMTA = v.mtamac and deletestatus=0)
                loop
                       delete from   SUBS_SERVICE_TO_DEVICE
                                  where  SERVICE_RECORD_NUMBER=e.e_rec
                                  and  SUBSCRIBER_REF = v.subs_rec
                                  and  SERVICE_NAME='EndPoint';
                end loop;
 
                delete from ENDPOINT where MACADDRESSOFMTA = v.mtamac;
                delete from VOICE where RECORDNUMBER = v.v_rec;
 
                delete from SUBS_SERVICE_TO_DEVICE
                        where SERVICE_RECORD_NUMBER=v.v_rec
                        and SUBSCRIBER_REF = v.subs_rec
                        and SERVICE_NAME='Voice';
        END LOOP;
 
END;
/
 


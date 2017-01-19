
grant all on QC_PROJECTUPDATES.CHANGE_LOG to public;                            
grant all on QC_PROJECTUPDATES.INCIDENT_TRACKING_ID to public;                  
grant all on QC_PROJECTUPDATES.PROJECT_NO to public;                            
grant all on QC_PROJECTUPDATES.PROJECT_TIME to public;                          
grant all on QC_PROJECTUPDATES.PROJECT_UPDATES to public;                       
grant all on QC_PROJECTUPDATES.RELEASES to public;                              


create public synonym CHANGE_LOG for QC_PROJECTUPDATES.CHANGE_LOG               
create public synonym INCIDENT_TRACKING_ID for QC_PROJECTUPDATES.INCIDENT_TRACKIng_id
                                                                                
create public synonym PROJECT_NO for QC_PROJECTUPDATES.PROJECT_NO               
create public synonym PROJECT_TIME for QC_PROJECTUPDATES.PROJECT_TIME           
create public synonym PROJECT_UPDATES for QC_PROJECTUPDATES.PROJECT_UPDATES     
create public synonym RELEASES for QC_PROJECTUPDATES.RELEASES                   



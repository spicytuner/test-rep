spool alterobjects.log
set echo on

alter VIEW     AUSPICE_SVP             recompile;
alter VIEW     DATA_TICKETS            recompile;
alter VIEW     HEADEND_DATA_TICKETS          recompile;
alter VIEW     HEADEND_RES_VOICE_TICKETS         recompile;
alter VIEW     HEADEND_VIDEO_TICKETS          recompile;
alter VIEW     NODE_DATA_TICKETS           recompile;
alter VIEW     NODE_DATA_TICKETSA           recompile;
alter VIEW     NODE_DATA_TICKETSB           recompile;
alter PROCEDURE   PROCDAT              recompile;
alter VIEW     RES_VOICE_TICKETS           recompile;
alter PROCEDURE   UPDATE_BZINCDAT_PROC          recompile;
alter PACKAGE BODY   UTL_RECOMP             recompile;
alter VIEW     VIDEO_TICKETS            recompile;

spool off
exit

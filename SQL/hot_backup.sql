/* Directory to hold the backups */
define HOT_BACK_DIR = &enterbackupdir

/* Create Temporary Table with Tablespace Data */

drop table dsc_hot_stage;

create table dsc_hot_stage
(
tablespace_name varchar2(30),
file_name varchar2(200)
);

insert into dsc_hot_stage
select rtrim(tablespace_name),rtrim(file_name) from sys.dba_data_files;

/**** Set up the parameters for the spool file */
set feedback off
set heading off
set pagesize 0
set linesize 128
set verify off
set termout oN
set echo off

spool /export/home/jsoria/SCRIPTS/SQL/hb.sql


/*
**** This is a generate script and has been generated,
**** by gen_hot_unix.sql.
**** You are Allowed to Use this script freely as long 
**** as this title is not deleted
**** For more Scripts and copyright info Visit DBASUPPORT.COM 
*/

select 'connect internal' from dual;

-- Create Script to backup Control File to Trace
select 'alter database backup controlfile to trace; '
from dual;

-- Create Script to backup actual files to a directory
select 'alter tablespace '|| tablespace_name||' begin backup;' c1,
'host cp '||file_name||' &HOT_BACK_DIR' || '/' ||
substr(file_name,instr(rtrim(file_name),'/',-1,1)+1,length(rtrim(file_name)))||
'.bak' c2,
'host compress -f '|| ' &HOT_BACK_DIR' || '/' ||
substr(file_name,instr(rtrim(file_name),'/',-1,1)+1,length(rtrim(file_name)))||
'.bak' c3
from dsc_hot_stage
union
select 'alter tablespace '|| tablespace_name||' end backup;' c1,
null, null
from dsc_hot_stage
group by tablespace_name,file_name order by 1;
select 'exit' from dual;
spool off

connect SYS/password as SYSDBA
set echo on
col comp_name for a30
spool textinstall.log
Rem =======================================================================
Rem Start of Text loading
Rem =======================================================================
EXECUTE dbms_registry.loading('CONTEXT', 'Oracle Text');

Rem dr0csys.sql <CTXSYS_password> <CTXSYS_TS_NAME> <TEMP_TS_NAME>
start ?/ctx/admin/dr0csys ctxsys DRSYS TEMP

*** NOTE: We assume that DRSYS tablespace already exists, if not create a 
***       tablespace for Oracle Text data dictionary tables, for example:
***       SQL> CREATE TABLESPACE tablespace_name 
***            DATAFILE 'ORACLE_BASE\oradata\db_name\drsys01.dbf' SIZE 40m;

REM ========================================================================
REM Install CTXSYS objects
REM ========================================================================
connect CTXSYS/ctxsys
start ?/ctx/admin/dr0inst <replace with $ORACLE_HOME>/ctx/lib/libctxx9.so
start ?/ctx/admin/defaults/drdefus.sql

REM =========================================================================
REM Upgrade CTXSYS to the latest patchset version, only required for >9.2.0.1
REM =========================================================================
connect SYS/password as SYSDBA

start ?/ctx/admin/ctxpatch.sql
select comp_name, version, status from dba_registry;
spool off
exit;
------------------- cut here ------------------------------

Review the output file textinstall.log for errors.
Installation of Oracle Text 9.2.0.x is complete.

Explanation of installation script
==================================

You need to be connected as SYS to create CTXSYS user
connect SYS/password as SYSDBA

EXECUTE dbms_registry.loading('CONTEXT', 'Oracle Text');

This will update the DBA_REGISTRY for Oracle Text loading.

start ?/ctx/admin/dr0csys ctxsys DRSYS TEMP

  ctxsys             - is the ctxsys user password
  DRSYS              - is the default tablespace for ctxsys 
  TEMP               - is the temporary tablespace for ctxsys 

This script sets up the ctxsys user, which owns the text 
supporting tables.  At this point it will have no objects.

Than we connect as CTXSYS user to create necessary objects.
connect CTXSYS/ctxsys
start ?/ctx/admin/dr0inst <replace with $ORACLE_HOME>/ctx/lib/libctxx9.so

On Solaris, Aix platform with $ORACLE_HOME of /u1/app/oracle/product/9.2.0
this part should look like: 
start ?/ctx/admin/dr0inst /u1/app/oracle/product/9.2.0/ctx/lib/libctxx9.so

On HP-UX you would run:
start ?/ctx/admin/dr0inst /u1/app/oracle/product/9.2.0/ctx/lib/libctxx9.sl
 
With NT you would run with %ORACLE_HOME% of C:\oracle\9.2.0
start ?\ctx\admin\dr0inst C:\oracle\9.2.0\bin\oractxx9.dll

*** Note: The error ORA-01031: insufficient privileges while CTXSYS 
***       calls the dbms_registry package can be ignored, see Bug 2977268

*** NOTE: If you install Text 9.2.0.1 manually the error 
***       ORA-01031, ORA-01403, ORA-06512 in "SYS.DBMS_REGISTRY" is thrown
***       and can be solved while running following PL/SQL code as SYSDBA

connect SYS/password as SYSDBA
declare
  ver varchar2(80);
begin
  select ver_dict into ver from ctxsys.ctx_version;
  dbms_registry.loaded('CONTEXT', ver,
                       'Oracle Text Release '||ver||' - Production');
  
  -- to do: a validation procedure
  dbms_registry.valid('CONTEXT');
end;
/

Last script that is called installs defaults preferences: default lexer, 
wordlist and stoplist.

This scripts are located in $ORACLE_HOME/ctx/admin/defaults and name of
scripts is drdef<country code>.sql 
In above example we run US specific script
start ?/ctx/admin/defaults/drdefus.sql

Then we connect as SYS user to upgrade Text to the latest Patchset version.
DBA_REGISTRY is also updated to the correct Oracle Text version, status.

connect SYS/password as SYSDBA
start ?/ctx/admin/ctxpatch.sql

*** Note: ERROR ORA-00001: unique constraint (CTXSYS.DRC$OAT_KEY) violated
***       Above error shows that the insert fails as the record with unique 
***       value in that table exist.
***       That means the record that needs to be inserted is already existing
***       and hence can be ignored.

Text Installation verification
-------------------------------
1. Check to make sure that all Text objects were created in CTXSYS schema
   and correct version is installed
2. Check to make sure that there are not invalid objects for CTXSYS. 
   You should get: "no rows selected"
   If there are then you can compile each invalid object manually.
3. Check to ensure that the library is correctly installed

------------------- cut here ------------------------------
connect SYS/password as SYSDBA
set pages 1000
col object_name format a40
col object_type format a20
col comp_name format   a30
column library_name format a8 
column file_spec format a60 wrap
spool text_install_verification.log

-- check on setup
select comp_name, status, substr(version,1,10) as version 
  from dba_registry 
    where comp_id = 'CONTEXT';
select * from ctxsys.ctx_version;
select substr(ctxsys.dri_version,1,10) VER_CODE from dual;

select count(*)
  from dba_objects where owner='CTXSYS';

-- Get a summary count
select object_type, count(*)
  from dba_objects where owner='CTXSYS' 
group by object_type;

-- Any invalid objects
select object_name, object_type, status
  from dba_objects 
    where owner='CTXSYS' 
    and status != 'VALID'
order by object_name;

select library_name,file_spec,dynamic,status 
from all_libraries
  where owner = 'CTXSYS';

spool off
------------------- cut here ------------------------------

Example output of text_install_verification.log after valid installtion of 
9.2.0.6.0 on Solaris. The number of ctxsys objects might differentiate after
applying a patchset.

-------------------------------------------------------------------------------
SQL>  select comp_name, status, substr(version,1,10) as version 
        from dba_registry
          where comp_id = 'CONTEXT'; 
 
COMP_NAME                      STATUS      VERSION
------------------------------ ----------- ------------------------------
Oracle Text                    VALID       9.2.0.6.0
 
SQL> select * from ctxsys.ctx_version;
 
VER_DICT  VER_CODE
--------- ---------------------------
9.2.0.6.0 9.2.0.6.0

SQL> select substr(ctxsys.dri_version,1,10) VER_CODE from dual;

VER_CODE                                                                        
------------------------------                                                  
9.2.0.6.0                                                                       

SQL> select count(*)
      from dba_objects where owner='CTXSYS';

  COUNT(*)                                                                      
----------                                                                      
       263                                                                      

SQL> select object_type, count(*)
       from dba_objects where owner='CTXSYS'
     group by object_type;

OBJECT_TYPE            COUNT(*)                                                 
-------------------- ----------                                                 
FUNCTION                      3                                                 
INDEX                        46                                                 
INDEXTYPE                     4                                                 
LIBRARY                       2                                                 
LOB                           2                                                 
OPERATOR                      5                                                 
PACKAGE                      53                                                 
PACKAGE BODY                 44                                                 
PROCEDURE                     1                                                 
SEQUENCE                      3                                                 
TABLE                        36                                                 
TYPE                         10                                                 
TYPE BODY                     7                                                 
VIEW                         47                                                 

14 rows selected.

SQL> select object_name, object_type, status
       from dba_objects
        where owner='CTXSYS'
        and status != 'VALID'
     order by object_name;

no rows selected

SQL> select library_name,file_spec,dynamic,status
     from all_libraries
       where owner = 'CTXSYS';

LIBRARY_ FILE_SPEC                                                    D STATUS  
-------- ------------------------------------------------------------ - ------- 
DR$LIB                                                                N VALID   
DR$LIBX  /emea/rdbms/32bit/app/oracle/product/9.2.0/lib/libctxx9.so   Y VALID   
-------------------------------------------------------------------------------

Additional configuration
------------------------
Oracle Text do NOT need configuration of external procedures (extproc), except
for one new document service function -- ctx_doc.ifilter, the on-demand 
INSO filtering call. If you don't use this function, you DON'T need to set up
the listener and extproc. This configuration is not covered by this document.
For more information check
Note 73605.1  Installation of InterMedia Text version 8.1.x




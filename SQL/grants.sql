GRANT CONNECT TO SMP42CM;	 
GRANT DEV_USER TO SMP42CM;	 
GRANT EXECUTE_CATALOG_ROLE TO SMP42CM;       
ALTER USER SMP42CM DEFAULT ROLE ALL;	 
GRANT SELECT ANY TABLE TO SMP42CM;	 
GRANT CREATE ANY DIRECTORY TO SMP42CM;	 
GRANT SELECT ANY DICTIONARY TO SMP42CM;	 
GRANT CREATE PROCEDURE TO SMP42CM; 	 
GRANT UNLIMITED TABLESPACE TO SMP42CM;  	 
GRANT CREATE SEQUENCE TO SMP42CM;	 
GRANT CREATE ANY TABLE TO SMP42CM;	 
GRANT CREATE TRIGER TO SMP42CM;
GRANT CREATE SYNONYM TO SMP42CM;	
GRANT EXECUTE ANY PROCEDURE TO SMP42CM;	
GRANT CREATE PROCEDURE TO SMP42CM;	
GRANT CREATE TYPE TO SMP42CM;	
GRANT CREATE VIEW TO SMP42CM;	
GRANT CONNECT TO SMP42CM;	
GRANT RESOURCE TO SMP42CM;	
GRANT CREATE DATABASE LINK TO SMP42CM;	
GRANT "SELECT_CATALOG_ROLE" TO SMP42CM;
GRANT SELECT ON V$SESSION TO SMP42CM;	
GRANT SELECT ON V$PARAMETER TO SMP42CM;
exit;

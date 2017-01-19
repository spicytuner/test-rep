#!/bin/bash

echo "Setting environment variables"
ORACLE_HOME=/home/oracle/OraHome1
ORACLE_BASE=/home/oracle
ORACLE_SID=remprd
export ORACLE_HOME ORACLE_BASE ORACLE_SID


echo "Running sqlldr"
/home/oracle/OraHome1/bin/sqlldr masterm/mMmMbeeR@remprd control=/home/jsoria/SCRIPTS/PERL/cust_import.ctl errors=50000 log=error.log skip=1
echo "finished"
~

#!/bin/bash

ORACLE_HOME=/u1/app/oracle/product/9.2.0.6/OraHome1
ORACLE_BASE=/u1/app/oracle/product/9.2.0.6/
ORACLE_SID=samprd
export ORACLE_HOME ORACLE_BASE ORACLE_SID

/home/jsoria/SCRIPTS/PERL/prim.pl

/bin/mail -s "Primary Residential Email Count" jsoria@bresnan.com bwilliams@bresnan.com < /home/jsoria/SCRIPTS/PERL/prim.log



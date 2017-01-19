#!/usr/bin/perl
#
# This script is used to populate the appropriate cust table with csg
# data.
##First you need to take the contents of the file from the csgdump directory
use strict;
use DBI;

$ENV{'ORACLE_SID'}="remprd";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";


system("rm -f /home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
system("pushd /home/jsoria/SCRIPTS/PERL/; unzip /home/csgdump/Cust_Import2*.zip");
system("touch /home/jsoria/SCRIPTS/PERL/insertion.log");
open(FILE,"/home/jsoria/SCRIPTS/PERL/Cust_Import.csv");
open(LOG,">>/home/jsoria/SCRIPTS/PERL/insertion.log");

system("mv /home/csgdump/Cust_Import2*.zip /home/csgdump/LOADED/.");

close(FILE);
close(LOG);


#!/usr/bin/perl

# Author: Joe Soria
# Date: July 23, 2007
#
# This script will alert when the freespace threashold is met.

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;
use Spreadsheet::WriteExcel;

$ENV{'ORACLE_SID'}="remrep";
$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$database,$admin,$test,$usr,$passwd,$log,$dbh,$sth,$sid,$tbsname,$total,$free,$pctfree,$frags,$bfrag);

#@database=qw(samprd,remprd,remrep);
@database=qw();
$admin='jsoria@bresnan.com';
$test='2';
$usr="";
$passwd="";

open(LOG,">/home/jsoria/SCRIPTS/PERL/dbspacereport.log");

($usr,$passwd,$sid)=&serv_info($test);

$dbh = DBI->connect('dbi:Oracle:samprd',$usr,$passwd) || die "Cannot establish connection to the database";

$dbh->{RaiseError}=1;
#Define your queries

foreach ($database) 
{
$sth=$dbh->prepare(q{SELECT TABLESPACE_NAME NAME, TOTAL, FREE,
       	ROUND((FREE/TOTAL)*100,1) PCT_FREE,
       	FRAGMENTS, BIGGEST_FRAGMENT
	FROM(SELECT TABLESPACE_NAME, SUM(BYTES) TOTAL
       	FROM SYS.DBA_DATA_FILES
     	GROUP BY TABLESPACE_NAME),
    	(SELECT TABLESPACE_NAME TS_NAME,
     	SUM(BYTES) FREE, MAX(BYTES) BIGGEST_FRAGMENT, 
     	COUNT(TABLESPACE_NAME) FRAGMENTS
       	FROM SYS.DBA_FREE_SPACE
     	GROUP BY TABLESPACE_NAME)
	WHERE TABLESPACE_NAME = TS_NAME});
$sth->execute();
$sth->bind_columns($tbsname,$total,$free,$pctfree,$frags,$bfrag);

while ($sth->fetch)
        {
	if $free < 1000000 
		{
		mailx -s "$database SPACE ALERT" $admin;
	   	}

	}
}


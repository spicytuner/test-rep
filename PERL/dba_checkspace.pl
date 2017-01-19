#!/usr/bin/perl

# Author: Joe Soria
# Date: July 30, 2007
#
# This script will alert when the freespace threashold is met.

push(@INC, "/home/jsoria/SCRIPTS/PERL");
require 'serv_info.pl';

use DBI;
use strict;

$ENV{'ORACLE_HOME'}="/home/oracle/OraHome1";
$ENV{'ORACLE_BASE'}="/home/oracle";

#Define your variables
my(@database,$database,$contact,$domain,$test,$usr,$passwd,$sid,$dbh,$sth,$sth2,
$dbname,$tbspace,$EXIT,$total,$free,$pctfree,$frags,$bfrag);
 # Exit 0 = good 1 = critical
$EXIT = 0;
@database=qw(smpprd remprd remrep);
$contact='jsoria';
$domain='bresnan.com';
$test='2';
$usr="";
$passwd="";

($usr,$passwd,$sid)=&serv_info($test);
print "\n";
foreach $database(@database) 
	{

	$dbh = DBI->connect("dbi:Oracle:$database",$usr,$passwd) || die "Cannot establish connection to the database";
	$dbh->{RaiseError}=1;

	$sth=$dbh->prepare(q{
	select name from v$database});
	$sth->execute();
	$sth->bind_columns({},\($dbname));
	
	$sth2=$dbh->prepare(q{
	SELECT TABLESPACE_NAME NAME, TOTAL, FREE,
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
	WHERE TABLESPACE_NAME = TS_NAME
	AND TABLESPACE_NAME NOT IN ('RBS','SYSTEM','TEMP','TMP','TOOLS','ARCHIVE_DATA')});
	$sth2->execute();
	$sth2->bind_columns({},\($tbspace,$total,$free,$pctfree,$frags,$bfrag));

	while ($sth->fetch)
		{
		if ($sth2->fetch)
			{
			if ($free < 1024000)
				{
				print STDOUT "Database: $dbname needs more space to grow: $tbspace\n";
				$EXIT = 1;	
				}
			}
		}
	}
exit($EXIT)

